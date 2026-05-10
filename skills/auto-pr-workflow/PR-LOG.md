# PR 提交记录

> auto-pr-workflow 技能的实战记录，每次提交 PR 后更新。

## 统计

- **总计**: 51 个 PR（外部项目）
- **已合并**: 20 (39.2%)
- **Open**: 16 (31.4%)
- **Closed/Rejected**: 15 (29.4%)

## 语言分布

| 语言 | 数量 |
|------|------|
| Go | 12 |
| Rust | 8 |
| TypeScript | 9 |
| C | 4 |
| C++ | 2 |
| Python | 4 |

## PR 列表

| # | 项目 | 语言 | PR | 描述 | 日期 | 状态 | 备注 |
|---|------|------|-----|------|------|------|------|
| 1 | mco | Python | [#83](https://github.com/mco-org/mco/pull/83) | fix: close stdout/stderr pipes in AcpTransport.close() | 2026-04 | ✅ merged | 首个 PR，自审抓 ValueError |
| 2 | config-rs | Rust | [#751](https://github.com/rust-cli/config-rs/pull/751) | fix: sort MapAccess entries for deterministic iteration | 2026-04 | ❌ closed | 维护者批评：应先讨论再 PR |
| 3 | consola | TS | [#417](https://github.com/unjs/consola/pull/417) | fix: handle emoji sequences in stringWidth | 2026-04 | 🟢 open | CodeRabbit 暂停 review |
| 4 | dingo | Go | [#86](https://github.com/i-love-flamingo/dingo/pull/86) | fix: detect circular singleton dependency | 2026-04 | 🟢 open | 自审抓 3 个 bug |
| 5 | beelzebub | Go | [#302](https://github.com/beelzebub-labs/beelzebub/pull/302) | fix: context-based stop for data race | 2026-04 | 🟢 open | |
| 6 | cell | Go | [#85](https://github.com/garritfra/cell/pull/85) | fix: escape quotes/backslashes in .cell labels | 2026-04 | ✅ merged | 第5个合并！ |
| 7 | rtk | Rust | [#1645](https://github.com/rtk-ai/rtk/pull/1645) | fix: remove max_lines cap from helm filter | 2026-04 | 🟢 open | 38K⭐, CLA ✅ |
| 8 | pi-mono | TS | [#4015](https://github.com/badlogic/pi-mono/pull/4015) | fix: correct path for ~/.agents/skills | 2026-04 | ❌ closed | auto-close 机制 |
| 9 | go-basher | Go | [#61](https://github.com/progrium/go-basher/pull/61) | fix: TOCTOU race in bash binary extraction | 2026-04 | ❌ closed | 维护者合并了其他实现 |
| 10 | codebase-memory-mcp | C | [#306](https://github.com/DeusData/codebase-memory-mcp/pull/306) | fix: add .m extension to EXT_TABLE | 2026-04 | 🟢 open | 首个 C 语言 PR |
| 11 | openzl | C | [#702](https://github.com/facebook/openzl/pull/702) | fix: use ZL_free for ZL_malloc memory | 2026-04 | ✅ merged | squash merged, API shows closed but commit on main |
| 12 | tailslayer | C++ | [#19](https://github.com/LaurieWired/tailslayer/pull/19) | fix: mmap failure in hedged_reader | 2026-04-30 | 🟢 open | 2.5K⭐ |
| 13 | zenc | C | [#417](https://github.com/zenc-lang/zenc/pull/417) | fix: Drop cleanup for unassigned expressions | 2026-04-30 | 🟢 open | 4.2K⭐ 编译器 |
| 14 | obscura | Rust | [#73](https://github.com/h4ckf0r0day/obscura/pull/73) | fix: CharacterData DOM API for jQuery | 2026-04-30 | ✅ merged | 2026-05-03 合并 |
| 15 | zerobrew | Rust | [#344](https://github.com/lucasgelfond/zerobrew/pull/344) | fix: skip binary patching when prefix longer | 2026-04-30 | 🟢 open | 7.2K⭐ |
| 16 | lightning-lm | C++ | [#133](https://github.com/gaoxiang12/lightning-lm/pull/133) | fix: mutex locking for imu_buffer_ | 2026-04-30 | 🟢 open | |
| 17 | cc-connect | Go | [#828](https://github.com/chenhg5/cc-connect/pull/828) | feat: DingTalk image message handling | 2026-04-30 | ✅ merged | 2026-05-05 合并 |
| 18 | entireio/cli | Go | [#1086](https://github.com/entireio/cli/pull/1086) | fix: agent-neutral wording in empty-state | 2026-04-30 | ✅ merged | 第6个合并！ |
| 19 | posthog-js | TS | [#3508](https://github.com/PostHog/posthog-js/pull/3508) | fix: consume fetch response body for CF Workers | 2026-04-30 | ❌ closed | 2026-05-04 关闭 |
| 20 | rikaikun | TS | [#2978](https://github.com/melink14/rikaikun/pull/2978) | fix: don't skip ～ as first character | 2026-04-30 | 🟢 open | CI 全绿, BEHIND main |
| 21 | tod | Rust | [#1577](https://github.com/tod-org/tod/pull/1577) | refactor: once_cell → std::sync::LazyLock | 2026-04 | ✅ merged | 首个合并！ |
| 22 | Choreo | TS | [#1479](https://github.com/SleipnirGroup/Choreo/pull/1479) | docs: add name arg to SmartDashboard.putData | 2026-04-30 | 🟢 open | |
| 23 | daily-api | TS | [#3836](https://github.com/dailydotdev/daily-api/pull/3836) | ci: add GitHub Actions workflow | 2026-04-30 | 🟢 open | CLA 刚修好 |
| 24 | vite-plugin-css | TS | [#166](https://github.com/marco-prontera/vite-plugin-css-injected-by-js/pull/166) | ci: update outdated GitHub Actions | 2026-04-30 | 🟢 open | |
| 25 | vpncloud | Rust | [#389](https://github.com/dswd/vpncloud/pull/389) | ci: modernize GitHub Actions | 2026-04-30 | 🟢 open | |
| 26 | batch_invariant_ops | Python | [#22](https://github.com/thinking-machines-lab/batch_invariant_ops/pull/22) | fix: tooling config + CI lint workflow | 2026-04-30 | 🟢 open | |
| 27 | clay | Go | [#351](https://github.com/chadbyte/clay/pull/351) | ci: run existing tests in CI | 2026-04-30 | ❌ closed | 维护者关闭 |
| 28 | kontext-cli | Go | [#88](https://github.com/kontext-security/kontext-cli/pull/88) | fix: heartbeat exponential backoff + log dedup | 2026-05-01 | ✅ merged | 180⭐, 首个Go合并！ |
| 29 | go-openapi/runtime | Go | [#422](https://github.com/go-openapi/runtime/pull/422) | fix: handle literal colons in URL paths | 2026-05-01 | ✅ merged | 262⭐ |
| 30 | rss-to-readme | TS | [#38](https://github.com/JasonEtco/rss-to-readme/pull/38) | fix: improve error messages for timeout/HTTP errors | 2026-05-01 | 🟢 open | 230⭐ |
| 31 | reasonix | TS | [#62](https://github.com/esengine/reasonix/pull/62) | test: add unit tests for clipboard.ts | 2026-05-01 | ✅ merged | 第4个合并！ |
| 32 | warp | Rust | [#9833](https://github.com/warpdotdev/warp/pull/9833) | feat: add Hermes CLI agent detection | 2026-05-01 | ✅ merged | 2026-05-08 合并 |
| 33 | dali2mqtt | Python | [#72](https://github.com/dgomes/dali2mqtt/pull/72) | test: expand test coverage for lamp and devicesnamesconfig | 2026-05-02 | ❌ closed | 维护者：测试在测 Mock |
| 34 | dali2mqtt | Python | [#73](https://github.com/dgomes/dali2mqtt/pull/73) | fix: handle non-numeric level values in Lamp setter | 2026-05-02 | ❌ closed | 维护者：测试在测 Mock，非真实逻辑 |
| 35 | wrpc | Go | [#1170](https://github.com/bytecodealliance/wrpc/pull/1170) | docs: add Unix Domain Socket transport example | 2026-05-01 | ✅ merged | 第8个合并！ByteCode Alliance |
| 36 | vrc-get | Rust | [#2853](https://github.com/vrc-get/vrc-get/pull/2853) | fix: prevent page refresh during backup and migration | 2026-05-02 | ❌ closed | 已修复 window.confirm 问题，等待维护者确认 |
| 37 | astro-og-canvas | TS | [#172](https://github.com/delucis/astro-og-canvas/pull/172) | docs: add bgImage usage examples to README | 2026-05-01 | ❌ closed | 2026-05-04 关闭，维护者不满意 |
| 38 | warp | Rust | [#9849](https://github.com/warpdotdev/warp/pull/9849) | fix: Windows context menu path encoding | 2026-05-01 | ❌ closed | 2026-05-06 关闭 |
| 39 | hassette | Python | [#644](https://github.com/NodeJSmith/hassette/pull/644) | ci: install fd-find for docker requirements tests | 2026-05-02 | ✅ merged | 第9个合并！ |

| 40 | gh-fuda | Go | [#84](https://github.com/tnagatomi/gh-fuda/pull/84) | feat: add --version flag | 2026-05-02 | ❌ closed | good-first-issue #76 |
| 41 | warp | Rust | [#9923](https://github.com/warpdotdev/warp/pull/9923) | fix: use CLI_AGENT_RICH_INPUT_OPEN flag for Ctrl+G predicate | 2026-05-02 | ❌ closed | Oz review addressed: removed EditorView gate, using CLI_AGENT_RICH_INPUT_OPEN only |
| 42 | claude-agent-sdk | Python | [#245](https://github.com/anthropics/claude-agent-sdk-python/pull/245) | fix: handle Windows command line length limit for --agents | 2025-10-23 | ✅ merged |  |
| 43 | AIInfra | Python | [#365](https://github.com/Infrasys-AI/AIInfra/pull/365) | update: OpenCompass实践 | 2025-12-22 | ✅ merged |  |
| 44 | AIInfra | Python | [#327](https://github.com/Infrasys-AI/AIInfra/pull/327) | fix: 修正启动方式，jupyter内一键自动运行 | 2025-11-10 | ✅ merged |  |
| 45 | AIInfra | Python | [#322](https://github.com/Infrasys-AI/AIInfra/pull/322) | fix: 补充对比验证TP内存优化 | 2025-11-05 | ✅ merged |  |
| 46 | AIInfra | Python | [#303](https://github.com/Infrasys-AI/AIInfra/pull/303) | fix: Code02Megatron分布式训练代码 | 2025-10-28 | ✅ merged |  |
| 47 | AIInfra | Python | [#285](https://github.com/Infrasys-AI/AIInfra/pull/285) | fix: Code01ZeRO实验代码修改 | 2025-10-15 | ✅ merged |  |
| 48 | AIInfra | Python | [#277](https://github.com/Infrasys-AI/AIInfra/pull/277) | fix: Code01ZeRO、Code04Expert | 2025-10-12 | ✅ merged |  |
| 49 | nautilus_trader | Python | [#3978](https://github.com/nautechsystems/nautilus_trader/pull/3978) | feat: AI native engine | 2026-05-02 | ❌ closed | 维护者关闭 |
| 50 | cc-connect | Go | [#852](https://github.com/chenhg5/cc-connect/pull/852) | fix(claudecode): replace dots in project key encoding | 2026-05-05 | ❌ closed | 2026-05-06 关闭，维护者选 #820 |

## 教训汇总

| PR | 教训 |
|-----|------|
| mco #83 | 不传参考代码 → 只 catch OSError 漏 ValueError |
| dingo #86 | 自审必须覆盖错误路径和并发场景 |
| rtk #1645 | Fork PR 必须从干净 upstream 分支创建 |
| go-basher #61 | 最小修复 vs 生产级修复的权衡 |
| config-rs #751 | 必须先开 Issue 讨论再提交实现，不要用 AI PR 模板 |
| pi-mono #4015 | 贡献者门控是常见模式 |
| codebase-memory-mcp #306 | C 项目首次构建慢（4min），用 background=true |
| openzl #702 | 不同组织 CLA 系统不同 |
| tailslayer #19 | C++ 中「返回值被忽略」是 SIGSEGV 常见根因 |
| zenc #417 | 编译器 bug 在 codegen 层，对比正常/异常路径 |
| obscura #73 | 浏览器 DOM API 缺失搜 globalThis.XXX = Node |
| zerobrew #344 | 测试是真相来源，CHANGELOG 是意图线索 |
| daily-api #3836 | git config user.name 必须匹配 GitHub 身份，否则 CLA 无法关联 |
| dali2mqtt #72 | 测试必须验证真实逻辑而非 Mock 行为；generator fixture 耗尽导致级联失败 |
| vrc-get #2853 | Tauri 环境中 window.confirm 不工作，需使用项目自带的 dialog 系统 |
| warp #9923 | Oz bot AI review can catch real issues; use specific flags over broad AIInput |

---

*最后更新: 2026-05-07
| 51 | cc-connect | Go | [#852](https://github.com/chenhg5/cc-connect/pull/852) | fix: replace dots in project key encoding | 2026-05-06 | ❌ closed | 维护者说重复 #820，将关闭 |