#!/bin/bash
# Synth-VIB3+ Test Runner
# Easy-to-use script for running all tests

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Synth-VIB3+ Comprehensive Test Suite                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

echo -e "${BLUE}Flutter version:${NC}"
flutter --version | head -1
echo ""

# Function to run tests with nice output
run_test() {
    local test_name=$1
    local test_path=$2

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Running: $test_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if flutter test "$test_path" --reporter expanded; then
        echo -e "${GREEN}✓ $test_name PASSED${NC}"
    else
        echo -e "${RED}✗ $test_name FAILED${NC}"
        exit 1
    fi
    echo ""
}

# Get command line argument (default: all)
TEST_SUITE="${1:-all}"

case $TEST_SUITE in
    all)
        echo -e "${YELLOW}Running ALL tests...${NC}"
        echo ""

        # Run test utilities check
        echo -e "${BLUE}Verifying test utilities...${NC}"
        flutter analyze test/test_utilities.dart || true
        echo ""

        # Run unit tests
        run_test "Unit Tests: Synthesis Branch Manager" "test/unit/synthesis_branch_manager_test.dart"
        run_test "Unit Tests: Audio Analyzer" "test/unit/audio_analyzer_test.dart"

        # Run integration tests
        run_test "Integration Tests: Parameter Bridge" "test/integration/parameter_bridge_test.dart"
        run_test "Integration Tests: All 72 Combinations" "test/integration/all_72_combinations_test.dart"

        # Run all remaining tests
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Running: All Remaining Tests${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        flutter test --reporter expanded
        echo ""

        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✓ ALL TESTS PASSED                                           ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
        ;;

    unit)
        echo -e "${YELLOW}Running UNIT tests only...${NC}"
        echo ""
        run_test "Unit Tests: Synthesis Branch Manager" "test/unit/synthesis_branch_manager_test.dart"
        run_test "Unit Tests: Audio Analyzer" "test/unit/audio_analyzer_test.dart"

        echo -e "${GREEN}✓ All unit tests passed${NC}"
        ;;

    integration)
        echo -e "${YELLOW}Running INTEGRATION tests only...${NC}"
        echo ""
        run_test "Integration Tests: Parameter Bridge" "test/integration/parameter_bridge_test.dart"
        run_test "Integration Tests: All 72 Combinations" "test/integration/all_72_combinations_test.dart"

        echo -e "${GREEN}✓ All integration tests passed${NC}"
        ;;

    72)
        echo -e "${YELLOW}Running 72 COMBINATIONS test...${NC}"
        echo ""
        run_test "All 72 Combinations Comprehensive Test" "test/integration/all_72_combinations_test.dart"

        echo -e "${GREEN}✓ All 72 combinations verified${NC}"
        ;;

    synthesis)
        echo -e "${YELLOW}Running SYNTHESIS tests...${NC}"
        echo ""
        run_test "Synthesis Branch Manager Tests" "test/unit/synthesis_branch_manager_test.dart"

        echo -e "${GREEN}✓ Synthesis tests passed${NC}"
        ;;

    analyzer)
        echo -e "${YELLOW}Running AUDIO ANALYZER tests...${NC}"
        echo ""
        run_test "Audio Analyzer Tests" "test/unit/audio_analyzer_test.dart"

        echo -e "${GREEN}✓ Audio analyzer tests passed${NC}"
        ;;

    bridge)
        echo -e "${YELLOW}Running PARAMETER BRIDGE tests...${NC}"
        echo ""
        run_test "Parameter Bridge Tests" "test/integration/parameter_bridge_test.dart"

        echo -e "${GREEN}✓ Parameter bridge tests passed${NC}"
        ;;

    coverage)
        echo -e "${YELLOW}Running tests with COVERAGE...${NC}"
        echo ""

        # Run tests with coverage
        flutter test --coverage

        echo ""
        echo -e "${BLUE}Coverage report generated: coverage/lcov.info${NC}"
        echo ""

        # Generate HTML coverage report if genhtml is available
        if command -v genhtml &> /dev/null; then
            echo -e "${BLUE}Generating HTML coverage report...${NC}"
            genhtml coverage/lcov.info -o coverage/html
            echo -e "${GREEN}✓ HTML coverage report: coverage/html/index.html${NC}"
            echo ""
            echo -e "${BLUE}To view coverage:${NC}"
            echo "  open coverage/html/index.html"
        else
            echo -e "${YELLOW}Note: Install lcov to generate HTML coverage reports${NC}"
            echo "  sudo apt-get install lcov  (Ubuntu/Debian)"
            echo "  brew install lcov          (macOS)"
        fi
        ;;

    quick)
        echo -e "${YELLOW}Running QUICK test (synthesis only)...${NC}"
        echo ""
        flutter test test/unit/synthesis_branch_manager_test.dart --name "should route geometries"

        echo -e "${GREEN}✓ Quick test passed${NC}"
        ;;

    help|--help|-h)
        echo "Usage: ./run_tests.sh [option]"
        echo ""
        echo "Options:"
        echo "  all          - Run all tests (default)"
        echo "  unit         - Run unit tests only"
        echo "  integration  - Run integration tests only"
        echo "  72           - Run all 72 combinations test"
        echo "  synthesis    - Run synthesis branch manager tests"
        echo "  analyzer     - Run audio analyzer tests"
        echo "  bridge       - Run parameter bridge tests"
        echo "  coverage     - Run tests with coverage report"
        echo "  quick        - Run quick smoke test"
        echo "  help         - Show this help message"
        echo ""
        echo "Examples:"
        echo "  ./run_tests.sh              # Run all tests"
        echo "  ./run_tests.sh unit         # Unit tests only"
        echo "  ./run_tests.sh 72           # Test all 72 combinations"
        echo "  ./run_tests.sh coverage     # Generate coverage report"
        ;;

    *)
        echo -e "${RED}Unknown option: $TEST_SUITE${NC}"
        echo "Run './run_tests.sh help' for usage information"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Test suite complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
