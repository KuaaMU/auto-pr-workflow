#!/bin/bash
# submit.sh - PR 提交模块

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# 提交 PR
cmd_submit() {
    log_info "开始提交 PR..."
    
    local project_type
    project_type=$(detect_project_type)
    
    # 1. 本地安全门禁
    log_info "运行本地检查..."
    if ! run_local_checks "$project_type"; then
        log_error "本地检查失败，请修复后重试"
        exit 1
    fi
    log_success "本地检查通过"
    
    # 2. 检查变更范围
    local changes
    changes=$(git diff main...HEAD --stat 2>/dev/null | wc -l || echo "0")
    local draft_flag=""
    if [ "$changes" -gt 500 ]; then
        log_warn "变更超过 500 行，将创建 draft PR"
        draft_flag="--draft"
    fi
    
    # 3. 推送分支
    log_info "推送分支..."
    git push -u origin HEAD
    
    # 4. 创建 PR
    log_info "创建 PR..."
    local pr_url
    pr_url=$(gh pr create \
        --reviewer @copilot \
        $draft_flag \
        --title "$(get_commit_title)" \
        --body "$(get_pr_body)")
    
    log_success "PR 创建成功: $pr_url"
    
    # 5. 启用 auto-merge
    log_info "启用 auto-merge..."
    if gh pr merge --auto --squash --delete-branch 2>/dev/null; then
        log_success "Auto-merge 已启用"
    else
        log_warn "auto-merge 启用失败（可能需要设置 branch protection）"
    fi
    
    log_success "PR 提交完成！"
    echo ""
    echo "下一步："
    echo "  - 监控 CI: auto-pr watch"
    echo "  - 查看 PR: gh pr view"
}

# 获取 commit 标题
get_commit_title() {
    git log -1 --format=%s
}

# 获取 PR body
get_pr_body() {
    local changes
    changes=$(git diff main...HEAD --stat 2>/dev/null || echo "No changes")
    
    cat << BODYEOF
## Summary
$(git log -1 --format=%s)

## Changes
\`\`\`
$changes
\`\`\`

## Test Plan
- [ ] CI passes
- [ ] Code review completed

## Related Issues
N/A
BODYEOF
}

# 手动触发 AI 审查
cmd_review() {
    log_info "触发 AI 审查..."
    
    local pr_number
    pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
    
    if [ -z "$pr_number" ]; then
        log_error "未找到当前 PR"
        exit 1
    fi
    
    # 触发 Copilot 审查
    log_info "请求 Copilot 审查..."
    if gh pr edit "$pr_number" --add-reviewer @copilot 2>/dev/null; then
        log_success "Copilot 审查已请求"
    else
        log_warn "Copilot 审查请求失败"
    fi
    
    # 触发 CodeRabbit 审查（通过评论）
    log_info "请求 CodeRabbit 审查..."
    if gh pr comment "$pr_number" --body "@coderabbitai review" 2>/dev/null; then
        log_success "CodeRabbit 审查已请求"
    else
        log_warn "CodeRabbit 审查请求失败"
    fi
    
    log_success "AI 审查已触发"
    echo "查看审查结果: gh pr view $pr_number"
}

# 启用 auto-merge
cmd_merge() {
    log_info "启用 auto-merge..."
    
    local pr_number
    pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
    
    if [ -z "$pr_number" ]; then
        log_error "未找到当前 PR"
        exit 1
    fi
    
    if gh pr merge "$pr_number" --auto --squash --delete-branch 2>/dev/null; then
        log_success "Auto-merge 已启用"
        echo "PR 将在 CI 通过后自动合并"
    else
        log_error "Auto-merge 启用失败"
        echo "请检查："
        echo "  1. 仓库是否开启了 auto-merge 功能"
        echo "  2. 是否设置了 branch protection rules"
        exit 1
    fi
}

# 增量审查 - 只审查新变更
cmd_review_incremental() {
    log_info "增量审查..."
    
    local pr_number
    pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
    
    if [ -z "$pr_number" ]; then
        log_error "未找到当前 PR"
        exit 1
    fi
    
    # 获取上次审查的 commit
    local last_reviewed
    last_reviewed=$(gh pr view "$pr_number" --json commits -q '.[-1].oid' 2>/dev/null || echo "")
    
    if [ -z "$last_reviewed" ]; then
        log_warn "无法获取上次审查 commit，执行完整审查"
        cmd_review
        return
    fi
    
    # 获取新变更
    local new_changes
    new_changes=$(git diff "$last_reviewed"..HEAD --stat 2>/dev/null || echo "")
    
    if [ -z "$new_changes" ]; then
        log_success "没有新变更，跳过审查"
        return
    fi
    
    log_info "新变更："
    echo "$new_changes"
    
    # 触发审查
    cmd_review
}

# 持久评论 - 更新同一条评论
post_persistent_comment() {
    local pr_number=$1
    local content=$2
    local marker="<!-- auto-pr-review -->"
    
    # 查找现有评论
    local comment_id
    comment_id=$(gh pr view "$pr_number" --comments --json comments -q \
        '.[] | select(.body | contains("auto-pr-review")) | .id' 2>/dev/null || echo "")
    
    if [ -n "$comment_id" ]; then
        # 更新现有评论
        gh api "repos/$(get_owner_repo)/issues/comments/$comment_id" \
            -X PATCH -f body="$marker
$content" 2>/dev/null || true
    else
        # 创建新评论
        gh pr comment "$pr_number" --body "$marker
$content" 2>/dev/null || true
    fi
}
