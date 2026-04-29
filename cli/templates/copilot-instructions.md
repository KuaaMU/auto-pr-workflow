# Copilot Code Review 自定义指令
# 文件位置: .github/copilot-instructions.md
# 最大 4000 字符

## Code Review Guidelines

### Security
- Check for SQL injection, XSS, path traversal
- No hardcoded secrets or credentials
- Input validation on user-facing inputs
- Auth/authz checks where needed

### Code Quality
- Clear naming (variables, functions, classes)
- No unnecessary complexity
- DRY — no duplicated logic
- Functions focused (single responsibility)

### Testing
- New code paths must have tests
- Happy path and error cases covered
- Tests should be readable and maintainable

### Documentation
- Public APIs must have doc comments
- Non-obvious logic needs "why" comments
- README updated if behavior changed

### Performance
- No N+1 queries or unnecessary loops
- Appropriate caching where beneficial
- No blocking operations in async code paths
