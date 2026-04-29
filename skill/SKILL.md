---
name: auto-pr-workflow
description: "Agent 自主提交高质量 PR 的完整能力 — 深度分析项目 → 制定策略 → 调用 Claude Code → 监控 CI → 回应审查"
version: 2.1.0
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

```bash
# 1. 读取项目核心文件
cat README.md           # 项目定位、技术栈
cat CONTRIBUTING.md     # 贡献政策（最关键！）
cat .github/CODEOWNERS  # 维护者
cat LICENSE             # 开源协议

# 2. 检查项目编码规范
# 检查 .github/instructions/ 目录
ls -la .github/instructions/ 2>/dev/null || true
```
ls .github/workflows/   # 现有 CI 配置
cat .github/workflows/*.yml

# 3. 检查质量基础设施
ls test/                # 测试现状
cat package.json        # 依赖和脚本
ls .github/             # 现有配置

# 4. 了解项目历史
gh issue list --limit 10    # 开放的 Issues
gh pr list --limit 10       # 最近的 PR
git log --oneline -20       # 最近的提交
```

**关键判断**：
- 这个项目接受什么样的 PR？（有些项目拒绝 feature PR）
- 维护者风格是什么？（solo-maintained vs 社区驱动）
- 什么是真正的痛点？（不是你以为的，是项目实际缺的）

### Phase 2: 制定策略（Agent 决策）

**基于分析结果，选择最高价值的 PR 方向。**

#### 高价值方向（通常被接受）

| 方向 | 价值 | 风险 |
|------|------|------|
| 修复真实 Bug | ⭐⭐⭐ | 低 |
| 补充测试用例 | ⭐⭐⭐ | 低 |
| 修复 CI 遗漏 | ⭐⭐⭐ | 低 |
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

### 4. CodeRabbit 反馈处理

**问题**：CodeRabbit 提出代码风格或项目规范问题

**解决**：
- 检查项目编码规范文件（如 .github/instructions/）
- 根据反馈更新代码或配置
- 保持与项目现有风格一致

## Agent 能力清单

掌握这个 Skill 的 Agent 应该能够：

- [ ] 深度分析任何 GitHub 项目（架构、CI、贡献政策）
- [ ] 制定针对性的 PR 策略（基于项目实际需求）
- [ ] 调用 Claude Code 编写高质量代码
- [ ] 监控 CI 并自动修复失败
- [ ] 回应 AI 审查反馈（Copilot、CodeRabbit）
- [ ] 遵循项目编码风格和规范
- [ ] 记录每次测试的结果和学习

## 与 Hermes 集成

```bash
# 让 Agent 自主执行完整工作流
hermes delegate_task --goal "分析项目 X，提交一个有价值的 PR" \
  --context "使用 auto-pr-workflow skill 的方法论"

# 定期监控 PR 状态
hermes cronjob create --schedule "*/10 * * * *" \
  --prompt "检查所有开放 PR 的 CI 状态"
```

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
