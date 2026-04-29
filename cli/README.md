# auto-pr CLI

全自动 PR 提交工作流 CLI 工具。

## 安装

```bash
npm install -g auto-pr-workflow
```

## 使用

```bash
auto-pr check     # 检查环境和依赖
auto-pr init      # 初始化项目配置
auto-pr submit    # 提交 PR
auto-pr watch     # 监控 CI
auto-pr review    # 触发 AI 审查
auto-pr merge     # 启用 auto-merge
auto-pr describe  # 自动生成 PR 描述
```

## 命令详解

### check - 环境检查

检查运行环境和依赖是否满足要求。

```bash
auto-pr check
```

检查内容：
- Git 是否安装
- GitHub CLI 是否安装并登录
- Git 用户配置
- 项目语言环境（Node.js、Python、Go、Rust）
- 项目依赖是否安装
- CI 配置是否存在

### init - 初始化

初始化项目配置，创建必要的文件。

```bash
auto-pr init
```

创建的文件：
- `.github/pull_request_template.md` - PR 模板
- `.github/copilot-instructions.md` - Copilot 审查指南
- `.coderabbit.yaml` - CodeRabbit 配置
- `.github/workflows/ci.yml` - CI 配置
- `.github/dependabot.yml` - Dependabot 配置

### submit - 提交 PR

提交 PR，包括本地检查、创建分支、提交代码、创建 PR。

```bash
auto-pr submit
```

### watch - 监控 CI

监控 CI 状态，失败时自动修复。

```bash
auto-pr watch
```

### review - 触发审查

手动触发 AI 审查。

```bash
auto-pr review
```

### merge - 启用合并

启用 auto-merge。

```bash
auto-pr merge
```

### describe - 生成描述

自动生成 PR 描述。

```bash
auto-pr describe
```

## 配置文件

支持 `.auto-pr.yml` 配置文件，放在项目根目录。

```yaml
# 项目配置
project:
  type: auto  # auto, rust, node, python, go
  style:
    use_var: false
    use_arrow_functions: true
    server_module: commonjs
    client_module: esm

# PR 配置
pr:
  base_branch: main
  commit_style: angular  # angular, conventional, custom
  add_co_authored_by: false

# CI 配置
ci:
  watch_interval: 30
  max_fix_attempts: 3
  auto_fix: true
  auto_merge: false

# AI 审查配置
review:
  copilot: true
  coderabbit: true
  timeout: 300

# 本地检查配置
checks:
  syntax: true
  lint: true
  test: true
  typecheck: false
  build: false
```

## 详细文档

见 [项目主页](https://github.com/KuaaMU/auto-pr-workflow)
