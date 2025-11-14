# Deployment Guide - Synth-VIB3+ Integrated

## Platform Support Matrix

| Feature | Android/iOS | Web | Notes |
|---------|-------------|-----|-------|
| **Real-time Audio Synthesis** | ✅ Full | ❌ No | Requires flutter_pcm_sound (native only) |
| **VIB3+ Visualization** | ✅ Full | ❌ No | WebView can't load local assets in web build |
| **Sensor Input (Tilt/Gyro)** | ✅ Full | ❌ No | Browser has limited sensor access |
| **Haptic Feedback** | ✅ Full | ❌ No | No standardized browser haptic API |
| **Multi-Touch Gestures** | ✅ Full | ✅ Yes | Touch events work in modern browsers |
| **UI Components** | ✅ Full | ✅ Yes | All Flutter UI works |
| **Preset Browser** | ✅ Full | ✅ Yes | Fully functional |
| **Modulation Matrix** | ✅ Full | ✅ Yes | Fully functional |
| **Performance Monitor** | ✅ Full | ⚠️  Limited | Can't measure audio latency on web |
| **Help System** | ✅ Full | ✅ Yes | Fully functional |
| **Firebase Sync** | ✅ Full | ✅ Yes | Works with Firebase JS SDK |

**Summary**:
- **Android/iOS**: 100% features working
- **Web**: ~50% features working (UI only, no audio/sensors/haptics)

---

## Recommended Deployment Strategy

### 🎯 Primary Deployment: Android/iOS

The full "extra dimension of ability" experience requires native platform features. Deploy to mobile for the complete feature set.

**Why Mobile First:**
1. Real-time low-latency audio synthesis (<10ms)
2. VIB3+ holographic 4D visualization
3. Accelerometer/gyroscope tilt control
4. Musical haptic feedback
5. Multi-touch performance pad (up to 10 touches)
6. Full sensor integration

### 🌐 Secondary Deployment: Web (Demo/Showcase)

Web deployment can showcase the UI and interaction design but cannot provide the full audio-visual experience.

**Use Web For:**
- UI/UX demonstration
- Preset browsing interface
- Modulation matrix visualization
- Help system showcase
- Marketing/screenshots
- Code portfolio

**Don't Use Web For:**
- Live performance
- Sound design
- Production use
- Full feature demonstration

---

## Android Deployment

### Prerequisites
```bash
# Ensure Flutter SDK installed
flutter --version

# Ensure Android SDK installed
flutter doctor
```

### Build Release APK
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

### Output
```
build/app/outputs/flutter-apk/app-release.apk
```

### Install on Device
```bash
# Install via adb
adb install build/app/outputs/flutter-apk/app-release.apk

# Or drag APK to device and install manually
```

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### Output
```
build/app/outputs/bundle/release/app-release.aab
```

---

## iOS Deployment

### Prerequisites
```bash
# Ensure Flutter SDK installed
flutter --version

# Ensure Xcode installed (macOS only)
xcode-select --version

# Install CocoaPods
sudo gem install cocoapods
```

### Build Release IPA
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Install pods
cd ios && pod install && cd ..

# Build release IPA (requires Xcode)
flutter build ios --release
```

### Open in Xcode
```bash
open ios/Runner.xcworkspace
```

### Deploy
1. Archive in Xcode (Product → Archive)
2. Upload to App Store Connect
3. Or export IPA for TestFlight

---

## Web Deployment (Limited Demo)

### Prerequisites
```bash
# Ensure Flutter SDK with web support
flutter config --enable-web
flutter devices  # Should show Chrome
```

### Build Web Release

#### Option 1: Standard Web Build (Won't Work Fully)
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build web
flutter build web --release
```

**Output**: `build/web/`

**Issues**:
- ❌ flutter_pcm_sound won't compile for web
- ❌ sensors_plus won't work properly
- ❌ webview_flutter won't load local VIB3+ assets

#### Option 2: Web-Compatible Build (Recommended for Demo)

**Create a web-specific version** that:
1. Disables audio synthesis
2. Shows placeholder for VIB3+ visualization
3. Disables sensor input
4. Disables haptic feedback
5. Shows "Mobile App Required" message for audio features

To create this, you would need to:
```dart
// Create lib/main_web.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  if (kIsWeb) {
    runApp(WebDemoApp());  // Limited version
  } else {
    runApp(FullApp());     // Full version
  }
}
```

### Deploy to GitHub Pages

#### Manual Deployment
```bash
# Build web
flutter build web --release

# Clone gh-pages branch (or create it)
git checkout --orphan gh-pages

# Remove all files
git rm -rf .

# Copy web build
cp -r build/web/* .

# Add base href
# Edit index.html:
# <base href="/your-repo-name/">

# Commit
git add .
git commit -m "Deploy web demo"

# Push
git push origin gh-pages --force
```

#### Automated Deployment (GitHub Actions)

Create `.github/workflows/deploy-web.yml`:

```yaml
name: Deploy Web Demo

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'

    - name: Build Web (will have errors due to native deps)
      run: |
        flutter pub get
        flutter build web --release || true

    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
```

**⚠️  WARNING**: This build will fail due to flutter_pcm_sound not supporting web.

### Fix for Web Build

To make web build succeed, you need to conditionally exclude native-only packages:

**Option A**: Use conditional imports (complex)

**Option B**: Create separate pubspec.yaml for web (not standard)

**Option C**: Fork native packages to provide web stubs (time-consuming)

**Option D**: Accept that web deployment won't work (recommended)

---

## Current Deployment Status

### ✅ Android: READY FOR DEPLOYMENT
```bash
flutter build apk --release
# Result: Fully functional APK with all features
```

### ✅ iOS: READY FOR DEPLOYMENT
```bash
flutter build ios --release
# Result: Fully functional IPA with all features
```

### ⚠️  Web: LIMITED DEPLOYMENT POSSIBLE

**Current State**: Web build will FAIL due to:
1. `flutter_pcm_sound` (no web support)
2. `webview_flutter` loading local assets
3. `sensors_plus` limited web support

**To Deploy Web Demo**:
1. Create web-specific version without native deps
2. Replace audio synthesis with "Mobile Only" message
3. Replace VIB3+ visualization with static image/video
4. Disable sensor features
5. Show "Download Mobile App" prompts

**Effort Required**: ~4-6 hours of additional development

**Value**: Showcase UI/UX only, not full product

---

## Recommended Deployment Plan

### Phase 1: Mobile Deployment (Now)
```bash
# Android
flutter build apk --release
# Upload to Play Store or distribute APK

# iOS
flutter build ios --release
# Upload to App Store or TestFlight
```

**Features**: 100% working
**Timeline**: Ready now
**Effort**: Minimal (standard deployment)

### Phase 2: Web Demo (Optional, Future)
```bash
# Create web-compatible fork
# Replace native features with placeholders
# Build and deploy to GitHub Pages
```

**Features**: 50% working (UI only)
**Timeline**: 4-6 hours development
**Effort**: Moderate (requires refactoring)
**Value**: Marketing/showcase only

---

## Testing Before Deployment

### Android Testing
```bash
# Debug build
flutter run

# Profile build (check performance)
flutter run --profile

# Release build test
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Verify**:
- ✅ Audio synthesis works
- ✅ VIB3+ visualization renders
- ✅ Multi-touch gestures work
- ✅ Haptic feedback triggers
- ✅ Sensor input responds
- ✅ All UI components functional
- ✅ Performance: 60 FPS, <10ms latency

### iOS Testing
```bash
# Debug build
flutter run

# Profile build
flutter run --profile

# Release build test
flutter build ios --release
# Install via Xcode
```

**Verify**: Same as Android

### Web Testing (Limited)
```bash
# Try to build
flutter build web --release

# Expected: Build FAILURE
# Reason: flutter_pcm_sound not supported

# If you create web-compatible version:
flutter run -d chrome

# Verify:
# ✅ UI components render
# ✅ Gestures work
# ✅ Preset browser works
# ❌ Audio doesn't work
# ❌ VIB3+ doesn't work
# ❌ Sensors don't work
# ❌ Haptics don't work
```

---

## Performance Targets

### Mobile (Android/iOS)
- **FPS**: 60 (maintained)
- **Audio Latency**: <10ms
- **Parameter Update Rate**: 60 Hz
- **Memory**: <200 MB
- **Battery**: Efficient (optimized rendering)

### Web (If Implemented)
- **FPS**: 60 (maintained)
- **Audio Latency**: N/A (not supported)
- **Parameter Update Rate**: N/A (visual only)
- **Memory**: <100 MB (no audio buffers)
- **Load Time**: <3 seconds

---

## Distribution Options

### Android
1. **Google Play Store** (recommended)
   - Full distribution
   - Automatic updates
   - Reviews & ratings
   - Analytics

2. **Direct APK** (alternative)
   - No store fees
   - Full control
   - Manual updates
   - Side-loading required

3. **Alternative Stores**
   - Amazon App Store
   - Samsung Galaxy Store
   - F-Droid (if open-sourced)

### iOS
1. **App Store** (recommended)
   - Full distribution
   - TestFlight beta testing
   - Automatic updates

2. **Enterprise Distribution**
   - Internal deployment only
   - Requires enterprise account

3. **TestFlight** (beta)
   - Up to 10,000 testers
   - Time-limited builds

### Web
1. **GitHub Pages** (free, limited)
   - Static hosting
   - Custom domain support
   - CI/CD friendly

2. **Firebase Hosting** (recommended for web)
   - CDN distribution
   - SSL included
   - Analytics integration

3. **Netlify/Vercel** (alternatives)
   - Easy deployment
   - Preview deployments
   - Custom domains

---

## Asset Preparation

### Before Deployment

#### Android
```bash
# Update version in pubspec.yaml
version: 1.0.0+1  # version+buildNumber

# Update app icon
# Place in android/app/src/main/res/mipmap-*/ic_launcher.png

# Update app name
# Edit android/app/src/main/AndroidManifest.xml
android:label="Synth-VIB3+"

# Add signing config
# Create android/key.properties
# Configure android/app/build.gradle
```

#### iOS
```bash
# Update version in pubspec.yaml
version: 1.0.0+1

# Update app icon
# Place in ios/Runner/Assets.xcassets/AppIcon.appiconset/

# Update app name
# Edit ios/Runner/Info.plist
<key>CFBundleDisplayName</key>
<string>Synth-VIB3+</string>

# Configure signing
# Open ios/Runner.xcworkspace in Xcode
# Set Team and Bundle Identifier
```

#### Web
```bash
# Update index.html title
<title>Synth-VIB3+ | Holographic Synthesizer</title>

# Update favicon
# Place in web/favicon.png

# Update manifest.json
# Edit web/manifest.json
```

---

## Post-Deployment

### Monitoring
- **Crashlytics**: Add Firebase Crashlytics for error reporting
- **Analytics**: Add Firebase Analytics for usage tracking
- **Performance**: Monitor FPS, latency via Performance Monitor

### Updates
```bash
# Increment version
version: 1.0.1+2  # New version+new buildNumber

# Rebuild
flutter build apk --release

# Redeploy
```

### Rollback
```bash
# If issues found, rollback in store
# Keep previous APK/IPA versions

# For web, revert gh-pages branch
git revert HEAD
git push origin gh-pages
```

---

## Troubleshooting

### Build Fails (Android)
```bash
# Clean everything
flutter clean
rm -rf build/

# Update dependencies
flutter pub get

# Check Gradle
cd android
./gradlew clean
cd ..

# Rebuild
flutter build apk --release
```

### Build Fails (iOS)
```bash
# Clean everything
flutter clean
rm -rf build/
rm -rf ios/Pods
rm ios/Podfile.lock

# Reinstall pods
cd ios
pod install
cd ..

# Rebuild
flutter build ios --release
```

### Build Fails (Web)
**Expected**: flutter_pcm_sound not supported

**Solution**: Create web-compatible version (see above)

---

## Summary & Recommendations

### ✅ DEPLOY NOW: Mobile (Android/iOS)
- All features working
- Full audio-visual experience
- Low latency performance
- Haptic feedback
- Sensor integration
- Ready for production

**Action**:
```bash
flutter build apk --release     # Android
flutter build ios --release     # iOS
```

### ⚠️  DEPLOY LATER: Web (GitHub Pages)
- UI showcase only
- No audio synthesis
- No VIB3+ visualization
- No sensors/haptics
- Requires additional development

**Action**:
1. First deploy mobile versions
2. If needed for marketing, create web-compatible demo
3. Set expectations: "UI Preview Only - Download Mobile App for Full Experience"

### 🎯 Recommended Priority

1. **✅ Android APK** (1-2 hours)
   - Build
   - Test
   - Deploy

2. **✅ iOS IPA** (2-3 hours)
   - Build
   - Test via TestFlight
   - Deploy

3. **⏸️  Web Demo** (4-6 hours - optional)
   - Create web-compatible fork
   - Build with placeholders
   - Deploy to GitHub Pages
   - Add "Download App" CTAs

---

**Deployment Status**: ✅ MOBILE READY | ⚠️  WEB NEEDS WORK

**Recommendation**: Deploy to mobile platforms now. Web deployment is optional and should be positioned as a demo/showcase only.

A Paul Phillips Manifestation
"The Revolution Will Not be in a Structured Format"
© 2025 Paul Phillips - Clear Seas Solutions LLC
