#!/bin/bash
# Synth-VIB3+ Build and Test Script
# Run this on a machine with Flutter installed

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Synth-VIB3+ Build and Test - Complete Validation          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found. Please install Flutter first.${NC}"
    echo "  Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"
flutter --version | head -1
echo ""

# Step 1: Clean
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 1: Cleaning previous builds${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Step 2: Get dependencies
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 2: Fetching dependencies${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Step 3: Analyze code
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 3: Analyzing code${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if flutter analyze; then
    echo -e "${GREEN}✓ Code analysis passed (no errors)${NC}"
else
    echo -e "${YELLOW}⚠ Code analysis found issues (see above)${NC}"
    echo -e "${YELLOW}Continuing with tests...${NC}"
fi
echo ""

# Step 4: Run tests
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 4: Running all tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Run with verbose output
if flutter test --reporter expanded; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
else
    echo ""
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
echo ""

# Step 5: Generate coverage
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 5: Generating coverage report${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
flutter test --coverage
echo -e "${GREEN}✓ Coverage report generated: coverage/lcov.info${NC}"
echo ""

# Generate HTML coverage if lcov is available
if command -v genhtml &> /dev/null; then
    echo -e "${BLUE}Generating HTML coverage report...${NC}"
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✓ HTML coverage: coverage/html/index.html${NC}"

    # Calculate coverage percentage
    if command -v lcov &> /dev/null; then
        COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}')
        echo -e "${GREEN}Coverage: $COVERAGE${NC}"
    fi
else
    echo -e "${YELLOW}⚠ lcov not installed. Install with:${NC}"
    echo "  Ubuntu/Debian: sudo apt-get install lcov"
    echo "  macOS: brew install lcov"
fi
echo ""

# Step 6: Try to build APK (Android)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 6: Building Android APK (debug)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if flutter build apk --debug 2>&1 | tee build.log; then
    echo ""
    echo -e "${GREEN}✓ APK built successfully${NC}"

    # Find and display APK location
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        APK_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-debug.apk | awk '{print $5}')
        echo -e "${GREEN}APK Location: build/app/outputs/flutter-apk/app-debug.apk${NC}"
        echo -e "${GREEN}APK Size: $APK_SIZE${NC}"
    fi
else
    echo ""
    echo -e "${YELLOW}⚠ APK build had issues (see build.log)${NC}"
fi
echo ""

# Summary
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Build and Test Complete!                                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  ✓ Dependencies installed"
echo "  ✓ Code analyzed"
echo "  ✓ All tests run"
echo "  ✓ Coverage generated"
echo "  ✓ APK built (if Android SDK available)"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. View coverage: open coverage/html/index.html"
echo "  2. Install APK: adb install build/app/outputs/flutter-apk/app-debug.apk"
echo "  3. Check build.log for detailed build output"
echo ""
echo -e "${GREEN}All validation complete!${NC}"
