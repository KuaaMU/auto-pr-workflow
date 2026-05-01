# 2026-05-01 Nightly Scan: PR Status Audit

## Session Summary
Nightly cron scan of all open PRs. Found 15 open PRs (at 15-PR threshold). All PRs in stable states — no CI failures to fix, no new review feedback to address. No new projects searched (at threshold).

## PR Status Overview

### ✅ Merged (Recent)
| PR | Title | Merged |
|----|-------|--------|
| kontext-security/kontext-cli #88 | fix: add exponential backoff to sidecar heartbeat loop | 2026-05-01 |
| garritfra/cell #85 | fix: escape quotes and backslashes in .cell format labels | 2026-05-01 |
| tod-org/tod #1577 | refactor: replace once_cell with std::sync::LazyLock | 2026-04-30 |

### ✅ Approved (Ready to Merge)
| PR | Title | Notes |
|----|-------|-------|
| chenhg5/cc-connect #828 | feat: add DingTalk image message handling | APPROVED by chenhg5. All CI green. CLEAN merge state. Waiting for maintainer to click merge. |

### ✅ CI Passing (Waiting for Review)
| PR | Title | CI Status |
|----|-------|-----------|
| SleipnirGroup/Choreo #1479 | docs: add name argument to SmartDashboard.putData | ✅ All 5 C++ checks passing |
| melink14/rikaikun #2978 | fix: don't skip ～ when first character | ✅ All passing (Codacy, codecov, Mergify) |
| zenc-lang/zenc #417 | fix: generate Drop cleanup for unassigned Drop-typed expressions | ✅ triage passing. Copilot feedback addressed (3 inline comments replied). UNSTABLE mergeState (likely optional check). |
| go-openapi/runtime #422 | fix: handle literal colons in URL paths for denco router | ✅ CodeFactor + DCO passing. BLOCKED (needs review). |

### ⏸️ No CI (Expected for Fork PRs)
| PR | Title | Notes |
|----|-------|-------|
| JasonEtco/rss-to-readme #38 | fix: improve error messages for timeout and HTTP errors | No CI configured (only publish/update workflows). CLEAN merge state. |
| dswd/vpncloud #389 | ci: modernize GitHub Actions workflows | No checks on fork PR. UNSTABLE. |
| thinking-machines-lab/batch_invariant_ops #22 | fix: correct tooling config mismatches | No CI configured. CLEAN. |
| entireio/cli #1086 | fix: use agent-neutral wording | No checks on fork PR. BLOCKED. |
| gaoxiang12/lightning-lm #133 | fix: add mutex locking for imu_buffer_ | No checks on fork PR. CLEAN. |
| lucasgelfond/zerobrew #344 | fix: skip binary patching when prefix longer | No checks on fork PR. BLOCKED. |
| h4ckf0r0day/obscura #73 | fix: implement CharacterData DOM API | No checks on fork PR. CLEAN. |
| LaurieWired/tailslayer #19 | fix: handle mmap failure in hedged_reader | No checks on fork PR. CLEAN. |
| DeusData/codebase-memory-mcp #306 | fix: add .m extension to EXT_TABLE | No checks on fork PR. CLEAN. |

### 📋 No Review Yet (Various CI States)
| PR | Title | CI Status |
|----|-------|-----------|
| facebook/openzl #702 | fix: use ZL_free instead of free for ZL_malloc-allocated memory | BLOCKED (Meta CLA pass, needs review) |
| rtk-ai/rtk #1645 | fix(filters): remove max_lines cap from helm filter | BLOCKED (CLA pass, needs review) |
| beelzebub-labs/beelzebub #302 | fix: add context-based stop mechanism for data race | BLOCKED (no checks reported, needs review) |

## PR Count Changes Since Evening Scan
- **Evening scan**: 20 open PRs
- **Night scan**: 15 open PRs (-5)
- **Merged since evening**: kontext-cli #88 (new merge today)
- **Closed since evening**: 6 PRs closed (PostHog #3508, dingo #86, vite-plugin-css #166, consola #417, config-rs #751, daily-api #3836, mco #83)
- **New since evening**: 0 new PRs submitted

## Actions Taken
1. Verified all 15 open PRs' CI status via batch check
2. Confirmed kontext-cli #88 merged (new merge today!)
3. Confirmed cc-connect #828 still APPROVED + CLEAN (waiting for maintainer)
4. Verified zenc #417 Copilot feedback already addressed (3 inline comments replied)
5. No CI failures to fix across any PR
6. No new project search (at 15-PR threshold)

## Stats
- Total merged PRs: 12+ (kontext-cli, cell, tod, and earlier)
- Open PRs: 15 (at threshold)
- PRs approved: 1 (cc-connect #828)
- PRs with CI passing: 4 (Choreo, rikaikun, zenc, runtime)
- PRs with no CI: 9 (expected for fork PRs)
- PRs needing review: 3 (openzl, rtk, beelzebub)

## Next Steps
- cc-connect #828: CLEAN + APPROVED — waiting for chenhg5 to merge
- Monitor all 15 PRs for review feedback
- No new PRs until open count drops below 15
- Priority: push approved PRs to merge, respond to any review feedback
