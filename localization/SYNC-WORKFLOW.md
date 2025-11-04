# CodMate 同步工作流程

> 创建日期：2025-11-03
> 适用场景：本地化维护者日常操作指南

## 📋 目录

- [日常同步流程](#日常同步流程)
- [初次设置流程](#初次设置流程)
- [增量更新流程](#增量更新流程)
- [紧急回滚流程](#紧急回滚流程)
- [团队协作流程](#团队协作流程)

---

## 日常同步流程

**适用场景**: 你已经完成了基础本地化设置，只需要定期同步上游更新。

### 步骤概览

```
每日/每周检查 → 发现更新 → 生成补丁 → 同步上游 → 应用补丁 → 测试验证
```

### 详细步骤

#### 1. 检查更新（每日或每周）

```bash
cd localization/

# 快速检查是否有更新
./sync-upstream.sh --check-only

# 预期输出：
# [INFO] 检查上游更新...
# [INFO] 当前提交: 544e8c2 feat: add AI-powered commit message generation
# [INFO] 上游提交: 544e8c2 feat: add AI-powered commit message generation
# [INFO] 已是最新，无需同步
```

**如果无更新**：
- 退出，工作完成 ✅

**如果有更新**：
- 继续步骤 2

---

#### 2. 生成当前补丁

```bash
# 生成最新的本地化补丁
./generate-patch.sh

# 预期输出：
# [INFO] 检测到以下文件更改:
# [INFO]   - Sources/CodMate/Views/ContentView.swift
# [INFO]   - Sources/CodMate/Views/SettingsView.swift
# [INFO] 补丁已生成: patches/manual-patch-20251103-143000-main.patch
# [INFO] 补丁大小: 15KB
```

**检查补丁**：
```bash
# 查看补丁摘要
cat patches/manual-patch-20251103-143000-main.patch.summary
```

---

#### 3. 同步上游

```bash
# 标准同步（推荐）
./sync-upstream.sh

# 预期输出：
# [INFO] 检测到上游有更新
# [INFO] 上游同步完成
# [INFO] 应用本地化补丁: patches/manual-patch-20251103-143000-main.patch
# [INFO] 补丁应用成功
# [INFO] 同步完成！
```

---

#### 4. 处理冲突（如果有）

```bash
# 如果同步失败，会显示：
# [ERROR] 检测到冲突，无法应用补丁
# [INFO] 请先解决冲突，或使用 --force 选项

# 检查冲突详情
./check-conflicts.sh --detailed

# 手动解决冲突：
# 1. 打开冲突的文件
# 2. 找到 <<<<<<< ======= >>>>>>> 标记
# 3. 手动编辑，保留你的修改
# 4. 标记为已解决
git add <冲突文件>

# 5. 继续同步
./sync-upstream.sh --force
```

---

#### 5. 验证结果

```bash
# 检查工作目录
git status

# 查看提交历史
git log --oneline -5

# 运行应用测试
# ... 运行 CodMate 应用 ...

# 如果一切正常，推送到你的 fork
git push origin main
```

---

## 初次设置流程

**适用场景**: 你第一次设置本地化环境，或者需要重新设置。

### 步骤概览

```
设置环境 → 创建本地化修改 → 首次生成补丁 → 首次同步 → 验证
```

### 详细步骤

#### 1. 检查环境

```bash
# 确保你的 fork 是最新的
git status

# 检查远程仓库
git remote -v
# 应该看到：
# origin  git@github.com:cat-xierluo/CodMate.git (fetch)
# origin  git@github.com:cat-xierluo/CodMate.git (push)
# upstream        https://github.com/loocor/codmate (fetch)
# upstream        https://github.com/loocor/codmate (push)

# 如果没有 upstream，添加它
git remote add upstream https://github.com/loocor/codmate
git fetch upstream
```

---

#### 2. 使脚本可执行

```bash
cd localization/
chmod +x scripts/*.sh
ls -la scripts/
# 应该看到：
# -rwxr-xr-x  1 user  staff  脚本大小  日期  sync-upstream.sh
# -rwxr-xr-x  1 user  staff  脚本大小  日期  generate-patch.sh
# -rwxr-xr-x  1 user  staff  脚本大小  日期  check-conflicts.sh
```

---

#### 3. 创建本地化修改

```bash
# 编辑 Swift 文件，添加本地化代码
# 例如：修改 ContentView.swift
open Sources/CodMate/Views/ContentView.swift

# 将：
# Text("Settings")
# 改为：
# Text("settings.title")

# 添加翻译到 zh-Hans/Localizable.strings
open zh-Hans/Localizable.strings
# 添加：
# "settings.title" = "设置";
```

---

#### 4. 首次生成补丁

```bash
# 生成补丁
./generate-patch.sh --all

# 查看生成的补丁
ls -lh patches/
# 应该看到类似：
# -rw-r--r--  1 user  staff  15KB  11月  3 14:30 manual-patch-20251103-143000-main.patch
```

---

#### 5. 测试补丁

```bash
# 检查补丁是否能正确应用
./check-conflicts.sh --detailed

# 预期输出：
# [INFO] 验证补丁: patches/manual-patch-20251103-143000-main.patch
# [INFO] 补丁验证通过

# 如果验证失败，修复问题后重新生成
```

---

#### 6. 首次同步

```bash
# 试运行
./sync-upstream.sh --dry-run

# 实际同步
./sync-upstream.sh

# 预期输出：
# [INFO] 创建备份分支: localization-backup-20251103-143000
# [INFO] 同步上游代码...
# [INFO] 应用本地化补丁...
# [INFO] 补丁应用成功
```

---

#### 7. 提交并推送

```bash
# 查看更改
git status
git diff --stat

# 提交
git add .
git commit -m "feat: add Chinese localization for ContentView and SettingsView"

# 推送到你的 fork
git push origin main
```

---

## 增量更新流程

**适用场景**: 你有多个本地化修改会话，需要分批次应用。

### 步骤概览

```
创建多个补丁 → 批量应用 → 统一提交 → 推送
```

### 详细步骤

#### 1. 创建第一批补丁

```bash
# 修改 ContentView.swift
# ...
git add Sources/CodMate/Views/ContentView.swift zh-Hans/Localizable.strings
git commit -m "localize: ContentView main interface"
./generate-patch.sh --since HEAD~1 --output patches/batch1-contentview.patch
```

---

#### 2. 创建第二批补丁

```bash
# 修改 SettingsView.swift
# ...
git add Sources/CodMate/Views/SettingsView.swift
git commit -m "localize: SettingsView"
./generate-patch.sh --since HEAD~1 --output patches/batch2-settings.patch
```

---

#### 3. 批量应用

```bash
# 应用所有补丁
git apply patches/batch1-contentview.patch
git apply patches/batch2-settings.patch

# 检查结果
git status
```

---

#### 4. 统一提交

```bash
git add .
git commit -m "feat: complete Chinese localization for ContentView and SettingsView"
git push origin main
```

---

## 紧急回滚流程

**适用场景**: 同步后出现严重问题，需要立即回滚。

### 步骤概览

```
发现问题 → 识别问题 → 回滚 → 修复 → 重新同步
```

### 详细步骤

#### 1. 识别问题

```bash
# 应用同步后出现问题
# 例如：编译错误、运行时崩溃等

# 检查最近的提交
git log --oneline -5

# 查看具体修改
git show HEAD --stat
```

---

#### 2. 快速回滚

```bash
# 回滚到上一个提交（保留修改为未提交状态）
git reset --soft HEAD~1

# 或者完全回滚（丢弃修改）
git reset --hard HEAD~1

# 如果需要回滚到更早的提交
git log --oneline
git reset --hard <commit-hash>
```

---

#### 3. 从备份分支恢复

```bash
# 查看备份分支
git branch -a | grep backup

# 切换到备份分支
git checkout localization-backup-20251103-143000

# 创建新的工作分支
git checkout -b recovery-branch
```

---

#### 4. 修复问题

```bash
# 分析问题原因
# ...
# 修复代码
# ...

# 测试修复
# 编译并运行应用
```

---

#### 5. 重新生成补丁

```bash
# 生成修复后的补丁
./generate-patch.sh --all

# 重新同步
./sync-upstream.sh --dry-run
./sync-upstream.sh
```

---

## 团队协作流程

**适用场景**: 多个人协作维护本地化，或需要从其他成员获取修改。

### 步骤概览

```
获取共享补丁 → 应用补丁 → 测试 → 推送更新
```

### 详细步骤

#### 1. 获取共享补丁

```bash
# 从团队成员获取补丁文件
# 例如：通过邮件、Slack、GitHub 等

# 假设你收到文件：team-localization.patch
cp ~/Downloads/team-localization.patch patches/team-localization-20251103.patch
```

---

#### 2. 备份当前状态

```bash
# 创建备份
git add .
git stash push -m "backup-before-team-patch"
git stash list
# 记录 stash ID： stash@{0}
```

---

#### 3. 应用团队补丁

```bash
# 检查补丁
./check-conflicts.sh --patch patches/team-localization-20251103.patch

# 应用补丁
git apply patches/team-localization-20251103.patch

# 检查结果
git status
```

---

#### 4. 解决冲突（如果有）

```bash
# 如果有冲突
./check-conflicts.sh --detailed --patch patches/team-localization-20251103.patch

# 手动解决冲突
# ...

git add <已解决的文件>
```

---

#### 5. 测试验证

```bash
# 编译应用
# ...
# 运行测试
# ...
```

---

#### 6. 提交更改

```bash
git add .
git commit -m "chore: apply team localization updates"
git push origin main
```

---

#### 7. 清理（可选）

```bash
# 删除备份（如果一切正常）
git stash drop stash@{0}

# 或者保留备份以防万一
```

---

## 高级用法

### 自动化日常同步

```bash
# 创建 cron 任务（每天检查一次）
# 编辑 crontab
crontab -e

# 添加行：
# 0 9 * * 1-7 cd /path/to/CodMate/localization && ./sync-upstream.sh --check-only >> sync.log 2>&1

# 每周日自动同步
# 0 10 * * 0 cd /path/to/CodMate/localization && ./sync-upstream.sh >> weekly-sync.log 2>&1
```

---

### 创建别名

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
alias codemate-sync='cd /path/to/CodMate/localization && ./sync-upstream.sh'
alias codemate-check='cd /path/to/CodMate/localization && ./check-conflicts.sh'
alias codemate-patch='cd /path/to/CodMate/localization && ./generate-patch.sh'

# 使用别名
codemate-check  # 检查冲突
codemate-sync   # 同步
```

---

### 生成状态报告

```bash
#!/bin/bash
# 创建脚本：scripts/generate-status.sh
cd "$(dirname "$0")/.."

echo "=== CodMate 本地化状态报告 ==="
echo "生成时间: $(date)"
echo ""

echo "=== 上游状态 ==="
git fetch upstream --quiet
echo "上游最新提交: $(git log --oneline -1 upstream/main)"
echo "本地当前提交: $(git log --oneline -1 HEAD)"
echo "分支状态: $(git rev-parse --abbrev-ref HEAD)"
echo ""

echo "=== 补丁状态 ==="
echo "补丁总数: $(ls patches/*.patch 2>/dev/null | wc -l)"
echo "最新补丁: $(ls -t patches/*.patch 2>/dev/null | head -1 | xargs basename)"
echo ""

echo "=== 本地化文件状态 ==="
echo "Swift 文件修改: $(git status --short Sources/CodMate | wc -l)"
echo "字符串文件修改: $(git status --short localization/zh-Hans | wc -l)"
echo ""

echo "=== 建议操作 ==="
if [ -n "$(git diff HEAD upstream/main)" ]; then
    echo "需要同步上游更新"
else
    echo "已是最新，无需同步"
fi
```

---

## 故障处理速查表

| 问题 | 症状 | 解决方案 |
|------|------|----------|
| 脚本无法执行 | Permission denied | `chmod +x scripts/*.sh` |
| 补丁应用失败 | patch does not apply | 检查冲突，手动解决 |
| upstream 未配置 | 未配置 upstream 远程仓库 | `git remote add upstream ...` |
| 工作目录不干净 | cannot pull with uncommitted changes | `git stash` 或提交更改 |
| 编译错误 | 代码有语法错误 | 回滚到上一个提交 |

---

## 资源链接

- [详细补丁管理指南](PATCH-MANAGEMENT.md)
- [本地化键名参考](localization-keys.json)
- [快速开始指南](../快速开始.md)

---

**祝你工作顺利！** 🚀

记住：定期备份、有问题及时回滚、测试后再推送。
