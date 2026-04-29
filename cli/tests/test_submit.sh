#!/bin/bash
# test_submit.sh - 测试 submit.sh 模块

set -uo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# 测试辅助函数
assert_exit_code() {
    local expected=$1
    local actual=$2
    local desc=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$actual" -eq "$expected" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $desc"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}: $desc - 期望退出码 $expected, 实际 $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# 加载模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/submit.sh
source "$SCRIPT_DIR/../src/submit.sh"

# 测试用例
test_get_commit_title() {
    echo -e "${YELLOW}测试: get_commit_title${NC}"
    
    # 创建临时目录
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    git init -q
    git commit -q --allow-empty -m "feat: test commit"
    
    set +e
    local title
    title=$(get_commit_title)
    local exit_code=$?
    set -e
    
    assert_exit_code 0 $exit_code "get_commit_title 应该成功"
    
    cd /
    rm -rf "$tmp_dir"
}

test_get_pr_body() {
    echo -e "${YELLOW}测试: get_pr_body${NC}"
    
    # 创建临时目录
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    git init -q
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "feat: add test file"
    
    set +e
    local body
    body=$(get_pr_body)
    local exit_code=$?
    set -e
    
    assert_exit_code 0 $exit_code "get_pr_body 应该成功"
    
    cd /
    rm -rf "$tmp_dir"
}

# 主函数
main() {
    echo "=========================================="
    echo "  submit.sh 测试套件"
    echo "=========================================="
    echo ""
    
    test_get_commit_title
    echo ""
    test_get_pr_body
    
    echo ""
    echo "=========================================="
    echo "  测试结果: $TESTS_PASSED/$TESTS_RUN 通过"
    echo "=========================================="
    
    if [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    fi
}

main "$@"
