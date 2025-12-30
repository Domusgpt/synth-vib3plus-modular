# GitHub Actions CI/CD Guide

This repository includes automated build workflows using GitHub Actions to build Android APKs automatically.

---

## 📋 Available Workflows

### 1. **Build APK** (`.github/workflows/build-apk.yml`)

**Triggers:**
- Push to `main`, `master`, `develop`, or any `claude/**` branch
- Pull requests to main branches
- Manual trigger from GitHub Actions tab

**What it does:**
1. ✅ Sets up Flutter and Java 21
2. ✅ Runs `flutter pub get`
3. ✅ Runs static analysis (`flutter analyze`)
4. ✅ Runs tests (`flutter test`)
5. ✅ Builds release APK (universal)
6. ✅ Builds split APKs (arm64, armv7, x86_64)
7. ✅ Uploads all APKs as artifacts

**Output:**
- Universal APK (~40-60 MB)
- ARM64 APK (~30-40 MB) - Most devices
- ARMv7 APK (~25-35 MB) - Older devices
- x86_64 APK (~30-40 MB) - Intel devices

### 2. **PR Build Check** (`.github/workflows/pr-build.yml`)

**Triggers:**
- When pull requests are opened, updated, or reopened

**What it does:**
1. ✅ Runs code analysis
2. ✅ Runs all tests
3. ✅ Generates coverage report
4. ✅ Comments on PR with results
5. ✅ Builds debug APK for testing

**Output:**
- PR comment with build status
- Debug APK for testing (7-day retention)

### 3. **Release Build** (`.github/workflows/release.yml`)

**Triggers:**
- Git tags matching `v*.*.*` (e.g., `v1.0.0`)
- Manual trigger with version input

**What it does:**
1. ✅ Full analysis and testing
2. ✅ Builds release APK with obfuscation
3. ✅ Generates debug symbols for crash reporting
4. ✅ Creates SHA-256 checksums
5. ✅ Renames APKs with version numbers
6. ✅ Creates GitHub Release with notes
7. ✅ Uploads all APKs to release

**Output:**
- GitHub Release with:
  - `synth-vib3plus-v1.0.0-universal.apk`
  - `synth-vib3plus-v1.0.0-arm64.apk`
  - `synth-vib3plus-v1.0.0-armv7.apk`
  - `synth-vib3plus-v1.0.0-x86_64.apk`
  - `checksums.txt`
- Debug symbols artifact (90-day retention)

---

## 🚀 How to Use

### Download Built APKs from GitHub

#### After Every Push:

1. Go to **GitHub Repository** → **Actions** tab
2. Click on the latest **Build APK** workflow run
3. Scroll down to **Artifacts** section
4. Download the APK you need:
   - `app-release-universal` - Universal APK
   - `app-release-arm64-v8a` - ARM64 (most common)
   - `app-release-armeabi-v7a` - ARMv7 (older devices)
   - `app-release-x86_64` - x86 64-bit

#### For Releases:

1. Go to **GitHub Repository** → **Releases**
2. Find the version you want (e.g., `v1.0.0`)
3. Download the APK from **Assets** section
4. Verify checksum (optional):
   ```bash
   sha256sum synth-vib3plus-v1.0.0-arm64.apk
   # Compare with checksums.txt
   ```

### Manually Trigger a Build

1. Go to **Actions** tab
2. Click **Build APK** workflow (left sidebar)
3. Click **Run workflow** button (top right)
4. Select branch and click **Run workflow**
5. Wait for completion (~5-10 minutes)
6. Download from **Artifacts**

### Create a Release

#### Option 1: Git Tag (Recommended)

```bash
# Create and push a version tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# GitHub Actions will automatically:
# - Build APKs
# - Create GitHub Release
# - Upload APKs to release
```

#### Option 2: Manual Trigger

1. Go to **Actions** tab
2. Click **Release Build** workflow
3. Click **Run workflow**
4. Enter version number (e.g., `1.0.0`)
5. Click **Run workflow**

---

## 📊 Workflow Status Badges

Add these badges to your README.md:

```markdown
[![Build APK](https://github.com/Domusgpt/synth-vib3plus-modular/actions/workflows/build-apk.yml/badge.svg)](https://github.com/Domusgpt/synth-vib3plus-modular/actions/workflows/build-apk.yml)

[![PR Build Check](https://github.com/Domusgpt/synth-vib3plus-modular/actions/workflows/pr-build.yml/badge.svg)](https://github.com/Domusgpt/synth-vib3plus-modular/actions/workflows/pr-build.yml)

[![Release Build](https://github.com/Domusgpt/synth-vib3plus-modular/actions/workflows/release.yml/badge.svg)](https://github.com/Domusgpt/synth-vib3plus-modular/actions/workflows/release.yml)
```

---

## ⚙️ Configuration

### Modify Flutter Version

Edit the workflows to change Flutter version:

```yaml
- name: 📱 Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'  # Change this
    channel: 'stable'
```

### Change Artifact Retention

Default retention periods:
- **Regular builds:** 30 days
- **PR builds:** 7 days
- **Release debug symbols:** 90 days

To modify, edit the `retention-days` in workflows:

```yaml
- name: 📤 Upload APK
  uses: actions/upload-artifact@v4
  with:
    name: app-release
    path: build/app/outputs/flutter-apk/app-release.apk
    retention-days: 30  # Change this
```

### Add Slack/Discord Notifications

Add a notification step at the end of workflows:

```yaml
- name: 📢 Notify on Slack
  uses: 8398a7/action-slack@v3
  if: always()
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🐛 Troubleshooting

### Build Fails on Analysis

If `flutter analyze` has warnings:

```yaml
- name: 🔎 Run static analysis
  run: flutter analyze --no-fatal-infos
  continue-on-error: true  # Don't fail build on warnings
```

### Build Fails on Tests

If tests are failing but you want to build anyway:

```yaml
- name: 🧪 Run tests
  run: flutter test
  continue-on-error: true  # Don't fail build on test failures
```

### Out of Disk Space

GitHub runners have limited disk space. Clean up:

```yaml
- name: 🧹 Free disk space
  run: |
    sudo rm -rf /usr/local/lib/android
    sudo rm -rf /usr/share/dotnet
    flutter clean
```

### Gradle Build Timeout

Increase timeout:

```yaml
- name: 🔨 Build APK
  run: flutter build apk --release
  timeout-minutes: 30  # Default is 360
```

### Java Version Issues

Ensure Java 21 is used (required by this project):

```yaml
- name: ☕ Setup Java 21
  uses: actions/setup-java@v4
  with:
    distribution: 'temurin'
    java-version: '21'
```

---

## 📈 Build Times

Typical workflow execution times:

| Workflow | Duration |
|----------|----------|
| Build APK | 5-8 minutes |
| PR Build Check | 3-5 minutes |
| Release Build | 6-10 minutes |

**Note:** First run may take longer due to cache setup.

---

## 🔐 Secrets Configuration

### Required Secrets

None required for basic builds!

### Optional Secrets

For advanced features, add these in **Settings** → **Secrets and variables** → **Actions**:

- `SLACK_WEBHOOK` - Slack notifications
- `DISCORD_WEBHOOK` - Discord notifications
- `FIREBASE_TOKEN` - Firebase deployment
- `UPLOAD_KEYSTORE` - Signing keystore (base64)
- `KEYSTORE_PASSWORD` - Keystore password
- `KEY_ALIAS` - Key alias
- `KEY_PASSWORD` - Key password

---

## 📱 Installing Built APKs

### From Artifacts:

1. Download `.zip` file from GitHub Actions
2. Extract APK file
3. Transfer to Android device
4. Enable "Install from unknown sources"
5. Tap APK to install

### From Releases:

1. Download APK directly on Android device
2. Enable "Install from unknown sources"
3. Open Downloads folder
4. Tap APK to install

---

## 🔄 Workflow Updates

To modify workflows:

1. Edit files in `.github/workflows/`
2. Commit and push changes
3. Workflows update automatically
4. Test by triggering manually

---

## 📚 Additional Resources

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Flutter CI/CD:** https://docs.flutter.dev/deployment/cd
- **subosito/flutter-action:** https://github.com/subosito/flutter-action
- **actions/upload-artifact:** https://github.com/actions/upload-artifact

---

**GitHub Actions configured and ready!** 🚀

Every push will now automatically build your APK and make it available for download.

A Paul Phillips Manifestation
© 2025 Clear Seas Solutions LLC
