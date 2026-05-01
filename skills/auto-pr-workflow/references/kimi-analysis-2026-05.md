# Kimi 对 auto-pr-workflow 的分析 (2026-05-01)

来源: https://www.kimi.com/share/19de2ec3-c5f2-8453-8000-000055f4c0f5

## 核心判断

auto-pr-workflow 和 Memento-Skills 是**同构的**：都是"外部记忆 + 执行反馈 → 策略进化"的架构。但优化目标不同。

## auto-pr-workflow 的独特创新

### 1. 信任梯度（Trust Gradient）
把社交动态纳入优化目标。合并率作为 bandit 的 reward signal。

### 2. 对比学习（Contrastive Learning）
同项目内模仿风格（特异性），比 Memento-Skills 的跨任务复用更精细。
关键操作：把参考代码作为 context 传入，而不是让 agent 自己找。

### 3. 自审循环（Self-Review Loop）
编码 → 自审（第二个实例）→ 修复 → 再审 → 通过

### 4. 项目画像注册表
projects-registry.yml 是 POMDP 的信念状态更新。

## 硬边界

1. **灾难性遗忘** — prompt 空间的遗忘：SKILL.md 膨胀后早期教训被稀释
2. **反馈信号稀疏** — 合并率是极其稀疏的奖励，无响应有 10 种可能原因
3. **目标函数锁死** — 可能只选 easy 项目，陷入舒适区
4. **自指稳定性** — 缺陷 SKILL.md → 错误执行 → 错误归因 → 更糟的 SKILL.md

## 进化方向

### 短期
- 把反模式变成可执行技能
- 自动化自审循环
- 项目画像的主动学习

### 中期
- 合并率预测模型
- 跨项目迁移学习

### 长期
- Agent 自己发现新反模式（因果推断 + RL）

## 事件驱动架构建议

三层设计：
1. **事件总线** — pr_submitted/ci_failed/pr_merged/pr_rejected → 绑定记忆操作
2. **状态机** — 每个 PR 是长运行工作流，可持久化、可重放
3. **记忆唤醒** — watchers 在条件满足时主动注入 prompt（不是 agent 被动查）

### Watchers
- stale_pr_reminder: 7 天无更新 → 注入提醒
- merge_rate_monitor: 合并率 < 10% → 停止新 PR
- skill_outdated: 30 天未更新 → 回顾最近 PR

### 遗忘机制
- 90 天未触发的反模式 → 摘要后归档
- 180 天无活动的项目 → 冷存储

## 关键洞察

> "你的 Hermes 不是在使用一个 skill，它是在运行一个'自我记录、自我修正、自我迭代'的认知系统。auto-pr-workflow 是这个系统的'日记本'。"

> "当这个日记本足够厚时，agent 还能记住第一页写了什么吗？"
