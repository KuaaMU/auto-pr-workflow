---
name: auto-pr-workflow
description: "Agent 自主提交高质量 PR 的完整能力 — 深度分析项目 → 制定策略 → 调用 Claude Code → 监控 CI → 回应审查"
version: 2.4.0
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
Agent 是大脑（分析、决策、判断）
CLI 是手脚（执行、检查、提交）
```

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

### Phase 2: 制定策略（Agent 决策）

**基于分析结果，选择最高价值的 PR 方向。**

#### 高价值方向（通常被接受）

| 方向 | 价值 | 风险 |
|------|------|------|
| 修复真实 Bug | ⭐⭐⭐ | 低 |
| 补充测试用例 | ⭐⭐⭐ | 低 |
| 修复 CI 遗漏 | ⭐⭐⭐ | 低 |
| 修复工具配置（lint/format） | ⭐⭐⭐ | 极低 |
| 文档修正/完善 | ⭐⭐ | 极低 |
| 安全漏洞修复 | ⭐⭐⭐⭐ | 低 |

#### 低价值方向（常被拒绝）

| 方向 | 问题 |
|------|------|
| 通用模板填充 | 没有分析项目实际需求 |
| 添加新功能 | 大多数项目需要先讨论 |
| 引入新依赖 | 需要维护者同意 |
| 代码风格重构 | 主观性强，容易被拒 |

#### 策略选择原则

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

### Phase 3: 执行（调用工具）

**用 Claude Code 做代码工作，用 CLI 做检查和提交。**

```bash
# 1. 让 Claude Code 分析并编写代码
delegate_task --goal "为项目 X 补充 Y 测试用例" --context "项目使用 node:test，风格要求..."

# 2. 本地检查（CLI 辅助）
auto-pr check          # 语法检查、lint
node --test test/      # 运行测试

# 3. 提交 PR
auto-pr submit         # 或手动 gh pr create
```

### Phase 4: 监控与修复（Agent 循环）

```bash
# 监控 CI
gh pr checks <PR#> --watch

# CI 失败时，Agent 分析原因并修复
gh run view <RUN_ID> --log-failed

# 回应审查反馈
gh pr view <PR#> --json reviews
# 根据 review 修改代码，再次提交
```

### Phase 5: 记录与学习

```bash
# 记录测试结果
cp test-records/template.md test-records/YYYY-MM-DD_project.md
# 填写完整记录（分析、策略、执行、结果、学习）
```

## CLI 工具（Agent 的手）

CLI 是辅助工具，不是主体。Agent 可以选择用或不用。

```bash
auto-pr check     # 本地检查（语法、lint）
auto-pr submit    # 提交 PR（创建分支、commit、push、创建 PR）
auto-pr watch     # 监控 CI 状态
auto-pr review    # 查看审查反馈
```

**CLI 不做的事**：
- 不决定提交什么（Agent 决定）
- 不分析项目（Agent 分析）
- 不生成内容（Agent 或 Claude Code 生成）

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

### 7. CodeRabbit 反馈处理

**问题**：CodeRabbit 提出代码风格或项目规范问题

**解决**：
- 检查项目编码规范文件（如 .github/instructions/）
- 根据反馈更新代码或配置
- 保持与项目现有风格一致

### 7. Shellcheck 误报导致 CI 失败

**问题**：shellcheck 默认对 info 级别也返回非零退出码，CI 中 `set -e` 导致失败

**常见误报**：
- SC1091: `source` 的相对路径在 CI 环境中解析失败
- SC2034: 间接数组引用被误判为未使用变量
- SC2120/SC2119: 函数设计为可选参数但被误报

**解决**：
```yaml
shellcheck --exclude=SC1091,SC2034,SC2120,SC2119 cli/bin/auto-pr
```

**原则**：只排除确认的误报，不要排除真正的 warning（如 SC2086 变量未引用）

## 提交前验证清单

**每次提交 PR 前，必须确认：**

- [ ] **工具验证**：lint/format 工具实际能运行（不是只看配置文件存在）
- [ ] **去重检查**：open PR 中没有人在做同样的事
- [ ] **格式干净**：`git diff --cached` 无无关改动（.venv、__pycache__ 等）
- [ ] **测试通过**：本地 CI 能跑通（如果有测试的话）
- [ ] **Commit 规范**：遵循项目风格（conventional commits / 简洁描述）
- [ ] **PR 描述**：说明修了什么、为什么、怎么验证

## Agent 能力清单

掌握这个 Skill 的 Agent 应该能够：

- [ ] 深度分析任何 GitHub 项目（架构、CI、贡献政策）
- [ ] 验证工具链是否真正可用（不只看配置文件存在）
- [ ] 检查已有 open PR，避免重复贡献
- [ ] 制定针对性的 PR 策略（基于项目实际需求，找没人处理的 gap）
- [ ] 调用 Claude Code 编写高质量代码
- [ ] 监控 CI 并自动修复失败
- [ ] 回应 AI 审查反馈（Copilot、CodeRabbit）
- [ ] 遵循项目编码风格和规范
- [ ] 提交前执行验证清单（工具、去重、格式、测试、规范）
- [ ] 记录每次测试的结果和学习

## 与 Hermes 集成

```bash
# 单次执行：让 Agent 自主提交一个 PR
hermes delegate_task --goal "分析项目 X，提交一个有价值的 PR" \
  --context "使用 auto-pr-workflow skill 的方法论"

# 持续执行：自主循环测试（详见「自主循环测试」章节）
hermes cronjob create --schedule "every 1h" \
  --name "auto-pr-workflow 循环测试" \
  --skill auto-pr-workflow --deliver local \
  --prompt "检查现有 PR → 找新项目 → 执行 → 更新 skill → 仅重大事件通知"
```

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

- [CLI 文档](../cli/README.md)
- [测试记录](../test-records/README.md)
- [项目主页](https://github.com/KuaaMU/auto-pr-workflow)
