# GitHub CLI Quirks

## `gh search prs` vs `gh pr view` field support

**Critical**: `gh search prs` and `gh pr view` support DIFFERENT JSON fields.

### `gh search prs` does NOT support:
- `mergedAt` — returns empty stdout + stderr error, silently fails
- Use `closedAt` instead for search results
- `--state merged` — INVALID flag value, only `open|closed` are valid
- Use `--merged` as a standalone flag instead: `gh search prs --author @me --merged`

### Verified workflow for PR status checking:

```bash
# Step 1: Get PR lists (use supported fields only)
gh search prs --author @me --state open --json number,title,repository,createdAt,url
gh search prs --author @me --merged --json number,title,repository  # NO mergedAt
gh search prs --author @me --state closed --json number,title,repository,closedAt

# Step 2: ALWAYS verify individual PR state with gh pr view (ground truth)
gh pr view <NUM> --repo <OWNER/REPO> --json state,mergedAt,reviewDecision,statusCheckRollup,comments

# Step 3: Check stderr and exit code — empty stdout ≠ no data
# If exit code != 0 or stderr has content, the COMMAND failed, not the data
```

### Common mistake pattern:
1. `gh search prs --merged --json ...mergedAt` → stderr error, stdout empty
2. Python script parses empty stdout → concludes 0 merged PRs
3. **Wrong conclusion** — merged PRs exist, just the field query failed

### Prevention:
- Never use a JSON field without checking `gh search prs --help` for available fields
- Always check stderr when piping to Python/JSON parser
- Cross-validate search results with `gh pr view` on individual PRs

## Fork PR CI issues

Most GitHub repos do NOT run CI on fork PRs without maintainer approval. This is the #1 blocker for auto-pr-workflow PRs.

**Signals**: `gh pr checks` returns "no checks reported", CI status is "none"

**Mitigation**: Note in PR description that "CI will run on review" — maintainer needs to approve CI first.

## Backticks in `gh pr create --body`

**Problem**: Backticks in the `--body` argument cause bash parsing errors because bash interprets them as command substitution.

**Symptoms**: 
- `extension/data.ts: Permission denied` — bash tries to execute file paths as commands
- `result.length: command not found` — bash tries to execute code inside backticks

**Solution**: Use `gh api` to create/update the PR body instead:

```bash
# Instead of:
gh pr create --body "Changes to \`file.ts\` with \`result.length\`"

# Use:
gh api repos/OWNER/REPO/pulls -X POST --field title="..." --field body='...' --field head="..." --field base="main"
```

**Or** escape backticks with backslash: `\`file.ts\``

## GitHub Projects (classic) deprecation

**Problem**: `gh pr view` and `gh issue view` fail with:
```
GraphQL: Projects (classic) is being deprecated in favor of the new Projects experience
```

**Cause**: The repo still references deprecated GitHub Projects (classic) in its PR/issue metadata.

**Workaround**: Use `gh api` directly instead:
```bash
# Instead of:
gh issue view 190 --repo melink14/rikaikun

# Use:
gh api repos/melink14/rikaikun/issues/190 | jq '{title, body: .body[:500], labels: [.labels[].name]}'
```

This bypasses the GraphQL field that triggers the deprecation error.

## `--jq` complex templates silently produce literal text

**Problem**: `gh pr view --json reviews --jq '{reviews: [.reviews[] | {author: .author.login, state: .state}]}'` outputs the literal jq template text `{reviews: [.reviews[] | ...]}` instead of evaluated JSON.

**Root cause**: Bash brace expansion and quoting interact badly with jq's `{}` syntax. Even with double-quotes, nested braces/brackets get mangled.

**Symptoms**: Output looks like `{author}: {body[:300]}` — literal template, not data.

**Solution — parse raw JSON in code instead of complex --jq**:
```bash
# ❌ Breaks silently
gh pr view $NUM --repo $REPO --json reviews,comments --jq '{reviews: [.reviews[] | {author: .author.login}]}'

# ✅ Get raw JSON, parse in Python/Node
gh pr view $NUM --repo $REPO --json reviews,comments
# Then parse the JSON output in your script
```

**Simple --jq filters still work**: `.reviews | length`, `.[].title`, single-level projections.
**Rule of thumb**: If the --jq template has nested `{}` or `[]` iteration, get raw JSON instead.

## Fetching fork PR branch for local fix

**Problem**: Need to locally fix a fork PR (e.g., amend commit author for CLA). The PR branch exists on the fork, not upstream.

**Correct pattern**:
```bash
# Clone YOUR fork (not upstream)
git clone https://github.com/YOUR_USER/REPO.git
cd REPO

# Fetch the PR from UPSTREAM (where the PR was opened)
git remote add upstream https://github.com/UPSTREAM/REPO.git
git fetch upstream refs/pull/{NUM}/head:pr-{NUM}
git checkout pr-{NUM}

# Fix, amend, force-push to YOUR fork's branch
git commit --amend --author="YourName <noreply@github.com>" --no-edit
git push origin pr-{NUM}:{branch-name} --force
```

**Common mistake**: Trying `git fetch origin refs/pull/{NUM}/head` on the fork — this ref only exists on the upstream repo.

## CLA fix: commit author mismatch

**Problem**: CLA bot shows "not signed" even after signing. Root cause is commit author is system default (e.g., `Ubuntu <ubuntu@localhost.localdomain>`).

**Diagnosis**:
```bash
gh pr view {NUM} --repo {OWNER/REPO} --json commits --jq '.commits[] | {oid: .oid[:8], author: .authors[0]}'
# If author shows ubuntu/root/system default → mismatch
```

**Fix** (see "Fetching fork PR branch" above for full flow):
```bash
git commit --amend --author="GitHubUsername <ID+username@users.noreply.github.com>" --no-edit
git push origin pr-{NUM}:{branch} --force
```

**Verification**: `gh pr checks {NUM} --repo {OWNER/REPO}` — CLA should go from `pending` to `pass` within seconds.
