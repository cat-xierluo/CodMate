# CodMate 本地化补丁管理指南

> 创建日期：2025-11-03
> 最后更新：2025-11-03

## 📋 目录

- [概述](#概述)
- [文件结构](#文件结构)
- [工作流程](#工作流程)
- [命令参考](#命令参考)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)

---

## 概述

CodMate 本地化补丁管理系统使用 Git 补丁机制来管理你的中文本地化修改与上游代码的同步。

### 核心概念

**补丁 (Patch)**: 一个文本文件，描述了对代码的修改，可以应用到其他代码库。

**上游 (Upstream)**: 原始项目仓库（`https://github.com/loocor/codmate`）

**Fork**: 你的项目副本（`https://github.com/cat-xierluo/CodMate`）

**本地化分支**: 包含你中文本地化修改的分支

---

## 文件结构

```
localization/
├── scripts/
│   ├── sync-upstream.sh       # 同步上游代码脚本
│   ├── generate-patch.sh      # 生成补丁脚本
│   └── check-conflicts.sh     # 冲突检查脚本
├── patches/                   # 自动创建的补丁目录
│   ├── localization-20251103-143000-main.patch
│   └── ...
├── PATCH-MANAGEMENT.md        # 本文件
├── SYNC-WORKFLOW.md          # 工作流程文档
├── localization-keys.json    # 本地化键名映射
└── zh-Hans/                  # 中文翻译文件
    ├── Localizable.strings
    └── ...
```

---

## 工作流程

### 场景 1：首次设置本地化

```bash
# 1. 确认你的 fork 已与上游同步
git status
git log --oneline -5

# 2. 创建本地化修改
# ... 编辑代码 ...

# 3. 生成补丁
cd localization/
chmod +x scripts/*.sh
./generate-patch.sh

# 4. 测试补丁
git checkout .
./check-conflicts.sh

# 5. 提交本地化修改到你的 fork
git add .
git commit -m "feat: add Chinese localization"
git push origin main
```

### 场景 2：上游有更新，需要同步

```bash
# 方法 1：使用自动同步脚本（推荐）
cd localization/
./sync-upstream.sh

# 方法 2：手动同步
# 1. 生成当前补丁
./generate-patch.sh

# 2. 同步上游
git fetch upstream
git reset --hard upstream/main

# 3. 应用补丁
ls patches/
git apply patches/localization-20251103-143000-main.patch

# 4. 解决冲突（如果有）
# 编辑冲突文件，然后：
git add .
git commit -m "resolve conflicts in localization"

# 5. 推送更新
git push origin main
```

### 场景 3：只想检查是否有更新

```bash
cd localization/
./sync-upstream.sh --check-only

# 输出：
# [INFO] 检查上游更新...
# [INFO] 有可用更新
# 或
# [INFO] 已是最新
```

### 场景 4：处理补丁冲突

```bash
# 1. 检查冲突
cd localization/
./check-conflicts.sh --detailed

# 2. 尝试应用补丁
git apply patches/your-patch.patch

# 3. 如果有冲突，会显示：
# error: patch failed: Sources/CodMate/Views/ContentView.swift:231
# error: Sources/CodMate/Views/ContentView.swift: patch does not apply

# 4. 手动解决冲突
# 打开冲突的文件，找到 <<<<<<<, =======, >>>>>>> 标记
# 手动编辑内容，保留你想要的修改

# 5. 标记冲突已解决
git add Sources/CodMate/Views/ContentView.swift

# 6. 继续应用其他文件...
# 或使用 --continue 选项（如果脚本支持）

# 7. 生成新的补丁
./generate-patch.sh --since HEAD
```

---

## 命令参考

### sync-upstream.sh - 同步脚本

**基本用法**：
```bash
./sync-upstream.sh
```

**选项**：
- `--dry-run` 试运行，显示将要执行的操作但不实际执行
- `--force` 强制应用补丁，跳过冲突检查
- `--check-only` 仅检查是否有更新，不同步

**示例**：
```bash
# 试运行（推荐）
./sync-upstream.sh --dry-run

# 强制同步（谨慎使用）
./sync-upstream.sh --force

# 检查更新
./sync-upstream.sh --check-only
```

---

### generate-patch.sh - 补丁生成脚本

**基本用法**：
```bash
./generate-patch.sh
```

**选项**：
- `--output <文件>` 指定补丁输出文件
- `--since <提交>` 从指定提交开始生成补丁
- `--all` 包含所有更改（默认只包含本地化相关）
- `--verify` 验证生成的补丁

**示例**：
```bash
# 生成当前更改的补丁
./generate-patch.sh

# 指定输出文件
./generate-patch.sh --output my-changes.patch

# 从过去5个提交开始
./generate-patch.sh --since HEAD~5

# 验证补丁
./generate-patch.sh --verify
```

---

### check-conflicts.sh - 冲突检查脚本

**基本用法**：
```bash
./check-conflicts.sh
```

**选项**：
- `--patch <文件>` 检查指定补丁文件
- `--upstream <提交>` 指定上游提交
- `--detailed` 显示详细冲突信息
- `--save-report` 保存报告到文件

**示例**：
```bash
# 检查与上游的冲突
./check-conflicts.sh

# 检查指定补丁
./check-conflicts.sh --patch patches/my-patch.patch

# 显示详细信息
./check-conflicts.sh --detailed

# 保存报告
./check-conflicts.sh --save-report
```

---

## 故障排除

### 问题 1：脚本无法执行

**症状**：
```
bash: ./scripts/sync-upstream.sh: Permission denied
```

**解决方案**：
```bash
chmod +x localization/scripts/*.sh
```

---

### 问题 2：补丁应用失败

**症状**：
```
error: patch failed: Sources/CodMate/Views/ContentView.swift:231
error: Sources/CodMate/Views/ContentView.swift: patch does not apply
```

**原因**：
上游代码在相同位置也做了修改，导致冲突。

**解决方案**：
```bash
# 1. 检查冲突详情
./check-conflicts.sh --detailed

# 2. 手动应用补丁
git apply patches/your-patch.patch 2>&1 | head -20

# 3. 打开冲突文件，手动解决
open Sources/CodMate/Views/ContentView.swift

# 4. 搜索标记：<<<<<<<, =======, >>>>>>>

# 5. 解决后标记为已解决
git add Sources/CodMate/Views/ContentView.swift

# 6. 重新生成补丁
./generate-patch.sh --since HEAD
```

---

### 问题 3：上游没有 upstream 远程

**症状**：
```
[ERROR] 未配置 upstream 远程仓库
```

**解决方案**：
```bash
git remote add upstream https://github.com/loocor/codmate
git fetch upstream
```

---

### 问题 4：工作目录不干净

**症状**：
```
error: cannot pull with uncommitted changes
```

**解决方案**：
```bash
# 提交或暂存你的更改
git stash push -m "暂存本地化修改"
git stash list

# 同步后恢复
git stash pop
```

---

### 问题 5：补丁为空

**症状**：
```
[ WARN ] 没有检测到任何更改
```

**原因**：当前没有本地化相关的修改。

**解决方案**：
```bash
# 确认你有修改
git status
git diff

# 如果确实有修改，使用 --all 选项
./generate-patch.sh --all
```

---

## 最佳实践

### 1. 定期同步

每周至少同步一次上游更新，避免积累太多冲突。

```bash
# 设置每周提醒或cronjob
./sync-upstream.sh --check-only
```

---

### 2. 小步提交

将本地化工作分解为小的提交，便于管理和回滚。

```bash
# 好的做法
git add Sources/CodMate/Views/ContentView.swift
git commit -m "localize: ContentView buttons and labels"

git add Sources/CodMate/Views/SettingsView.swift
git commit -m "localize: SettingsView general settings"
```

---

### 3. 测试补丁

每次生成新补丁后都进行测试。

```bash
# 1. 生成补丁
./generate-patch.sh

# 2. 检查冲突
./check-conflicts.sh --detailed

# 3. 验证补丁
./generate-patch.sh --verify

# 4. 试运行同步
./sync-upstream.sh --dry-run
```

---

### 4. 备份重要补丁

```bash
# 备份关键补丁
cp patches/localization-20251103-143000-main.patch ~/backup/

# 或创建标签
git tag localization-backup-20251103
```

---

### 5. 使用分支进行实验

```bash
# 创建实验分支
git checkout -b experiment-new-features

# 修改...
git add .
git commit -m "feat: experimental localization"

# 如果实验成功，合并到主分支
git checkout main
git merge experiment-new-features

# 如果实验失败，删除分支
git branch -D experiment-new-features
```

---

### 6. 记录重要更改

在 `PATCHES.md` 文件中记录重要的补丁：

```markdown
# 本地化补丁历史

## 2025-11-03 - 初始中文化
- 添加了 200+ 基础翻译
- 包含主界面和设置页面本地化
- 补丁：localization-20251103-143000-main.patch

## 2025-11-10 - 会话管理本地化
- 添加会话列表和详情页翻译
- 修复了界面布局问题
- 补丁：localization-20251110-100000-main.patch
```

---

### 7. 团队协作

如果你与其他开发者协作本地化：

```bash
# 1. 确保你的分支是最新的
git fetch origin
git rebase origin/main

# 2. 生成补丁分享
./generate-patch.sh --output team-patch.patch

# 3. 其他成员应用补丁
git apply team-patch.patch
```

---

## 常见问题解答

### Q: 我需要保留原始的英文文本吗？

**A**: 不需要。本地化文件会自动处理回退。如果系统语言不是中文，会显示英文原文。

---

### Q: 如何添加新的翻译？

**A**: 编辑 `zh-Hans/Localizable.strings` 文件，然后重新生成并应用补丁。

```bash
# 1. 添加翻译
vim zh-Hans/Localizable.strings
# 添加： "new.key" = "新的翻译";

# 2. 重新生成补丁
./generate-patch.sh

# 3. 应用补丁
git apply patches/latest.patch
```

---

### Q: 多久需要同步一次上游？

**A**: 建议每周一次。如果上游更新频繁（每天都有），可以每2-3天同步一次。

---

### Q: 如果上游放弃了这个项目怎么办？

**A**: 你已经 fork 了项目，可以继续维护你自己的版本。补丁系统保证你可以继续同步任何未来的更新。

---

### Q: 可以回滚补丁吗？

**A**: 可以。使用 Git 的强大回滚功能：

```bash
# 回滚到补丁应用前
git reset --hard HEAD~1

# 或者创建一个反补丁
git diff patches/your-patch.patch | git apply
```

---

## 资源链接

- [Git 补丁文档](https://git-scm.com/docs/apply)
- [Git 冲突解决指南](https://git-scm.com/docs/merge)
- [CodMate 上游项目](https://github.com/loocor/codmate)
- [你的 Fork 项目](https://github.com/cat-xierluo/CodMate)

---

**祝你本地化工作顺利！** 🚀

如有问题，请查看 `SYNC-WORKFLOW.md` 或在 GitHub 上提交 Issue。
