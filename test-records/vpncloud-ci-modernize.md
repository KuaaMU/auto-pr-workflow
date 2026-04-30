# Test Record: dswd/vpncloud CI Modernization

## Date: 2026-04-30

## Project Info
- **Repo**: dswd/vpncloud
- **Language**: Rust (edition 2021)
- **Stars**: ~388
- **PR**: https://github.com/dswd/vpncloud/pull/389

## Task: CI Modernization

### Analysis Findings
- `check.yml`: Used deprecated `actions/checkout@v2`, `actions-rs/toolchain@v1`, `actions-rs/cargo@v1`
- `audit.yml`: Used deprecated `actions/checkout@v2`, `actions-rs/audit-check@v1`
- Both only triggered on `push`, missing `pull_request`
- Project has `rustfmt.toml` with custom config, no clippy configuration
- Open PRs: none conflicting with CI changes (PR #386 adds release.yml only)

### Changes Made
**check.yml:**
- `actions/checkout@v2` → `v4`
- `actions-rs/toolchain@v1` → `dtolnay/rust-toolchain@stable`
- `actions-rs/cargo@v1` → direct `cargo` commands
- Added `pull_request` trigger to master
- Added `Swatinem/rust-cache@v2` for caching
- Added new `clippy` job: `cargo clippy --all-targets --all-features -- -D warnings`
- Added new `fmt` job: `cargo fmt --all -- --check`

**audit.yml:**
- `actions/checkout@v2` → `v4`
- `actions-rs/audit-check@v1` → `rustsec/audit-check@v2.0.0`
- Added `push`/`pull_request` triggers on Cargo file changes

### Local Verification
- ✅ `cargo check` - compiles successfully (5 pre-existing warnings, not from our changes)
- ✅ `cargo test` - 71 passed, 6 ignored, 0 failed
- ✅ Only `.github/workflows/` files modified

### Files Modified
- `.github/workflows/check.yml` (31 → 41 lines)
- `.github/workflows/audit.yml` (12 → 20 lines)

### Commit
```
ci: modernize GitHub Actions workflows
```
