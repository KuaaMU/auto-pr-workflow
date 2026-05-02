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

---

## 安装

### 方式一：Hermes Agent（推荐）

```bash
hermes skills install https://raw.githubusercontent.com/KuaaMU/auto-pr-workflow/main/skills/auto-pr-workflow/SKILL.md -y
```

### 方式二：手动安装

```bash
git clone https://github.com/KuaaMU/auto-pr-workflow.git
cd auto-pr-workflow
# 核心方法论在 skills/auto-pr-workflow/SKILL.md
```

### 前置依赖

- Git
- GitHub CLI (`gh`) 并登录
- Python 3.8+（用于批量审计脚本）
- Claude Code 或其他 AI Agent 框架

```bash
# 安装 GitHub CLI
brew install gh  # macOS
# 或
sudo apt install gh  # Ubuntu

# 登录 GitHub
gh auth login
```

---

## 使用教程

### 1. 单次执行：提交一个 PR

#### 方式 A：让 Agent 自主执行

```bash
# 使用 Hermes Agent
hermes delegate_task --goal "分析项目 X，提交一个有价值的 PR" \
  --context "使用 auto-pr-workflow skill 的方法论"
```

#### 方式 B：指定具体项目和 Issue

```bash
hermes delegate_task --goal "为 warpdotdev/warp 修复 Issue #9745" \
  --context "
项目：warpdotdev/warp (Rust, ⭐51K)
Issue：#9745 - Add Hermes CLI agent detection
要求：
1. 先读 CONTRIBUTING.md 和 AGENTS.md
2. 检查是否有 .agents/ 目录（AI 友好项目）
3. 用 auto-pr-workflow skill 的方法论执行
4. 提交后更新 PR-LOG.md
"
```

#### 方式 C：并发提交多个 PR

```bash
hermes delegate_task --role orchestrator --tasks '[
  {
    "goal": "为 projectA 提交 PR",
    "context": "项目语言: Go, Issue: #123, 修复方案: ...",
    "toolsets": ["terminal", "file"]
  },
  {
    "goal": "为 projectB 提交 PR",
    "context": "项目语言: Rust, Issue: #456, 修复方案: ...",
    "toolsets": ["terminal", "file"]
  }
]'
```

### 2. 批量 PR 审计

检查所有 open PR 的状态：

```bash
# 进入 skill 目录
cd ~/.hermes/skills/auto-pr-workflow

# 运行审计脚本
python3 scripts/batch-pr-audit.py
```

输出示例：
```
🔍 Fetching open PRs... (2026-05-02 10:00 UTC)
Found 26 external open PRs

============================================================
📊 PR WATCHDOG REPORT (26 external open PRs)
============================================================

✅ READY TO MERGE (1)
  chenhg5/cc-connect #828 — feat: add DingTalk image message handling
    CI: 5/5 passing | https://github.com/chenhg5/cc-connect/pull/828

⚠️ NEEDS ACTION (2)
  delucis/astro-og-canvas #172 — docs: add bgImage usage examples
    Changes requested by: ['delucis']
  PostHog/posthog-js #3508 — fix: consume fetch response body
    CI: 7 real failures

📭 NO ACTIVITY (16)
  ...

Summary: ✅1 ⚠️2 💬7 🔀0 💤0 📭16
```

### 3. 持续监控（Cron Job）

设置定时任务自动监控 PR 状态：

```bash
# 创建 cron job，每 2 小时检查一次
hermes cronjob create \
  --name "PR 状态复查" \
  --schedule "0 */2 * * *" \
  --prompt "
你是 PR 监控 Agent。运行 batch-pr-audit.py 脚本检查所有 open PR。

如果有以下事件，通知用户：
- ✅ PR 被合并
- ❌ CI 持续失败
- ⚠️ 维护者请求修改
- 🔀 合并冲突

无事件时只回复：✅ PR 状态正常，无需干预。
" \
  --skills '["auto-pr-workflow"]' \
  --deliver telegram
```

### 4. 查看 PR 记录

```bash
# 查看 PR-LOG.md
cat ~/.hermes/skills/auto-pr-workflow/PR-LOG.md

# 查看案例库
ls ~/.hermes/skills/auto-pr-workflow/test-records/
```

### 5. 自定义配置

#### 修改 OWN_REPOS（排除自有仓库）

编辑 `scripts/batch-pr-audit.py`：

```python
OWN_REPOS = {"KuaaMU/omnihive", "KuaaMU/auto-pr-workflow", "KuaaMU/clay"}
```

#### 修改合并率阈值

```python
MERGE_RATE_THRESHOLD = 0.10  # 10%，低于此值报警
```

#### 修改 stale 检测天数

```python
STALE_DAYS = 7  # 超过 7 天无更新视为 stale
```

---

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
│           ├── batch-pr-audit.md
│           └── ...
├── test-records/                 # 案例库
└── README.md
```

---

## 战略原则

**做减法再做加法**：合并率 < 10% 时，停止提交新 PR，优先推动已有 PR 合并。

| 合并率 | 策略 |
|--------|------|
| < 10% | 停止新 PR，全力跟踪现有 PR |
| 10-30% | 放慢节奏，增加跟踪频率 |
| > 30% | 可以继续提交 |

---

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

---

## 关键教训

| 教训 | 来源 |
|------|------|
| 必须先开 Issue 讨论再提交实现 | config-rs #751 |
| 测试必须验证真实逻辑而非 Mock 行为 | dali2mqtt #72 |
| Fork PR 必须从干净 upstream 分支创建 | rtk #1645 |
| 自审必须覆盖错误路径和并发场景 | dingo #86 |
| squash merge 不一定设置 mergedAt | openzl #702 |
| C 项目首次构建慢，用 background=true | codebase-memory-mcp #306 |
| git config user.name 必须匹配 GitHub 身份 | daily-api #3836 |

---

## 常见问题

### Q: 如何判断一个项目是否接受 AI PR？

检查以下信号：
1. 有 `.agents/` 或 `AGENTS.md` 文件
2. CONTRIBUTING.md 提到 "you can use any coding agent"
3. 有 `ready-to-implement` 或 `good first issue` 标签
4. 近期有 AI agent 提交的 PR 被合并
5. 有 AI review bot（Oz、CodeRabbit、Copilot）

### Q: PR 提交后多久能合并？

取决于项目活跃度：
- 活跃项目：1-7 天
- 一般项目：1-4 周
- 不活跃项目：可能永远不合并

建议：14 天无更新的 PR 发一条友好提醒。

### Q: CI 失败怎么办？

1. 检查是否是预期失败（Vercel fork 授权、artifact upload）
2. 运行 `gh run view <RUN_ID> --log-failed` 查看具体原因
3. 修复代码后 push，CI 会自动重跑
4. 如果是基础设施问题，push 空 commit 触发 re-run

### Q: 如何提高合并率？

1. 选择 AI 友好项目
2. 首次贡献只做 docs/typo
3. 修复真实 Bug 而非添加功能
4. 小 PR（< 10 文件）更容易被审查
5. 提供完整的测试覆盖

### Q: 如何处理 CodeRabbit/Copilot 的审查？

1. 先检查反馈是否有效
2. 如果建议合理，修复代码后回复
3. 如果是误报，礼貌解释
4. 添加回归测试是最有力的回应

---

## 与竞品的区别

| | Qodo Merge / CodeRabbit | Sweep / Devin | Auto-PR Workflow |
|-|------------------------|---------------|-----------------|
| 主体 | CLI / 服务 | Agent | Skill（方法论） |
| 思考方式 | 固定流程 | 任务执行 | 深度分析 + 自主决策 |
| 适用场景 | 代码审查 | 自动修复 | 开源贡献全流程 |
| 独立运行 | ✅ | ✅ | 需要 Agent 框架 |

---

## 贡献

欢迎贡献！请先阅读 [CONTRIBUTING.md](./CONTRIBUTING.md)。

## License

MIT
