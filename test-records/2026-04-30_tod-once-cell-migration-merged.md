# Test Record: tod-org/tod — once_cell → std::sync::LazyLock Migration

## Test Metadata
- **Date**: 2026-04-30
- **Tester**: auto-pr-workflow (automated)
- **Test Type**: merge
- **Duration**: ~2 days (submitted Apr 28, merged Apr 30)

## Target Project
- **Repository**: tod-org/tod
- **URL**: https://github.com/tod-org/tod
- **Language**: Rust
- **Stars**: ~300+
- **CI Status**: ✅ Yes (GitHub Actions)
- **Existing Config**: CodeRabbit, gitleaks (org-level, pre-existing failure)

## Test Objectives
- [x] Replace deprecated `once_cell` crate with `std::sync::LazyLock` (stabilized in Rust 1.80)
- [x] Verify all tests pass
- [x] Get PR merged

## Execution Log

### Phase 1: Analysis
- Identified that `once_cell::sync::Lazy` can be replaced with `std::sync::LazyLock`
- Checked Rust edition and MSRV to confirm `LazyLock` is available
- Found all usages of `once_cell` in the codebase

### Phase 2: Implementation
- Replaced all `once_cell::sync::Lazy` with `std::sync::LazyLock`
- Removed `once_cell` from dependencies in Cargo.toml
- Ran `cargo test` to verify all tests pass

### Phase 3: Submission
- **PR Created**: [PR #1577](https://github.com/tod-org/tod/pull/1577)
- All CI checks passed (except gitleaks which is a pre-existing org-level issue)
- PR merged on 2026-04-30T06:51:26Z

## Issues Encountered

### Issue 1: Gitleaks CI failure
- **Symptom**: Gitleaks check fails on all PRs
- **Root Cause**: Org-level gitleaks configuration requires a license key that isn't set
- **Solution**: Pre-existing issue, not related to our changes
- **Prevention**: N/A — org-level config issue

## Conclusions

### What Worked Well
- Simple, focused change (dependency modernization)
- All tests passed without modification
- Quick merge (2 days)

### What Needs Improvement
- None — this was a clean PR

### Action Items
- [x] Record test result

## Related
- PR: https://github.com/tod-org/tod/pull/1577
- Merge commit: 28d4e459c419b6f43c447f6a6535084d7f86923b
