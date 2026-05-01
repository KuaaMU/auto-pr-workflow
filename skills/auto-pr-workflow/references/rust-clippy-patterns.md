# Rust Clippy Fix Patterns

Common Clippy fixes encountered during auto-pr-workflow. Each pattern shows the before/after with context on when to use which variant.

## `unnecessary_sort_by` → `sort_by_key`

Clippy lint: `clippy::unnecessary_sort_by`
Triggered when `sort_by` closure just compares one field.

### Pattern 1: Descending sort (Reverse)

```rust
// ❌ Before
rules.sort_by(|a, b| b.priority.cmp(&a.priority));

// ✅ After
rules.sort_by_key(|r| std::cmp::Reverse(r.priority));
```

**When**: Sorting by a single field in descending order. `Reverse` wraps the key to invert the comparison.

### Pattern 2: Ascending sort (non-Copy field)

```rust
// ❌ Before
tasks.sort_by(|a, b| a.task_id.cmp(&b.task_id));

// ✅ After
tasks.sort_by_key(|t| t.task_id.clone());
```

**When**: Sorting by a single field in ascending order where the field is `Ord` but not `Copy` (e.g., `String`). Requires `.clone()` because `sort_by_key` takes ownership of the key.

**Note**: If the field is `Copy` (e.g., `i32`, `usize`), no `.clone()` needed:
```rust
items.sort_by_key(|item| item.order);  // Copy type, no clone
```

### Pattern 2b: Case-insensitive ascending sort

```rust
// ❌ Before
results.sort_by(|a, b| a.name.to_lowercase().cmp(&b.name.to_lowercase()));

// ✅ After
results.sort_by_key(|a| a.name.to_lowercase());
```

**When**: Sorting by a string field case-insensitively. `to_lowercase()` returns an owned `String`, so no `.clone()` needed — it's already owned.

### Pattern 3: Nested field extraction

```rust
// ❌ Before
items.sort_by(|a, b| {
    let a_name = a["name"].as_str().unwrap_or("");
    let b_name = b["name"].as_str().unwrap_or("");
    a_name.cmp(b_name)
});

// ✅ After
items.sort_by_key(|item| item["name"].as_str().unwrap_or("").to_string());
```

**When**: The sort key requires extraction/computation from the item. Must convert `&str` to `String` to own the value.

**Pitfall**: Don't forget `.to_string()` when the extracted value is a reference — `sort_by_key` requires the key to be owned.

### Multi-field sort (not a Clippy issue, but related)

When sorting by multiple fields, `sort_by` is still correct — Clippy won't flag it:

```rust
// This is fine, Clippy won't complain
items.sort_by(|a, b| {
    a.priority.cmp(&b.priority)
        .then(a.name.cmp(&b.name))
});
```

## Quick Reference

| Original | Clippy Fix | Key Type |
|----------|-----------|----------|
| `sort_by(\|a,b\| b.x.cmp(&a.x))` | `sort_by_key(\|r\| Reverse(r.x))` | `Copy` + descending |
| `sort_by(\|a,b\| a.x.cmp(&b.x))` | `sort_by_key(\|t\| t.x.clone())` | `Ord` + ascending |
| `sort_by(\|a,b\| { ... cmp })` | `sort_by_key(\|item\| expr.to_string())` | computed + owned |
| `sort_by(\|a,b\| multi-field)` | Keep `sort_by` | multi-field |

## Verification

After fixing, run:
```bash
cargo clippy -- -D warnings 2>&1 | grep -i "sort_by"
```

Should return empty. If it returns results, there are more instances to fix.

## `dead_code` — Unused Function After Refactoring

Clippy lint: `dead_code` (implied by `-D warnings`)
Triggered when a function is no longer called after code changes.

### When This Happens

When you replace a function call with inline logic or a new implementation:
```rust
// Old code: called normalize_path_lexical()
// New code: inline symlink-aware resolution
// → normalize_path_lexical() is now dead code
```

### Fix Options

**Option 1: Remove the function** (preferred if truly unused)
```bash
# Check if it's used anywhere
grep -rn "normalize_path_lexical" src/ --include="*.rs"
# If only the definition remains → delete it
```

**Option 2: Suppress the warning** (if keeping for future use)
```rust
#[allow(dead_code)]
fn normalize_path_lexical(path: &Path) -> PathBuf {
    // ...
}
```

**Option 3: Add a `_` prefix** (Rust convention for intentionally unused)
```rust
fn _normalize_path_lexical(path: &Path) -> PathBuf {
    // ...
}
```

### Prevention

After refactoring that removes a function call, always check:
```bash
# Find the old function name and check for callers
grep -rn "old_function_name" crates/ --include="*.rs"
# If only the definition line matches → it's dead code
```

## CI Cascade Prevention

**Always run the full check suite before pushing:**
```bash
cargo fmt --check && cargo clippy -- -D warnings && cargo test
```

This catches formatting, lint, and test issues in one pass instead of 3 CI rounds.
