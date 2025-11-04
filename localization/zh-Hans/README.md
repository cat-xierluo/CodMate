# CodMate 中文化包

> 项目版本：基于 544e8c2（2025-11-03）
> 中文版本：1.0

## 📦 包含内容

本中文化包为 CodMate 提供完整的中文本地化支持，包括：

### 📚 文档
- **[术语表.md](./术语表.md)** - 技术术语翻译规范
- **[中文化实施计划.md](./中文化实施计划.md)** - 详细实施计划和工作进度
- **[错误和提示.md](./错误和提示.md)** - 错误消息和用户提示的翻译指南

### 📝 本地化文件
- **[Localizable.strings](./Localizable.strings)** - 基础本地化字符串
- **[Views/ContentView.strings](./Views/ContentView.strings)**
- **[Views/SettingsView.strings](./Views/SettingsView.strings)**
- **[Models/SessionSummary.strings](./Models/SessionSummary.strings)**

## 🚀 快速开始

### 方法 1：使用现有的本地化文件

1. 在 Xcode 中打开 CodMate 项目
2. 在项目导航器中右键点击 `CodMate` 目标
3. 选择 "New File..." → "Strings File"
4. 命名为 `Localizable.strings`
5. 将 `zh-Hans/Localizable.strings` 中的内容复制到新文件
6. 在文件检查器中添加本地化语言：zh-Hans（简体中文）

### 方法 2：逐步替换

参考 [中文化实施计划](./中文化实施计划.md)，按照以下顺序进行：

1. ✅ 准备工作（已完成）
2. 🔥 核心 UI 本地化
3. 📋 会话管理相关界面
4. ⚠️ 错误消息和帮助文本
5. ✅ 测试和优化

## 🔧 代码集成

### 替换硬编码字符串

```swift
// 替换前
Text("Settings")
Label("Delete", systemImage: "trash")
Button("OK") { }

// 替换后
Text("settings.title")
Label("actions.delete", systemImage: "trash")
Button("actions.ok") { }
```

### 使用 NSLocalizedString

```swift
// 使用键值对
NSLocalizedString("session.resume", comment: "继续执行会话")

// 带参数
String(format: NSLocalizedString("open.in.format", comment: ""), appName)
```

## 📊 进度追踪

| 阶段 | 状态 | 完成度 | 备注 |
|------|------|--------|------|
| 准备工作 | ✅ 完成 | 100% | 已创建所有基础文件 |
| 核心 UI | 🔥 进行中 | 20% | 已完成 ContentView 和 SettingsView 的基础翻译 |
| 会话管理 | ⏳ 待开始 | 0% | 待开始 SessionList 和 SessionDetail |
| 错误消息 | ⏳ 待开始 | 0% | 待开始错误提示和帮助文本 |
| 测试优化 | ⏳ 待开始 | 0% | 待开始全面测试 |

## 🎯 下一步工作

1. **优先完成**：
   - ContentView.swift 的完整本地化
   - SettingsView.swift 的完整本地化
   - SessionList 相关视图

2. **后续任务**：
   - 错误消息处理
   - 工具提示和帮助文本
   - 动态文本和格式化字符串

## 📚 相关文档

- [Apple 本地化指南](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/BPInternational.html)
- [SwiftUI 本地化](https://developer.apple.com/documentation/swiftui/localization)
- [中文化实施计划](./中文化实施计划.md)

## ⚠️ 注意事项

1. **保持一致性** - 使用术语表中的翻译规范
2. **测试布局** - 验证中文文本的显示效果
3. **更新文档** - 修改术语表或添加新翻译时更新文档
4. **代码审查** - 确保新添加的字符串已被本地化

## 📝 更新日志

- **2025-11-03 (v1.0)**
  - 创建基础本地化文件结构
  - 完成术语表
  - 完成核心术语翻译
  - 创建 ContentView 和 SettingsView 基础翻译

## 🤝 贡献指南

如果你想参与中文化工作：

1. 查看 [术语表](./术语表.md) 确保术语一致性
2. 在对应的 `.strings` 文件中添加翻译
3. 更新 [中文化实施计划.md](./中文化实施计划.md) 中的进度
4. 提交前测试确保显示正常

---

**版权声明**：本中文化包基于 CodMate 开源项目创建，仅用于本地化目的。
