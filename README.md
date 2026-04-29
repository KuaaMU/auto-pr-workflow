# Auto-PR Workflow 🔄

全自动 PR 提交工作流 — 从代码变更到合并，最大限度减少人工干预。

## ✨ 特性

- **本地安全门禁** — 提交前自动检查 lint、test、密钥
- **AI 双重审查** — Copilot + CodeRabbit 同时审查
- **CI 自动监控** — 失败自动诊断、自动修复（最多3轮）
- **Auto-Merge** — CI 全绿自动合并
- **多语言支持** — Rust、Node.js、Python

## 🚀 安装

```bash
# 克隆
git clone https://github.com/KuaaMU/auto-pr-workflow.git

# 添加到 PATH
echo 'export PATH="$HOME/auto-pr-workflow/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 📖 使用

```bash
# 初始化项目配置
auto-pr init

# 提交 PR
auto-pr submit

# 监控 CI 并自动修复
auto-pr watch

# 手动触发 AI 审查
auto-pr review

# 启用 auto-merge
auto-pr merge
```

## 🔄 工作流程

```
Agent 改代码
    │
    ▼
本地安全门禁 ──── 失败 → 自动修复（最多3轮）
    │ 通过
    ▼
创建分支 + Commit
    │
    ▼
Push + 创建 PR
    │  ├── @copilot（AI审查1）
    │  └── @coderabbitai（AI审查2）
    ▼
CI 运行 ──── 失败 → 自动诊断+修复 → 再push（最多3轮）
    │ 全绿
    ▼
Auto-Merge ──── CI+审查通过 → 自动合并
    │
    ▼
清理分支
```

## 📁 项目结构

```
auto-pr-workflow/
├── bin/auto-pr           # 可执行入口
├── src/
│   ├── auto-pr.sh        # 主逻辑
│   ├── checks.sh         # 本地检查模块
│   ├── submit.sh         # PR 提交模块
│   ├── watch.sh          # CI 监控模块
│   └── fix.sh            # 自动修复模块
├── tests/
│   ├── test_init.sh      # 初始化测试
│   ├── test_checks.sh    # 检查模块测试
│   └── test_submit.sh    # 提交模块测试
├── templates/
│   ├── copilot-instructions.md
│   ├── pr-template.md
│   └── coderabbit.yaml
└── .github/
    ├── workflows/ci.yml
    └── dependabot.yml
```

## 🤖 AI 审查额度

| 工具 | 免费额度 | 省额度策略 |
|------|----------|------------|
| Copilot | 包含在订阅中 | 小PR不@，大PR才用 |
| CodeRabbit | 公共仓库免费无限 | 公共仓库放心用 |

## 📝 最佳实践

1. **原子化提交** — 一个 PR 解决一个问题
2. **小步快跑** — PR < 300 行
3. **先跑 CI** — 本地检查通过再 push
4. **善用 Draft** — 不确定的 PR 先标 draft
5. **双重审查** — 大功能同时 @copilot 和 @coderabbitai
6. **及时合并** — CI 全绿就合并

## 📄 License

MIT
