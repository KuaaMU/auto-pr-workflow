# Anti-Patterns Library

Real failure patterns extracted from PR test records. Each entry documents what went wrong, why, and how to prevent it.

## Project Selection

### 1. Contributor Gate Auto-Close

**Pattern**: PR is auto-closed or blocked because the project requires contributor status, CLA signing, or org membership that an external AI agent cannot obtain.

**Description**: Some projects gate contributions behind CLA agreements, org-level contributor status, or other bureaucratic requirements that require human intervention or browser-based authentication. PRs from external forks are automatically blocked.

**Real Example**: `dailydotdev/daily-api` PR #3836 — CLA pending, cannot sign without browser-based GitHub OAuth credentials. `rtk-ai/rtk` PR #1645 — CLA pending after base branch fix.

**Prevention**:
- Check CONTRIBUTING.md for CLA/DCO requirements before starting work
- Search for CLA bot comments in recent closed PRs: `gh pr list --state closed --search "CLA"`
- Skip projects requiring signed CLAs unless you can automate the signing process

### 2. Maintainer Merged Different Implementation

**Pattern**: Your PR addresses a real issue, but the maintainer closes it and merges their own (often more thorough) implementation instead.

**Description**: The maintainer acknowledges the problem but prefers their own solution, which may include production-grade concerns your PR missed (sync/fsync, cleanup, concurrency tests, etc.).

**Real Example**: `progrium/go-basher` PR #61 — Fixed TOCTOU race condition with minimal `os.Rename` approach. Maintainer closed it and merged PR #63 with a more thorough fix: explicit `Sync()`, `Chmod()`, stale temp file cleanup, and 16-goroutine concurrency test.

**Prevention**:
- Study the maintainer's coding style and quality bar before submitting
- For concurrency/crash-safety fixes, always include: `fsync`/`Sync()`, explicit permissions, cleanup of partial state, and concurrency tests
- Ask: "Would the maintainer write this themselves?" If not, level up the quality
- Read the maintainer's recent merged PRs to understand their standards

### 3. Project Too Large for Environment

**Pattern**: Target project is too large or requires infrastructure (Docker, GPU, databases) that the execution environment doesn't have.

**Description**: Claude Code times out analyzing large codebases, or tests fail because required services aren't available.

**Real Example**: `fakecloud` (Rust AWS emulator, 17MB) — Claude Code timed out twice at 600s trying to analyze RDS persistence. Required Docker for E2E tests.

**Prevention**:
- Always run environment assessment first: check disk, RAM, Docker, language toolchains
- Reject projects > 5MB or requiring Docker when Docker is unavailable
- Prefer projects with pure unit tests (no external service dependencies)

## Trust & Maintainer Relations

### 4. No Maintainer Response

**Pattern**: PR is submitted but the maintainer never responds — no review, no CI trigger, no merge, no rejection.

**Description**: Many solo-maintained projects have slow or absent review cycles. The PR sits indefinitely.

**Real Example**: Multiple PRs in the 2026-04-30 session: `i-love-flamingo/dingo` #86, `garritfra/cell` #85, `mco-org/mco` #83, `dswd/vpncloud` #389, `thinking-machines-lab/batch_invariant_ops` #22 — all open with no maintainer response.

**Prevention**:
- Before submitting, check maintainer activity: `gh api repos/{owner}/{repo} --jq '.pushed_at'`
- Check average time-to-merge for recent external PRs
- Prefer projects with multiple maintainers or recent merge activity (< 30 days)
- If no response after 2 weeks, consider a polite follow-up comment

### 5. Fork PR CI Not Triggering

**Pattern**: After submitting a PR from a fork, `gh pr checks` shows "no checks reported" — CI never runs.

**Description**: Many projects configure CI with only `pull_request` triggers (no `push`). Fork PRs require maintainer approval before CI runs, which may never happen.

**Real Example**: `marco-prontera/vite-plugin-css-injected-by-js` PR #166, `progrium/go-basher` PR #61 — CI not triggered on fork PRs.

**Prevention**:
- Check if the project's CI triggers on `push` (fork-friendly) vs only `pull_request` (requires approval)
- Look at recent external PRs — did CI run for them?
- In PR description, note "CI will run on maintainer approval" to set expectations
- Don't assume PR is broken if CI doesn't trigger

### 6. Anti-AI / Anti-Bot Sentiment

**Pattern**: Maintainer rejects PRs perceived as AI-generated or bot-submitted, regardless of quality.

**Description**: Some maintainers have explicit or implicit policies against automated/AI contributions. They may close PRs without reviewing the code.

**Real Example**: Referenced in SKILL.md case studies — projects with anti-bot language in Issues or CONTRIBUTING.md.

**Prevention**:
- Search for AI/bot sentiment: `gh issue list --search "AI OR bot OR automated OR spam" --state closed`
- Check recently closed PRs for anti-AI rejection patterns
- If sentiment is negative, stop — don't try to "prove quality"
- First contribution should be docs/typo only to test receptiveness

## Technical

### 7. Python Tooling Config Mismatch

**Pattern**: Project configures linting/formatting tools (black, flake8, isort) but the configuration is broken or contradictory, so the tools fail when actually run.

**Description**: Config files exist but target wrong Python version, have mismatched line lengths, or are incomplete. Looking at the config alone doesn't reveal the problem — you must actually run the tools.

**Real Example**: `thinking-machines-lab/batch_invariant_ops` — `pyproject.toml` set `target-version = ['py38']` but code uses `match/case` (Python 3.10+), causing black to fail. No `.flake8` file meant flake8 defaulted to 79-char lines vs black's 100.

**Prevention**:
- Always run `black --check .`, `flake8 .`, `isort --check .` during analysis — don't trust config files
- Check Python version used in code (match/case, walrus operator) vs configured target-version
- Ensure flake8 and black agree on line length

### 8. Test Process Hangs

**Pattern**: Tests pass but the process never exits, causing CI timeout.

**Description**: Open handles (database connections, WebSocket servers, event listeners) prevent Node.js from exiting naturally.

**Real Example**: `chadbyte/clay` — `require('../lib/server')` loaded ws module which kept the event loop alive. All 23 tests passed but CI timed out at 120s.

**Prevention**:
- Always run tests with timeout: `timeout 60 node --test test/*.test.js`
- Use `--test-force-exit` for Node.js tests
- Check for open handles: `node --inspect` or `why-is-node-running`
- Prefer projects with `test` scripts in package.json that handle cleanup

### 9. CI Workflow Overlap

**Pattern**: New CI workflow duplicates functionality of existing workflows, causing confusion or redundant checks.

**Description**: The init/analysis phase doesn't check existing `.github/workflows/` before creating new ones.

**Real Example**: `chadbyte/clay` — New `ci.yml` overlapped with existing `pr-checks.yml`. Fixed by switching to complementary strategy (syntax check vs import check).

**Prevention**:
- Always read existing workflows before creating new ones
- Design CI to complement, not duplicate
- If existing CI covers the same ground, fix gaps in the existing workflow instead

### 10. Generated File Formatting Noise

**Pattern**: `go fmt`, `prettier`, or other formatters reformat generated/boilerplate files, creating noisy diffs that distract from the real change.

**Description**: Generated files from older tool versions don't match current formatter expectations.

**Real Example**: `progrium/go-basher` — `go fmt` auto-formatted build-tagged bindata files, adding `//go:build` directives. Had to revert and only commit hand-written code.

**Prevention**:
- Only commit changes to hand-written files
- Run formatters with path exclusions for generated code
- Check `.gitattributes` or generation markers before formatting

## Process

### 11. Wrong Base Branch

**Pattern**: PR targets `main` but project requires PRs to target `develop` or another branch.

**Description**: CONTRIBUTING.md specifies branch conventions but the agent defaults to `main`.

**Real Example**: `rtk-ai/rtk` PR #1645 — targeted `master` but project requires `develop`. Fixed via GitHub API.

**Prevention**:
- Read CONTRIBUTING.md branch conventions before creating PR
- Check `git branch -a` for develop/development branches
- Use `--base` flag explicitly in `gh pr create`

### 12. Skipping Fork Step

**Pattern**: Agent clones upstream repo directly, makes changes, then `git push` fails with 403.

**Description**: External contributions require forking first, but the workflow skipped this step.

**Real Example**: `tod-org/tod` PR #1577 — Push to upstream returned 403. Had to fork retroactively.

**Prevention**:
- Always fork first: `gh repo fork owner/repo --clone=false`
- Add fork remote before making changes
- Make this the first step in the workflow, not an afterthought

### 13. Staging Unwanted Files

**Pattern**: `.venv/`, `node_modules/`, `__pycache__/`, or other generated directories get accidentally committed.

**Description**: Missing or incomplete `.gitignore` allows build artifacts into the commit.

**Real Example**: `thinking-machines-lab/batch_invariant_ops` — `.venv` accidentally staged. Had to add `.gitignore` and reset staging.

**Prevention**:
- Always check staged files: `git diff --cached --name-only`
- Add `.gitignore` before first commit if missing
- Never use `git add .` — always add specific files

### 14. CodeRabbit / AI Review Finding Real Issues

**Pattern**: AI code review (CodeRabbit, Copilot) finds legitimate issues in the submitted code that the agent missed.

**Description**: AI reviewers catch edge cases, spec compliance issues, and style violations that the coding agent overlooked.

**Real Example**: `unjs/consola` PR #417 — CodeRabbit found 3 issues: emoji subdivision flag handling, missing numeric separators, and hex escape case. `KuaaMU/omnihive` #8 — CodeRabbit found cost accumulation only in success path and missing shell injection regression test.

**Prevention**:
- Treat AI review feedback as high-priority — address promptly
- Run `eslint --fix` before submitting to catch auto-fixable issues
- Self-review for spec compliance (Unicode, numeric formats, etc.)
