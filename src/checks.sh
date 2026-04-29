#!/bin/bash
# checks.sh - 本地安全门禁模块

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

# 运行本地检查
run_local_checks() {
    local project_type=$1
    
    # 通用检查：密钥扫描
    log_info "扫描密钥..."
    if grep -rn "password\|secret\|api_key\|token.*=\|private_key" \
        --include="*.rs" --include="*.ts" --include="*.py" --include="*.js" --include="*.go" \
        2>/dev/null | grep -v "node_modules" | grep -v ".git" | grep -v "test" | grep -v "example" | grep -v "\.md"; then
        log_warn "发现可能的密钥，请检查"
    fi
    
    # 项目特定检查
    case $project_type in
        rust)
            run_rust_checks
            ;;
        node)
            run_node_checks
            ;;
        python)
            run_python_checks
            ;;
        go)
            run_go_checks
            ;;
        bash)
            run_bash_checks
            ;;
        *)
            log_warn "未知项目类型，跳过项目特定检查"
            ;;
    esac
    
    return $?
}

# Rust 检查
run_rust_checks() {
    log_info "运行 cargo fmt --check..."
    if ! cargo fmt --check 2>/dev/null; then
        log_error "格式检查失败"
        return 1
    fi
    
    log_info "运行 cargo clippy..."
    if ! cargo clippy -- -D warnings 2>/dev/null; then
        log_error "Clippy 检查失败"
        return 1
    fi
    
    log_info "运行 cargo test..."
    if ! cargo test 2>/dev/null; then
        log_error "测试失败"
        return 1
    fi
    
    return 0
}

# Node.js 检查
run_node_checks() {
    if command -v npm &>/dev/null; then
        log_info "运行 npm run lint..."
        if ! npm run lint 2>/dev/null; then
            log_error "Lint 失败"
            return 1
        fi
        
        log_info "运行 npm test..."
        if ! npm test 2>/dev/null; then
            log_error "测试失败"
            return 1
        fi
    fi
    
    return 0
}

# Python 检查
run_python_checks() {
    if command -v ruff &>/dev/null; then
        log_info "运行 ruff check..."
        if ! ruff check . 2>/dev/null; then
            log_error "Lint 失败"
            return 1
        fi
    fi
    
    if command -v pytest &>/dev/null; then
        log_info "运行 pytest..."
        if ! pytest 2>/dev/null; then
            log_error "测试失败"
            return 1
        fi
    fi
    
    return 0
}

# Go 检查
run_go_checks() {
    log_info "运行 go vet..."
    if ! go vet ./... 2>/dev/null; then
        log_error "go vet 失败"
        return 1
    fi
    
    log_info "运行 go test..."
    if ! go test ./... 2>/dev/null; then
        log_error "测试失败"
        return 1
    fi
    
    return 0
}

# Bash 检查
run_bash_checks() {
    if command -v shellcheck &>/dev/null; then
        log_info "运行 shellcheck..."
        if ! find . -name "*.sh" -exec shellcheck {} \; 2>/dev/null; then
            log_warn "shellcheck 发现问题"
        fi
    fi
    
    # 语法检查
    log_info "检查 bash 语法..."
    for script in bin/* src/*.sh; do
        if [ -f "$script" ]; then
            if ! bash -n "$script" 2>/dev/null; then
                log_error "$script 语法错误"
                return 1
            fi
        fi
    done
    
    return 0
}
