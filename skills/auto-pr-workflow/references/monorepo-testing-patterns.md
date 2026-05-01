# Monorepo Testing Patterns

## posthog-js (pnpm + Jest)

**Repo**: PostHog/posthog-js — pnpm monorepo with Turbo build orchestration

### Install
```bash
pnpm install --frozen-lockfile  # ~5-6s on this VPS
```

### Run tests for a specific package
```bash
cd packages/core && npx jest --testPathPattern=posthog.flush --no-coverage
```

### Test patterns
- Uses Jest with `jest.useFakeTimers()` / `jest.useRealTimers()`
- Mock fetch via `mocks.fetch.mockImplementation(async () => { return { status: 200, text: ..., json: ..., body: ... } })`
- `createTestClient('API_KEY', { config })` returns `[posthog, mocks]`
- Tests in `packages/core/src/__tests__/`

### Claude Code delegation pitfalls
- **pnpm install timeout**: Large monorepos may timeout during `pnpm install` when delegated to Claude Code (300s limit). Install deps manually first, then delegate.
- **Shell special chars**: `claude -p` prompt containing `()`, `{}``, backticks causes bash syntax errors. Use plain text descriptions instead of code snippets in the prompt.
- **Simple tests**: For straightforward test additions (mock + assert), write directly instead of delegating — faster and more reliable.

### PR workflow
- Fork PR branch on `KuaaMU/posthog-js`
- Push to fork: `git push origin <branch>`
- PR auto-updates on push
- Greptile AI review is used (not CodeRabbit)
- PostHog team reviews with `APPROVED` / `CHANGES_REQUESTED`
