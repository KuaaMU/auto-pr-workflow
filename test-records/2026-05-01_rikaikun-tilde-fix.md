# 2026-05-01 rikaikun — Handle ～ properly (TypeScript)

## Project
- **Name**: melink14/rikaikun
- **Language**: TypeScript
- **Stars**: 475
- **Type**: Chrome extension for Japanese dictionary lookup

## Issue
- **Number**: #190
- **Title**: Handle ～ properly
- **Labels**: bug, easy, good first issue, P1
- **Age**: Open since 2020

## Analysis
### Problem
The ～ character (J_TILDE, U+FF5E) was always skipped during dictionary lookup normalization, even when it appeared as the first character. This caused lookups to fail when the input started with ～, since it has standalone meaning.

### Reference
The issue referenced rikaichamp's implementation which already handled this case:
```ts
else if (c == 0xff5e && i > 0) {
    // ignore ～ (but only if it's in the middle/end of a word)
    previous = 0;
    continue;
}
```

## PR
- **Number**: #2978
- **Title**: fix: don't skip ～ when it's the first character
- **URL**: https://github.com/melink14/rikaikun/pull/2978
- **Branch**: fix/tilde-first-char

## Changes
1. **extension/data.ts**: Modified SKIPPABLE check to only skip J_TILDE when `result.length > 0`
2. **extension/character_info.ts**: Updated TODO comment to reflect the fix
3. **extension/test/data_test.ts**: Added test for standalone ～ lookup

## Strategy
- **Direction**: Bug fix (P1, easy, good first issue)
- **Risk**: Low — minimal change, clear reference implementation
- **Trust level**: First contribution to this project

## Execution
- **Approach**: Read existing code → understand SKIPPABLE mechanism → apply targeted fix → add test
- **Time**: ~15 minutes (clone, analyze, fix, commit, push, create PR)
- **Issues**: npm install timed out (network), could not run tests locally

## Learnings
1. **Shallow clone works for timeout-prone repos**: `git clone --depth 1` succeeded when full clone timed out
2. **Backticks in gh pr create --body cause bash parsing errors**: Use `gh api` to update PR body instead
3. **Projects (classic) deprecation**: Some repos still reference deprecated GitHub Projects, causing GraphQL errors with `gh pr view`

## Status
- [ ] CI passing
- [ ] Review received
- [ ] Merged
