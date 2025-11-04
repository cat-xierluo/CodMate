#!/bin/bash
# CodMate 本地化同步脚本
# 用法: ./sync-upstream.sh [选项]
# 选项:
#   --dry-run    试运行，不实际应用补丁
#   --force      强制应用补丁，跳过冲突检查
#   --help       显示帮助信息

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
LOCALIZATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="$LOCALIZATION_DIR/patches"
WORK_DIR="/tmp/codemate-localization-$$"

# 显示帮助信息
show_help() {
    cat << EOF
CodMate 本地化同步脚本

用法: $0 [选项]

选项:
    --dry-run    试运行，显示将要执行的操作但不实际执行
    --force      强制应用补丁，跳过冲突检查
    --check-only 仅检查是否有更新，不同步
    --help       显示此帮助信息

示例:
    $0                    # 标准同步
    $0 --dry-run          # 试运行
    $0 --force            # 强制同步

更多信息请参考: PATCH-MANAGEMENT.md
EOF
}

# 记录日志
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        INFO)
            echo -e "${GREEN}[INFO]${NC} $message" >&2
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} $message" >&2
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        DEBUG)
            echo -e "${BLUE}[DEBUG]${NC} $message" >&2
            ;;
    esac
}

# 检查依赖
check_dependencies() {
    log INFO "检查依赖..."

    # 检查必要的命令
    local missing=()
    for cmd in git; do
        if ! command -v $cmd &> /dev/null; then
            missing+=($cmd)
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log ERROR "缺少必要的命令: ${missing[*]}"
        log INFO "请安装这些命令后重试"
        exit 1
    fi

    log INFO "依赖检查通过"
}

# 解析命令行参数
DRY_RUN=false
FORCE=false
CHECK_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log WARN "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 创建工作目录
setup_workspace() {
    log INFO "设置工作空间..."
    mkdir -p "$WORK_DIR"
    mkdir -p "$PATCH_DIR"

    log DEBUG "工作目录: $WORK_DIR"
    log DEBUG "补丁目录: $PATCH_DIR"
}

# 检查是否有上游更新
check_for_updates() {
    log INFO "检查上游更新..."

    # 检查是否配置了 upstream 远程
    if ! git remote get-url upstream &> /dev/null; then
        log ERROR "未配置 upstream 远程仓库"
        log INFO "请运行: git remote add upstream <上游仓库URL>"
        exit 1
    fi

    # 获取上游最新提交
    git fetch upstream --quiet

    local local_commit=$(git rev-parse HEAD)
    local upstream_commit=$(git rev-parse upstream/main)

    log DEBUG "本地提交: $local_commit"
    log DEBUG "上游提交: $upstream_commit"

    if [ "$local_commit" = "$upstream_commit" ]; then
        log INFO "已是最新版本，无需同步"
        return 1
    fi

    log INFO "检测到上游有更新"
    log INFO "本地: $(git log --oneline -1 $local_commit)"
    log INFO "上游: $(git log --oneline -1 $upstream_commit)"

    return 0
}

# 生成补丁
generate_patch() {
    log INFO "生成本地化补丁..."

    # 获取当前分支名
    local branch=$(git rev-parse --abbrev-ref HEAD)

    # 生成补丁文件名（包含日期时间）
    local timestamp=$(date '+%Y%m%d-%H%M%S')
    local patch_file="$PATCH_DIR/localization-$timestamp-$branch.patch"

    # 生成补丁
    log DEBUG "生成补丁文件: $patch_file"
    git diff HEAD > "$patch_file"

    if [ ! -s "$patch_file" ]; then
        log WARN "没有检测到任何更改"
        rm -f "$patch_file"
        return 1
    fi

    log INFO "补丁已生成: $patch_file"
    log INFO "补丁大小: $(du -h "$patch_file" | cut -f1)"

    # 显示补丁摘要
    echo
    log INFO "补丁摘要:"
    git diff --stat HEAD >> /dev/null

    return 0
}

# 检查补丁冲突
check_patch_conflicts() {
    log INFO "检查补丁冲突..."

    # 模拟应用补丁以检测冲突
    if git apply --check "$1" 2>/dev/null; then
        log INFO "补丁检查通过，无冲突"
        return 0
    else
        log WARN "检测到潜在冲突"
        log INFO "详细信息请运行: $0 --dry-run"

        # 尝试显示冲突信息
        log INFO "尝试应用补丁以获取详细错误..."
        git apply "$1" 2>&1 | head -20

        return 1
    fi
}

# 同步上游代码
sync_upstream() {
    log INFO "同步上游代码..."

    if [ "$DRY_RUN" = true ]; then
        log INFO "[试运行模式] 将执行以下操作:"
        log INFO "1. git fetch upstream"
        log INFO "2. git reset --hard upstream/main"
        log INFO "3. git apply 最新的本地化补丁"
        return 0
    fi

    # 备份当前分支（以防万一）
    local backup_branch="localization-backup-$(date +%Y%m%d-%H%M%S)"
    log INFO "创建备份分支: $backup_branch"
    git checkout -b "$backup_branch" &> /dev/null || true
    git checkout main &> /dev/null

    # 同步上游
    log INFO "拉取上游更新..."
    git fetch upstream --quiet
    git reset --hard upstream/main --quiet

    log INFO "上游同步完成"
    log INFO "当前分支: $(git rev-parse --abbrev-ref HEAD)"
    log INFO "当前提交: $(git log --oneline -1 HEAD)"

    # 应用最新的本地化补丁
    local latest_patch=$(ls -t "$PATCH_DIR"/localization-*.patch 2>/dev/null | head -1)

    if [ -n "$latest_patch" ]; then
        log INFO "应用本地化补丁: $(basename "$latest_patch")"

        if [ "$FORCE" = true ]; then
            # 强制应用
            if git apply "$latest_patch" 2>/dev/null; then
                log INFO "补丁应用成功"
            else
                log WARN "补丁应用失败，将尝试强制应用..."
                git apply --whitespace=warn "$latest_patch" 2>&1 || true
            fi
        else
            # 检查冲突
            if check_patch_conflicts "$latest_patch"; then
                if git apply "$latest_patch"; then
                    log INFO "补丁应用成功"
                else
                    log ERROR "补丁应用失败"
                    log INFO "请手动解决冲突，或使用 --force 选项"
                    exit 1
                fi
            else
                log ERROR "检测到冲突，无法应用补丁"
                log INFO "请先解决冲突，或使用 --force 选项"
                exit 1
            fi
        fi
    else
        log WARN "未找到本地化补丁文件"
    fi
}

# 清理
cleanup() {
    log DEBUG "清理工作空间..."
    rm -rf "$WORK_DIR"
}

# 主函数
main() {
    log INFO "========================================="
    log INFO "CodMate 本地化同步脚本"
    log INFO "========================================="
    log INFO ""

    # 如果只是检查更新
    if [ "$CHECK_ONLY" = true ]; then
        if check_for_updates; then
            log INFO "有可用更新"
            exit 0
        else
            log INFO "已是最新"
            exit 0
        fi
    fi

    # 检查是否有更新
    if ! check_for_updates; then
        log INFO "无需同步，退出"
        cleanup
        exit 0
    fi

    # 设置工作空间
    setup_workspace

    # 生成补丁
    generate_patch

    # 同步上游代码
    sync_upstream

    # 清理
    cleanup

    log INFO ""
    log INFO "========================================="
    log INFO "同步完成！"
    log INFO "========================================="
    log INFO ""
    log INFO "下一步:"
    log INFO "1. 运行应用并检查界面"
    log INFO "2. 如有问题，请检查: PATCH-MANAGEMENT.md"
    log INFO "3. 查看文档: SYNC-WORKFLOW.md"
    log INFO ""
}

# 捕获退出信号
trap cleanup EXIT

# 运行主函数
main "$@"
