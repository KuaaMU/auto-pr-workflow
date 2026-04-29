#!/bin/bash
# watch.sh - CI 监控模块

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

# 监控 CI 并自动修复
cmd_watch() {
    log_info "开始监控 CI..."
    
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "监控尝试 $attempt/$max_attempts..."
        
        # 等待 CI 完成
        if gh pr checks --watch 2>/dev/null; then
            log_success "CI 全部通过！"
            
            # 检查是否可以合并
            local pr_state
            pr_state=$(gh pr view --json state -q '.state' 2>/dev/null || echo "")
            if [ "$pr_state" = "OPEN" ]; then
                log_info "PR 已就绪，等待合并..."
                gh pr merge --auto --squash --delete-branch 2>/dev/null || true
            fi
            return 0
        fi
        
        log_warn "CI 失败，尝试自动修复..."
        
        # 获取失败的 run
        local run_id
        run_id=$(gh run list --branch "$(git branch --show-current)" --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null || echo "")
        
        if [ -z "$run_id" ]; then
            log_error "无法获取 CI run ID"
            return 1
        fi
        
        # 拉取失败日志
        log_info "获取失败日志..."
        gh run view "$run_id" --log-failed > /tmp/ci-failure.log 2>/dev/null || true
        
        # 尝试自动修复
        if auto_fix_ci; then
            log_info "修复完成，推送中..."
            git add -A
            git commit -m "fix: resolve CI failure (attempt $attempt)"
            git push
            attempt=$((attempt + 1))
        else
            log_error "无法自动修复，请手动处理"
            echo ""
            echo "失败日志："
            head -50 /tmp/ci-failure.log 2>/dev/null
            return 1
        fi
    done
    
    log_error "已达最大重试次数（$max_attempts），请手动处理"
    return 1
}

# CI 自动修复循环 - 从 Sweep 学到的
cmd_watch_auto_fix() {
    log_info "CI 自动修复循环..."
    
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "尝试 $attempt/$max_attempts..."
        
        # 等待 CI 完成
        if gh pr checks --watch 2>/dev/null; then
            log_success "CI 全部通过！"
            return 0
        fi
        
        log_warn "CI 失败，分析原因..."
        
        # 获取失败的 run
        local run_id
        run_id=$(gh run list --branch "$(git branch --show-current)" --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null || echo "")
        
        if [ -z "$run_id" ]; then
            log_error "无法获取 CI run ID"
            return 1
        fi
        
        # 拉取失败日志
        log_info "获取失败日志..."
        gh run view "$run_id" --log-failed > /tmp/ci-failure.log 2>/dev/null || true
        
        # 分析失败类型
        local failure_type
        failure_type=$(analyze_failure_type /tmp/ci-failure.log)
        
        log_info "失败类型: $failure_type"
        
        # 尝试修复
        if auto_fix_by_type "$failure_type"; then
            log_info "修复完成，推送中..."
            git add -A
            git commit -m "fix: resolve CI failure ($failure_type, attempt $attempt)"
            git push
            attempt=$((attempt + 1))
        else
            log_error "无法自动修复"
            echo ""
            echo "失败日志："
            head -50 /tmp/ci-failure.log 2>/dev/null
            return 1
        fi
    done
    
    log_error "已达最大重试次数（$max_attempts）"
    return 1
}

# 分析失败类型
analyze_failure_type() {
    local log_file=$1
    
    if grep -q "fmt\|formatting" "$log_file" 2>/dev/null; then
        echo "formatting"
    elif grep -q "clippy\|lint\|eslint\|ruff" "$log_file" 2>/dev/null; then
        echo "lint"
    elif grep -q "test\|assertion" "$log_file" 2>/dev/null; then
        echo "test"
    elif grep -q "build\|compile" "$log_file" 2>/dev/null; then
        echo "build"
    else
        echo "unknown"
    fi
}

# 按类型修复
auto_fix_by_type() {
    local failure_type=$1
    local project_type
    project_type=$(detect_project_type)
    
    case $failure_type in
        formatting)
            fix_formatting "$project_type"
            ;;
        lint)
            fix_lint "$project_type"
            ;;
        test)
            fix_tests "$project_type"
            ;;
        build)
            fix_build "$project_type"
            ;;
        *)
            log_warn "未知失败类型，尝试通用修复"
            return 1
            ;;
    esac
}

# 修复构建问题
fix_build() {
    local project_type=$1
    
    log_info "尝试修复构建问题..."
    
    case $project_type in
        rust)
            # 尝试更新依赖
            cargo update 2>/dev/null || true
            return $?
            ;;
        node)
            # 尝试重新安装依赖
            rm -rf node_modules package-lock.json
            npm install 2>/dev/null || true
            return $?
            ;;
    esac
    
    return 1
}
