#!/bin/bash
# CodMate 本地化冲突检查脚本
# 检查本地化修改与上游更新的冲突

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="$SCRIPT_DIR/patches"
WORK_DIR="/tmp/codemate-conflict-check-$$"

# 日志函数
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
    esac
}

# 显示帮助
show_help() {
    cat << EOF
CodMate 冲突检查脚本

用法: $0 [选项]

选项:
    --patch <文件>     检查指定补丁文件（默认使用最新补丁）
    --upstream <提交>  指定上游提交（默认使用 upstream/main）
    --detailed         显示详细冲突信息
    --save-report      保存报告到文件
    --help             显示帮助信息

示例:
    $0                           # 检查与上游的冲突
    $0 --patch my.patch         # 检查指定补丁
    $0 --detailed               # 显示详细冲突信息
    $0 --save-report            # 保存报告到文件

EOF
}

# 解析参数
PATCH_FILE=""
UPSTREAM_REF="upstream/main"
DETAILED=false
SAVE_REPORT=false
REPORT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --patch)
            PATCH_FILE="$2"
            shift 2
            ;;
        --upstream)
            UPSTREAM_REF="$2"
            shift 2
            ;;
        --detailed)
            DETAILED=true
            shift
            ;;
        --save-report)
            SAVE_REPORT=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log ERROR "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 创建工作空间
setup_workspace() {
    mkdir -p "$WORK_DIR"
}

# 清理
cleanup() {
    log DEBUG "清理工作空间..."
    rm -rf "$WORK_DIR"
}

# 获取最新补丁
get_latest_patch() {
    if [ -n "$PATCH_FILE" ]; then
        if [ -f "$PATCH_FILE" ]; then
            echo "$PATCH_FILE"
            return 0
        else
            log ERROR "补丁文件不存在: $PATCH_FILE"
            exit 1
        fi
    fi

    # 查找最新补丁
    local latest=$(ls -t "$PATCH_DIR"/localization-*.patch 2>/dev/null | head -1)

    if [ -z "$latest" ]; then
        log ERROR "未找到补丁文件"
        log INFO "请确保补丁目录中有补丁文件: $PATCH_DIR"
        exit 1
    fi

    echo "$latest"
}

# 模拟应用补丁到上游
simulate_apply() {
    local patch_file="$1"
    local upstream_commit="$2"

    log INFO "模拟应用补丁到: $upstream_commit"

    # 保存当前状态
    git stash push -q -m "conflict-check-stash-$(date +%s)" &>/dev/null

    # 切换到上游
    git checkout -q "$upstream_commit" &>/dev/null

    # 尝试应用补丁
    local apply_result
    if apply_result=$(git apply "$patch_file" 2>&1); then
        # 应用成功
        log INFO "补丁应用成功，无冲突"
        git checkout -q - &>/dev/null  # 恢复原分支
        git stash pop -q &>/dev/null   # 恢复暂存
        return 0
    else
        # 应用失败，可能有冲突
        log WARN "补丁应用失败，检测到冲突"

        # 切换回原分支
        git checkout -q - &>/dev/null
        git stash pop -q &>/dev/null

        # 尝试获取冲突信息
        echo "$apply_result"
        return 1
    fi
}

# 检查具体冲突
check_detailed_conflicts() {
    local patch_file="$1"

    log INFO "详细冲突检查..."

    # 分析补丁中的更改
    log INFO "补丁文件: $patch_file"
    log INFO "补丁大小: $(du -h "$patch_file" | cut -f1)"

    # 提取补丁中的文件列表
    log INFO "补丁中的文件:"
    git apply --numstat "$patch_file" | while IFS=$'\t' read -r add del file; do
        log INFO "  - $file (+$add, -$del)"
    done

    # 检查每个文件
    git apply --numstat "$patch_file" | while IFS=$'\t' read -r add del file; do
        if [ -f "$file" ]; then
            log DEBUG "检查文件: $file"

            # 检查文件是否在上游也存在
            if git show "upstream/main:$file" &>/dev/null; then
                log DEBUG "  文件在上游存在"

                # 检查行号冲突
                if git diff "upstream/main" -- "$file" | grep -q "^@@"; then
                    log WARN "  $file: 上游也有修改，可能产生冲突"
                fi
            else
                log DEBUG "  $file: 是新文件，无冲突"
            fi
        else
            log DEBUG "  $file: 将被删除"
        fi
    done
}

# 生成冲突报告
generate_report() {
    local patch_file="$1"
    local has_conflicts="$2"
    local output_file="$3"

    cat > "$output_file" << EOF
CodMate 本地化冲突检查报告
============================

生成时间: $(date '+%Y-%m-%d %H:%M:%S')
补丁文件: $patch_file
上游引用: $UPSTREAM_REF

检查结果:
EOF

    if [ "$has_conflicts" = "false" ]; then
        cat >> "$output_file" << EOF
状态: ✅ 无冲突

补丁可以安全应用。
EOF
    else
        cat >> "$output_file" << EOF
状态: ⚠️  可能存在冲突

建议操作:
1. 仔细检查冲突区域
2. 手动解决冲突
3. 重新生成补丁

详细信息请查看上方输出。
EOF
    fi

    cat >> "$output_file" << EOF

补丁统计:
$(git apply --numstat "$patch_file" 2>/dev/null | while IFS=$'\t' read -r add del file; do echo "  - $file (+$add, -$del)"; done)

---
报告生成完成。
EOF

    log INFO "报告已保存到: $output_file"
}

# 主函数
main() {
    log INFO "========================================="
    log INFO "CodMate 冲突检查脚本"
    log INFO "========================================="

    # 设置工作空间
    setup_workspace

    # 获取补丁文件
    PATCH_FILE=$(get_latest_patch)
    log INFO "使用补丁: $PATCH_FILE"

    # 获取上游提交
    log INFO "上游引用: $UPSTREAM_REF"

    # 检查上游远程是否配置
    if [[ "$UPSTREAM_REF" == upstream/* ]]; then
        if ! git remote get-url upstream &>/dev/null; then
            log ERROR "未配置 upstream 远程仓库"
            exit 1
        fi
        git fetch upstream -q &>/dev/null || true
    fi

    # 执行冲突检查
    log INFO "开始冲突检查..."
    echo

    if simulate_apply "$PATCH_FILE" "$UPSTREAM_REF"; then
        # 无冲突
        log INFO ""
        log INFO "========================================="
        log INFO "检查完成: ✅ 无冲突"
        log INFO "========================================="

        if [ "$DETAILED" = true ]; then
            check_detailed_conflicts "$PATCH_FILE"
        fi

        if [ "$SAVE_REPORT" = true ]; then
            REPORT_FILE="$SCRIPT_DIR/conflict-check-report-$(date +%Y%m%d-%H%M%S).txt"
            generate_report "$PATCH_FILE" "false" "$REPORT_FILE"
        fi
    else
        # 有冲突
        log INFO ""
        log INFO "========================================="
        log INFO "检查完成: ⚠️  检测到冲突"
        log INFO "========================================="

        if [ "$DETAILED" = true ]; then
            check_detailed_conflicts "$PATCH_FILE"
        fi

        if [ "$SAVE_REPORT" = true ]; then
            REPORT_FILE="$SCRIPT_DIR/conflict-check-report-$(date +%Y%m%d-%H%M%S).txt"
            generate_report "$PATCH_FILE" "true" "$REPORT_FILE"
        fi

        log INFO ""
        log INFO "解决冲突的步骤:"
        log INFO "1. 手动应用补丁: git apply $PATCH_FILE"
        log INFO "2. 编辑冲突文件，标记为已解决"
        log INFO "3. 提交更改: git add . && git commit"
        log INFO "4. 重新生成补丁: ./generate-patch.sh"
    fi

    cleanup
}

# 捕获退出信号
trap cleanup EXIT

# 运行主函数
main "$@"
