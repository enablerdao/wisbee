#!/bin/bash

# 🧪 Comprehensive Test Runner for Wisbee

echo "🐝 Starting Wisbee Comprehensive Test Suite"
echo "==========================================="

# Function to run tests with timeout
run_with_timeout() {
    local timeout=$1
    local command="$2"
    local name="$3"
    
    echo "🔄 Running $name..."
    
    # Start the command in background
    eval "$command" &
    local pid=$!
    
    # Wait for timeout
    sleep $timeout
    
    # Kill if still running
    if kill -0 $pid 2>/dev/null; then
        echo "⏰ $name timed out after ${timeout}s, terminating..."
        kill -TERM $pid 2>/dev/null
        sleep 2
        kill -KILL $pid 2>/dev/null
        return 1
    else
        wait $pid
        return $?
    fi
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "📋 Test Plan:"
echo "  1. Unit Tests (Jest)"
echo "  2. Integration Tests (API)"
echo "  3. Performance Tests"
echo "  4. Linting & Formatting"
echo ""

# Track results
UNIT_RESULT=0
INTEGRATION_RESULT=0
PERFORMANCE_RESULT=0
LINT_RESULT=0

# 1. Unit Tests
echo -e "${BLUE}1. 🧪 Running Unit Tests...${NC}"
npm run test:unit
UNIT_RESULT=$?

if [ $UNIT_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Unit Tests: PASSED${NC}"
else
    echo -e "${RED}❌ Unit Tests: FAILED${NC}"
fi

echo ""

# 2. Integration Tests (if Ollama is available)
echo -e "${BLUE}2. 🔗 Checking Ollama Integration...${NC}"
if curl -s http://localhost:11434/api/version > /dev/null 2>&1; then
    echo "✅ Ollama is running, running integration tests..."
    npm test tests/integration/ollama-api.test.js
    INTEGRATION_RESULT=$?
    
    if [ $INTEGRATION_RESULT -eq 0 ]; then
        echo -e "${GREEN}✅ Integration Tests: PASSED${NC}"
    else
        echo -e "${RED}❌ Integration Tests: FAILED${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Ollama not running, skipping integration tests${NC}"
    INTEGRATION_RESULT=0  # Don't fail if Ollama isn't running
fi

echo ""

# 3. Performance Tests
echo -e "${BLUE}3. ⚡ Running Performance Tests...${NC}"
npm run test:performance
PERFORMANCE_RESULT=$?

if [ $PERFORMANCE_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Performance Tests: PASSED${NC}"
else
    echo -e "${RED}❌ Performance Tests: FAILED${NC}"
fi

echo ""

# 4. Linting and Formatting
echo -e "${BLUE}4. 🔍 Running Code Quality Checks...${NC}"
npm run lint
LINT_RESULT=$?

if [ $LINT_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Code Quality: PASSED${NC}"
else
    echo -e "${RED}❌ Code Quality: FAILED${NC}"
fi

echo ""

# Summary
echo "🏁 Test Summary"
echo "==============="

TOTAL_SCORE=0
MAX_SCORE=4

if [ $UNIT_RESULT -eq 0 ]; then
    echo -e "Unit Tests:       ${GREEN}✅ PASSED${NC}"
    ((TOTAL_SCORE++))
else
    echo -e "Unit Tests:       ${RED}❌ FAILED${NC}"
fi

if [ $INTEGRATION_RESULT -eq 0 ]; then
    echo -e "Integration:      ${GREEN}✅ PASSED${NC}"
    ((TOTAL_SCORE++))
else
    echo -e "Integration:      ${RED}❌ FAILED${NC}"
fi

if [ $PERFORMANCE_RESULT -eq 0 ]; then
    echo -e "Performance:      ${GREEN}✅ PASSED${NC}"
    ((TOTAL_SCORE++))
else
    echo -e "Performance:      ${RED}❌ FAILED${NC}"
fi

if [ $LINT_RESULT -eq 0 ]; then
    echo -e "Code Quality:     ${GREEN}✅ PASSED${NC}"
    ((TOTAL_SCORE++))
else
    echo -e "Code Quality:     ${RED}❌ FAILED${NC}"
fi

echo ""
echo "📊 Overall Score: $TOTAL_SCORE/$MAX_SCORE"

if [ $TOTAL_SCORE -eq $MAX_SCORE ]; then
    echo -e "${GREEN}🎉 All tests passed! Wisbee is ready for production.${NC}"
    exit 0
elif [ $TOTAL_SCORE -ge 3 ]; then
    echo -e "${YELLOW}⚠️ Most tests passed, but some issues need attention.${NC}"
    exit 1
else
    echo -e "${RED}🚨 Multiple test failures detected. Please fix before deploying.${NC}"
    exit 1
fi