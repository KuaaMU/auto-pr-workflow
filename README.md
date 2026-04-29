# Auto-PR Workflow 🔄

**教你的 Agent 自主提交高质量 PR 的能力。**

不是固定脚本，而是 Agent 的思维方式。

## ✨ 核心理念

```
Skill 是大脑 — 教 Agent 分析、决策、判断
CLI 是手脚 — 帮 Agent 检查、执行、提交
```

**其他工具**：CLI 为主体，Agent 调用 CLI → 固定流程 → 模板填充  
**Auto-PR Workflow**：Skill 为主体，Agent 自主思考 → 调用 CLI → 高质量 PR

## 🧠 Agent 工作流

```
Agent 深度分析项目（读代码、文档、CI、Issues）
    │
    ▼
Agent 制定策略（什么 PR 有价值、什么会被拒绝）
    │
    ▼
调用 Claude Code 执行代码工作
    │
    ▼
CLI 辅助检查（语法、lint、测试）
    │
    ▼
提交 PR + 监控 CI
    │
    ▼
回应审查反馈 + 自动修复
    │
    ▼
记录结果 + 学习改进
```

## 🚀 使用方式

### 方式 1: 作为 Skill（推荐）

让 Agent 学会这个能力：

```bash
# Agent 自主执行完整工作流
hermes delegate_task --goal "分析项目 X，提交一个有价值的 PR" \
  --context "使用 auto-pr-workflow skill 的方法论"
```

### 方式 2: CLI 辅助工具

Agent 可以用 CLI 做具体操作：

```bash
auto-pr check     # 本地检查（语法、lint）
auto-pr submit    # 提交 PR
auto-pr watch     # 监控 CI 状态
auto-pr review    # 查看审查反馈
```

**CLI 不做的事**：
- ❌ 不决定提交什么（Agent 决定）
- ❌ 不分析项目（Agent 分析）
- ❌ 不生成内容（Agent 或 Claude Code 生成）

## 🔍 深度分析能力

Agent 学会这个 Skill 后，应该能够：

1. **分析项目架构** — 读 README、CONTRIBUTING、CLAUDE.md
2. **理解贡献政策** — 什么 PR 会被接受、什么会被拒绝
3. **找到真实痛点** — 不是模板填充，而是项目实际需要的
4. **制定 PR 策略** — 基于分析结果选择最高价值方向

### 高价值 PR 方向

| 方向 | 价值 | 风险 |
|------|------|------|
| 修复真实 Bug | ⭐⭐⭐ | 低 |
| 补充测试用例 | ⭐⭐⭐ | 低 |
| 修复 CI 遗漏 | ⭐⭐⭐ | 低 |
| 文档修正/完善 | ⭐⭐ | 极低 |
| 安全漏洞修复 | ⭐⭐⭐⭐ | 低 |

### 低价值方向（常被拒绝）

| 方向 | 问题 |
|------|------|
| 通用模板填充 | 没有分析项目实际需求 |
| 添加新功能 | 大多数项目需要先讨论 |
| 引入新依赖 | 需要维护者同意 |

## 📁 项目结构

```
auto-pr-workflow/
├── skill/                  # 🧠 Agent 的大脑
│   └── SKILL.md            # 工作流方法论
├── cli/                    # 🤖 Agent 的手脚
│   ├── bin/auto-pr         # CLI 入口
│   ├── src/                # 检查、提交、监控
│   └── templates/          # 配置模板
├── test-records/           # 📝 测试记录
│   ├── README.md           # 索引
│   └── *.md                # 具体记录
└── README.md
```

## 🏆 真实案例

| 日期 | 项目 | Stars | 分析深度 | 结果 |
|------|------|-------|---------|------|
| 2026-04-30 | [chadbyte/clay](https://github.com/chadbyte/clay) | 249 | ✅ Agent 自主分析 | [PR#351](https://github.com/chadbyte/clay/pull/351) |

**详细记录**：[test-records/](./test-records/)

## 🤖 与其他工具对比

| 工具 | 主体 | 思考方式 | 结果 |
|------|------|---------|------|
| Qodo Merge | CLI | 固定流程 | 通用审查 |
| CodeRabbit | 服务 | 模式匹配 | 代码建议 |
| Sweep | Agent | 任务执行 | 自动修复 |
| **Auto-PR Workflow** | **Skill** | **深度分析** | **高质量 PR** |

## 📄 License

MIT
