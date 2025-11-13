# Integration Test Plan & Status
**Date:** November 12, 2025
**Session:** Post-VIB3+ WebView Integration

---

## ✅ VERIFIED WORKING

### 1. Foundation Layer
- **Java 21**: All builds use Java 21, zero "obsolete" warnings
- **Dependencies**: 12 packages updated to latest versions
- **VIB3+ WebView**: All 4 engines load successfully
  - ✅ VIB34DIntegratedEngine (Faceted system)
  - ✅ QuantumEngine
  - ✅ RealHolographicSystem
  - ✅ NewPolychoraEngine (Polychora system)
- **ParameterBridge**: Running at 60 FPS (`🌉 ParameterBridge started`)
- **AudioProvider**: Initialized with PCM audio output
- **Visual Rendering**: VIB3+ canvas rendering at 60 FPS
- **Flutter UI**: Orb controller, side controls, bottom tabs all rendering

### 2. VIB3+ Inlined Bundle
- **Size**: 544KB single HTML file (all CSS + JS embedded)
- **Vite Config**: `inlineDynamicImports: true` prevents code splitting
- **No CORS Errors**: File access working with inlined assets
- **Bundle Location**: `assets/vib3_dist/index.html`

### 3. UI Layer Visibility
**Current State (from screenshot):**
- VIB3+ system selector (Q/F/H) visible at top ✅ (intentional per CSS)
- VIB3+ FPS counter visible ✅ (intentional)
- Flutter orb controller visible at bottom center ✅
- Flutter side controls (Octave/Filter) visible ✅
- Flutter bottom tabs (Parameters/Geometry) visible ✅

**Note**: VIB3+ control panel, bezel UI, and diagnostics are hidden as intended.

---

## ❓ NOT YET TESTED

### Critical Integration Points (Need Verification)

#### A. Audio Synthesis Functionality
**Test**: Touch XY performance pad → generates sound
- **Method**: Tap center of screen, listen for audio
- **Expected**: Synthesis engine generates tone based on XY position
- **Status**: **UNTESTED**

**Code Reference**:
- `lib/ui/components/xy_performance_pad.dart` - Touch handling
- `lib/audio/synthesizer_engine.dart` - Sound generation
- `lib/providers/audio_provider.dart:noteOn()` - Trigger synthesis

#### B. Bidirectional Parameter Coupling

##### Audio → Visual (FFT Modulation)
**Test**: Play audio → visual parameters change
- **Expected Behavior**:
  - Bass energy (20-250 Hz) → increases rotation speed
  - Mid energy (250-2000 Hz) → increases tessellation density
  - High energy (2000-8000 Hz) → increases vertex brightness
  - Spectral centroid → shifts hue (dark red → bright cyan)
  - RMS amplitude → modulates glow intensity

**Code Reference**: `lib/mapping/audio_to_visual.dart`

**Verification Method**:
```bash
# Check logs for FFT analysis output
adb logcat | grep -E "(FFT|audio.*visual|modulation)"
```

**Status**: **UNTESTED**

##### Visual → Audio (Quaternion/Geometry Modulation)
**Test**: Change visual parameters → synthesis responds
- **Expected Behavior**:
  - XY rotation → Oscillator 1 detune (±12 cents)
  - XZ rotation → Oscillator 2 detune (±12 cents)
  - YZ rotation → Combined detuning (±7 cents)
  - XW rotation → FM depth (0-2 semitones) - Hypersphere only
  - YW rotation → Ring mod depth (0-100%) - Hypertetrahedron only
  - ZW rotation → Filter cutoff modulation (±40%)
  - Morph → Waveform crossfade
  - Chaos → Noise injection (0-30%)
  - Speed → LFO rate (0.1-10 Hz)
  - Hue Shift → Spectral tilt
  - Glow Intensity → Reverb mix (5-60%)

**Code Reference**: `lib/mapping/visual_to_audio.dart`

**Verification Method**:
```dart
// Add debug logging to visual_to_audio.dart updateFromVisual()
debugPrint('🔊 Visual → Audio: rotationXW=${rotationXW}, detune=${calculatedDetune}');
```

**Status**: **UNTESTED**

#### C. System Switching
**Test**: Click Q/F/H/Polychora buttons → systems switch
- **Q (Quantum)**: Should load QuantumEngine
- **F (Faceted)**: Should load VIB34DIntegratedEngine (current default)
- **H (Holographic)**: Should load RealHolographicSystem
- **Fourth button**: Should load NewPolychoraEngine

**Verification**:
```javascript
// Check if window.switchSystem() is being called
adb logcat | grep -i "switchSystem"
```

**Expected Logs**:
```
"📊 Switching to system: quantum"
"✅ System switched to quantum"
```

**Status**: **UNTESTED**

#### D. Geometry Switching (24 Geometries)
**Test**: Use geometry selector → switches between 24 geometries
- **Geometry Index 0-7**: Base geometries (Tetrahedron → Crystal)
- **Geometry Index 8-15**: Hypersphere Core (FM synthesis)
- **Geometry Index 16-23**: Hypertetrahedron Core (Ring mod)

**Verification**:
```javascript
adb logcat | grep -iE "(geometry|GEOMETRY:|geometryIndex)"
```

**Code Reference**:
- Flutter: `lib/providers/visual_provider.dart:switchGeometry()`
- VIB3+: `window.updateParameter('geometryIndex', value)`

**Status**: **UNTESTED**

#### E. XY Pad Touch Handling
**Critical Question**: Are touches captured by Flutter XY pad or VIB3+ WebView?

**Current CSS** (vib34d_widget.dart:172-179):
```javascript
.canvas-container,
#canvasContainer,
.holographic-layers,
canvas {
  pointer-events: none !important;  // ← Disables VIB3+ touch handling
  touch-action: none !important;
}
```

**Expected**: Flutter XY pad captures ALL touch events, VIB3+ only renders visuals.

**Verification**:
1. Touch screen
2. Check logs for XY coordinates from Flutter (not VIB3+)

**Expected Logs**:
```dart
// From xy_performance_pad.dart
debugPrint('👆 Touch: x=$x, y=$y, noteNumber=$note');
```

**Status**: **UNTESTED**

#### F. Orb Controller Pitch Modulation
**Test**: Drag orb → pitch bends
- **Expected**: Pitch bend range ±2 to ±12 semitones (configurable)
- **Visual**: Orb position should update in real-time
- **Audio**: Continuous pitch glide during drag

**Code Reference**: `lib/ui/components/orb_controller.dart`

**Status**: **UNTESTED**

---

## 🐛 DISCOVERED ISSUES

### Issue 1: Flutter UI Partially Obscured
**Symptom**: VIB3+ system selector buttons visible at top, may block Flutter top bezel

**Investigation Needed**:
- Is Flutter TopBezel rendering? (should show FPS, geometry display)
- Is VIB3+ system selector intentionally visible or CSS bug?

**Code to Check**:
```dart
// lib/ui/screens/synth_main_screen.dart:148-156
Positioned(
  top: 0,
  left: 0,
  right: 0,
  child: TopBezel(...),  // ← Is this rendering?
),
```

**Resolution**:
- If intentional: Document that VIB3+ provides system selector
- If not: Update CSS to hide system selector, add Flutter system selector

### Issue 2: Tilt Sensor Calibration Error
**Symptom**: "Bad state: No element" in TiltSensorProvider._finalizeCalibration

**Cause**: Emulator has no accelerometer, calibration fails

**Impact**: None on physical devices (emulator only)

**Status**: Known limitation, not blocking

### Issue 3: Performance Verification Needed
**Target**: Sustained 60 FPS during synthesis + visualization

**Test Method**:
1. Play multiple notes (4-8 simultaneous)
2. Enable audio reactivity (FFT analysis running)
3. Monitor FPS counter in VIB3+ UI
4. Check for frame drops

**Expected**: No drops below 55 FPS

**Status**: **UNTESTED**

---

## 📋 IMMEDIATE ACTION ITEMS

### Priority 1: Basic Functionality
1. **Test XY pad touch → audio synthesis**
   - Tap screen, verify audio plays
   - Multi-touch test (2-4 fingers)
   - Log XY coordinates and note numbers

2. **Verify Flutter UI layer is on top**
   - Check if TopBezel is visible
   - Confirm touch events go to Flutter, not VIB3+

### Priority 2: Parameter Integration
3. **Enable visual → audio coupling**
   - Add debug logging to `visual_to_audio.dart`
   - Manually change rotation parameters
   - Verify synthesis responds (detune, filter, etc.)

4. **Enable audio → visual coupling**
   - Play sustained note
   - Verify FFT modulation updates VIB3+ (rotation speed, tessellation)

### Priority 3: System/Geometry Switching
5. **Test system switching**
   - Click Q/F/H buttons
   - Verify correct engine loads
   - Check visual style changes

6. **Test geometry switching**
   - Cycle through all 24 geometries
   - Verify synthesis branch changes (Base/FM/RingMod)
   - Verify voice character updates

### Priority 4: Polish & Performance
7. **Orb controller testing**
   - Drag orb, verify pitch bend
   - Test tilt sensor integration (physical device)

8. **Performance profiling**
   - Monitor FPS during heavy use
   - Check memory usage
   - Identify bottlenecks

---

## 🧪 TEST SCRIPT EXAMPLE

```bash
#!/bin/bash
# Quick integration test

echo "=== VIB3+ Integration Test ==="

# 1. Check app is running
adb shell "ps | grep synther" || { echo "App not running!"; exit 1; }

# 2. Clear logs
adb logcat -c

# 3. Touch center of screen (simulate XY pad tap)
adb shell input tap 540 1200

# 4. Wait for audio synthesis
sleep 1

# 5. Check for synthesis logs
adb logcat -d | grep -E "(noteOn|PCM|synthesis|Touch)"

# 6. Check for parameter coupling
adb logcat -d | grep -E "(Visual.*Audio|Audio.*Visual|modulation)"

# 7. Check FPS
adb logcat -d | grep "FPS"

echo "=== Test Complete ==="
```

---

## 📊 EXPECTED VS ACTUAL STATE

| Component | Expected | Actual | Status |
|-----------|----------|--------|--------|
| VIB3+ Loading | All 4 engines | ✅ All 4 engines | ✅ PASS |
| ParameterBridge | Running 60 FPS | ✅ Running | ✅ PASS |
| Audio Init | PCM output ready | ✅ Ready | ✅ PASS |
| XY Pad Touch | Generates audio | ❓ Untested | ⏳ PENDING |
| Audio→Visual | FFT modulates visuals | ❓ Untested | ⏳ PENDING |
| Visual→Audio | Rotation affects synth | ❓ Untested | ⏳ PENDING |
| System Switching | 4 systems switchable | ❓ Untested | ⏳ PENDING |
| Geometry Switching | 24 geometries | ❓ Untested | ⏳ PENDING |
| Orb Controller | Pitch bend works | ❓ Untested | ⏳ PENDING |
| FPS Performance | 60 FPS sustained | ✅ 60 FPS idle | ⏸️ PARTIAL |

---

**A Paul Phillips Manifestation**
Paul@clearseassolutions.com
"The Revolution Will Not be in a Structured Format"
© 2025 Paul Phillips - Clear Seas Solutions LLC
