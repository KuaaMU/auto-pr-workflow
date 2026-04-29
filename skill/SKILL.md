---
name: auto-pr-workflow
description: "全自动 PR 提交工作流 — Agent 改代码 → 本地检查 → 创建 PR → AI 审查 → CI 监控 → 自动修复 → Auto-Merge"
version: 1.1.0
author: KuaaMU
license: MIT
metadata:
  hermes:
    tags: [GitHub, PR, Automation, CI/CD, AI-Review, Copilot, CodeRabbit]
    related_skills: [github-pr-workflow, github-code-review, claude-code]
---

# Auto-PR Workflow

全自动 PR 提交工作流，集成 Copilot + CodeRabbit 双重 AI 审查。

## 命令

```bash
auto-pr init      # 初始化项目配置
auto-pr submit    # 提交 PR（本地检查 → 创建 PR → 触发审查）
auto-pr watch     # 监控 CI 并自动修复
auto-pr review    # 手动触发 AI 审查
auto-pr merge     # 启用 auto-merge
auto-pr describe  # 自动生成 PR 描述
```

## 工作流程

```
Agent 改代码 → 本地安全门禁 → 创建 PR → AI 审查 → CI 监控 → 自动修复 → Auto-Merge
```

## 测试记录系统

### 记录目的
- **溯源索引**：追踪每次测试的完整过程
- **项目宣传**：真实案例展示工具能力
- **举例子**：新用户通过案例快速理解

### 记录规范
```bash
# 创建新测试记录
cp test-records/template.md test-records/YYYY-MM-DD_project-name.md

# 填写测试记录
# 1. 测试元数据（日期、类型、耗时）
# 2. 目标项目信息（仓库、语言、Star数）
# 3. 执行日志（每个阶段的命令和结果）
# 4. 问题记录（症状、根因、解决方案）
# 5. 结论和改进建议
```

### 记录索引
所有测试记录在 `test-records/README.md` 中维护索引表：
```markdown
| Date | Project | Language | Stars | Test Type | Result | PR |
|------|---------|----------|-------|-----------|--------|-----|
| 2026-04-30 | chadbyte/clay | JavaScript | 249 | init + submit | ✅ | #N |
```

### 与 Hermes 集成
```bash
# 自动记录测试结果
hermes delegate_task --goal "执行测试并记录" --context "运行 auto-pr test --record"
```

## 与 Hermes 集成

### 调度监控
```bash
# 每 5 分钟检查 CI 状态
hermes cronjob create --schedule "*/5 * * * *" --prompt "auto-pr watch"
```

### 自动修复
```bash
# CI 失败时自动修复
hermes delegate_task --goal "修复 CI 失败" --context "运行 auto-pr watch"
```

## 详细文档

- [CLI 文档](../cli/README.md)
- [测试记录](../test-records/README.md)
- [项目主页](https://github.com/KuaaMU/auto-pr-workflow)
