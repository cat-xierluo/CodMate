# ContentView.swift 本地化键名映射

> 创建日期：2025-11-03
> 文件：views/ContentView.swift
> 字符串总数：60+

## 📋 键名映射表

### 1. 对话框和警告 (Dialogs & Alerts)

| 位置 | 原文本 | 本地化键 | 中文翻译 |
|------|--------|----------|----------|
| L224 | "Stop running session?" | `dialogs.stopSession.title` | "停止运行中的会话？" |
| L231 | "Stop" | `actions.stop` | "停止" |
| L237 | "Cancel" | `actions.cancel` | "取消" |
| L239 | "The embedded terminal appears to be running. Stopping now will terminate the current Codex/Claude task." | `dialogs.stopSession.message` | "嵌入式终端似乎正在运行。现在停止将终止当前的 Codex/Claude 任务。" |
| L184 | "Operation Failed" | `error.operationFailed` | "操作失败" |
| L245 | "OK" | `actions.ok` | "确定" |
| L249 | "Delete selected sessions?" | `dialogs.deleteSession.title` | "删除选中的会话？" |
| L253 | "Move to Trash" | `actions.moveToTrash` | "移动到废纸篓" |
| L257 | "Session files will be moved to Trash and can be restored in Finder." | `dialogs.deleteSession.message` | "会话文件将被移动到废纸篓，可以在 Finder 中恢复。" |
| L831 | "Delete Prompt" | `dialogs.deletePrompt.title` | "删除提示" |
| L832 | "Delete '\(item.label)'? This cannot be undone." | `dialogs.deletePrompt.message` | "删除 '\(item.label)'？此操作无法撤销。" |
| L833 | "Delete" | `actions.delete` | "删除" |
| L1381 | "Failed to choose directory" | `error.failedChooseDirectory` | "选择目录失败" |

### 2. 工具提示和帮助文本 (Tooltips & Help)

| 位置 | 原文本 | 本地化键 | 中文翻译 |
|------|--------|----------|----------|
| L333 | "Refresh session index" | `help.refreshSessionIndex` | "刷新会话索引" |
| L449 | "Rename / Add Comment" | `help.renameAddComment` | "重命名/添加评论" |
| L539 | "Start a new \($0.source.branding.displayName) session" | `help.startNewSession` | "开始新的 \($0.source.branding.displayName) 会话" |
| L540 | "Select a session to start new conversations" | `help.selectSessionToStart` | "选择一个会话以开始新对话" |
| L629 | "Reveal in Finder" | `help.revealInFinder` | "在 Finder 中显示" |
| L638 | "Toggle Review Mode" | `help.toggleReviewMode` | "切换评审模式" |
| L647 | "Insert preset command…" | `help.insertPresetCommand` | "插入预设命令…" |
| L669 | "Manage Prompts" | `help.managePrompts` | "管理提示" |
| L772 | "Delete prompt" | `help.deletePrompt` | "删除提示" |
| L863,868 | "Return to history" | `help.returnToHistory` | "返回历史记录" |
| L877 | "Export Markdown" | `help.exportMarkdown` | "导出 Markdown" |
| L887 | "Delete" | `help.delete` | "删除" |
| L1366 | "Restore view" | `help.restoreView` | "恢复视图" |
| L1366 | "Maximize terminal" | `help.maximizeTerminal` | "最大化终端" |

### 3. 菜单项和按钮 (Menu Items & Buttons)

| 位置 | 原文本 | 本地化键 | 中文翻译 |
|------|--------|----------|----------|
| L467 | "New With Context…" | `actions.newWithContext` | "基于上下文新建…" |
| L488,559 | "Open in Terminal" | `actions.openInTerminal` | "在终端中打开" |
| L495,570 | "Open in iTerm2" | `actions.openInIterm2` | "在 iTerm2 中打开" |
| L502,584 | "Open in Warp" | `actions.openInWarp` | "在 Warp 中打开" |
| L512,592 | "Open Embedded Terminal" | `actions.openEmbeddedTerminal` | "打开嵌入式终端" |
| L481 | "Use Preferred Launch" | `actions.usePreferredLaunch` | "使用首选启动方式" |
| L522 | "Select a session to start a new conversation" | `placeholder.selectSessionForNew` | "选择一个会话以开始新对话" |
| L530 | "New" | `actions.new` | "新建" |
| L596 | "Select a session to resume" | `placeholder.selectSessionForResume` | "选择一个会话以继续" |
| L599 | "Resume" | `actions.resume` | "继续" |

### 4. 占位符和状态文本 (Placeholders & Status)

| 位置 | 原文本 | 本地化键 | 中文翻译 |
|------|--------|----------|----------|
| L430 | "New Session" | `status.newSession` | "新会话" |
| L433 | "Appears in list after first message" | `status.appearsAfterFirstMessage` | "发送第一条消息后出现在列表中" |
| L522 | "Select a session to start a new conversation" | `placeholder.selectSessionNewConversation` | "选择一个会话以开始新对话" |
| L596 | "Select a session to resume" | `placeholder.selectSessionResume` | "选择一个会话以继续" |
| L671 | "Search prompts" | `placeholder.searchPrompts` | "搜索提示" |
| L730 | "No matches" | `status.noMatches` | "无匹配项" |
| L788 | "Showing first \(maxShown) results — refine search to see more" | `status.showingFirstResults` | "显示前 \(maxShown) 个结果 — 优化搜索以查看更多" |
| L1388,1390 | "Select a session" | `placeholder.selectSession` | "选择一个会话" |
| L1390 | "Pick a session from the middle list to view details." | `placeholder.pickSessionDetails` | "从中间列表中选择一个会话以查看详情。" |

### 5. 标题和标签 (Titles & Labels)

| 位置 | 原文本 | 本地化键 | 中文翻译 |
|------|--------|----------|----------|
| L651 | "Preset Commands" | `title.presetCommands` | "预设命令" |
| L1181,1228,1265 | "CodMate" | `app.name` | "CodMate" |
| L555,580 | "Command copied. Paste it in the opened terminal." | `notification.commandCopied` | "命令已复制。粘贴到打开的终端中。" |
| L1181 | "Command copied. Paste it in the opened terminal." | `notification.commandCopied` | "命令已复制。粘贴到打开的终端中。" |

## 🔧 Swift 代码修改示例

### 示例 1：替换对话框文本
```swift
// 修改前
.confirmationDialog(
    "Stop running session?",
    isPresented: ...
) {
    Button("Stop", role: .destructive) { ... }
    Button("Cancel", role: .cancel) { ... }
} message: {
    Text("The embedded terminal appears to be running...")
}

// 修改后
.confirmationDialog(
    L10n.Dialogs.StopSession.title,
    isPresented: ...
) {
    Button(L10n.Actions.stop, role: .destructive) { ... }
    Button(L10n.Actions.cancel, role: .cancel) { ... }
} message: {
    Text(L10n.Dialogs.StopSession.message)
}
```

### 示例 2：替换工具提示
```swift
// 修改前
.help("Refresh session index")

// 修改后
.help(L10n.Help.refreshSessionIndex)
```

### 示例 3：替换占位符文本
```swift
// 修改前
Text("Search prompts")

// 修改后
Text(L10n.Placeholder.searchPrompts)
```

### 示例 4：带参数的字符串
```swift
// 修改前
Text("Delete '\(item.label)'? This cannot be undone.")

// 修改后
Text(L10n.Dialogs.DeletePrompt.message(item.label))

// 在 Localizable.strings 文件中
"dialogs.deletePrompt.message" = "删除 \"%@\"？此操作无法撤销。";
```

## 📝 实施步骤

1. ✅ 创建本键名映射文档
2. ⏳ 修改 ContentView.swift，使用本地化键
3. ⏳ 更新 zh-Hans/Views/ContentView.strings 文件
4. ⏳ 生成并应用补丁
5. ⏳ 测试界面显示

## 🎯 命名约定总结

- `dialogs.*` - 对话框相关
- `actions.*` - 动作按钮相关
- `help.*` - 帮助提示和工具提示
- `placeholder.*` - 占位符文本
- `status.*` - 状态文本
- `title.*` - 标题文本
- `error.*` - 错误消息
- `notification.*` - 通知消息
- `app.*` - 应用相关信息

---

**下一步**：开始修改 ContentView.swift 文件
