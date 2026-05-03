# PR-LOG — Auto-PR Workflow Test Results

Last updated: 2026-05-03 19:15 UTC

## Summary

| Metric | Count |
|--------|-------|
| Total PRs submitted | 42 |
| Merged ✅ | 8 |
| Closed/Rejected ❌ | 6 |
| Open 🟢 | 28 |
| Merge rate | 19.0% (8/42) |

## Merged PRs ✅

| # | Repo | Title | Merged |
|---|------|-------|--------|
| 1 | esengine/reasonix #62 | test: add unit tests for clipboard.ts | 2026-05-01 |
| 2 | go-openapi/runtime #422 | fix: handle literal colons in URL paths for denco router | 2026-05-01 |
| 3 | kontext-security/kontext-cli #88 | fix: add exponential backoff to sidecar heartbeat loop | 2026-05-01 |
| 4 | garritfra/cell #85 | fix: escape quotes and backslashes in .cell format labels | 2026-05-01 |
| 5 | tod-org/tod #1577 | refactor: replace once_cell with std::sync::LazyLock | 2026-04-30 |
| 6 | bytecodealliance/wrpc #1170 | docs: add Unix Domain Socket transport example | 2026-05-01 |
| 7 | entireio/cli #1086 | fix: use agent-neutral wording in explain empty-state message | 2026-05-01 |
| 8 | NodeJSmith/hassette #644 | ci: install fd-find so docker requirements tests run in CI | 2026-05-02 |

## Closed/Rejected ❌

| # | Repo | Title | Closed |
|---|------|-------|--------|
| 1 | dgomes/dali2mqtt #72 | test: expand test coverage for lamp and devicesnamesconfig | 2026-05-01 |
| 2 | badlogic/pi-mono #4015 | fix: show correct path for ~/.agents/skills in config selector | 2026-04-30 |
| 3 | rust-cli/config-rs #751 | fix: sort MapAccess entries for deterministic iteration | 2026-05-01 |
| 4 | progrium/go-basher #61 | fix: prevent TOCTOU race condition when extracting bash binary | 2026-04-30 |
| 5 | facebook/openzl #702 | fix: use ZL_free instead of free for ZL_malloc-allocated memory | 2026-05-01 |
| 6 | nautechsystems/nautilus_trader #3978 | Feat/ai native engine | 2026-05-02 |

## Open PRs 🟢

### Ready for merge (APPROVED + CLEAN)
| Repo | PR | Title |
|------|----|-------|
| chenhg5/cc-connect | #828 | feat: add DingTalk image message handling |

### Clean — awaiting review
| Repo | PR | Title |
|------|----|-------|
| LaurieWired/tailslayer | #19 | fix: handle mmap failure in hedged_reader constructor |
| thinking-machines-lab/batch_invariant_ops | #22 | fix: correct tooling config mismatches and add CI lint workflow |
| gaoxiang12/lightning-lm | #133 | fix: add mutex locking for imu_buffer_ concurrent access |
| h4ckf0r0day/obscura | #73 | fix: implement CharacterData DOM API for jQuery DataTables |
| DeusData/codebase-memory-mcp | #306 | fix: add .m extension to EXT_TABLE for content-based disambiguation |
| JasonEtco/rss-to-readme | #38 | fix: improve error messages for timeout and HTTP errors |
| tnagatomi/gh-fuda | #84 | feat: add --version flag |

### Changes requested
| Repo | PR | Title | Note |
|------|----|-------|------|
| delucis/astro-og-canvas | #172 | docs: add bgImage usage examples to README | Simplified to inline example per maintainer feedback |
| warpdotdev/warp | #9923 | fix: allow Ctrl+G to toggle CLI Agent Rich Input when editor has focus | Oz bot suggested fix, applied |ner feedback |

### Blocked — awaiting review
| Repo | PR | Title |
|------|----|-------|
| melink14/rikaikun | #2978 | fix: don't skip ～ when it's the first character |
| warpdotdev/warp | #9833 | feat: add Hermes CLI agent detection and configuration |
| SleipnirGroup/Choreo | #1479 | docs: add name argument to SmartDashboard.putData |
| rtk-ai/rtk | #1645 | fix(filters): remove max_lines cap from helm filter |
| beelzebub-labs/beelzebub | #302 | fix: add context-based stop mechanism to fix data race |
| lucasgelfond/zerobrew | #344 | fix: skip binary patching when new prefix is longer |
| mco-org/mco | #83 | fix: close stdout/stderr pipes in AcpTransport.close() |

### Approved but blocked (expected fork behavior)
| Repo | PR | Title | Note |
|------|----|-------|------|
| PostHog/posthog-js | #3508 | fix(core): consume fetch response body to prevent CF Workers warnings | APPROVED; browser tests failing (investigating) |

### Behind — needs rebase
| Repo | PR | Title |
|------|----|-------|
| dailydotdev/daily-api | #3836 | ci: add GitHub Actions workflow for lint, typecheck, and tests |
| i-love-flamingo/dingo | #86 | fix: detect circular singleton dependency instead of deadlocking |

### Unstable (non-required checks)
| Repo | PR | Title | Note |
|------|----|-------|------|
| unjs/consola | #417 | fix: handle emoji sequences in stringWidth for correct box alignment | CodeRabbit reviewed |
| marco-prontera/vite-plugin-css-injected-by-js | #166 | ci: update outdated GitHub Actions and improve CI reliability | |
| dswd/vpncloud | #389 | ci: modernize GitHub Actions workflows | |
| chadbyte/clay | #351 | ci: run existing tests in CI pipeline | |
| dgomes/dali2mqtt | #73 | fix: handle non-numeric level values in Lamp setter | |
| vrc-get/vrc-get | #2853 | fix: prevent page refresh during backup and migration | |
| zenc-lang/zenc | #417 | fix: generate Drop cleanup for unassigned Drop-typed expressions | |
| warpdotdev/warp | #9849 | fix(windows): context menu "Open Warp in new tab" navigates to home dir | |