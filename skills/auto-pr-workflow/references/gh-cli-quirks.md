# GitHub CLI Quirks

## `gh search prs` vs `gh pr view` field support

**Critical**: `gh search prs` and `gh pr view` support DIFFERENT JSON fields.

### `gh search prs` does NOT support:
- `mergedAt` — returns empty stdout + stderr error, silently fails
- Use `closedAt` instead for search results

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
