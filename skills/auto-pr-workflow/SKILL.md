---
name: auto-pr-workflow
description: "Agent 自主提交高质量 PR 的完整能力 — 深度分析项目 → 制定策略 → 调用 Claude Code → 监控 CI → 回应审查"
version: 3.9.0
author: KuaaMU
license: MIT
metadata:
  hermes:
    tags: [GitHub, PR, Agent-Workflow, AI-Review, Autonomous]
    related_skills: [github-pr-workflow, github-code-review, claude-code]
---

# Auto-PR Workflow — Agent Skill

**这个 Skill 教你的 Agent 如何自主提交高质量 PR。**

不是固定脚本，而是 Agent 的思维方式和能力。

## 核心理念

```
Agent 是大脑（分析、决策、判断、执行）
工具是基础设施（gh、git、Claude Code）
```

## 核心原则（Agent 永远记住）

1. **先理解，再动手** — 不读完 README/CONTRIBUTING/CI 不写一行代码
2. **最小修复** — 改动越小越容易被 merge，不要顺手重构
3. **维护者视角** — 每个 PR 都在增加维护者的审查负担，你的 PR 必须值得
4. **诚实透明** — PR 描述说清楚改了什么、为什么、怎么验证，不夸大
5. **知道何时不 PR** — 项目明确拒绝 AI PR、没有真实痛点、改动有风险 → 停下来
6. **合并率是唯一硬指标** — < 10% 就停止提交，先推已有 PR 合并

## 红线：必须暂停并请求人类确认

以下情况 Agent 不得自行决策，必须暂停等待人类确认：

1. **项目明确禁止 AI PR** — CONTRIBUTING.md 或近期 Issues 有相关声明
2. **涉及安全相关代码** — 加密、认证、权限校验
3. **修改 CI/CD 配置** — 可能影响所有贡献者
4. **删除他人代码** — 重构、移除功能
5. **引入新依赖** — 增加维护负担
6. **修改数据库迁移文件** — 不可逆操作
7. **涉及法律敏感内容** — License、版权、专利

**Phase 1 分析时必须检查这些红线。**

## 信任梯度：像人类新手一样建立信任

Agent 应该像一个有礼貌的新贡献者一样，渐进式建立信任：

| 接触次数 | 贡献类型 | 风险 |
|----------|---------|------|
| 第一次 | 文档修复 / Typo 修正 | 零风险，建立存在感 |
| 第二次 | 补充测试用例 | 低风险，展示技术能力 |
| 第三次+ | 修复 Bug（有复现步骤） | 中风险，此时已有信任基础 |

**PR 描述中诚实声明**：首次贡献时附加 "This is my first contribution to this project. Feedback welcome."

**永远不要**：在第一次贡献时就提交代码逻辑改动。

**例外**：如果 Issue 同时满足以下全部条件，首次贡献可以修 Bug：
- 标有 "good first issue" 或 "easy"
- 有明确的复现步骤或参考实现
- 修复范围小（1-3 行核心改动）
- 案例：rikaikun #190 — Issue 有 rikaichamp 的参考实现，修复只改 1 行条件判断

## 工作流程

### Phase 1: 深度分析（Agent 思考）

**必须先理解项目，再动手。**

#### 1.1 项目基本面

```bash
cat README.md           # 项目定位、技术栈
cat CONTRIBUTING.md     # 贡献政策（最关键！）
cat .github/CODEOWNERS  # 维护者
cat LICENSE             # 开源协议
```

#### 1.2 CI 和工具链（验证是否真正可用）

```bash
# CI 配置
ls .github/workflows/
cat .github/workflows/*.yml

# 关键：不要只看配置是否存在，要验证工具是否能运行！
# Node.js 项目
node --test test/*.test.js 2>&1 | head -5   # 测试能否执行
npx eslint . 2>&1 | head -5                  # lint 是否配置

# Python 项目
black --check . 2>&1 | head -5               # 是否解析失败
flake8 . 2>&1 | head -20                     # 行长是否冲突
isort --check . 2>&1 | head -5
```

#### 1.3 项目历史和已有贡献

```bash
gh issue list --limit 10          # 开放的 Issues
gh pr list --state open --limit 10  # 已有的 open PR（关键！）
gh pr list --state merged --limit 5 # 最近合并的 PR
git log --oneline -20             # 最近的提交
```

**关键判断**：
- 这个项目接受什么样的 PR？（有些项目拒绝 feature PR）
- 维护者风格是什么？（solo-maintained vs 社区驱动）
- 什么是真正的痛点？（不是你以为的，是项目实际缺的）
- **已有 PR 在解决什么问题？**（避免重复贡献，找别人没处理的 gap）

#### 1.4 维护者友好度评估（决定是否 PR）

在动手之前，必须评估目标项目对 AI 贡献的接受度：

```bash
# 检查 Issues 中是否有对 AI/bot 的负面态度
gh issue list --limit 30 --search "AI OR bot OR automated OR spam" --state closed

# 检查近期关闭的 PR 中是否有 AI 相关的被拒
gh pr list --state closed --limit 20 --search "AI OR automated OR bot"

# 检查 CONTRIBUTING.md 是否明确禁止
grep -i "AI\|automated\|bot\|generated" CONTRIBUTING.md 2>/dev/null

# 检查维护者数量（solo-maintained 更敏感）
gh api repos/{owner}/{repo}/contributors --jq 'length'
```

**评分矩阵**：

| 信号 | 友好度 | 策略 |
|------|--------|------|
| 近期有外部 AI PR 被 merge | ✅ 高 | 正常提交 |
| 无 AI 相关声明，维护者活跃 | 🟡 中 | 首次只做 docs/typo |
| Issues 中有反 bot 言论 | 🔴 低 | 只分析，不提交；或先开 Issue 讨论 |
| CONTRIBUTING.md 明确禁止 | ⛔ 禁止 | 停止，不要尝试 |

**如果友好度为 🟡 或 🔴**：遵循"信任梯度"策略，首次接触只做最低风险贡献。

### Phase 2: 制定策略（Agent 决策）

**先评估工作环境，再选项目。**

#### 2.0 环境评估（选项目前必须）

```bash
# 语言工具链
which cargo && cargo --version     # Rust
which python3 && python3 --version # Python
which node && node --version       # Node
which go && go version             # Go
which deno && deno --version       # Deno (some TS projects use this)

# 基础设施
docker info 2>&1 | head -1         # Docker 是否可用
df -h / | tail -1                  # 磁盘空间
free -h | head -2                  # 内存

# 网络
curl -s --connect-timeout 5 https://github.com > /dev/null && echo "GitHub OK" || echo "GitHub blocked"
```

**环境决定选择：**

| 环境条件 | 可选项目类型 |
|---------|-------------|
| 有 Docker | 任何项目（含 E2E 测试） |
| 无 Docker | 只选纯单元测试的项目 |
| 磁盘 < 2GB | 只选小项目（< 1MB） |
| 磁盘 > 10GB | 大项目也行 |
| 有 Rust 工具链 | 可选 Rust 项目 |
| 无 Rust 工具链 | 跳过 Rust |
| 有 Deno | 可选 Deno TS 项目 |
| 无 Deno 且安装超时 | 跳过 Deno 项目，或分析代码后提交（CI 会验证） |

**识别 Deno 项目**：有 `deno.json` 而不是 `package.json`，CI 用 `deno task` 而不是 `npm test`。

**不要硬编码限制，让环境说话。**

#### 2.1 项目大小过滤（避免 clone 超时）

搜索项目时加 `size:<5000`（KB）过滤大仓库：
```bash
gh search repos --language=TypeScript --sort=updated --limit 20 \
  "stars:100..500 pushed:>2026-04-15 size:<5000" \
  --json fullName,stargazersCount,openIssuesCount,size
```

**超时经验值**：
| 仓库大小 | clone 耗时 | 可行性 |
|----------|-----------|--------|
| < 2MB | < 5s | ✅ 理想 |
| 2-5MB | 5-15s | ✅ 可接受 |
| 5-15MB | 15-60s | ⚠️ 可能超时，用 `--depth 1` |
| > 15MB | > 60s | ❌ 大概率超时，跳过 |

**案例**：opentabs-dev/opentabs（450⭐）clone 在 60s 超时，而 newtype-ai/nit（193⭐, 626KB）瞬间完成。

#### 2.2 高价值方向（通常被接受）

**选择方向时，先问：这个项目的测试能在我的环境跑吗？**

| 方向 | 价值 | 风险 |
|------|------|------|
| 修复真实 Bug | ⭐⭐⭐ | 低 |
| 补充测试用例 | ⭐⭐⭐ | 低 |
| 修复 CI 遗漏 | ⭐⭐⭐ | 低 |
| 修复工具配置（lint/format） | ⭐⭐⭐ | 极低 |
| 文档修正/完善 | ⭐⭐ | 极低 |
| 安全漏洞修复 | ⭐⭐⭐⭐ | 低 |

#### 2.3 低价值方向（常被拒绝）

| 方向 | 问题 |
|------|------|
| 通用模板填充 | 没有分析项目实际需求 |
| 添加新功能 | 大多数项目需要先讨论 |
| 引入新依赖 | 需要维护者同意 |
| 代码风格重构 | 主观性强，容易被拒 |

#### 2.4 策略选择原则

1. **先读 CONTRIBUTING.md** — 了解项目接受什么
2. **找真实痛点** — 不是你觉得缺的，是项目实际需要的
3. **小而精** — 一个 PR 做一件事
4. **可验证** — 有测试、有证据、可复现
5. **找没人处理的 gap** — 先检查 open PR 列表：
   - 如果 Issue #X 已有 PR 在处理 → 不要重复，转向其他方向
   - 如果多个显而易见的问题都有人做了 → 深挖配置/工具/文档层面的问题
   - **独特价值 > 重复贡献** — 别人没做的、但项目确实需要的，才是最好的 PR 方向
6. **验证工具是否真的能用** — 不要只看配置文件存在就假设工具可用：
   - 实际运行 `black --check .`、`flake8 .`、`node --test` 看是否报错
   - 配置错误（如 wrong target-version）比缺少配置更隐蔽、更有修复价值

### Phase 3: 执行（对比学习 → 编码 → 自审）

**三步走：先学再写，写完再审。**

#### 3.1 对比学习（编码前必须）

**先看项目里类似的高质量代码，再写自己的。**

LLM 缺乏工程直觉，但擅长模仿。让项目自己的代码成为最好的老师。

```bash
# 找到项目中与你要修改的代码类似的模块
# 比如要修文件操作 → 找项目里其他文件操作的代码
# 比如要加测试 → 找项目里已有的测试风格

# 读 3-5 个相关文件，学习：
# - 错误处理方式（返回 error？log.Fatal？panic？）
# - 资源清理模式（defer？committed flag？）
# - 函数签名风格（参数顺序、返回值）
# - 测试风格（table-driven？独立函数？）
```

**关键：把参考代码作为 context 传入 Claude Code。**

不是"让它自己找"，而是"你读完后告诉它"。LLM 不会主动去看别的文件，但你把参考代码贴进 context，它会模仿。

```bash
# 步骤：
# 1. 你自己先读相关文件，提取关键模式
# 2. 把模式作为 context 传入 delegate_task
# 3. context 中明确要求："参考这个模式写代码"

delegate_task --goal "修复 bug X" \
  --context "
参考代码（项目中类似功能的实现模式）：
\`\`\`python
# 来自 runtime/session/manager.py — 资源清理模式
try:
    stdout_log.close()
    stderr_log.close()
except (OSError, ValueError):
    pass
\`\`\`

要求：
1. 遵循上述模式（catch OSError + ValueError）
2. 在 terminate() 之前关闭所有 pipes
3. 加测试验证修复有效
"
```

**为什么必须这样做**：实测证明，不传参考代码时，Claude Code 只给最小修复（只 catch OSError）。传了参考代码后，它会模仿完整的错误处理模式（catch OSError + ValueError）。

#### 3.2 编码

**Claude Code 是工程师，不是架构师。给它小任务，不给大任务。**

```
❌ "分析这个项目的持久化机制，找到 bug 并修复"  → 超时
✅ "读 /path/to/file.rs 第 200-250 行，这个函数有没有关闭 stdout?"  → 15秒
✅ "在 test_xxx.rs 里加一个测试，验证 DB instance 重启后还在"  → 15秒
```

**任务粒度规则：**

| 维度 | ✅ 正确 | ❌ 错误 |
|------|---------|---------|
| 文件范围 | 1-2 个文件 | "分析整个项目" |
| 问题类型 | 具体问题 | "找到 bug" |
| 输出要求 | 明确（报告/代码/测试） | 模糊（"分析一下"） |
| 工具限制 | 指定用哪些工具 | 让它自己选 |

**验证有效的任务模板（config-rs 实测）：**

```bash
# 你已经分析完根因，让 Claude Code 只做执行
delegate_task \
  --goal "在 src/de.rs 的 MapAccess::new 函数里，对 entries 按 key 排序" \
  --context "
当前代码：
\`\`\`rust
fn new(table: Map<String, Value>) -> Self {
    Self { elements: table.into_iter().collect() }
}
\`\`\`
改为：
\`\`\`rust
fn new(table: Map<String, Value>) -> Self {
    let mut elements: VecDeque<(String, Value)> = table.into_iter().collect();
    elements.make_contiguous().sort_by_key(|(k, _)| k.clone());
    Self { elements }
}
\`\`\`
加测试：跑 20 次 adjacently tagged enum 反序列化，验证每次都成功。
跑 cargo test 验证。
" \
  --toolsets '["file", "terminal"]'
```

**关键区别：**
- ❌ "找到 bug 并修复" → Claude Code 做决策，可能走偏
- ✅ "这个函数改成这样" → 你做决策，Claude Code 只执行

**超时对策：**
- 600 秒超时 = 任务太大，拆成更小的块
- 连续 2 次超时 = 换策略（自己分析，只让 Claude Code 写代码）

```bash
# 用 Claude Code 分析并编写代码
delegate_task --goal "为项目 X 修复 Y bug" \
  --context "项目使用 [语言/框架]，风格要求... 先读 [文件路径] 学习项目风格"
```

#### 3.3 代码自审（提交前必须）

**用第二个 Claude Code 实例审查第一个的代码。**

```bash
# 读取生成的 diff
git diff > /tmp/pr-diff.patch

# 用新实例审查
delegate_task --goal "审查这个 PR diff，找出遗漏的问题" \
  --context "这是一个 [bug修复/功能补充] 的 PR。请重点检查：
  1. 并发场景：多个进程同时运行会出问题吗？
  2. 崩溃场景：进程中途退出，留下什么状态？
  3. 边界条件：文件不存在、权限不足、磁盘满？
  4. 测试覆盖：有没有测试验证修复的有效性？
  5. 风格一致：和项目其他代码风格一致吗？
  diff 内容：[贴入 diff]"
```

#### 3.4 修复循环（自审发现问题时必须）

**自审发现的问题 → 自动修复 → 重新自审，直到通过。**

不要手动修！把自审结果反馈给编码 agent，让它修。

```bash
# 循环直到自审通过（最多 3 轮）
for i in 1 2 3; do
  # 自审
  review=$(delegate_task --goal "审查 diff，列出所有问题" \
    --context "[贴入当前 diff]")

  # 检查是否有问题
  if echo "$review" | grep -q "Approve"; then
    break  # 自审通过
  fi

  # 把自审结果反馈给编码 agent 修复
  delegate_task --goal "根据审查反馈修复代码" \
    --context "
  当前 diff：[贴入 diff]
  审查反馈：[贴入 review 结果]
  要求：修复所有指出的问题，保持现有正确部分不变。
  "
done
```

**为什么必须这样做**：实测证明，自审能发现编码 agent 的盲区（如漏 catch ValueError、测试覆盖不足）。但自审只发现问题不修问题 — 必须有修复循环把两者串联。

**循环上限**：3 轮。如果 3 轮后仍有问题，可能是审查太严格或问题太复杂，人工介入。

#### 3.5 本地检查与提交

```bash
# 本地检查
node --test test/      # 运行测试
# lint / format 按项目配置执行

# 提交 PR（直接使用 gh CLI）
# fork → branch → commit → push → gh pr create
```

#### 3.6 PR 描述模板（强制使用）

PR 描述是维护者第一眼看到的东西，必须高信息密度、低认知负荷：

```
## Summary
[一句话说明改了什么，不超过 20 字]

## Motivation
[链接到具体 Issue，或描述复现步骤]

## Changes
- 具体改动 1
- 具体改动 2

## Verification
[如何验证这个改动有效，提供命令或步骤]
```

**禁止写**：
- "This PR improves performance"（没有数据支撑）
- "Refactored for better readability"（主观判断）
- "AI generated"（不需要主动说，但被问到要诚实回答）

### Phase 4: 监控与修复（Agent 循环）

```bash
# 监控 CI（本地仓库）
gh pr checks <PR#> --watch

# 监控 CI（跨仓库，fork PR 必须用 --repo）
gh pr checks <PR#> --repo <owner/repo>

# CI 失败时，Agent 分析原因并修复
gh run view <RUN_ID> --log-failed

# 回应审查反馈 — 关键：同时检查 mergeStateStatus
gh pr view <PR#> --repo <owner/repo> --json reviews,mergeable,mergeStateStatus

# 检查 inline review comments（CodeRabbit、Copilot 等）
gh api repos/<owner>/<repo>/pulls/<PR#>/comments --jq '.[] | {user: .user.login, body: .body[:200], path: .path}'

# 回复 Copilot/CodeRabbit 的 inline comment
gh api repos/<owner>/<repo>/pulls/comments/<COMMENT_ID>/replies --method POST -f body="Your reply here"

# 根据 review 修改代码，再次提交
```

**mergeStateStatus 含义（必须检查）**：

| mergeStateStatus | 含义 | 需要行动？ |
|-----------------|------|-----------|
| `CLEAN` | 所有检查通过，可合并 | ✅ 等维护者 merge |
| `BLOCKED` | 有 required check 未通过 | ⚠️ 见下方分析 |
| `BEHIND` | PR 分支落后于 base，需要 rebase | 🔄 `git rebase main && push` |
| `CONFLICTING` | 有合并冲突 | 🔧 解决冲突（见 Phase 4.1） |
| `UNKNOWN` | GitHub 还在计算状态 | ⏳ 等几分钟再查 |

**BLOCKED 但 APPROVED 的特殊情况**：

当 `reviewDecision: APPROVED` 但 `mergeStateStatus: BLOCKED` 时，通常是 required deployment check 失败（Vercel、Netlify 等）。这是 fork PR 的预期行为——部署服务不授权 fork PR。

```bash
# 诊断：检查哪些 required check 失败
gh pr checks <PR#> --repo <owner/repo> | grep -E "fail|action_required"
```

**案例（PostHog/posthog-js #3508）**：APPROVED by maintainer，但 Vercel deployment check 持续 BLOCKED。维护者可以用 admin override 合并，或调整 branch protection。无需 contributor 行动。

#### 4.1 合并冲突解决（PR 变成 CONFLICTING 时）

**问题**：PR 创建后 main 分支继续前进，PR 变成 `mergeable: CONFLICTING`。

**诊断**：
```bash
gh pr view <PR#> --json mergeable  # CONFLICTING / MERGEABLE / UNKNOWN
git merge --no-commit --no-ff origin/main 2>&1 | grep "CONFLICT"  # 看哪些文件冲突
```

**解决策略（按冲突类型）**：

| 冲突类型 | 策略 | 示例 |
|---------|------|------|
| 格式化/import 变更 | 用 incoming（main）版本 | main 重构了 import 排序 |
| 实质性代码修复 | 保留 HEAD（你的 PR）版本 | shell 死锁修复、安全加固 |
| 两边都改了同一函数 | 手动合并：main 的格式 + HEAD 的逻辑 | 函数签名变了但逻辑保留 |

**委托解决流程**（冲突 > 3 个文件时）：
```bash
# 1. 浅克隆 + fetch PR 分支
git clone --depth 5 https://github.com/OWNER/REPO.git
git remote set-branches origin '*'
git fetch origin <pr-branch> main
git checkout -b <pr-branch> origin/<pr-branch>

# 2. 合并 main
git merge origin/main  # 会产生冲突

# 3. 委托 subagent 解决
delegate_task --goal "解决所有合并冲突" --context "
冲突文件列表：[列出]
策略：格式化/import 用 incoming，实质性修复用 HEAD
PR 的目的：[描述 PR 做了什么]
"

# 4. 验证 + push
git diff --name-only --diff-filter=U  # 确认无剩余冲突
git push origin <pr-branch>
```

**案例（omnihive #8）**：50 文件的 PR 一个月后产生 8 个冲突文件（20 个冲突标记）。委托 subagent 在 6 分钟内解决，策略正确：格式化用 main，shell 死锁修复和 filesystem 边界加固用 HEAD。

**教训**：大 PR（>20 文件）更容易变成 CONFLICTING，因为 main 的任何触碰都可能冲突。这是"小 PR 原则"的又一个理由。

### Phase 5: 记录与学习

```bash
# 记录测试结果
cp test-records/template.md test-records/YYYY-MM-DD_project.md
# 填写完整记录（分析、策略、执行、结果、学习）
```

## 常见问题与解决方案

### 1. node --test 目录语法错误

**问题**：`node --test test/` 尝试将目录作为模块加载

**解决**：使用 glob 模式
```bash
node --test test/*.test.js
```

### 2. 测试进程挂起

**问题**：测试通过但进程不退出（SQLite、WebSocket 等保持连接）

**解决**：使用 --test-force-exit
```bash
node --test --test-force-exit test/*.test.js
```

### 3. CI 与现有 workflow 重复

**问题**：auto-pr init 生成的 CI 与项目现有 CI 功能重叠

**解决**：
- 先检查 `.github/workflows/` 已有配置
- 选择互补策略，而不是重复
- 优先修复现有 CI 的遗漏

### 4. Python 工具配置陷阱

**问题**：项目配了 black/isort/flake8 但工具实际无法运行

**常见原因**：
- `target-version = ['py38']` 但代码用了 `match/case`（Python 3.10+）→ black 解析失败
- 没有 `.flake8` 文件 → flake8 默认行长 79 vs black 默认 100 → 大量 E501 误报
- `pyproject.toml` 中 `[tool.black]` 配置了 `line-length = 100` 但 flake8 不读 pyproject.toml

**诊断方法**：
```bash
cd <project>
black --check . 2>&1 | head -5    # 看是否解析失败
flake8 . 2>&1 | head -20          # 看行长冲突
isort --check . 2>&1 | head -5
```

**解决**：
- 修复 `target-version` 为代码实际使用的最低版本（有 match/case → py310+）
- 创建 `.flake8` 文件设置 `max-line-length = 100` 匹配 black
- 运行 `black .` 和 `isort .` 自动修复格式问题
- 将修复和 CI 作为同一个 PR 提交（工具修复 + CI 执行 = 完整价值）

### 5. .gitignore 缺失导致脏提交

**问题**：项目没有 `.gitignore`，容易把 `__pycache__/`、`.venv/`、`node_modules/` 等提交进去

**解决**：
```bash
# 提交前检查 staged 文件
git diff --cached --name-only | grep -E '(node_modules|__pycache__|\.venv|\.pyc)'
# 如果有，添加 .gitignore 并 reset
```

### 5c. Embedded Git Repos Staged by `git add -A`

**问题**：工作目录中包含嵌入式 git 仓库（submodules、vendored repos），`git add -A` 会将它们作为 gitlink 条目暂存。

**症状**：
```
warning: adding embedded git repository: repos/consola
hint: You've added another git repository inside your current repository.
```

**解决**：`git reset HEAD` 后选择性添加文件：
```bash
git reset HEAD
git add test-records/ src/  # 只添加需要的文件/目录
# 或者用 git add -p 逐个选择
```

**防御**：在 `.gitignore` 中添加嵌入式仓库目录，或在提交前始终检查 `git diff --cached --stat`。

**案例（2026-05-01 auto-pr-workflow）**：`git add -A` 暂存了 `repos/consola` 和 `vpncloud` 两个嵌入式仓库。需要 `git reset HEAD` + 选择性 `git add` 才能干净提交。

### 5b. Terminal CWD 删除导致所有命令失败

**问题**：Terminal 会话的 CWD 被 `rm -rf` 删除后，所有后续命令都报 `FileNotFoundError`，包括 `cd`、`mkdir`、`echo`。

**症状**：
- 任何命令都返回 `FileNotFoundError: [Errno 2] No such file or directory: '/tmp/deleted-dir'`
- `workdir` 参数也无效（shell 进程的 CWD 已经指向不存在的目录）

**根因**：Shell 进程的 CWD 被删除后，内核无法解析当前工作目录。

**解决**：用 `execute_code`（Python sandbox）重建目录：
```python
from hermes_tools import terminal
terminal("mkdir -p /tmp/deleted-dir")  # 这会失败
# 改用 execute_code
import subprocess
subprocess.run(["mkdir", "-p", "/tmp/deleted-dir"], check=True)
# 之后 terminal 就恢复了
```

**防御**：在 `rm -rf` 一个目录前，确保没有 terminal 会话的 CWD 指向它。或者在 clone 后立即 `cd` 到一个稳定目录（如 `~` 或 `/tmp`）。

**案例（2026-05-01）**：Clone entireio/cli 到 `/tmp/entireio-cli`，失败后 `rm -rf`，导致所有 terminal 命令挂死约 5 分钟直到发现根因。

### 6a. 代理（Proxy）干扰 GitHub API 和 Git

**问题**：环境中配置了 `HTTPS_PROXY` 或 `ALL_PROXY`（如 `socks5://127.0.0.1:54989`），导致 `gh`、`curl`、`git` 对 GitHub 的 TLS 握手超时。

**症状**：
- `gh run list` → `TLS handshake timeout`
- `gh auth status` → `Timeout trying to log in`
- `git fetch` → `gnutls_handshake() failed`
- `curl -s https://api.github.com` → 空响应或 timeout
- `ping github.com` → 成功（说明 DNS 和网络通，但 TLS 被代理拦截）

**诊断**：
```bash
env | grep -i proxy
# 如果看到 ALL_PROXY, HTTPS_PROXY, HTTP_PROXY → 代理在拦截
```

**解决**：在所有 `gh`/`curl`/`git` 命令前 unset 代理变量：
```bash
unset ALL_PROXY HTTPS_PROXY HTTP_PROXY && gh run list --limit 3
unset ALL_PROXY HTTPS_PROXY HTTP_PROXY && git fetch origin
```

**注意**：`git config --global --unset http.proxy` 不够——环境变量优先级更高。必须 `unset` 环境变量。

**案例**：omnihive CI 修复时，所有 GitHub API 调用因代理超时，unset 后立即恢复正常。

### 6b. Git Push 代理超时（curl 通但 git push 不通）

**问题**：`curl -s https://github.com` 成功，但 `git push` 超时：`Failed to connect to github.com port 443 after 133810 ms`。

**根因**：Git 使用不同的代理配置。环境变量 `NO_PROXY` 或 `GOPROXY` 可能干扰 git 的 HTTPS 连接。`git config --global --unset http.proxy` 不够——某些代理设置来自环境变量或系统配置。

**解决**：显式禁用代理：
```bash
git -c http.proxy="" -c https.proxy="" push origin branch-name
```

**案例（2026-05-01）**：Push 到 KuaaMU/cli 超时 60s，`curl` 正常。`git -c http.proxy="" -c https.proxy="" push` 立即成功。环境中有 `NO_PROXY=localhost,127.0.0.1` 和 `GOPROXY=https://mirrors.tencent.com/go,direct`。

**通用规则**：所有 git push/fetch 对 GitHub 的操作，如果超时，先加 `-c http.proxy="" -c https.proxy=""`。

### 6c. 网络超时：clone/install 下载失败

**问题**：在带宽受限环境中，`git clone`、`npm install`、`deno install` 等操作可能超时。

**解决策略**：

| 操作 | 超时对策 |
|------|---------|
| `git clone` | 用 `git clone --depth 1` 浅克隆（rikaikun 实测：完整克隆 60s 超时，浅克隆成功） |
| `npm install` | 跳过本地测试，直接提交让 CI 验证。或者只 `npm install` 需要的包 |
| `deno install` | Deno 二进制下载可能超时。如果无法安装，分析代码后提交，CI 会验证 |
| `curl` 下载大文件 | 用 `wget --timeout=30` 代替，或跳过该步骤 |

**关键原则**：不要因为本地无法运行测试就放弃提交。如果你对代码改动有信心（基于代码分析），提交让 CI 验证。在 PR 描述中说明"Could not run tests locally due to network limitations; CI will verify."

### 6. Go: 理解库 API 语义再设计修复

**问题**：设计修复方案时假设库函数行为，实际行为不同

**案例（go-basher）**：
```go
// 假设 RestoreAsset 可以写入任意文件 → 错误
RestoreAsset(tmpFile, "bash")  // 实际总是写入 dir/name

// 正确理解：RestoreAsset(dir, name) 总是写入 dir/name
// 解决：用临时目录 + os.Rename
tmpDir, _ := os.MkdirTemp(bashDir, "extract-*")
RestoreAsset(tmpDir, "bash")
os.Rename(tmpDir+"/bash", bashPath)
```

**教训**：在编写修复代码前，先确认函数签名和实际行为。特别是嵌入式资源、代码生成工具（go-bindata、embed 等）的 API 可能有隐含约束。

## 📖 案例库：从失败中学到的教训

### 案例 0: Fork-First 工作流（避免 403 错误）

**问题**：在本地 clone 了上游仓库并修改代码后，`git push` 返回 403 错误。

**根因**：没有 push 权限到上游仓库（外部贡献的预期行为）。

**正确流程**：
```bash
# 1. 先 fork
gh repo fork owner/repo --remote=true

# 2. 添加 fork remote
git remote add fork https://github.com/YOUR_USER/repo.git

# 3. 在 fork 上创建分支、push
git checkout -b feature/my-change
git push -u fork feature/my-change

# 4. 从 fork 创建 PR
gh pr create --repo owner/repo --head YOUR_USER:feature/my-change
```

**教训**：先 fork，再 clone。或者 clone 后立即 fork 并添加 remote。

### 案例 1: go-basher PR #61 vs #63 — 最小修复 vs 生产级修复

**背景**：Issue #57 报告 TOCTOU 竞态条件 — 并发首次运行时，多个进程同时写入 bash 二进制文件，导致读到半写的 ELF。

**我们的 PR #61（被关闭）**：
```go
// 最小修复：临时目录 + Rename
tmpDir, _ := os.MkdirTemp(bashDir, "extract-*")
defer os.RemoveAll(tmpDir)
RestoreAsset(tmpDir, "bash")
os.Rename(tmpDir+"/bash", bashPath)
```

**维护者的 PR #63（被合并）**：
```go
// 生产级修复：临时文件 + Sync + Chmod + 孤儿清理 + 并发测试
tmp, _ := os.CreateTemp(dir, "bash.tmp.*")
tmp.Write(data)
tmp.Sync()          // ← 我们缺的：确保数据落盘
tmp.Close()
os.Chmod(tmpName, info.Mode())  // ← 我们缺的：显式设置权限
os.Rename(tmpName, finalPath)
sweepStaleBashTmp(dir, ...)     // ← 我们缺的：孤儿清理
// + 5 个测试（含 16 并发 goroutine 压力测试）  // ← 我们缺的：测试
```

**差距分析**：

| 维度 | 我们 | 维护者 | 缺失原因 |
|------|------|--------|----------|
| Sync 落盘 | ❌ | ✅ | 没考虑断电/崩溃 |
| 权限设置 | ❌ | ✅ | 依赖了 RestoreAsset 的隐含行为 |
| 孤儿清理 | ❌ | ✅ | 只考虑正常流程 |
| 并发测试 | ❌ | ✅ | 没验证修复真的有效 |
| 代码组织 | 内联 | 独立函数 | 可测试性差 |

**根因**：我们给了 Claude Code "修复 TOCTOU" 的指令，但没说"要生产级质量"。Claude Code 给了最小可行修复 — 这是 LLM 的默认行为。

**改进**：
1. 对比学习：先读项目里其他文件操作代码，看它怎么处理 Sync/Cleanup
2. 代码自审：问自己"如果进程崩溃在第 N 行，留下什么状态？"
3. 测试先行：并发修复必须有并发测试

### 案例 2: mco PR #83 — 对比学习 + 自审的价值

**背景**：Issue #82 报告 `AcpTransport.close()` 没关 stdout pipe，导致 ResourceWarning。

**编码阶段（Claude Code 第一次）**：
- 写了正确的修复：关闭 stdout/stderr
- 但只 catch `OSError`，漏了 `ValueError`
- 只测了 stdout 路径，没测 stderr PIPE 路径

**自审阶段（Claude Code 第二次）**：
- 发现并发风险：reader thread 关闭时会触发 `ValueError`
- 发现测试盲区：stderr PIPE 路径没覆盖

**修复阶段（手动 patch）**：
- `except OSError` → `except (OSError, ValueError)`
- 加了 `test_close_no_resource_warning_with_stderr_pipe`

**差距分析**：

| 问题 | 根因 | 改进 |
|------|------|------|
| 只 catch OSError | 没传参考代码 | 对比学习：把 manager.py 的 cleanup 模式作为 context |
| stderr 没测 | 最小修复心态 | 自审：第二个实例检查测试覆盖 |
| 手动修复 | 缺修复循环 | 自动化：自审结果 → 重新编码 → 再审 |

**核心教训**：
1. **对比学习必须传参考代码** — 不是"让它自己找"，而是"你读完后告诉它"
2. **自审有效但需要修复循环** — 审查发现问题 ≠ 自动修复，必须串联
3. **3 步循环**：编码 → 自审 → 修复 → 再审 → 通过

### 案例 3: fakecloud — 项目选择和任务粒度的教训

**背景**：测试 auto-pr-workflow skill，选了 fakecloud（Rust AWS emulator ⭐263）修 RDS 持久化 bug。

**问题**：
1. **项目太大**（17MB）→ Claude Code 分析整个 RDS 持久化时连续 2 次超时（600秒）
2. **需要 Docker** → E2E 测试无法在本机跑
3. **任务太宽泛** → "分析持久化机制"让 Claude Code 读了 30+ 个文件

**正确做法**：
```bash
# ❌ 太宽泛
delegate_task --goal "找到 RDS 持久化 bug 并修复"

# ✅ 拆成小块
delegate_task --goal "读 state.rs，DbInstance 有没有 Serialize" --toolsets '["file"]'
# → 15秒完成

delegate_task --goal "在 rds_persistence.rs 加 DB instance 持久化测试" --toolsets '["file"]'
# → 15秒完成
```

**教训**：
1. **先评估环境再选项目** — 没 Docker 就不要选需要 Docker 的项目
2. **Claude Code 任务必须小而具体** — 1-2 个文件，明确问题，明确输出
3. **超时 = 任务太大，不是 Claude Code 不行** — 拆小就好
4. **分析可以自己做，编码交给 Claude Code** — 分析不需要 Claude Code，写代码才需要

### 案例 4: config-rs — 完整流程的成功案例

**背景**：测试 auto-pr-workflow skill v2.7.0，选了 config-rs（Rust 配置库 ⭐3141）修 adjacently tagged enum 反序列化 bug。

**流程复盘：**

| 步骤 | 做了什么 | 耗时 | 效果 |
|------|---------|------|------|
| 环境评估 | 检查 cargo/python/node/docker | 30s | ✅ 确认有 cargo，无 Docker |
| 选项目 | 基于环境选纯 cargo 项目 | 2min | ✅ 选对了 |
| 对比学习 | 自己读 env.rs + de.rs | 5min | ✅ 找到根因（HashMap 无序） |
| Claude Code 编码 | 给精确任务：改 1 个函数 + 加 1 个测试 | 108s | ✅ 完成，147 测试通过 |
| 自审 | 第二个实例审查 | 66s | ✅ 发现 2 个改进点 |
| 修复 | 应用 style 建议 | 30s | ✅ 手动修复 |
| 提交 PR | fork + push + gh pr create | 30s | ✅ PR #751 |

**成功关键：**

1. **环境评估避免了错误选择** — 有 cargo，无 Docker，选纯 cargo 项目
2. **对比学习是自己做的** — 读了 env.rs 和 de.rs，找到了根因，然后把精确修复方案传给 Claude Code
3. **Claude Code 任务极小** — "改 MapAccess::new 函数，排序 entries，加一个测试"。不是"分析整个反序列化系统"
4. **自审用了第二个实例** — 发现 `sort_by_key` 比 `sort_by` 更简洁

**Claude Code 任务模板（验证有效）：**

```
goal: "在 [文件] 的 [函数] 里做 [具体修改]"
context: "当前代码：[贴代码]。修改为：[贴修改]。加测试验证：[贴测试]"
toolsets: ["file", "terminal"]
```

**关键区别：**
- ❌ "找到 bug 并修复" → Claude Code 做决策，可能走偏
- ✅ "这个函数改成这样" → 你做决策，Claude Code 只执行

**任务精确度光谱（越右越好）：**

| 精确度 | 示例 | 耗时 | 正确率 |
|--------|------|------|--------|
| 低 | "修复 emoji 宽度计算" | 431s | 有 bug |
| 中 | "重写 stringWidth，处理 ZWJ/flag/skin tone" | ~200s | 大概率对 |
| 高 | "改成这段代码，加这个测试" | 108s | 几乎一定对 |

**经验法则**：如果你能写出修复代码，就自己写，只让 Claude Code 写测试。如果你不确定怎么修，才让 Claude Code 决定，但要准备自审。

**对比学习的正确姿势：**
- ❌ 让 Claude Code 自己读项目学模式 → 它不会主动学
- ✅ 你自己读完，把模式作为 context 传入 → 它会模仿
- ✅ 最好直接告诉它改什么 → 跳过学习，直接执行

### 案例 2a: zenc PR #417 — 回应 Copilot 审查 + 添加回归测试

**背景**：PR #417 修复 Drop 类型在未赋值表达式中的内存泄漏。Copilot 提出 3 个审查意见。

**执行过程**：
1. 读取 Copilot 的 3 条 inline comments（通过 `gh api repos/.../pulls/.../comments`）
2. 对每条意见：
   - 评估是否真实有效（不是所有 Copilot 建议都需要采纳）
   - 编写回复（通过 `gh api .../comments/{ID}/replies`）
   - 如果建议合理（如添加回归测试），立即执行
3. 添加回归测试 `test_drop_unassigned.zc` — 验证 `MyResource::new()` 作为裸语句时 drop 被调用
4. 本地运行测试确认通过
5. commit + push
6. 回复 Copilot 说明已添加测试

**关键教训**：
- 回复 Copilot 评论时用 `gh api .../comments/{ID}/replies --method POST -f body="..."`
- 回复中反引号会被 bash 吞掉 — 用 `-f body="..."` 而不是 `-f body='...'`，或者用 heredoc
- 添加回归测试是最有说服力的回应方式 — 代码说话比解释更有力
- 对于 Copilot 的边界情况建议（如 lvalue 表达式、TYPE_FUNCTION），诚实说明当前行为是安全的，defer 到 follow-up

### 案例 2b: mco PR #83 — 自审抓到的真实问题

**背景**：Issue #82 报告 `AcpTransport.close()` 没关 stdout pipe，导致 ResourceWarning。

**编码阶段（Claude Code 第一次）**：
- 修复了 stdout/stderr 关闭
- 加了 1 个测试验证无 ResourceWarning

**自审阶段（Claude Code 第二次）抓到两个问题**：

1. **并发风险**：`except OSError` 不够 — reader thread 关闭时会触发 `ValueError`（I/O operation on closed file）
   - 修复：改为 `except (OSError, ValueError)`

2. **测试覆盖盲区**：默认 `stderr=DEVNULL`，新建的 `stderr.close()` 路径从未被测试
   - 修复：加了 `test_close_no_resource_warning_with_stderr_pipe`，手动构造 `stderr=subprocess.PIPE`

**结果**：PR #83 提交，13/13 测试通过，ResourceWarning 完全消除。

**教训**：
- 自审不是形式 — 它真的能抓到第一个实例的盲点
- 并发 + 异常类型是 LLM 最容易忽略的细节
- 测试路径覆盖要显式检查，不能只看"测试数量"

### 7. CodeRabbit 反馈处理

**问题**：CodeRabbit 提出代码风格或项目规范问题

**解决**：
- 检查项目编码规范文件（如 .github/instructions/）
- 根据反馈更新代码或配置
- 保持与项目现有风格一致

**重要：先检查是否已修复再动手**

CodeRabbit 的 inline comments 是针对 diff 的快照。如果你在第一轮修复后又 push 了新 commit，CodeRabbit 的评论可能已经过时。

**案例（consola #417）**：CodeRabbit 提了 5 条 inline comments（tag-sequence overcount、variation selectors、keycap emoji 等）。子 agent 克隆代码后发现所有问题在之前的 commit 中已经修复，只需要补充测试覆盖和回复评论。

**流程**：
1. 读取所有 CodeRabbit comments
2. 检查当前代码是否已经修复了每个问题
3. 如果已修复 → 只补充测试 + 回复评论说明
4. 如果未修复 → 修复代码 + 回复评论
5. 不要重复修复已经解决的问题

### 7b. Copilot 审查回应策略

**问题**：GitHub Copilot 提出行内审查意见，需要回应

**回应流程**：
1. 先读取所有 comments：`gh api repos/.../pulls/.../comments`
2. 对每条意见评估：是否真实有效？是否需要修复？
3. 如果建议合理（如添加回归测试），**先修复再回复**
4. 回复时说明做了什么修改
5. 如果是边界情况，诚实说明当前行为是安全的，defer 到 follow-up

**最有力的回应方式**：添加回归测试。代码说话比解释更有说服力。

**命令**：
```bash
# 读取 inline review comments
gh api repos/{owner}/{repo}/pulls/{PR#}/comments \
  --jq '.[] | {id: .id, user: .user.login, body: .body[:300], path: .path}'

# 回复某条评论
gh api repos/{owner}/{repo}/pulls/comments/{COMMENT_ID}/replies \
  --method POST -f body="Added regression test that verifies..."
```

**反引号陷阱**：`-f body="..."` 中的反引号会被 bash 解释。用 `-f body='...'`（单引号）或 heredoc：
```bash
gh api repos/{owner}/{repo}/pulls/comments/{ID}/replies \
  --method POST --field body="$(cat << 'EOF'
Good catch! Added test for `MyFunction()` behavior.
EOF
)"
```

**CodeRabbit 安全类反馈的处理策略**：

CodeRabbit 经常报告路径遍历、注入、竞态等安全问题。处理时：
1. 先确认问题是否真实存在（有些是理论性的，实际不可利用）
2. 如果真实，修复时要防御深度 — 不只是修表面，要修根因
3. 修复后加测试验证（安全修复没有测试 = 没有保障）

**案例：Rust 路径解析中的 symlink 逃逸（omnihive #8）**

CodeRabbit 报告 `resolve_path` 函数中，walk-up 分支只对最终路径做 `starts_with` 检查，但 rejoin suffix 时没有逐级 canonicalize 中间组件。如果某个中间路径是 symlink 指向 workspace 外部，`starts_with` 做的是词法前缀匹配，可能误判。

**修复模式**：在 walk-up + rejoin 循环中，每 join 一个组件后检查是否存在并 canonicalize：
```rust
// ❌ 原代码：直接 join 所有 suffix，不做中间 canonicalize
let mut resolved = canon;
for name in suffix.iter().rev() {
    resolved = resolved.join(name);
}

// ✅ 修复：每 join 一个组件，如果存在就 canonicalize
let mut resolved = canon;
for name in suffix.iter().rev() {
    resolved = resolved.join(name);
    if resolved.exists() {
        resolved = std::fs::canonicalize(&resolved).unwrap_or_else(|_| resolved);
    }
}
```

**为什么 `starts_with` 不够**：`Path::starts_with` 做组件级前缀匹配，`/workspace` 是 `/workspace_evil` 的前缀（不同组件），但如果 workspace 本身是 symlink 且 resolved 路径通过不同 symlink chain 构建，可能存在边界情况。逐级 canonicalize 是防御深度的正确做法。

### 9. CI 服务容器遗漏（只检查 setup，没检查 teardown）

**问题**：为项目添加 CI workflow 时，只检查了 `setup.ts` / `setup.py` 的依赖，遗漏了 `teardown.ts` 中需要的服务。

**案例（dailydotdev/daily-api）**：
- `__tests__/setup.ts` 只导入数据库连接 → 只配了 PostgreSQL
- `__tests__/teardown.ts` 导入了 Redis → 需要 Redis 服务容器
- 初始 CI workflow 缺少 Redis → 测试会超时或报连接错误

**诊断方法**：
```bash
# 不只看 setup，也看 teardown
grep -r "import\|require" __tests__/setup.ts __tests__/teardown.ts
# 搜索所有外部连接
grep -r "redis\|mongo\|kafka\|rabbit" __tests__/ --include="*.ts" -l
```

**教训**：CI 服务容器配置必须覆盖 setup + teardown + 测试文件中所有外部依赖。

### 10b. 测试使用固定临时文件名导致 flaky

**问题**：测试使用硬编码文件名（如 `omnihive_nonexistent_12345.txt`）写入共享临时目录（如 `/tmp`），如果该文件恰好已存在，测试会非确定性失败。

**案例（omnihive #8）**：`test_fs_read_nonexistent` 使用 `std::env::temp_dir().join("omnihive_nonexistent_12345.txt")`，如果该文件存在则测试失败。

**解决**：使用基于 PID 的隔离临时目录：
```rust
// ❌ 固定文件名，可能与其他测试或进程冲突
let tmp = std::env::temp_dir();
let path = tmp.join("omnihive_nonexistent_12345.txt");

// ✅ PID 隔离的临时目录，清理后不影响其他进程
let dir = std::env::temp_dir().join(format!("myapp_test_{}", std::process::id()));
let _ = std::fs::create_dir_all(&dir);
// ... use dir.join("nonexistent_file.txt") ...
let _ = std::fs::remove_dir_all(&dir);
```

**通用规则**：
- 测试中的临时文件/目录必须唯一（PID、UUID、或 `tempfile::tempdir()`）
- 测试结束后清理（`defer`/`let _guard`/`remove_dir_all`）
- 不要用固定文件名写入共享目录（`/tmp`、系统 temp dir）

### 10. 测试"不跳过字符"修复时的陷阱

**问题**：修复"当字符 X 在首位时不跳过"的逻辑后，测试 `translate('X')` 返回 null 而不是预期结果。

**根因**：字符 X 可能根本不在字典中。`translate` 在字典查找失败后会跳过 1 个字符继续，最终如果没有匹配就返回 null。这和"被跳过"的最终结果一样——无法区分。

**案例（rikaikun #2978）**：
- 修复：`～`（U+FF5E）在首位时不跳过
- 错误测试：`translate('～')` → null（字典中没有 `～` 条目）
- 正确测试：`translate('～猫')` → 验证 `猫` 被找到（证明 `～` 没有阻止后续查找）

**正确做法**：
```typescript
// ❌ 错误：假设字符本身在字典中
const result = rcxDict.translate('～');
expect(result?.data).to.have.length(1);

// ✅ 正确：用字符 + 已知在字典中的词
const result = rcxDict.translate('～猫');
expect(result?.data).to.have.length(1);
expect(result?.data[0].entry).to.match(/猫/);
```

**后续陷阱（同 PR 第二次 CI 失败）**：
```typescript
// ❌ 错误：改了输入没改断言
const result = rcxDict.translate('～可爱');
expect(result?.data[0].entry).to.match(/猫/);  // ← 断言是旧的！

// ✅ 正确：断言必须匹配当前输入的实际输出
const result = rcxDict.translate('～可爱');
expect(result?.data[0].entry).to.match(/可爱/);
```

**教训**：测试修复时，先验证测试输入是否存在于数据源中。不要假设所有字符都有字典条目。

**续坑 — 输入改了但断言没跟上（rikaikun #2978 CI 失败）**：

第一轮修复把 `translate('～')` 改成 `translate('～猫')`，断言正确。但后来又把输入改成 `translate('～可爱')`，断言仍然是 `/猫/` — CI 报错 `expected '可爱...' to match /猫/`。

**根因**：修改测试输入时，没有同步更新断言。LLM 在多次修改测试时容易犯这个错——改了 "setup" 忘了改 "assert"。

**防御规则**：
1. 每次修改测试输入后，立即问：这个输入会产生什么输出？
2. 在 PR 描述的 Verification 中写明预期行为，提交前对照检查
3. 自审时专门检查：测试的 input 和 assertion 是否匹配？

```typescript
// ❌ 输入改了，断言没改
const result = rcxDict.translate('～可爱');
expect(result?.data[0].entry).to.match(/猫/);  // ← 还在用旧的预期

// ✅ 断言跟着输入走
const result = rcxDict.translate('～可爱');
expect(result?.data[0].entry).to.match(/可爱/);  // ← 匹配实际输出
```

### 11. Deno 项目在受限环境中不可用

**问题**：安全策略阻止 `curl | sh` 安装模式，Deno 无法安装。

**识别 Deno 项目**：有 `deno.json` 而不是 `package.json`，CI 用 `deno task` 而不是 `npm test`。

**解决**：搜索 TypeScript 项目时直接跳过 Deno 项目。nshiab/simple-data-analysis 就是一个例子——344 星，有 CI 和 open issues，但用 Deno，无法本地测试。

### 12. AGENTS.md 是项目分析的金矿

**发现**：越来越多的项目有 `AGENTS.md` 文件，包含：
- 精确的工具链版本（Node.js、pnpm、Python 等）
- 数据库配置细节（连接参数、测试数据库名）
- 测试运行命令和注意事项
- 项目架构概览

**用法**：
```bash
# 分析项目时，优先读 AGENTS.md
cat AGENTS.md 2>/dev/null || cat .github/copilot-instructions.md 2>/dev/null
```

**价值**：AGENTS.md 里的信息比 README 更精确、更实用，尤其是数据库连接参数和测试配置。

### 13. Fork PR CI 不触发

**问题**：提交 PR 后 `gh pr checks` 显示 "no checks reported"。

**根因**：项目 CI 只有 `pull_request` trigger（没有 `push`），fork PR 在维护者 approve 之前不会触发 CI。

**常见模式**：
```yaml
# 只有这种 trigger 的项目 → fork PR 不触发
on:
  pull_request:
    branches: [main]

# 有这种 trigger 的项目 → fork PR 会触发
on:
  push:
    branches: [main]
  pull_request:
```

**解决**：
- 这是预期行为，不是你的 PR 有问题
- 等维护者 review 后 CI 会自动触发
- 在 PR 描述中说明"CI will run on review"让维护者知道

**教训**：不要因为 CI 没触发就认为 PR 有问题。很多项目出于安全考虑（防止恶意 workflow）不自动触发 fork PR 的 CI。

### 14. CodeQL v1 Actions 已废弃

**问题**：老项目经常使用 `github/codeql-action@v1`，这些 action 已经废弃。

**诊断**：
```bash
grep -r "codeql-action@" .github/workflows/
# 如果看到 @v1 → 需要更新到 @v3
```

**解决**：
```yaml
# 更新前
- uses: github/codeql-action/init@v1
- uses: github/codeql-action/autobuild@v1
- uses: github/codeql-action/analyze@v1

# 更新后
- uses: github/codeql-action/init@v3
- uses: github/codeql-action/autobuild@v3
- uses: github/codeql-action/analyze@v3
```

**价值**：这是一个高价值、低风险的 PR 方向。CodeQL v1 使用已废弃的 runner，更新到 v3 确保安全扫描继续工作。

### 13. CONTRIBUTING.md 分支约定

**问题**：项目要求从 `develop` 分支创建 PR，但你从 `main` 分支创建了 PR。

**案例（vite-plugin-css-injected-by-js）**：
- CONTRIBUTING.md 明确要求：branch from `develop`, target `develop`
- 如果从 `main` 创建 PR → 可能被拒绝或需要重新创建

**诊断**：
```bash
# 提交 PR 前，检查：
cat CONTRIBUTING.md | grep -i "branch\|develop\|main\|target"
git branch -a | grep develop
```

**教训**：不要默认用 `main` 分支。先读 CONTRIBUTING.md 看它要求什么分支约定。

### 8. Linter 修复不完整：只修了报错的那个，漏了其他的

**问题**：Linter 报告 1 个错误，你修了那个，CI 再跑又报同样的错误——因为项目里还有其他实例。

**案例（omnihive #8）**：
- Clippy 报 `unnecessary_sort_by` 在 `policy_engine.rs:73`
- 修了那一处，CI 再跑 → 又报 2 个同样的错误（`eval.rs:60` 和 `filesystem.rs:163`）
- 总共 3 个实例，Clippy 只显示了第 1 个

**根因**：Clippy/error 输出按编译顺序显示，一次只报一批。修复一个后，下一批才暴露。

**防御规则**：
```bash
# 修复 linter 错误时，搜索项目中所有匹配实例
# Rust (Clippy)
grep -rn "sort_by(" crates/ --include="*.rs" | grep -v "sort_by_key"

# Python (flake8/ruff)
grep -rn "unused import" src/ --include="*.py"

# JavaScript (eslint)
npx eslint . --format json | jq '.[].messages[] | select(.ruleId == "no-unused-vars")'

# 通用模式：用 linter 的规则名搜索代码
grep -rn "<pattern>" . --include="*.<ext>"
```

**关键**：修 linter 错误不是"修那一个"，是"修那一类"。提交前确认整个项目没有同类问题。

**进阶陷阱：多源码树项目（如 Tauri + Core crate）**

有些项目有多个独立的源码树，linter 在每个树上独立运行。修了一个树的错误，另一个树可能还有同样的问题。

**案例（omnihive #8）**：
- 项目结构：`crates/omnihive-core/`（核心库）+ `app/src-tauri/`（Tauri 应用）
- 修了 `crates/omnihive-core/src/policy_engine.rs` 的 `sort_by` → `sort_by_key`
- CI 再跑 → `app/src-tauri/src/engine/policy_engine.rs` 还有同样的 `sort_by` 错误
- 总共 3 个 Clippy 错误分散在两个源码树中

**防御规则**：
```bash
# 修复 linter 错误时，搜索整个项目（不只是报错的文件）
# 不要只搜 crates/ 或只搜 app/src-tauri/，要搜全部
grep -rn "sort_by(" . --include="*.rs" | grep -v "sort_by_key"
```

**关键**：多源码树项目的 linter 是按目录独立运行的。一个目录的修复不会自动传播到另一个目录。

### 9. Shellcheck 误报导致 CI 失败

### 14. 首次贡献修 Bug — rikaikun #190

**背景**：rikaikun（Chrome 日语词典扩展，⭐475）Issue #190 标记为 P1、easy、good first issue，自 2020 年未解决。

**为什么首次贡献可以修这个 Bug**：
- Issue 有 rikaichamp 的参考实现（3 行代码）
- 修复只改 1 行条件判断 + 更新 1 行注释
- 有现有测试可验证不回退
- 项目 CONTRIBUTING.md 明确欢迎贡献

**执行过程**：
1. 浅克隆（`--depth 1`）因为完整克隆超时
2. 读 `character_info.ts` 理解 SKIPPABLE 机制
3. 读 `data.ts` 找到使用点
4. 修改条件：`!(currentCharCode === SKIPPABLE.J_TILDE && result.length === 0)`
5. 添加测试：验证 standalone `～` 被查词
6. 提交 PR #2978

**教训**：信任梯度不是死规则。当 Issue 有参考实现、标记为 easy/good-first-issue、改动范围极小时，首次贡献修 Bug 是合理的。

**问题**：shellcheck 默认对 info 级别也返回非零退出码，CI 中 `set -e` 导致失败

**常见误报**：
- SC1091: `source` 的相对路径在 CI 环境中解析失败
- SC2034: 间接数组引用被误判为未使用变量
- SC2120/SC2119: 函数设计为可选参数但被误报

**解决**：
```yaml
# shellcheck --exclude=SC1091,SC2034,SC2120,SC2119 <script>
```

**原则**：只排除确认的误报，不要排除真正的 warning（如 SC2086 变量未引用）

### 15. `gh run view --log-failed` 返回空

**问题**：CI 步骤失败但 `gh run view <RUN_ID> --log-failed` 返回空输出。

**常见原因**：日志太长或错误嵌套在 group/step 层级中，`--log-failed` 无法精确定位。

**诊断方法**：
```bash
# 方法 1：先看哪个 job/step 失败
gh run view <RUN_ID> --repo <owner/repo>  # 看 JOBS 列表

# 方法 2：用 API 拿完整日志，grep 错误
gh api repos/<owner>/<repo>/actions/jobs/<JOB_ID>/logs 2>&1 | grep -i "error\|fail\|FAIL\|Error" | grep -v "##\[debug\]" | head -20

# 方法 3：只拿失败步骤的日志
gh api repos/<owner>/<repo>/actions/jobs/<JOB_ID>/logs 2>&1 | grep -B5 -A10 "exit code 1"
```

**案例（rikaikun #2978）**：`--log-failed` 返回空，但 `gh api .../logs | grep error` 找到了 `AssertionError: expected '可爱...' to match /猫/`。

### 15b. PR 统计必须排除自有仓库

**问题**：统计 open PR 数量或分类 PR 状态时，把用户自己的仓库（如 `KuaaMU/omnihive`、`KuaaMU/auto-pr-workflow`）也算作外部贡献。

**后果**：PR 计数虚高（如显示 25 个 open PR 实际只有 23 个外部），合并率计算失真，PR-LOG 记录不准确。

**解决**：所有 PR 统计和分类必须先过滤掉用户的自有仓库：
```python
own_repos = {"KuaaMU/omnihive", "KuaaMU/auto-pr-workflow", "KuaaMU/clay"}
external = [pr for pr in all_prs if pr['repository']['nameWithOwner'] not in own_repos]
```

**通用规则**：在任何 PR 审计、状态报告、PR-LOG 更新中，先识别并排除自有仓库。自有仓库的 PR（如 omnihive #8）属于内部开发，不是外部贡献。

**案例（2026-05-01）**：用户纠正——"你要确定24个pr都是本项目做的吗，不要包括omnihive"。实际外部 PR 是 23 个，omnihive #8 是自有项目。

### 16. 并发 PR 提交（Parallel PR Submission）

**问题**：逐个提交 PR 效率低，每个 PR 需要分析 + 编码 + 自审 + 提交，串行执行耗时长。

**解决**：用 `delegate_task` 并发提交多个 PR。先快速筛选项目，再并行委派。

**执行流程**：
1. 快速扫描 3-5 个候选项目（issue 详情 + CONTRIBUTING + CI 配置）
2. 选出 2-3 个适合的项目
3. 一次性 `delegate_task` 委派所有 PR 任务（每个任务独立 context）
4. 验证结果：`gh pr view` 确认每个 PR 存在且 MERGEABLE
5. 更新 PR-LOG

**每个委派任务的 context 必须包含**：
- 项目名和 issue 号
- 语言和工具链要求
- `git config user.name/email` 和 proxy 设置
- "先读 CONTRIBUTING.md"
- 明确的修复方案（不要让子 agent 自己找 bug）

**案例（2026-05-01）**：并发提交 3 个 PR（kontext-cli Go、runtime Go、rss-to-readme TS），全部成功创建。其中 1 个子 agent 超时但代码已完成，主 agent 补完了 commit/push/PR 创建。

**子 agent 超时的处理**：
- 子 agent max_iterations 超时时，代码可能已经写好但未 commit/push
- 检查 `git status` 和 `git diff` 看改动是否完整
- 如果改动完整：直接 `git add + commit + push + gh pr create` 完成提交
- 如果改动不完整：手动补完缺失部分再提交
- **不要重新运行子 agent** — 它的工作成果在磁盘上，直接用

### 17. Open PR 积压管理

**问题**：持续创建新 PR 导致 open PR 数量过多，维护者审查负担大，自身监控成本高。

**策略**：
- **阈值**：open PR > 15 时，暂停创建新 PR，优先推动已有 PR 合并
- **优先级**：修复已有 PR 的 CI 失败 > 回应 review 反馈 > 创建新 PR
- **语言轮换暂停**：积压期间不按轮换找新项目

**理由**：20+ open PR 会分散注意力，每个 PR 都需要监控 CI、回应 review。集中精力推几个 PR 到合并比广撒网更有效。

### 17. 批量 PR 状态监控模式

**问题**：有 20+ 个 open PR 分散在不同仓库，逐个检查耗时且容易遗漏。

**快速方式**：运行 `scripts/batch-pr-audit.py` 自动分类所有 open PR（approved / needs-action / feedback / conflicting / no-activity）。

**正确语法**：`gh pr checks NUM --repo owner/repo`（不是 `gh pr checks owner/repo#NUM`）

**批量检查模板**：
```bash
# 先 unset 代理（如果环境有代理）
unset ALL_PROXY HTTPS_PROXY HTTP_PROXY

# 批量检查 CI 状态
for pr in "owner1/repo1:123" "owner2/repo456" "owner3/repo7:789"; do
  repo=$(echo $pr | cut -d: -f1)
  num=$(echo $pr | cut -d: -f2)
  echo "=== $repo #$num ==="
  gh pr checks $num --repo $repo 2>&1 | head -5
  echo ""
done
```

**批量检查 review 状态**：
```bash
for pr in "owner1/repo1:123" "owner2/repo2:456"; do
  repo=$(echo $pr | cut -d: -f1)
  num=$(echo $pr | cut -d: -f2)
  echo "=== $repo #$num ==="
  gh pr view $num --repo $repo --json reviews,comments,mergeable,mergeStateStatus,reviewDecision \
    --jq '{reviews: [.reviews[] | {author: .author.login, state: .state}], comment_count: (.comments | length), mergeable: .mergeable, mergeState: .mergeStateStatus, reviewDecision: .reviewDecision}'
  echo ""
done
```

**获取 CodeRabbit/Copilot 的 inline review comments**（PR review comments，不是 issue comments）：
```bash
# Inline review comments（CodeRabbit、Copilot 等 bot 的行内评论）
gh api repos/{owner}/{repo}/pulls/{PR#}/comments --jq '.[] | {user: .user.login, body: .body[:200], path: .path}'

# 顶层 PR comments（CLA bot、codecov 等）
gh pr view {PR#} --repo {owner}/{repo} --json comments --jq '.comments[] | {author: .author.login, body: .body[:200]}'
```

**⚠️ --jq 复杂模板陷阱**：嵌套 `{}` 的 --jq 模板会被 bash 吞掉，输出字面模板文本而非数据。批量检查时用 `gh pr view --json ...` 拿原始 JSON，再用 Python/Node 解析（详见 `references/gh-cli-quirks.md`）。

**分类输出模板**（cron job 报告用）：
```
✅ Ready for merge: PRs with APPROVED reviews
✅ CI passing: PRs with all checks green, awaiting review
🟡 No CI: PRs with "no checks reported" (fork PR trigger issue or no CI)
⚠️ Needs action: PRs with CI failures, CLA issues, or unresolved reviews
```

### 17b. CLA（Contributor License Agreement）阻塞

**问题**：PR 的 CI 显示 CLA 未签名，无法合并。

**常见根因：git 身份不匹配**
```bash
# 检查 commit 的 author 信息
gh pr view {PR#} --repo {owner}/{repo} --json commits --jq '.commits[] | {oid: .oid[:8], author: .authors[0]}'
```

**症状**：commit author 显示为 `Ubuntu <ubuntu@localhost.localdomain>` 或其他非 GitHub 账户身份。CLA bot 无法将 commit 关联到 GitHub 用户。

**诊断**：
```bash
# 检查本地 git 配置
git config user.name
git config user.email

# 检查 commit 是否用了正确的身份
git log --format='%an <%ae>' -3
```

**修复**：
```bash
# 1. 确保 git config 正确（与 GitHub 账户匹配）
git config user.name "YourGitHubUsername"
git config user.email "your-github-email@example.com"

# 2. 修改 commit author
git commit --amend --author="YourGitHubUsername <your-github-email@example.com>"

# 3. 强制推送
git push --force-with-lease
```

**预防**：在 Phase 2 环境评估时检查 git config：
```bash
git config user.name && git config user.email
# 如果是系统默认值（ubuntu, root 等）→ 需要修正后再提交
```

### 17b2. DCO（Developer Certificate of Origin）签章

**问题**：项目要求 commit 有 DCO sign-off（`Signed-off-by` 行），但你用了普通 `git commit`。

**识别**：检查 AGENTS.md 或 CONTRIBUTING.md 是否提到：
- `git commit -s`
- DCO
- `Signed-off-by`
- `probot/dco` 或 `dco.yml`

**案例（go-openapi/runtime）**：AGENTS.md 明确要求 `git commit -s`（DCO sign-off）。如果用普通 commit，CI 会失败。

**解决**：
```bash
# 已有 commit 加 sign-off
git commit --amend -s

# 或新 commit 加 -s
git commit -s -m "fix: your message"
```

**预防**：Phase 1 分析时检查 AGENTS.md 的 Conventions 节。DCO 和 CLA 是两个不同的东西——CLA 是法律协议，DCO 是 commit 元数据。

### 17c. Fork PR 的预期 CI 行为

**不是所有 CI 失败都需要修复。** Fork PR 有一些预期的"失败"：

| CI 服务 | 状态 | 含义 | 需要行动？ |
|---------|------|------|-----------|
| `autofix.ci` | `action_required` | Bot 想推送 autofix 但需要权限 | ❌ 不需要，等维护者 approve 后自动处理 |
| Vercel | `Authorization required to deploy` | Fork PR 无 Vercel 部署权限 | ❌ 不需要，这是预期行为 |
| CLA assistant | `not signed` | CLA 未签名 | ⚠️ 需要签名或修复 git 身份 |
| `no checks reported` | CI 未触发 | 项目 CI 只有 `pull_request` trigger | ❌ 不需要，等维护者 review |
| `gitleaks` | `fail` | 可能是 org 级别配置问题 | ❌ 如果其他 PR 也失败则是预存在的问题 |
| Vercel/Netlify + `BLOCKED` | `mergeStateStatus: BLOCKED` 但 `reviewDecision: APPROVED` | Required deployment check 失败 | ❌ 维护者可用 admin override 合并 |

**判断方法**：
```bash
# 检查其他人的 PR 是否也有同样的 CI 失败
gh pr list --repo {owner}/{repo} --state open --limit 5 --json number,title
# 选一个别人的 PR 检查 CI
gh pr checks {OTHER_PR#} --repo {owner}/{repo}
# 如果别人的 PR 也有同样的失败 → org 级别问题，不是你的 PR 的问题
```

### 18. 大 PR 快速变成 CONFLICTING

**问题**：PR 触碰了 20+ 文件，一个月后 main 分支前进了，PR 产生大量合并冲突。

**根因**：冲突概率 ∝ 触碰文件数 × 时间。50 文件的 PR 几乎必然会在几周内冲突。

**数据点（omnihive #8）**：
- PR 触碰 50 文件 → 1 个月后 8 个冲突文件（20 个冲突标记）
- PR 触碰 3 文件的 rikaikun #2978 → 同期零冲突

**防御**：
- PR 触碰文件数控制在 10 以内
- 如果必须大改，拆成多个独立 PR（每个 PR 可独立合并）
- 大 PR 合并前先 `git merge main` 预检冲突

**修复**：见 Phase 4.1 的委托解决流程。

### 19. PR 描述中的反引号被 Shell 吞掉

**问题**：`gh pr create --body` 和 `gh pr edit --body` 中的反引号（backtick）会被 bash 解释为命令替换，导致 PR 描述中的代码引用丢失。

**症状**：
- PR 描述中 `` `SmartDashboard.putData()` `` 变成空字符串
- Shell 报 `syntax error: unexpected end of file`

**解决**：
```bash
# 方法 1：写入文件，用 --body-file
cat > /tmp/pr_body.md << 'EOF'
## Summary
Fix `SmartDashboard.putData()` call...
EOF
gh pr create --body-file /tmp/pr_body.md

# 方法 2：用 gh api 直接更新
gh api repos/OWNER/REPO/pulls/NUM --method PATCH --field body="$(cat /tmp/pr_body.md)"

# 方法 3：用 heredoc 的单引号模式保护反引号
gh pr create --body "$(cat << 'EOF'
Fix `some_function()` call...
EOF
)"
```

**关键**：`<< 'EOF'`（单引号）防止变量展开和命令替换。`<< EOF`（无引号）仍然会展开。

**教训**：任何包含反引号、`$()`、或特殊字符的 PR 描述，必须通过文件传递，不能直接作为命令行参数。

### 20. Rust CI 级联失败：fix → push → fail → fix → push → fail

**问题**：修了一个 Rust CI 错误，push 后又报另一个。反复 3-4 轮才通过 CI。

**典型级联序列**：
1. 第一轮：`cargo fmt --check` 失败（格式化问题）
2. 第二轮：`cargo clippy` 失败（dead code / unused import）
3. 第三轮：`cargo test` 失败（测试断言错误）

**根因**：CI 按顺序运行 check → clippy → test。每一步独立失败，不会跳到下一步。

**防御：push 前运行全部检查**：
```bash
# Rust 项目：一键全检
cargo fmt --check && cargo clippy -- -D warnings && cargo test

# 或者用项目自己的 CI 命令
mise run test:ci  # 如果项目用 mise
```

**额外陷阱 — dead code after refactoring**：

当用新代码替换旧函数调用时，旧函数变成 dead code：
```rust
// 旧代码调用了 normalize_path_lexical()
// 新代码用 inline 逻辑替换了它
// → normalize_path_lexical 变成 dead code
// → clippy -D warnings 报 error: function never used
```

**解决**：要么删除旧函数，要么加 `#[allow(dead_code)]`。

**案例（2026-05-01 omnihive #8）**：
- 第一轮：`cargo fmt --check` 失败（一行式闭包需要展开为多行）
- 第二轮：`cargo clippy` 失败（`normalize_path_lexical` dead code）
- 第三轮：终于通过

**教训**：每轮 CI 修复成本 ~3-5 分钟（push + CI 运行）。3 轮 = 10-15 分钟浪费。本地运行 `cargo fmt --check && cargo clippy -- -D warnings && cargo test` 可以一次性发现所有问题。

### 21. 大仓库冲突解决：无需完整 clone

**问题**：仓库太大无法完整 clone（超时），但 PR 变成 CONFLICTING 需要解决冲突。

**解决**：不 clone 整个仓库，直接从上游 main 创建新分支，应用 PR 的改动，force-push：
```bash
# 1. 浅克隆 fork（只 clone fork 的分支）
git clone --depth 50 https://github.com/YOUR_USER/repo.git
cd repo

# 2. 添加 upstream
git remote add upstream https://github.com/ORIGINAL/repo.git
git fetch upstream main --depth 50

# 3. 从 upstream/main 创建新分支
git checkout -b fix/my-branch upstream/main

# 4. 应用 PR 的改动（手动或用 sed/patch）
# ... make changes ...

# 5. Commit 并 force-push 到 PR 分支
git add -A && git commit -m "fix: resolve merge conflicts"
git -c http.proxy="" -c https.proxy="" push origin fix/my-branch:fix/my-branch --force
```

**为什么有效**：PR 的改动通常很小（1-2 文件），不需要整个仓库历史。从 upstream/main 重新应用改动 = 自动解决所有冲突。

**案例（2026-05-01 entireio/cli #1086）**：仓库 clone 超时。用 `gh pr diff` 查看 PR 改动（2 行），从 upstream/main 创建新分支，`sed` 应用改动，force-push。PR 从 CONFLICTING 变为 MERGEABLE。

## 提交前验证清单

**每次提交 PR 前，必须确认：**

- [ ] **Git 身份**：`git config user.name` 和 `user.email` 匹配 GitHub 账户（不是系统默认值如 ubuntu/root）
- [ ] **工具验证**：lint/format 工具实际能运行（不是只看配置文件存在）
- [ ] **去重检查**：open PR 中没有人在做同样的事
- [ ] **对比学习**：读了项目中类似代码，学习了它的模式
- [ ] **代码自审**：第二个实例审查通过（并发/崩溃/边界/测试/风格）
- [ ] **测试覆盖**：Bug 修复有回归测试，并发修复有并发测试
- [ ] **格式干净**：`git diff --cached` 无无关改动（.venv、__pycache__ 等）
- [ ] **测试通过**：本地 CI 能跑通（如果有测试的话）
- [ ] **Commit 规范**：遵循项目风格（conventional commits / 简洁描述）
- [ ] **PR 描述**：说明修了什么、为什么、怎么验证

## Agent 能力清单

掌握这个 Skill 的 Agent 应该能够：

- [ ] 深度分析任何 GitHub 项目（架构、CI、贡献政策）
- [ ] **评估项目可执行性**（size < 5MB，能跑测试，无 Docker 依赖）
- [ ] 验证工具链是否真正可用（不只看配置文件存在）
- [ ] 检查已有 open PR，避免重复贡献
- [ ] 制定针对性的 PR 策略（基于项目实际需求，找没人处理的 gap）
- [ ] **对比学习**：先读项目里类似代码，学习模式再写
- [ ] **任务拆分**：把大任务拆成 1-2 文件的小任务给 Claude Code
- [ ] 调用 Claude Code 编写高质量代码（小任务，不超时）
- [ ] **代码自审**：用第二个实例审查 diff（并发/崩溃/边界/测试/风格）
- [ ] 监控 CI 并自动修复失败
- [ ] 回应 AI 审查反馈（Copilot、CodeRabbit）
- [ ] 遵循项目编码风格和规范
- [ ] 提交前执行验证清单（对比学习、自审、测试覆盖、工具、格式、规范）
- [ ] 记录每次测试的结果和学习

## 与 Hermes 集成

```bash
# 单次执行：让 Agent 自主提交一个 PR
hermes delegate_task --goal "分析项目 X，提交一个有价值的 PR" \
  --context "使用 auto-pr-workflow skill 的方法论"

# 并发执行：同时提交多个 PR（推荐 2-3 个，不要超过 3 个避免质量下降）
hermes delegate_task --role orchestrator --tasks '[
  {"goal": "提交 PR 到 projectA", "toolsets": ["terminal","file"]},
  {"goal": "提交 PR 到 projectB", "toolsets": ["terminal","file"]}
]'

# 持续执行：自主循环测试（详见「自主循环测试」章节）
hermes cronjob create --schedule "every 1h" \
  --name "auto-pr-workflow 循环测试" \
  --skill auto-pr-workflow --deliver local \
  --prompt "检查现有 PR → 找新项目 → 执行 → 更新 skill → 仅重大事件通知"
```

### 并发 PR 提交

**适用场景**：已有明确目标项目和 issue，多个任务之间无依赖。

**流程**：
1. 先串行分析候选项目（5-10 分钟），选定 2-3 个目标
2. 每个任务的 context 必须包含：项目语言、CONTRIBUTING 要求、issue 内容、git config 命令
3. 用 `delegate_task --role orchestrator` 并发执行
4. 每个子 agent 独立完成：fork → clone → 分析 → 编码 → 自审 → 提交 PR
5. 主 agent 验证所有 PR 状态，更新 PR-LOG

**案例（2026-05-01）**：并发提交 3 个 PR（kontext-cli Go, runtime Go, rss-to-readme TS），全部成功。kontext-cli 当天合并。

**注意事项**：
- 不要超过 3 个并发——子 agent 会争用 terminal 资源
- 每个任务必须独立设置 git config（子 agent 不共享环境）
- 子 agent 可能超时（max_iterations）——主 agent 需要检查并补完未完成的 push/PR 创建
- PR-LOG 更新放在所有子任务完成后统一做

**子 agent 超时补完流程**：
1. 检查子 agent 的 summary，看它完成了什么
2. `cd` 到工作目录，`git log --oneline -3` 检查是否已 commit
3. 如果已 commit 但未 push：手动 `git push fork branch-name`
4. 如果已 push 但未创建 PR：手动 `gh pr create`
5. 如果未 commit：检查 `git diff` 看代码改动是否还在

**案例（2026-05-01 runtime #422）**：子 agent 完成了代码修改和测试，但因 max_iterations 超时，没有 commit/push。主 agent 检查发现 `git diff` 有改动，手动 commit + push + 创建 PR，成功。

## 自主循环测试（Continuous Testing Loop）

**设置定时任务让 Agent 自主持续测试和改进 skill。**

### 模式

```
检查现有 PR → 找新项目 → 执行工作流 → 更新 skill → 记录
     ↑                                                    |
     └──────────────── 每小时循环 ←────────────────────────┘
```

### 设计原则

1. **静默执行** — 只在重大事件时通知用户（PR 合并/拒绝/CI 持续失败）
2. **语言轮换** — 每次测试不同语言（JS → Python → Go → Rust → TS）
3. **自我改进** — 发现新坑点立即更新 skill，不等用户指示
4. **去重优先** — 先检查已有 PR 状态，再决定下一步

### Cron Job 模板

```bash
hermes cronjob create --schedule "every 1h" --name "auto-pr-workflow 循环测试" \
  --skill auto-pr-workflow --deliver local --prompt "
你是 auto-pr-workflow skill 的自动测试 Agent。

Step 1: 检查现有 PR 状态
  gh search prs --author=@me --state=open
  对每个 PR: 检查 CI、review、合并状态
  CI 失败 → 修复并推送
  PR 合并/关闭 → 记录

Step 2: 如果没有活跃任务，找新项目测试
  语言轮换: JS → Python → Go → Rust → TS
  条件: stars 50-1000, 有 CI, 最近更新, 有 open issues

Step 3: 按 auto-pr-workflow skill 执行
  深度分析 → 制定策略 → 修复 → 提交 PR → 记录

Step 4: 更新 skill
  发现新坑点 → 更新 SKILL.md → 同步到 GitHub

Step 5: 汇报（仅重大事件）
  PR 合并 ✅ / PR 拒绝 ❌ / CI 连续 3 次失败 ⚠️ → 发消息
  否则静默
"
```

### 通知策略

| 事件 | 动作 |
|------|------|
| PR 被合并 | ✅ 通知用户 |
| PR 被关闭/拒绝 | ❌ 通知原因 |
| CI 连续 3 次修复失败 | ⚠️ 请求帮助 |
| 完成一批测试 | 🎯 汇总通知 |
| 其他（分析、提交、记录） | 🔇 静默执行 |

## 测试记录

所有测试记录在 `test-records/` 目录，用于：
- 溯源追踪
- 项目宣传
- 案例展示

详见 [test-records/README.md](../test-records/README.md)

## 详细文档

- [测试记录](../test-records/README.md)
- [GitHub CLI 坑点](references/gh-cli-quirks.md)
- [Rust Clippy 修复模式](references/rust-clippy-patterns.md)
- [批量 PR 检查模式](references/batch-pr-check-pattern.md)
- [Kimi 设计分析](references/kimi-analysis-2026-05.md)
- [项目主页](https://github.com/KuaaMU/auto-pr-workflow)
- [项目主页](https://github.com/KuaaMU/auto-pr-workflow)
