# Synth-VIB3+ Build, Test & Deployment Guide

**Last Updated**: 2025-11-17
**Target Platform**: Android (Phone/Tablet)
**Development Environment**: Linux/WSL, macOS, Windows

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Building the Application](#building-the-application)
4. [Testing Procedures](#testing-procedures)
5. [Performance Benchmarking](#performance-benchmarking)
6. [Debugging Guide](#debugging-guide)
7. [Known Issues](#known-issues)
8. [Troubleshooting](#troubleshooting)

---

## 🛠️ Prerequisites

### Required Software

- **Flutter SDK**: 3.27.1 or later (Dart SDK 3.6.0+)
- **Android SDK**: Platform 34 (Android 14) minimum
- **Android Build Tools**: 34.0.0 or later
- **Java JDK**: 17 or later
- **Git**: For version control

### Hardware Requirements

**Development Machine**:
- 8 GB RAM minimum (16 GB recommended)
- 10 GB free disk space
- USB port for device connection

**Target Device (Android)**:
- Android 8.0 (API 26) or later
- 2 GB RAM minimum (4 GB recommended for Holographic system)
- OpenGL ES 3.0+ support
- 500 MB free storage

---

## 🏗️ Environment Setup

### 1. Install Flutter SDK

#### Linux/macOS:
```bash
# Download Flutter
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz
tar xf flutter_linux_3.27.1-stable.tar.xz

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter --version
```

#### Windows:
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to PATH
4. Run `flutter doctor` to verify

### 2. Install Android SDK

#### Using Android Studio (Recommended):
1. Download Android Studio from https://developer.android.com/studio
2. Run Android Studio and complete setup wizard
3. Install:
   - Android SDK Platform 34
   - Android SDK Build-Tools 34.0.0
   - Android Emulator (optional)

#### Using Command-Line Tools (Advanced):
```bash
# Download SDK command-line tools
mkdir -p ~/android-sdk
cd ~/android-sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/

# Set environment variables (add to ~/.bashrc)
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Accept licenses and install SDK
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### 3. Configure Flutter for Android

```bash
# Configure Flutter to use Android SDK
flutter config --android-sdk $ANDROID_HOME

# Verify setup
flutter doctor -v

# Expected output (all checkmarks):
# [✓] Flutter
# [✓] Android toolchain
# [✓] Connected device (if device connected)
```

### 4. Clone and Setup Project

```bash
# Clone repository
git clone https://github.com/Domusgpt/synth-vib3plus-modular.git
cd synth-vib3plus-modular

# Checkout development branch
git checkout claude/refactor-synthesizer-visualizer-01WZyQHcrko29P2RSnGG1Kmp

# Get dependencies
flutter pub get

# Verify no errors
flutter analyze --no-fatal-infos
```

---

## 🔨 Building the Application

### Development Build (Debug)

```bash
# Connect Android device via USB or start emulator
adb devices  # Should show your device

# Run app in debug mode
flutter run

# Or specify device explicitly
flutter run -d <device-id>
```

**Debug Build Features**:
- Hot reload enabled (press `r` in terminal)
- Hot restart enabled (press `R` in terminal)
- Debug logging enabled
- Performance overlay available (press `p`)

### Release Build (APK)

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build APK split by ABI (smaller file size)
flutter build apk --split-per-abi

# Outputs:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM - most devices)
# - app-x86_64-release.apk (x86 64-bit - emulators)
```

### Install Release APK on Device

```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or install with replacement
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (Google Play)

```bash
# Build Android App Bundle (.aab)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🧪 Testing Procedures

### Phase 1: Core Functionality Test

**Test Module**: Parameter Registry & Modulation Matrix

```bash
# 1. Start app in debug mode
flutter run

# 2. Test parameter updates
# - Adjust any slider/knob in UI
# - Verify parameter changes reflect in sound
# - Check debug console for parameter logs

# Expected Console Output:
# ✅ Parameter Registry initialized with 27 parameters
# 💾 User parameter: <param-name> = <value>
# 📊 <SYSTEM>: <param-name> = <value>
```

**Verification Checklist**:
- [ ] All UI controls respond to touch
- [ ] Parameter changes update audio in real-time
- [ ] No console errors or exceptions
- [ ] Frame rate stays above 30 FPS

---

### Phase 2: Synthesis Engine Test

**Test Module**: 72-Combination Matrix (3 Systems × 24 Geometries)

```bash
# Test each visual system
1. Quantum (Geometry 0-7) - Direct synthesis
2. Faceted (Geometry 8-15) - FM synthesis
3. Holographic (Geometry 16-23) - Ring modulation

# For each geometry:
- Play a note (touch screen or MIDI input if configured)
- Verify unique sonic character
- Check visual representation
```

**Geometry Test Script**:
```dart
// Add this button to main.dart for quick testing
ElevatedButton(
  onPressed: () async {
    for (int geometry = 0; geometry < 24; geometry++) {
      await visualProvider.setFullGeometry(geometry);
      await Future.delayed(Duration(seconds: 2));

      // Play middle C for 1 second
      audioProvider.noteOn(60, 0.8);
      await Future.delayed(Duration(milliseconds: 1000));
      audioProvider.noteOff(60);
      await Future.delayed(Duration(milliseconds: 500));
    }
  },
  child: Text('Test All 72 Combinations'),
)
```

**Expected Results**:
| Geometry | System | Synthesis | Voice Character |
|----------|--------|-----------|-----------------|
| 0 | Quantum | Direct | Tetrahedron - Fundamental |
| 3 | Quantum | Direct | Torus - Cyclic Phase Mod |
| 8 | Faceted | FM | Tetrahedron - FM with Direct envelope |
| 11 | Faceted | FM | Torus - FM with Cyclic modulation |
| 16 | Holographic | Ring Mod | Tetrahedron - Ring Mod basic |
| 19 | Holographic | Ring Mod | Torus - Ring Mod cyclic |

---

### Phase 3: Smart Canvas Management Test

**Test Module**: Lazy Initialization & WebGL Context Management

#### 3.1 Initial Load Test
```bash
# 1. Run app
flutter run

# 2. Check WebView console (enable in VIB34D widget)
# Expected logs:
# 🎯 SmartCanvasManager: Initializing with lazy loading pattern
# 🌌 Quantum system initialized (Geometry 0-7, Direct synthesis)
# ✅ quantum system initialized
# ✅ SmartCanvasManager: Ready
# READY: VIB3+ Smart Canvas initialized
```

**Verification**:
- [ ] Only Quantum system initializes on startup
- [ ] Load time < 2 seconds
- [ ] No "all systems loaded" message
- [ ] Console shows "1/3 systems initialized"

#### 3.2 System Switching Test
```bash
# Test switching sequence:
1. Start on Quantum (default)
2. Switch to Faceted
3. Switch to Holographic
4. Switch back to Quantum

# For each switch, verify:
- Switch completes in < 100ms
- No visual glitches or blank screens
- Previous system state is preserved
- Console shows lazy initialization messages
```

**Expected Console Output (First Switch to Faceted)**:
```
🔄 Switching: quantum → faceted
🚀 Initializing faceted system (lazy)...
🔷 Faceted system initialized (Geometry 8-15, FM synthesis)
✅ faceted system initialized
✅ Switched to faceted
```

**Expected Console Output (Second Switch to Quantum)**:
```
🔄 Switching: faceted → quantum
⚡ quantum already initialized, reusing
✅ Switched to quantum
```

#### 3.3 Memory Usage Test
```bash
# Use Android Studio Profiler or adb
adb shell dumpsys meminfo <package-name>

# Monitor GPU memory:
adb shell dumpsys gfxinfo <package-name>
```

**Target Metrics**:
| Metric | Before Phase 3 | After Phase 3 | Improvement |
|--------|----------------|---------------|-------------|
| GPU Memory | 200-300 MB | 50-80 MB | 70% ↓ |
| WebGL Contexts | 8-20 | 1 | 85-95% ↓ |
| Load Time | 3-5 sec | <1 sec | 80% ↓ |
| System Switch | 500-1000ms | <50ms | 95% ↓ |
| FPS (avg) | 30-40 | 60 | 50% ↑ |

#### 3.4 Debug Overlay Test
```bash
# Enable debug overlay
# Add button to UI or use flutter_driver commands

# Verify overlay shows:
- Current System: quantum/faceted/holographic
- Initialized Systems: 1/3, 2/3, or 3/3
- Active WebGL Contexts: 1 (always)
- FPS: Real-time counter (should be ~60)
```

---

### Phase 4: Bidirectional Parameter Flow Test

**Test Module**: Audio ↔ Visual Coupling

#### 4.1 Audio → Visual Test
```dart
// Test audio modulates visual parameters
// Play different frequencies and verify:

// LOW FREQUENCY (100 Hz) - Bass Energy High
- Rotation speed increases (0.5x-2.5x)
- Glow intensity increases

// MID FREQUENCY (1000 Hz) - Mid Energy High
- Tessellation density increases (3-8)

// HIGH FREQUENCY (5000 Hz) - High Energy High
- Vertex brightness increases (0.5-1.0)
- Hue shifts toward cyan

// LOUD AMPLITUDE
- Overall glow intensity increases
```

#### 4.2 Visual → Audio Test
```dart
// Test visual parameters modulate audio
// Adjust visual sliders and verify audio changes:

// XW ROTATION (4D)
- FM depth changes (Faceted system only)
- Subtle detuning (other systems)

// YW ROTATION (4D)
- Ring mod depth changes (Holographic only)
- Phase modulation (other systems)

// ZW ROTATION (4D)
- Filter cutoff modulates (±40%)

// MORPH SLIDER
- Waveform crossfades smoothly

// CHAOS SLIDER
- Noise injection increases (0-30%)
- Filter randomization

// GLOW INTENSITY
- Reverb mix increases (5-60%)
- Attack time decreases (100ms→1ms)
```

---

## 📊 Performance Benchmarking

### Automated Performance Test

Create `test/performance_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:synther_vib34d_holographic/main.dart';

void main() {
  testWidgets('Performance benchmark', (WidgetTester tester) async {
    await tester.pumpWidget(const SynthVIB3App());
    await tester.pumpAndSettle();

    // Measure frame times
    final Stopwatch stopwatch = Stopwatch()..start();
    int frameCount = 0;

    for (int i = 0; i < 600; i++) {  // 10 seconds at 60 FPS
      await tester.pump(const Duration(milliseconds: 16));
      frameCount++;
    }

    stopwatch.stop();
    final double fps = frameCount / (stopwatch.elapsedMilliseconds / 1000);

    print('Average FPS: ${fps.toStringAsFixed(1)}');
    expect(fps, greaterThan(50));  // Should maintain >50 FPS
  });
}
```

Run benchmark:
```bash
flutter test test/performance_test.dart
```

### Manual Performance Testing

#### FPS Monitoring
```bash
# Enable performance overlay in app
flutter run --profile

# Or use adb
adb shell dumpsys gfxinfo <package-name> framestats
```

#### Memory Profiling
```bash
# Monitor memory in real-time
adb shell dumpsys meminfo <package-name> -d

# Check for memory leaks (run for 5+ minutes)
# Memory should stabilize, not continuously increase
```

---

## 🐛 Debugging Guide

### Enable WebView Debugging

Edit `lib/visual/vib34d_widget.dart`:
```dart
// Enable WebView debugging (line 85)
if (_webViewController.platform is AndroidWebViewController) {
  AndroidWebViewController.enableDebugging(true);  // Already enabled!
  // ...
}
```

Access WebView console:
1. Connect device via USB
2. Open Chrome on desktop
3. Navigate to `chrome://inspect`
4. Find your app's WebView
5. Click "inspect" to open DevTools

### Common Debug Scenarios

#### Issue: App crashes on startup
```bash
# Check logs
adb logcat -s flutter

# Look for:
# - Missing dependencies
# - Asset loading errors
# - Permission issues
```

#### Issue: No sound output
```bash
# Verify audio permissions in AndroidManifest.xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>

# Check AudioProvider initialization
# Expected console output:
# ✅ AudioProvider initialized
# 🎹 SynthesizerEngine: Initialized with <X> voices
```

#### Issue: Visualizer not loading
```bash
# Check WebView console (chrome://inspect)
# Look for JavaScript errors

# Verify asset loading
flutter pub get
flutter clean
flutter run

# Check for console messages:
# ✅ VIB3+ Smart Canvas initialized
# 🌌 Quantum system initialized
```

#### Issue: System switching doesn't work
```bash
# Check VisualProvider logs
# Expected on setFullGeometry():
# 🔄 System Switching: <old> → <new>
# Full Geometry Updated: <old-index> → <new-index>

# Check WebView console:
# 🔄 Switching: <old> → <new>
# 🚀 Initializing <new> system (lazy)...
# ✅ <new> system initialized
```

---

## ⚠️ Known Issues

### 1. Placeholder Rendering (CRITICAL)

**Issue**: Smart Canvas has placeholder render functions (solid colors only)

**Impact**: Visualizations don't show actual geometric rendering

**Workaround**: None - requires integration of actual VIB3+ rendering logic

**Fix Required**:
```javascript
// In assets/vib3_smart/index.html
// Replace placeholder functions with actual implementations from:
// - assets/src/quantum/QuantumVisualizer.js
// - assets/src/faceted/FacetedSystem.js
// - assets/src/holograms/HolographicSystem.js
```

### 2. Firebase Web Compatibility

**Issue**: Firebase packages prevent web builds

**Impact**: Can only build for Android/iOS, not web

**Workaround**: Remove Firebase dependencies if web build is required

### 3. Analysis Warnings

**Issue**: 759 style/lint warnings from `flutter analyze`

**Impact**: None - these are non-blocking style suggestions

**Fix**: Optional - run `dart format .` to auto-fix most issues

### 4. Dart SDK Version

**Issue**: pubspec.yaml originally required SDK ^3.9.0 but Flutter 3.27.1 has Dart 3.6.0

**Fix**: Already applied - updated to `sdk: ^3.6.0`

---

## 🔧 Troubleshooting

### Build Fails with "Gradle sync failed"

```bash
# Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### WebView shows blank screen

```bash
# Check AndroidManifest.xml has internet permission
<uses-permission android:name="android.permission.INTERNET"/>

# Verify hardware acceleration enabled
android:hardwareAccelerated="true"

# Check logcat for WebView errors
adb logcat | grep chromium
```

### App size too large

```bash
# Build with split ABIs (creates separate APKs for each architecture)
flutter build apk --split-per-abi --target-platform android-arm64

# Use app bundle for Play Store (automatic optimization)
flutter build appbundle
```

### Low FPS on device

```bash
# Profile performance
flutter run --profile

# Check for:
# 1. GPU overdraw (too many layers)
# 2. Excessive rebuilds (use flutter DevTools)
# 3. Large asset files (optimize images)
# 4. Multiple WebGL contexts (should be 1 after Phase 3)
```

---

## 📦 Release Checklist

Before creating a release build:

- [ ] All tests pass (`flutter test`)
- [ ] No analysis errors (`flutter analyze`)
- [ ] Performance targets met (>50 FPS, <100MB memory)
- [ ] All 72 combinations produce unique sounds
- [ ] System switching works smoothly
- [ ] Smart Canvas lazy initialization verified
- [ ] WebView console shows no errors
- [ ] Signed APK or App Bundle created
- [ ] Tested on minimum 2 devices (different Android versions)
- [ ] Version number updated in pubspec.yaml
- [ ] CHANGELOG updated

---

## 📞 Support

**Repository**: https://github.com/Domusgpt/synth-vib3plus-modular
**Branch**: `claude/refactor-synthesizer-visualizer-01WZyQHcrko29P2RSnGG1Kmp`

**Documentation**:
- `PHASE_1_COMPLETE.md` - Parameter Registry & Modulation Matrix
- `PHASE_2_COMPLETE.md` - Portamento & Voice Allocation
- `PHASE_3_COMPLETE.md` - Smart Canvas Management
- `REFACTORING_SUMMARY.md` - Complete architecture overview

**A Paul Phillips Manifestation**
Paul@clearseassolutions.com
"The Revolution Will Not be in a Structured Format"
© 2025 Paul Phillips - Clear Seas Solutions LLC
