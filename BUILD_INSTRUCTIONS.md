# Build Instructions - Synth-VIB3+ Modular

**Project:** Synth-VIB3+ Modular Synthesizer
**Platform:** Android (Flutter)
**Branch:** `claude/flutter-dart-support-01QmF9NpMzNS6zNpXLSFWNpf`

---

## Prerequisites

### Required Software

1. **Flutter SDK** (3.9.0 or higher)
   - Download: https://flutter.dev/docs/get-started/install
   - Verify: `flutter --version`

2. **Android Studio** or **Android SDK Command-line Tools**
   - Android SDK Platform (API 21 or higher)
   - Android SDK Build-Tools
   - Verify: `flutter doctor`

3. **Java Development Kit (JDK)**
   - JDK 21 (configured in `android/app/build.gradle`)
   - Verify: `java --version`

4. **Git** (for cloning the repository)
   - Verify: `git --version`

### Optional Tools

- **Android Device or Emulator** for testing
- **ADB (Android Debug Bridge)** for device installation
- **VS Code** or **Android Studio** for IDE support

---

## Quick Build (Automated)

### Using the Build Script

```bash
# Navigate to project directory
cd synth-vib3plus-modular

# Run the automated build script
./build_apk.sh

# The script will:
# 1. Check Flutter installation
# 2. Clean previous builds
# 3. Get dependencies
# 4. Run static analysis
# 5. Optionally run tests
# 6. Build release APK
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

## Manual Build (Step-by-Step)

### 1. Clone and Setup

```bash
# Clone the repository (if not already done)
git clone <repository-url>
cd synth-vib3plus-modular

# Checkout the Flutter/Dart integration branch
git checkout claude/flutter-dart-support-01QmF9NpMzNS6zNpXLSFWNpf

# Pull latest changes
git pull origin claude/flutter-dart-support-01QmF9NpMzNS6zNpXLSFWNpf
```

### 2. Verify Flutter Setup

```bash
# Check Flutter installation and dependencies
flutter doctor

# Should show:
# ✓ Flutter (Channel stable, 3.x.x)
# ✓ Android toolchain
# ✓ Android Studio / VS Code
```

### 3. Clean Previous Builds

```bash
# Remove old build artifacts
flutter clean

# This deletes:
# - build/ directory
# - .dart_tool/ cache
# - iOS/Android build folders
```

### 4. Get Dependencies

```bash
# Install all packages from pubspec.yaml
flutter pub get

# This installs:
# - vector_math (quaternion support)
# - webview_flutter (VIB3+ visualization)
# - provider (state management)
# - Firebase packages (optional cloud sync)
# - Audio packages (synthesis/analysis)
```

### 5. Run Static Analysis (Recommended)

```bash
# Check for code issues
flutter analyze

# Should show:
# "No issues found!"
# or list of warnings/errors to fix
```

### 6. Run Tests (Optional)

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### 7. Build the APK

```bash
# Build release APK (optimized, ~40-60MB)
flutter build apk --release

# Build debug APK (larger, ~80-100MB, includes debug symbols)
flutter build apk --debug

# Build APK for specific architecture (smaller size)
flutter build apk --target-platform android-arm64 --release  # ARM64 only
flutter build apk --split-per-abi --release                  # Separate APKs per ABI
```

### 8. Locate the APK

```bash
# Release APK location
build/app/outputs/flutter-apk/app-release.apk

# Split APKs (if using --split-per-abi)
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  # 32-bit ARM
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    # 64-bit ARM
build/app/outputs/flutter-apk/app-x86_64-release.apk       # x86 64-bit
```

### 9. Install on Device

```bash
# Connect Android device via USB (enable USB debugging)
# or start Android emulator

# Check device connection
adb devices

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Install and replace existing app
adb install -r build/app/outputs/flutter-apk/app-release.apk

# View logs while app runs
adb logcat -s flutter
```

---

## Build Variants

### Release Build (Production)

```bash
flutter build apk --release
```

**Characteristics:**
- ✅ Optimized code (smaller, faster)
- ✅ Obfuscated (harder to reverse engineer)
- ✅ No debug symbols
- ✅ Signed with release key (if configured)
- ⚠️ Cannot use debugging tools
- **Size:** ~40-60 MB

### Debug Build (Development)

```bash
flutter build apk --debug
```

**Characteristics:**
- ✅ Includes debug symbols
- ✅ Can use Flutter DevTools
- ✅ Hot reload support (when running, not after install)
- ⚠️ Larger file size
- ⚠️ Slower performance
- **Size:** ~80-100 MB

### Profile Build (Performance Testing)

```bash
flutter build apk --profile
```

**Characteristics:**
- ✅ Performance profiling enabled
- ✅ Some optimizations applied
- ✅ Flutter DevTools support
- ⚠️ Still larger than release
- **Size:** ~60-80 MB

---

## Split APKs by Architecture

To reduce APK size, build separate APKs for each CPU architecture:

```bash
flutter build apk --split-per-abi --release
```

**Generated APKs:**
- `app-armeabi-v7a-release.apk` - 32-bit ARM (~25-35 MB)
- `app-arm64-v8a-release.apk` - 64-bit ARM (~30-40 MB) ← **Most common**
- `app-x86_64-release.apk` - x86 64-bit (~30-40 MB)

**Note:** Most modern Android devices use ARM64 (arm64-v8a).

---

## Troubleshooting

### Common Issues

#### 1. "Flutter command not found"

```bash
# Add Flutter to PATH (Linux/Mac)
export PATH="$PATH:/path/to/flutter/bin"

# Add to ~/.bashrc or ~/.zshrc for permanent
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.bashrc

# Windows: Add to System Environment Variables
# C:\path\to\flutter\bin
```

#### 2. "SDK location not found"

```bash
# Create local.properties file
echo "sdk.dir=/path/to/android/sdk" > android/local.properties

# Or set ANDROID_HOME environment variable
export ANDROID_HOME=/path/to/android/sdk
```

#### 3. "Gradle build failed"

```bash
# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version 8.0

# Or clean Gradle cache
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 4. "Java version mismatch"

```bash
# This project requires JDK 21
# Check current version
java --version

# Set JAVA_HOME to JDK 21
export JAVA_HOME=/path/to/jdk-21

# Or modify android/app/build.gradle if needed
```

#### 5. "Out of memory" during build

```bash
# Increase Gradle memory in android/gradle.properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m

# Or use:
flutter build apk --release --no-tree-shake-icons
```

#### 6. "Firebase initialization failed"

Firebase is optional. If not using cloud features:
- The app will still work without Firebase
- Local presets are stored using SharedPreferences
- Cloud sync features will be disabled

#### 7. "WebView rendering issues"

```bash
# Enable WebView debugging in visual_provider.dart
AndroidWebViewController.enableDebugging(true);

# Check WebView version on device
adb shell dumpsys webviewupdate
```

---

## Build Configuration

### App Signing (Release)

For production releases, configure app signing:

1. **Generate keystore:**
   ```bash
   keytool -genkey -v -keystore ~/synth-vib3plus-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias synth-vib3plus
   ```

2. **Create `android/key.properties`:**
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=synth-vib3plus
   storeFile=/path/to/synth-vib3plus-key.jks
   ```

3. **Build signed APK:**
   ```bash
   flutter build apk --release
   ```

### Build Number & Version

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        │││││  │
#        ││││└──┴─ Build number (increment for each release)
#        └┴┴┴───── Version name (semantic versioning)
```

---

## Performance Optimization

### Reduce APK Size

```bash
# Remove unused resources
flutter build apk --release --tree-shake-icons

# Split by ABI
flutter build apk --release --split-per-abi

# Obfuscate Dart code
flutter build apk --release --obfuscate --split-debug-info=/symbols
```

### Improve Build Speed

```bash
# Use cached build
flutter build apk --release --no-pub

# Skip tests
flutter build apk --release --no-test

# Use local engine (advanced)
flutter build apk --release --local-engine=android_release
```

---

## Continuous Integration (CI/CD)

### GitHub Actions Example

```yaml
name: Build APK
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## Testing the APK

### Manual Testing Checklist

After installing the APK:

- [ ] **App Launch** - Opens without crashing
- [ ] **Visual System Selection** - Switch between Quantum/Faceted/Holographic
- [ ] **Geometry Selection** - Select geometries 0-23
- [ ] **Audio Synthesis** - Verify all 3 synthesis branches (Direct/FM/Ring)
- [ ] **Parameter Coupling** - Audio affects visuals and vice versa
- [ ] **Touch Controls** - All UI elements responsive
- [ ] **Performance** - 60 FPS visual rendering, <10ms audio latency
- [ ] **WebView** - VIB3+ visualization displays correctly
- [ ] **Preset System** - Save/load presets works
- [ ] **Sensors** - Tilt controls work (if enabled)

### ADB Debugging

```bash
# View real-time logs
adb logcat | grep -i flutter

# Check for crashes
adb logcat | grep -E "(FATAL|ERROR)"

# Monitor memory usage
adb shell dumpsys meminfo com.example.synther_vib34d_holographic

# Check CPU usage
adb shell top | grep synther
```

---

## Distribution

### Google Play Store

1. Build signed release APK
2. Test on multiple devices
3. Create listing in Play Console
4. Upload APK (or use App Bundle)
5. Fill out store listing
6. Submit for review

### Direct Distribution

Share `app-release.apk` via:
- Cloud storage (Google Drive, Dropbox)
- Direct download from website
- Email attachment

**Note:** Users must enable "Install from unknown sources" in Android settings.

---

## Additional Resources

- **Flutter Docs:** https://docs.flutter.dev/deployment/android
- **Android Docs:** https://developer.android.com/studio/publish
- **Project README:** `README.md`
- **Integration Guide:** `FLUTTER_DART_INTEGRATION.md`
- **Architecture:** `CLAUDE.md`

---

## Support

For build issues specific to this integration:
- Check `FLUTTER_DART_INTEGRATION.md` for integration details
- Review recent commits for changes
- Check `pubspec.yaml` for dependency conflicts

---

**Built with Flutter • A Paul Phillips Manifestation**

*"The Revolution Will Not be in a Structured Format"*

© 2025 Paul Phillips - Clear Seas Solutions LLC
