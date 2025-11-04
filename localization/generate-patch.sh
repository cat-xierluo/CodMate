#!/bin/bash
# CodMate 补丁生成脚本
# 自动检测本地化相关更改并生成补丁

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
WORK_DIR="/tmp/codemate-patch-$$"

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
CodMate 补丁生成脚本

用法: $0 [选项]

选项:
    --output <文件>    指定补丁输出文件
    --since <提交>     从指定提交开始生成补丁
    --all             包含所有更改（默认只包含本地化相关）
    --verify          验证生成的补丁
    --help            显示帮助信息

示例:
    $0                           # 生成当前更改的补丁
    $0 --output my-changes.patch # 指定输出文件
    $0 --since HEAD~5            # 从过去5个提交开始

EOF
}

# 解析参数
OUTPUT_FILE=""
SINCE_REF=""
INCLUDE_ALL=false
VERIFY_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --since)
            SINCE_REF="$2"
            shift 2
            ;;
        --all)
            INCLUDE_ALL=true
            shift
            ;;
        --verify)
            VERIFY_ONLY=true
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

# 解析since参数
if [ -z "$SINCE_REF" ]; then
    SINCE_REF="HEAD"
fi

# 创建输出文件名
generate_output_name() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local timestamp=$(date '+%Y%m%d-%H%M%S')
    echo "$PATCH_DIR/manual-patch-$timestamp-$branch.patch"
}

# 检查文件是否包含本地化相关更改
is_localization_change() {
    local file="$1"

    # 检查文件扩展名
    if [[ "$file" =~ \.(swift|strings|stringsdict)$ ]]; then
        return 0
    fi

    # 检查文件名
    if [[ "$file" =~ (Localizable|localization) ]]; then
        return 0
    fi

    # 检查更改内容
    if git show "$SINCE_REF" -- "$file" 2>/dev/null | grep -qE "(Text\(|Label\(|Button\(|NSLocalizedString)"; then
        return 0
    fi

    return 1
}

# 获取本地化相关文件列表
get_localization_files() {
    git diff --name-only "$SINCE_REF" | while read file; do
        if is_localization_change "$file"; then
            echo "$file"
        fi
    done
}

# 生成补丁摘要
generate_summary() {
    local patch_file="$1"
    local change_count=$(git diff --stat "$SINCE_REF" | tail -1)

    cat > "${patch_file}.summary" << EOF
CodMate 本地化补丁

生成时间: $(date '+%Y-%m-%d %H:%M:%S')
起始提交: $SINCE_REF
当前分支: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

更改统计:
$change_count

包含的文件:
$(git diff --name-only "$SINCE_REF" | sed 's/^/  - /')

说明:
此补丁包含 CodMate 项目的中文本地化修改。
应用此补丁前，请确保已备份当前代码。

EOF
}

# 验证补丁
verify_patch() {
    local patch_file="$1"

    log INFO "验证补丁: $patch_file"

    # 检查补丁格式
    if ! git apply --check "$patch_file" 2>/dev/null; then
        log ERROR "补丁格式无效"
        return 1
    fi

    # 检查冲突
    if git apply "$patch_file" 2>&1 | grep -q "conflict"; then
        log WARN "补丁可能产生冲突"
        return 1
    fi

    # 恢复（因为这是验证）
    git checkout . &>/dev/null

    log INFO "补丁验证通过"
    return 0
}

# 主函数
main() {
    log INFO "========================================="
    log INFO "CodMate 补丁生成脚本"
    log INFO "========================================="

    # 创建目录
    mkdir -p "$PATCH_DIR"

    # 确定输出文件
    if [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE=$(generate_output_name)
    fi

    log INFO "输出文件: $OUTPUT_FILE"
    log INFO "起始提交: $SINCE_REF"

    # 获取更改的文件列表
    local changed_files=$(git diff --name-only "$SINCE_REF")

    if [ -z "$changed_files" ]; then
        log WARN "没有检测到任何更改"
        exit 0
    fi

    log INFO "检测到以下文件更改:"

    # 筛选本地化相关文件
    local localized_files=()
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            log INFO "  - $file"
            localized_files+=("$file")
        fi
    done < <(get_localization_files)

    if [ ${#localized_files[@]} -eq 0 ]; then
        log WARN "没有检测到本地化相关更改"
        if [ "$INCLUDE_ALL" = true ]; then
            log INFO "包含所有更改..."
        else
            log INFO "使用 --all 选项可以包含所有更改"
            exit 0
        fi
    fi

    # 生成补丁
    log INFO "生成补丁中..."

    if [ "$INCLUDE_ALL" = true ]; then
        git diff "$SINCE_REF" > "$OUTPUT_FILE"
    else
        # 只包含本地化相关文件
        git diff "$SINCE_REF" -- "${localized_files[@]}" > "$OUTPUT_FILE"
    fi

    # 检查补丁大小
    if [ ! -s "$OUTPUT_FILE" ]; then
        log WARN "生成的补丁为空"
        rm -f "$OUTPUT_FILE"
        exit 0
    fi

    local patch_size=$(du -h "$OUTPUT_FILE" | cut -f1)
    log INFO "补丁已生成: $OUTPUT_FILE"
    log INFO "补丁大小: $patch_size"

    # 生成摘要
    generate_summary "$OUTPUT_FILE"
    log INFO "补丁摘要: ${OUTPUT_FILE}.summary"

    # 显示补丁统计
    echo
    log INFO "补丁统计:"
    git diff --stat "$SINCE_REF" | while read line; do
        log INFO "  $line"
    done

    # 验证补丁
    if [ "$VERIFY_ONLY" = true ]; then
        verify_patch "$OUTPUT_FILE"
    fi

    echo
    log INFO "========================================="
    log INFO "补丁生成完成！"
    log INFO "========================================="
    log INFO ""
    log INFO "下一步:"
    log INFO "1. 审核补丁: $OUTPUT_FILE"
    log INFO "2. 测试应用: git apply $OUTPUT_FILE"
    log INFO "3. 如需同步，请运行: ./sync-upstream.sh"
    log INFO ""
}

main "$@"
