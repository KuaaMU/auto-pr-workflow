# Auto-PR Workflow 🔄

全自动 PR 提交工作流 — 从代码变更到合并，最大限度减少人工干预。

## ✨ 特性

- **CLI-first** — 独立命令行工具，不依赖任何平台
- **AI 双重审查** — Copilot + CodeRabbit 同时审查
- **CI 自动监控** — 失败自动诊断、自动修复（最多3轮）
- **Auto-Merge** — CI 全绿自动合并
- **多语言支持** — Rust、Node.js、Python、Go
- **Hermes 集成** — 可作为 Hermes Skill 使用

## 🚀 安装

```bash
# npm 安装
npm install -g auto-pr-workflow

# 或直接克隆
git clone https://github.com/KuaaMU/auto-pr-workflow.git
echo 'export PATH="$HOME/auto-pr-workflow/cli/bin:$PATH"' >> ~/.bashrc
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

# 自动生成 PR 描述
auto-pr describe
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
├── cli/                    # CLI 工具
│   ├── bin/auto-pr         # 可执行入口
│   ├── src/                # 源码
│   ├── tests/              # 测试
│   ├── templates/          # 配置模板
│   └── package.json
├── skill/                  # Hermes Skill
│   ├── SKILL.md            # 技能文档
│   ├── scripts/            # 包装脚本
│   └── templates/          # → cli/templates
└── README.md
```

## 🤖 AI 审查额度

| 工具 | 免费额度 | 省额度策略 |
|------|----------|------------|
| Copilot | 包含在订阅中 | 小PR不@，大PR才用 |
| CodeRabbit | 公共仓库免费无限 | 公共仓库放心用 |

## 🏆 竞品对比

| 工具 | Stars | 我们的优势 |
|------|-------|-----------|
| Qodo Merge | 6.8k | CLI-first，Hermes 集成 |
| CodeRabbit | 2.8k | 多 AI 整合 |
| Sweep | 7.3k | 聚焦 PR 提交流程 |
| reviewdog | 7.8k | 全流程自动化 |

## 📄 License

MIT
