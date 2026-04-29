#!/bin/bash
# 测试 auto-pr check 命令

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_DIR="$SCRIPT_DIR/.."

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 测试计数
TESTS=0
PASSED=0

# 测试 check 命令
echo "=========================================="
echo "  测试 auto-pr check 命令"
echo "=========================================="

# 测试 1: check 命令应该成功
((TESTS++))
echo ""
echo "测试: check 命令应该成功"
if $CLI_DIR/bin/auto-pr check > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS: check 命令应该成功${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: check 命令应该成功${NC}"
fi

# 测试 2: check 命令应该输出环境信息
((TESTS++))
echo ""
echo "测试: check 命令应该输出环境信息"
if $CLI_DIR/bin/auto-pr check 2>&1 | grep -q 'Git 已安装'; then
    echo -e "${GREEN}✅ PASS: check 命令应该输出环境信息${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: check 命令应该输出环境信息${NC}"
fi

# 测试 3: check 命令应该检测 Node.js
((TESTS++))
echo ""
echo "测试: check 命令应该检测 Node.js"
if $CLI_DIR/bin/auto-pr check 2>&1 | grep -q 'Node.js 已安装'; then
    echo -e "${GREEN}✅ PASS: check 命令应该检测 Node.js${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: check 命令应该检测 Node.js${NC}"
fi

# 测试 4: check 命令应该检测 GitHub CLI
((TESTS++))
echo ""
echo "测试: check 命令应该检测 GitHub CLI"
if $CLI_DIR/bin/auto-pr check 2>&1 | grep -q 'GitHub CLI 已安装'; then
    echo -e "${GREEN}✅ PASS: check 命令应该检测 GitHub CLI${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: check 命令应该检测 GitHub CLI${NC}"
fi

# 测试 5: check 命令应该检测 GitHub CLI 登录状态
((TESTS++))
echo ""
echo "测试: check 命令应该检测 GitHub CLI 登录状态"
if $CLI_DIR/bin/auto-pr check 2>&1 | grep -q 'GitHub CLI 已登录'; then
    echo -e "${GREEN}✅ PASS: check 命令应该检测 GitHub CLI 登录状态${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: check 命令应该检测 GitHub CLI 登录状态${NC}"
fi

# 测试 6: check 命令应该输出总结
((TESTS++))
echo ""
echo "测试: check 命令应该输出总结"
if $CLI_DIR/bin/auto-pr check 2>&1 | grep -q '环境检查通过'; then
    echo -e "${GREEN}✅ PASS: check 命令应该输出总结${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: check 命令应该输出总结${NC}"
fi

# 测试 7: check 命令应该加载配置文件
((TESTS++))
echo ""
echo "测试: check 命令应该加载配置文件"
if $CLI_DIR/bin/auto-pr check 2>&1 | grep -q '使用默认配置'; then
    echo -e "${GREEN}✅ PASS: check 命令应该加载配置文件${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: check 命令应该加载配置文件${NC}"
fi

# 总结
echo ""
echo "=========================================="
echo "  测试结果: $PASSED/$TESTS 通过"
echo "=========================================="

if [ $PASSED -eq $TESTS ]; then
    echo -e "${GREEN}所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}有测试失败${NC}"
    exit 1
fi
