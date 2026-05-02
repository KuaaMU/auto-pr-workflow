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
│       ├── SKILL.md              # 核心方法论（v3.12.0）
│       ├── PR-LOG.md             # PR 提交记录
│       ├── scripts/
│       │   └── batch-pr-audit.py # 批量 PR 审计脚本
│       └── references/           # 详细文档
│           ├── anti-patterns.md  # 20+ 失败模式
│           ├── gh-cli-quirks.md  # GitHub CLI 坑点
│           ├── rust-clippy-patterns.md
│           └── ...
├── test-records/                 # 案例库
└── README.md
```

## 批量 PR 审计

内置 `batch-pr-audit.py` 脚本，自动监控所有 open PR：

```bash
python3 scripts/batch-pr-audit.py
```

功能：
- 扫描所有 open PR，检查 CI、review、mergeable 状态
- 检测新合并/关闭的 PR（支持 squash merge）
- 按优先级分类事件（critical → high → medium）
- 计算合并率，低于 10% 时报警
- 输出结构化报告供 Agent 决策

## 战略原则

**做减法再做加法**：合并率 < 10% 时，停止提交新 PR，优先推动已有 PR 合并。

| 合并率 | 策略 |
|--------|------|
| < 10% | 停止新 PR，全力跟踪现有 PR |
| 10-30% | 放慢节奏，增加跟踪频率 |
| > 30% | 可以继续提交 |

## 实战统计（37 个 PR）

| 状态 | 数量 | 比例 |
|------|------|------|
| ✅ Merged | 8 | 21.6% |
| 🟢 Open | 23 | 62.2% |
| ❌ Closed | 6 | 16.2% |

### 已合并的 PR

| 项目 | PR | 描述 | 语言 |
|------|-----|------|------|
| tod-org/tod | #1577 | once_cell → std::sync::LazyLock | Rust |
| kontext-security/kontext-cli | #88 | heartbeat exponential backoff | Go |
| go-openapi/runtime | #422 | literal colons in URL paths | Go |
| esengine/reasonix | #62 | unit tests for clipboard.ts | TS |
| garritfra/cell | #85 | escape quotes/backslashes | Go |
| entireio/cli | #1086 | agent-neutral wording | Go |
| bytecodealliance/wrpc | #1170 | Unix Domain Socket transport | Rust |
| facebook/openzl | #702 | ZL_free instead of free | C |

### 语言分布

| 语言 | 数量 |
|------|------|
| Go | 9 |
| TypeScript | 7 |
| Rust | 6 |
| C | 4 |
| C++ | 2 |
| Python | 2 |

**详细记录**：[PR-LOG.md](./skills/auto-pr-workflow/PR-LOG.md)　|　**案例库**：[test-records/](./test-records/)

## 关键教训

| 教训 | 来源 |
|------|------|
| 必须先开 Issue 讨论再提交实现 | config-rs #751 |
| 测试必须验证真实逻辑而非 Mock 行为 | dali2mqtt #72 |
| Fork PR 必须从干净 upstream 分支创建 | rtk #1645 |
| 自审必须覆盖错误路径和并发场景 | dingo #86 |
| squash merge 不一定设置 mergedAt | openzl #702 |

## 与竞品的区别

| | Qodo Merge / CodeRabbit | Sweep / Devin | Auto-PR Workflow |
|-|------------------------|---------------|-----------------|
| 主体 | CLI / 服务 | Agent | Skill（方法论） |
| 思考方式 | 固定流程 | 任务执行 | 深度分析 + 自主决策 |
| 适用场景 | 代码审查 | 自动修复 | 开源贡献全流程 |
| 独立运行 | ✅ | ✅ | 需要 Agent 框架 |

## License

MIT
