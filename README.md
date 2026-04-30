# Auto-PR Workflow

**教 AI Agent 自主提交高质量 PR 的方法论。**

不是自动化脚本，不是 CLI 工具 — 是一套让 Agent 像资深贡献者一样思考、分析、执行的工作流。

## 核心原则

1. **先理解，再动手** — 不读完 README/CONTRIBUTING/CI 不写一行代码
2. **最小修复** — 改动越小越容易被 merge，不要顺手重构
3. **维护者视角** — 每个 PR 都在增加维护者的审查负担，你的 PR 必须值得
4. **诚实透明** — PR 描述说清楚改了什么、为什么、怎么验证，不夸大
5. **知道何时不 PR** — 项目明确拒绝 AI PR、没有真实痛点、改动有风险 → 停下来
6. **合并率是唯一硬指标** — < 10% 就停止提交，先推已有 PR 合并

## 工作流

```
深度分析项目（README、CONTRIBUTING、CI、Issues、代码）
    │
    ▼
维护者友好度评估（该项目接受 AI PR 吗？）
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
结构化复盘 + 更新方法论
```

## 信任梯度

Agent 应该像一个有礼貌的新贡献者一样，渐进式建立信任：

| 接触次数 | 贡献类型 | 风险 |
|----------|---------|------|
| 第一次 | 文档修复 / Typo 修正 | 零风险，建立存在感 |
| 第二次 | 补充测试用例 | 低风险，展示技术能力 |
| 第三次+ | 修复 Bug（有复现步骤） | 中风险，此时已有信任基础 |

## 安装

```bash
hermes skills install https://raw.githubusercontent.com/KuaaMU/auto-pr-workflow/main/skills/auto-pr-workflow/SKILL.md -y
```

适用于任何支持 Skill 的 Agent 框架。核心方法论在 `skills/auto-pr-workflow/SKILL.md`，也可以直接阅读后手动执行。

## 项目结构

```
auto-pr-workflow/
├── skills/
│   └── auto-pr-workflow/
│       ├── SKILL.md              # 核心方法论（v3.1.0）
│       └── templates/            # CodeRabbit、PR 模板等
├── anti-patterns/                # 14 个失败模式（从真实 PR 中提取）
│   └── README.md
├── projects-registry.yml         # 项目画像注册表（哪些项目接受 AI PR）
├── templates/
│   └── review-template.yaml      # 结构化复盘模板
├── test-records/                 # 案例库
└── README.md
```

## 战略原则

**做减法再做加法**：合并率 < 10% 时，停止提交新 PR，优先推动已有 PR 合并。

| 合并率 | 策略 |
|--------|------|
| < 10% | 停止新 PR，全力跟踪现有 PR |
| 10-30% | 放慢节奏，增加跟踪频率 |
| > 30% | 可以继续提交 |

## 真实案例（27 个 PR）

| 状态 | 数量 | 比例 |
|------|------|------|
| ✅ Merged | 1 | 3.7% |
| 🟢 Open | 23 | 85.2% |
| 🔴 Closed | 3 | 11.1% |

| 日期 | 项目 | 语言 | 结果 |
|------|------|------|------|
| 2026-04-30 | [tod-org/tod](https://github.com/tod-org/tod) | Rust | ✅ Merged |
| 2026-04-30 | [PostHog/posthog-js](https://github.com/PostHog/posthog-js) | TS | 🟢 Review positive |
| 2026-04-30 | [rtk-ai/rtk](https://github.com/rtk-ai/rtk) | — | 🟢 CLA signed |
| 2026-04-30 | [progrium/go-basher](https://github.com/progrium/go-basher) | Go | 🔴 Maintainer merged different impl |

**详细记录**：[test-records/](./test-records/)　|　**失败模式**：[anti-patterns/](./anti-patterns/)

## 与竞品的区别

| | Qodo Merge / CodeRabbit | Sweep / Devin | Auto-PR Workflow |
|-|------------------------|---------------|-----------------|
| 主体 | CLI / 服务 | Agent | Skill（方法论） |
| 思考方式 | 固定流程 | 任务执行 | 深度分析 + 自主决策 |
| 适用场景 | 代码审查 | 自动修复 | 开源贡献全流程 |
| 独立运行 | ✅ | ✅ | 需要 Agent 框架 |

## License

MIT
