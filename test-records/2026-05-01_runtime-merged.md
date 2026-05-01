# Test Record: go-openapi/runtime #422

**Date:** 2026-05-01
**PR:** https://github.com/go-openapi/runtime/pull/422
**Status:** ✅ MERGED

## Summary

Fix literal colons in URL paths for denco router. The denco router uses `:` as a parameter delimiter, but `:` is a valid character in URL path segments per RFC 3986. Routes like `/allow/{serverName}/tokenlist:add` were being misinterpreted.

## Project Info

- **Language:** Go
- **Stars:** ~200
- **Size:** Medium
- **CI:** GitHub Actions (Go test matrix)

## Changes

- Handle literal colons in URL path segments for the denco router
- Fix routes like `/allow/{serverName}/tokenlist:add` being misinterpreted

## Workflow

1. Identified issue #352 reporting the bug
2. Analyzed denco router's parameter parsing logic
3. Fixed the colon handling in URL path segments
4. CI passed on all matrix jobs
5. Merged by maintainer on 2026-05-01

## Lessons

- Router parameter parsing is a common source of bugs when special characters overlap with delimiters
- Go projects with good CI matrices are reliable targets
