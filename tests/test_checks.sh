#!/bin/bash
# test_checks.sh - 测试 checks.sh 模块

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
# shellcheck source=src/checks.sh
source "$SCRIPT_DIR/../src/checks.sh"

# 测试用例
test_bash_syntax_check() {
    echo -e "${YELLOW}测试: bash 语法检查${NC}"
    
    # 测试 1: 有效脚本
    local tmp_dir1
    tmp_dir1=$(mktemp -d)
    cd "$tmp_dir1"
    
    mkdir -p bin src
    
    echo '#!/bin/bash
echo "hello"' > bin/test.sh
    chmod +x bin/test.sh
    
    set +e
    run_bash_checks
    local exit_code=$?
    set -e
    
    assert_exit_code 0 $exit_code "有效 bash 脚本应该通过"
    
    cd /
    rm -rf "$tmp_dir1"
    
    # 测试 2: 无效脚本
    local tmp_dir2
    tmp_dir2=$(mktemp -d)
    cd "$tmp_dir2"
    
    mkdir -p bin src
    
    echo '#!/bin/bash
if then' > bin/bad.sh
    chmod +x bin/bad.sh
    
    set +e
    run_bash_checks
    exit_code=$?
    set -e
    
    # bash -n 返回 2 表示语法错误，但我们的函数返回 1
    assert_exit_code 1 $exit_code "无效 bash 脚本应该失败"
    
    cd /
    rm -rf "$tmp_dir2"
}

# 主函数
main() {
    echo "=========================================="
    echo "  checks.sh 测试套件"
    echo "=========================================="
    echo ""
    
    test_bash_syntax_check
    
    echo ""
    echo "=========================================="
    echo "  测试结果: $TESTS_PASSED/$TESTS_RUN 通过"
    echo "=========================================="
    
    if [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    fi
}

main "$@"
