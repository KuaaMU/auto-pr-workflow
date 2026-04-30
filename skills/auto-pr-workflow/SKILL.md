---
name: auto-pr-workflow
description: "Agent 自主提交高质量 PR 的完整能力 — 深度分析项目 → 制定策略 → 调用 Claude Code → 监控 CI → 回应审查"
version: 2.5.0
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

**先评估工作环境，再选项目。**

#### 2.0 环境评估（选项目前必须）

```bash
# 语言工具链
which cargo && cargo --version     # Rust
which python3 && python3 --version # Python
which node && node --version       # Node
which go && go version             # Go

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

**不要硬编码限制，让环境说话。**

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

**拆任务模板：**

```bash
# 第一步：信息收集（只读，不改）
delegate_task --goal "读文件 X，报告 Y 是否有 Z" --toolsets '["file"]'

# 第二步：写代码（基于第一步结果）
delegate_task --goal "在文件 X 的 Y 函数里加 Z" --toolsets '["file"]'

# 第三步：验证（如果能跑测试）
delegate_task --goal "跑 cargo test / pytest 验证" --toolsets '["terminal", "file"]'
```

**超时对策：**
- 600 秒超时 = 任务太大，拆成更小的块
- 连续 2 次超时 = 换项目或换策略（自己分析，只让 Claude Code 写代码）

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
# 本地检查（CLI 辅助）
auto-pr check          # 语法检查、lint
node --test test/      # 运行测试

# 提交 PR
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

### 案例 2: mco PR #83 — 自审抓到的真实问题

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

### 10. AGENTS.md 是项目分析的金矿

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

### 8. Shellcheck 误报导致 CI 失败

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
