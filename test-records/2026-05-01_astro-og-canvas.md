# Test Record: delucis/astro-og-canvas #172

**Date:** 2026-05-01
**PR:** https://github.com/delucis/astro-og-canvas/pull/172
**Status:** 🟡 OPEN (awaiting review)

## Summary

Add `bgImage` usage examples to the package README. Closes #76 (good first issue, documentation label).

## Project Info

- **Language:** TypeScript
- **Stars:** 260
- **Size:** 985KB (small)
- **CI:** GitHub Actions (pnpm + uvu tests, astro check typecheck)
- **Default branch:** `latest`

## Changes

Added a "Using `bgImage`" section to `packages/astro-og-canvas/README.md` with:
- Basic background image with `fit: 'cover'`
- Background image with positioning (single value and tuple)
- Background image combined with `bgGradient` overlay
- Using frontmatter image as background
- Note about path resolution

## Workflow

1. Searched TypeScript projects with good-first-issue labels
2. Found issue #76 (documentation, good first issue)
3. Owner explicitly welcomed PRs in issue comments
4. Cloned repo, read existing demo code for bgImage patterns
5. Added examples derived from `demo/src/pages/background-test/[path].ts`
6. Fork → branch → commit → push → gh pr create
7. PR #172 created

## Why This Project

- Small (985KB), fast to clone
- Has CI (pnpm + uvu tests)
- Owner actively responds to issues
- Issue was labeled "good first issue" + "documentation"
- TypeScript (testing language rotation)

## Lessons

- Documentation PRs are the safest first contribution
- Deriving examples from existing demo code ensures accuracy
- `latest` branch (not `main`) — always check default branch
