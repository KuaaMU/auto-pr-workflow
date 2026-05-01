# TypeScript ESM Review Patterns

Common bugs found when reviewing TypeScript ESM projects. Check these during code review (Phase 3.3).

## `require()` in ESM modules

**Bug**: Using `require('module')` inside a `"type": "module"` project or ESM-only build output (tsup, esbuild with `format: ['esm']`).

**Why it fails**: `require()` is a CommonJS API. In ESM, `require` is not defined. If wrapped in `try/catch`, it silently falls through — the feature that depended on it simply doesn't work.

**Detection**:
```bash
# Search for require() in TypeScript source
grep -rn "require(" src/ --include="*.ts" | grep -v "import\|//.*require\|createRequire"
```

**Fix**: Replace `require()` with a top-level `import`:
```typescript
// ❌ Broken in ESM
const data = require('node:fs').readFileSync(path, 'utf-8');

// ✅ Use top-level import
import { readFileSync } from 'node:fs';
const data = readFileSync(path, 'utf-8');
```

**Special case — conditional/dynamic imports**: If `require()` is used for conditional loading, use `await import()` instead:
```typescript
// ❌ Conditional require
if (condition) {
  const mod = require('./optional-module');
}

// ✅ Dynamic import
if (condition) {
  const mod = await import('./optional-module.js');
}
```

**Note**: `tsup` with `format: ['esm']` will bundle the code but the runtime still needs ESM-compatible APIs. Some bundlers inject a `require` shim, but it's fragile and not portable.

**Case study**: `newtype-ai/nit` — `fingerprint.ts` used `require('node:fs').readFileSync('/etc/machine-id')` in an ESM module built by tsup. On Linux, the machine-id was never read; the code silently fell through to a hostname/cpu fallback. Fix: added `readFileSync` to the existing `import { promises as fs } from 'node:fs'` and replaced the `require()` call.

## `process.env` vs `import.meta.env`

**Bug**: Using `process.env.VITE_*` in a Vite frontend project, or `import.meta.env.*` in a Node.js CLI.

**Detection**: Check the project type first:
- Has `vite.config.*` → frontend, should use `import.meta.env`
- Has `tsup.config.*` or `bin` field in package.json → CLI/library, should use `import.meta.env` or `process.env`

## Missing `.js` extensions in ESM imports

**Bug**: `import { foo } from './bar'` without `.js` extension in a project targeting ESM.

**Detection**: Check tsconfig.json for `"module": "NodeNext"` or `"moduleResolution": "NodeNext"` — these require explicit extensions.

**Fix**: `import { foo } from './bar.js'` (even though the source file is `.ts`)

## Type-only imports not used at runtime

**Pattern**: `import type { X }` vs `import { X }` — not a bug, but a review signal. If the import is only used in type annotations, it should be `import type` for tree-shaking.

## Checklist for TypeScript ESM Review

- [ ] No `require()` calls in source (grep for it)
- [ ] Import paths have `.js` extensions if `moduleResolution: NodeNext`
- [ ] `process.env` only used in Node.js code, not Vite frontend
- [ ] `import type` used for type-only imports
- [ ] Build config (`tsup.config.ts`, `tsconfig.json`) matches runtime target
