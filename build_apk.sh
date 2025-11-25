#!/bin/bash
# Build APK for Synth-VIB3+ Modular
# A Paul Phillips Manifestation

set -e  # Exit on error

echo "🏗️  Building Synth-VIB3+ Modular APK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "   Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Display Flutter version
echo "📱 Flutter version:"
flutter --version
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo ""

# Analyze code for issues
echo "🔍 Running static analysis..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "⚠️  Warning: Analysis found issues. Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Run tests (optional)
echo "🧪 Run tests before building? (y/n)"
read -r run_tests
if [[ "$run_tests" =~ ^[Yy]$ ]]; then
    echo "Running tests..."
    flutter test
    echo ""
fi

# Build APK
echo "🔨 Building APK (release mode)..."
flutter build apk --release

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ APK built successfully!"
    echo ""
    echo "📍 Location:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📊 APK size:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "🚀 Install on device:"
    echo "   adb install build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo ""
    echo "❌ Build failed. Check the error messages above."
    exit 1
fi
