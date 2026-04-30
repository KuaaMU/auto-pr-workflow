# Auto-PR Workflow

**教 AI Agent 自主提交高质量 PR 的方法论。**

不是自动化脚本，不是 CLI 工具 — 是一套让 Agent 像资深贡献者一样思考、分析、执行的工作流。

## 核心理念

```
Agent 是大脑 — 分析、决策、判断、执行
工具是基础设施 — gh、git、Claude Code
```

**与竞品的区别**：
- **Qodo Merge / CodeRabbit**：固定流程 → 模板填充
- **Auto-PR Workflow**：深度分析 → 自主决策 → 高质量 PR

## 工作流

```
深度分析项目（README、CONTRIBUTING、CI、Issues、代码）
    │
    ▼
制定策略（什么 PR 有价值、什么会被拒绝）
    │
    ▼
调用 Claude Code 执行代码工作（小任务、精确指令）
    │
    ▼
自审 + 测试（第二个实例审查，覆盖并发/崩溃/边界）
    │
    ▼
提交 PR + 监控 CI
    │
    ▼
回应审查反馈 + 修复
    │
    ▼
记录结果 + 更新方法论
```

## 安装

```bash
hermes skills install https://raw.githubusercontent.com/KuaaMU/auto-pr-workflow/main/skills/auto-pr-workflow/SKILL.md -y
```

适用于任何支持 Skill 的 Agent 框架。核心方法论在 `skills/auto-pr-workflow/SKILL.md`，也可以直接阅读后手动执行。

## 高价值 PR 方向

| 方向 | 价值 | 风险 |
|------|------|------|
| 修复真实 Bug | ⭐⭐⭐ | 低 |
| 补充测试用例 | ⭐⭐⭐ | 低 |
| 修复 CI 遗漏 | ⭐⭐⭐ | 低 |
| 文档修正/完善 | ⭐⭐ | 极低 |
| 安全漏洞修复 | ⭐⭐⭐⭐ | 低 |

**低价值方向**（常被拒绝）：通用模板填充、未讨论的新功能、引入新依赖。

## 战略原则

**做减法再做加法**：合并率 < 10% 时，停止提交新 PR，优先推动已有 PR 合并。

| 合并率 | 策略 |
|--------|------|
| < 10% | 停止新 PR，全力跟踪现有 PR |
| 10-30% | 放慢节奏，增加跟踪频率 |
| > 30% | 可以继续提交 |

## 真实案例

| 日期 | 项目 | 语言 | 结果 |
|------|------|------|------|
| 2026-04-30 | [tod-org/tod](https://github.com/tod-org/tod) | Rust | ✅ Merged |
| 2026-04-30 | [PostHog/posthog-js](https://github.com/PostHog/posthog-js) | TS | 🟢 Review positive |
| 2026-04-30 | [chadbyte/clay](https://github.com/chadbyte/clay) | — | PR submitted |

**详细记录**：[test-records/](./test-records/)

## 项目结构

```
auto-pr-workflow/
├── skills/
│   └── auto-pr-workflow/
│       ├── SKILL.md          # 核心方法论
│       └── templates/        # 配置模板（CodeRabbit、PR 模板等）
├── test-records/             # 案例库
├── .github/                  # 项目自身 CI
└── README.md
```

## License

MIT
