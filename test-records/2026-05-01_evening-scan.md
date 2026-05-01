# 2026-05-01 Evening Scan: PR Status Audit

## Session Summary
Evening cron scan of all open PRs. Found 20 open PRs (over 15-PR threshold). 2 PRs approved and ready to merge. No new projects searched — focus on existing PRs.

## PR Status Overview

### ✅ Merged (Recent)
| PR | Title | Merged |
|----|-------|--------|
| garritfra/cell #85 | fix: escape quotes and backslashes in .cell format labels | 2026-05-01 |
| tod-org/tod #1577 | refactor: replace once_cell with std::sync::LazyLock | 2026-04-30 |

### ✅ Approved (Ready to Merge)
| PR | Title | Notes |
|----|-------|-------|
| PostHog/posthog-js #3508 | fix(core): consume fetch response body to prevent CF Workers warnings | APPROVED by turnipdabeets. BLOCKED by Vercel deployment (expected fork behavior). Greptile reviewed. |
| chenhg5/cc-connect #828 | feat: add DingTalk image message handling | APPROVED by chenhg5. CI all green. CLEAN merge state. |

### ✅ CI Passing (Waiting for Review)
| PR | Title | CI Status |
|----|-------|-----------|
| chadbyte/clay #351 | ci: run existing tests in CI pipeline | ✅ All passing |
| SleipnirGroup/Choreo #1479 | docs: add name argument to SmartDashboard.putData | ✅ All passing (5 checks) |
| melink14/rikaikun #2978 | fix: don't skip ～ when first character | ✅ All passing (codecov: all lines covered) |
| zenc-lang/zenc #417 | fix: generate Drop cleanup for unassigned Drop-typed expressions | ✅ triage passing |

### 🔧 CI Fixed / Review Addressed
| PR | Issue | Fix |
|----|-------|-----|
| KuaaMU/omnihive #8 | CodeRabbit: symlink ancestor escape in resolve_path | Canonicalize each intermediate path component during walk-up |
| KuaaMU/omnihive #8 | CodeRabbit: flaky test_fs_read_nonexistent | Use isolated temp dir with PID-based name |

### ⏸️ No CI (Expected for Fork PRs)
| PR | Title | Notes |
|----|-------|-------|
| dswd/vpncloud #389 | ci: modernize GitHub Actions workflows | No checks on fork PR |
| thinking-machines-lab/batch_invariant_ops #22 | fix: correct tooling config mismatches | No CI configured |
| entireio/cli #1086 | fix: use agent-neutral wording | No checks on fork PR |
| gaoxiang12/lightning-lm #133 | fix: add mutex locking for imu_buffer_ | No checks on fork PR |
| lucasgelfond/zerobrew #344 | fix: skip binary patching when prefix longer | No checks on fork PR |
| h4ckf0r0day/obscura #73 | fix: implement CharacterData DOM API | No checks on fork PR |
| LaurieWired/tailslayer #19 | fix: handle mmap failure in hedged_reader | No checks on fork PR |
| DeusData/codebase-memory-mcp #306 | fix: add .m extension to EXT_TABLE | No checks on fork PR |

### 📋 No Review Yet (Various CI States)
| PR | Title | CI Status |
|----|-------|-----------|
| facebook/openzl #702 | fix: use ZL_free instead of free for ZL_malloc-allocated memory | Meta CLA pass, Import pending |
| rtk-ai/rtk #1645 | fix(filters): remove max_lines cap from helm filter | CLA pass |
| i-love-flamingo/dingo #86 | fix: detect circular singleton dependency | No checks reported |
| beelzebub-labs/beelzebub #302 | fix: add context-based stop mechanism for data race | No checks reported |
| marco-prontera/vite-plugin-css-injected-by-js #166 | ci: update outdated GitHub Actions | No review decision |
| unjs/consola #417 | fix: handle emoji sequences in stringWidth | No review decision |
| rust-cli/config-rs #751 | fix: sort MapAccess entries for deterministic iteration | No review decision |
| dailydotdev/daily-api #3836 | ci: add GitHub Actions workflow | mergeable: UNKNOWN |
| mco-org/mco #83 | fix: close stdout/stderr pipes in AcpTransport.close() | No review decision |

## Actions Taken
1. Confirmed tod #1577 MERGED (2026-04-30)
2. Verified PostHog #3508 APPROVED (BLOCKED by Vercel — expected fork behavior)
3. Verified cc-connect #828 APPROVED (CLEAN — ready for maintainer to merge)
4. Full audit: 20 open PRs (over 15-PR threshold)
5. No new project search (at threshold)

## Stats
- Total merged PRs: 10+
- Open PRs: 20 (over threshold)
- PRs approved: 2 (PostHog #3508, cc-connect #828)
- PRs with CI passing: 4 (waiting for review)
- PRs with no CI: 8 (expected for fork PRs)
- PRs with no review yet: 6

## Next Steps
- PostHog #3508: BLOCKED by Vercel (expected). Wait for maintainer to merge despite Vercel status.
- cc-connect #828: CLEAN, waiting for chenhg5 to merge.
- Monitor all 20 PRs for review feedback.
- No new PRs until open count drops below 15.
- Priority: push approved PRs to merge, respond to any review feedback.
