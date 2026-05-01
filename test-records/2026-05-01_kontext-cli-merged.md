# Test Record: kontext-security/kontext-cli #88 — MERGED

**Date**: 2026-05-01
**Status**: ✅ MERGED
**Language**: Go
**Project**: kontext-security/kontext-cli (security CLI tool)

## PR Details

- **Title**: fix: add exponential backoff to sidecar heartbeat loop
- **URL**: https://github.com/kontext-security/kontext-cli/pull/88
- **Merged**: 2026-05-01T08:59:02Z
- **Changes**: +151 / -18 lines, 2 files

## Summary

Fixed issue #38: when network goes down, the heartbeat logs the same error every 30 seconds indefinitely, spamming logs. Added exponential backoff (30s → 60s → 120s → 240s → cap at 5min) with error deduplication and recovery logging.

## Key Changes

- Replace fixed 30s ticker with exponential backoff on consecutive failures
- Deduplicate error logs: only log on first occurrence and when error message changes
- Log recovery: print "heartbeat recovered after Xm Ys" when connectivity returns
- Reset backoff on success: return to 30s interval
- Extract `client` interface for testability
- Add 3 tests: deduplication, different errors, backoff calculation

## Key Learnings

- Go project with standard `go test` CI
- Clean merge with all CI passing
- Focused bug fix with tests (fix + regression tests = high value)
- Quick merge (~1 day from submission)

## Metrics

- Time to merge: ~1 day
- CI: All checks passed
- Reviews: No blocking feedback
- Tests added: 3 new tests
