---
name: auto-pr-workflow
description: "全自动 PR 提交工作流 — Agent 改代码 → 本地检查 → 创建 PR → AI 审查 → CI 监控 → 自动修复 → Auto-Merge"
version: 1.0.0
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
- [项目主页](https://github.com/KuaaMU/auto-pr-workflow)
