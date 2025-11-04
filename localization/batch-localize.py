#!/usr/bin/env python3
"""
自动化批量本地化脚本
"""

import os
import re

# 定义通用字符串替换映射
COMMON_REPLACEMENTS = {
    # 对话框
    "OK": "actions.ok",
    "Cancel": "actions.cancel",
    "Stop": "actions.stop",
    "Delete": "actions.delete",
    "Move to Trash": "actions.moveToTrash",
    "Save": "actions.save",
    "Edit": "actions.edit",
    "Refresh": "actions.refresh",
    "New": "actions.new",
    "Resume": "actions.resume",
    "Open in Terminal": "actions.openInTerminal",
    "Open in iTerm2": "actions.openInIterm2",
    "Open in Warp": "actions.openInWarp",
    "Open Embedded Terminal": "actions.openEmbeddedTerminal",
    "Use Preferred Launch": "actions.usePreferredLaunch",
    "Change…": "actions.change",
    "Restore Defaults": "actions.restoreDefaults",
    "View…": "actions.view",
    "Select": "actions.select",
    "Add": "actions.add",
    "Remove": "actions.remove",
    "Test": "actions.test",
    "Close": "actions.close",

    # 标题
    "Settings": "title.settings",
    "General Settings": "settings.general.title",
    "Terminal Settings": "settings.terminal.title",
    "Command Settings": "settings.command.title",
    "About CodMate": "about.title",

    # 帮助文本
    "Refresh session index": "help.refreshSessionIndex",
    "Reveal in Finder": "help.revealInFinder",
    "Delete": "help.delete",

    # 占位符
    "Select a session": "placeholder.selectSession",
    "Search": "placeholder.search",
    "Loading...": "status.loading",
    "No sessions": "status.noSessions",
}

def process_file(filepath):
    """处理单个文件"""
    print(f"处理文件: {filepath}")

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # 应用通用替换
    for english, chinese in COMMON_REPLACEMENTS.items():
        # 替换字符串字面值（带引号）
        content = re.sub(
            rf'"{re.escape(english)}"',
            f'"{chinese}"',
            content
        )

    # 只在有更改时写入文件
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✓ 已更新")
        return True
    else:
        print(f"  - 无更改")
        return False

def main():
    """主函数"""
    views_dir = "/Users/maoking/Library/Application Support/maoscripts/CodMate/views"

    # 要处理的文件列表
    files_to_process = [
        "SettingsView.swift",
        "SessionListColumnView.swift",
        "SessionDetailView.swift",
        "ProjectsListView.swift",
        "ProvidersSettingsView.swift",
        "MCPServersSettingsView.swift",
        "GitChangesPanel.swift",
        "EditSessionMetaView.swift",
    ]

    updated_count = 0
    for filename in files_to_process:
        filepath = os.path.join(views_dir, filename)
        if os.path.exists(filepath):
            if process_file(filepath):
                updated_count += 1
        else:
            print(f"文件不存在: {filepath}")

    print(f"\n处理完成！共更新了 {updated_count} 个文件")

if __name__ == "__main__":
    main()
