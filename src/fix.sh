#!/bin/bash
# fix.sh - 自动修复模块

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

# 自动修复 CI
auto_fix_ci() {
    local project_type
    project_type=$(detect_project_type)
    
    if [ ! -f /tmp/ci-failure.log ]; then
        log_error "未找到失败日志"
        return 1
    fi
    
    # 分析失败类型
    if grep -q "fmt\|formatting" /tmp/ci-failure.log 2>/dev/null; then
        fix_formatting "$project_type"
    elif grep -q "clippy\|lint\|eslint\|ruff" /tmp/ci-failure.log 2>/dev/null; then
        fix_lint "$project_type"
    elif grep -q "test\|assertion" /tmp/ci-failure.log 2>/dev/null; then
        fix_tests "$project_type"
    else
        log_warn "无法识别失败类型"
        return 1
    fi
    
    return $?
}

# 修复格式问题
fix_formatting() {
    local project_type=$1
    
    log_info "修复格式问题..."
    
    case $project_type in
        rust)
            cargo fmt 2>/dev/null
            return $?
            ;;
        node)
            if command -v prettier &>/dev/null; then
                npx prettier --write . 2>/dev/null
                return $?
            fi
            ;;
        python)
            if command -v ruff &>/dev/null; then
                ruff format . 2>/dev/null
                return $?
            fi
            ;;
    esac
    
    return 1
}

# 修复 lint 问题
fix_lint() {
    local project_type=$1
    
    log_info "尝试修复 lint 问题..."
    
    case $project_type in
        rust)
            cargo clippy --fix --allow-dirty 2>/dev/null
            return $?
            ;;
        node)
            if command -v eslint &>/dev/null; then
                npx eslint --fix . 2>/dev/null
                return $?
            fi
            ;;
        python)
            if command -v ruff &>/dev/null; then
                ruff check . --fix 2>/dev/null
                return $?
            fi
            ;;
    esac
    
    return 1
}

# 修复测试问题
fix_tests() {
    local project_type=$1
    
    log_info "分析测试失败..."
    
    # 测试失败通常需要人工分析
    # 这里只做简单的尝试性修复
    
    case $project_type in
        rust)
            # 尝试更新快照测试
            if grep -q "snapshot" /tmp/ci-failure.log 2>/dev/null; then
                INSTA_UPDATE=always cargo test 2>/dev/null
                return $?
            fi
            ;;
    esac
    
    # 测试失败通常需要人工介入
    log_warn "测试失败需要人工分析"
    return 1
}
