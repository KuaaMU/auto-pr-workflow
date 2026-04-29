#!/bin/bash
# test_init.sh - 测试 auto-pr init 命令

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# 测试辅助函数
assert_file_exists() {
    local file=$1
    local desc=$2
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $desc"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}: $desc - 文件不存在: $file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    local file=$1
    local pattern=$2
    local desc=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✅ PASS${NC}: $desc"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}: $desc - 未找到模式: $pattern"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# 创建临时测试目录
setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    git init -q
    git remote add origin https://github.com/test/test.git
    
    # 创建 Rust 项目结构
    echo '[package]
name = "test"
version = "0.1.0"
edition = "2021"' > Cargo.toml
    
    echo 'fn main() {}' > main.rs
}

cleanup() {
    cd /
    rm -rf "$TEST_DIR"
}

# 测试用例
test_init_creates_files() {
    echo -e "${YELLOW}测试: init 创建必要文件${NC}"
    
    # 运行 init
    "$AUTO_PR_BIN" init
    
    # 验证文件创建
    assert_file_exists ".github/pull_request_template.md" "PR 模板"
    assert_file_exists ".github/copilot-instructions.md" "Copilot 指令"
    assert_file_exists ".coderabbit.yaml" "CodeRabbit 配置"
    assert_file_exists ".github/workflows/ci.yml" "CI 配置"
    assert_file_exists ".github/dependabot.yml" "Dependabot 配置"
}

test_init_rust_ci() {
    echo -e "${YELLOW}测试: Rust CI 配置${NC}"
    
    "$AUTO_PR_BIN" init
    
    assert_contains ".github/workflows/ci.yml" "cargo fmt" "包含 cargo fmt 检查"
    assert_contains ".github/workflows/ci.yml" "cargo clippy" "包含 clippy 检查"
    assert_contains ".github/workflows/ci.yml" "cargo test" "包含测试"
}

test_init_idempotent() {
    echo -e "${YELLOW}测试: init 幂等性${NC}"
    
    # 运行两次 init
    "$AUTO_PR_BIN" init
    "$AUTO_PR_BIN" init
    
    # 验证文件仍然存在
    assert_file_exists ".github/pull_request_template.md" "PR 模板仍然存在"
    assert_file_exists ".github/workflows/ci.yml" "CI 配置仍然存在"
}

# 主函数
main() {
    AUTO_PR_BIN="$1"
    
    # 转换为绝对路径
    if [[ ! "$AUTO_PR_BIN" = /* ]]; then
        AUTO_PR_BIN="$(pwd)/$AUTO_PR_BIN"
    fi
    
    echo "=========================================="
    echo "  auto-pr init 测试套件"
    echo "=========================================="
    echo ""
    
    setup
    
    test_init_creates_files
    echo ""
    test_init_rust_ci
    echo ""
    test_init_idempotent
    
    cleanup
    
    echo ""
    echo "=========================================="
    echo "  测试结果: $TESTS_PASSED/$TESTS_RUN 通过"
    echo "=========================================="
    
    if [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    fi
}

main "$@"
