# Audio-Visual Synergy & Pairing Plan
## Base + Modulation Architecture

**Created**: 2025-01-14
**Philosophy**: User control (sliders) sets BASE values. Audio reactivity applies ±MODULATION over the base.

---

## Executive Summary

After comprehensive analysis of the visualizer and audio systems, here's the critical insight:

**Current Implementation Problem**: Audio reactivity **replaces** user-set values directly.
**Desired Behavior**: Audio reactivity should **modulate** user-set base values.

```dart
// CURRENT (Wrong):
visualProvider.setRotationSpeed(audioReactiveValue);  // Replaces user's setting!

// DESIRED (Correct):
final userBase = userSliderValue;  // User's chosen base
final audioMod = audioReactiveModulation;  // ±modulation from audio
final finalValue = userBase + audioMod;  // Combine
visualProvider.setRotationSpeed(finalValue);
```

---

## System Architecture Analysis

### 1. Visualizer System (VIB3+)

**What It Is**: THREE.js WebGL 4D polytope renderer in Flutter WebView

**Parameters** (17 total):
| Parameter | Type | Range | User Control | Audio Reactive | Formula |
|-----------|------|-------|--------------|----------------|---------|
| **System** | Discrete | quantum/faceted/holographic | ✅ Button | ❌ N/A | Discrete choice |
| **Geometry** | Discrete | 0-7 (8 shapes) | ✅ Selector | ❌ N/A | Discrete choice |
| **Rotation Speed** | Continuous | 0.1-5.0x | ✅ Slider | ✅ Bass Energy | `base + (bassEnergy × ±1.5)` |
| **Tessellation** | Integer | 3-10 | ✅ Slider | ✅ Mid Energy | `base + round(midEnergy × ±3)` |
| **Brightness** | Continuous | 0.0-1.0 | ✅ Slider | ✅ High Energy | `base + (highEnergy × ±0.3)` |
| **Hue Shift** | Continuous | 0-360° | ✅ Slider | ✅ Spectral Centroid | `base + (centroid × ±90°)` |
| **Glow Intensity** | Continuous | 0.0-3.0 | ✅ Slider | ✅ RMS Amplitude | `base + (rms × ±1.5)` |
| **RGB Split** | Continuous | 0.0-10.0 | ✅ Slider | ✅ Stereo Width | `base + (stereoWidth × ±5)` |
| **Morph** | Continuous | 0.0-1.0 | ✅ Slider | ❌ Manual only | N/A |
| **Projection** | Continuous | 5.0-15.0 | ✅ Slider | ❌ Manual only | N/A |
| **Layer Depth** | Continuous | 0.0-5.0 | ✅ Slider | ❌ Manual only | N/A |
| **Rotation XW** | Continuous | 0-2π | ⚠️ Auto-animate | ✅ Audio modulates | `baseSpeed + audioMod` |
| **Rotation YW** | Continuous | 0-2π | ⚠️ Auto-animate | ✅ Audio modulates | `baseSpeed + audioMod` |
| **Rotation ZW** | Continuous | 0-2π | ⚠️ Auto-animate | ✅ Audio modulates | `baseSpeed + audioMod` |

**Problems Found**:
1. ❌ No timer loop calls `updateRotations()` - rotations are static
2. ❌ Audio reactivity REPLACES values instead of MODULATING them
3. ❌ No user base values stored separate from current values

---

### 2. Audio System (Synthesis)

**What It Is**: Dual-architecture synthesis engine
- **SynthesisBranchManager**: 72 combinations (3 systems × 3 cores × 8 geometries)
- **SynthesizerEngine**: Polyphony + effects chain

**Parameters** (12 controllable):
| Parameter | Type | Range | User Control | Visual Reactive | Formula |
|-----------|------|-------|--------------|-----------------|---------|
| **System** | Discrete | quantum/faceted/holographic | ✅ Button | ✅ Synced to visual | Direct sync |
| **Geometry** | Discrete | 0-23 (72 combos) | ✅ Selector | ✅ Synced to visual | Direct sync |
| **Osc 1 Frequency** | Continuous | ±2 semitones | ❌ Auto | ✅ Rotation XW | `base + sin(rotXW) × ±2st` |
| **Osc 2 Frequency** | Continuous | ±2 semitones | ❌ Auto | ✅ Rotation YW | `base + sin(rotYW) × ±2st` |
| **Filter Cutoff** | Continuous | ±40% | ✅ Slider | ✅ Rotation ZW | `base + sin(rotZW) × ±40%` |
| **Wavetable Pos** | Continuous | 0.0-1.0 | ✅ Slider | ✅ Morph param | Direct sync |
| **Reverb Mix** | Continuous | 0.0-1.0 | ✅ Slider | ✅ Projection | `base + (projDist × ±0.3)` |
| **Delay Time** | Continuous | 0-500ms | ✅ Slider | ✅ Layer depth | `base + (layerDepth × ±250ms)` |
| **Noise Amount** | Continuous | 0.0-1.0 | ✅ Slider | ⚠️ NOT CONNECTED | Should be chaos param |
| **Attack Time** | Continuous | 1-100ms | ✅ Slider | ⚠️ NOT CONNECTED | Should be glow intensity |
| **Resonance** | Continuous | 0.0-0.9 | ✅ Slider | ⚠️ NOT CONNECTED | Should be vertex count |
| **Voice Count** | Integer | 1-8 | ❌ Auto | ✅ Vertex count | Logarithmic map |

**Problems Found**:
1. ❌ Visual modulation REPLACES base frequency instead of modulating it
2. ❌ Chaos → Noise mapping not connected
3. ❌ Glow → Attack time mapping not connected
4. ❌ No user base values for filter, reverb, delay

---

### 3. Parameter Bridge (60 FPS Coupling)

**What It Is**: Timer loop that runs at 60 FPS, updates bidirectional mappings

**Current Flow**:
```dart
Timer.periodic(Duration(milliseconds: 16), (timer) {
  // Audio → Visual
  audioBuffer = audioProvider.getCurrentBuffer();
  features = analyzer.extractFeatures(audioBuffer);  // FFT

  // PROBLEM: Direct replacement
  visualProvider.setRotationSpeed(features.bassEnergy * 2.5);  // ❌ Overwrites user setting

  // Visual → Audio
  rotation = visualProvider.getRotationAngle('XW');

  // PROBLEM: Direct replacement
  audioProvider.modulateOscillator1Frequency(sin(rotation) * 2.0);  // ❌ Overwrites base freq
});
```

**Problems Found**:
1. ❌ No concept of "base value" vs "modulated value"
2. ❌ User slider changes get overwritten immediately
3. ❌ No UI feedback showing base vs modulation range

---

## The Solution: Base + Modulation Architecture

### Core Concept

Every parameter has THREE values:
1. **Base Value** - Set by user via sliders/controls
2. **Modulation Amount** - Calculated from audio/visual coupling
3. **Final Value** - `base + modulation` (sent to systems)

### Implementation Pattern

```dart
class ParameterState {
  // User-controlled base
  double baseValue;

  // Audio/visual modulation range
  double modulationDepth;  // 0-1, controls how much audio affects it

  // Current modulation amount
  double currentModulation;  // Calculated each frame

  // Final output
  double get finalValue => (baseValue + currentModulation).clamp(minValue, maxValue);
}
```

---

## Detailed Pairing Map

### Audio → Visual Mappings

#### 1. Bass Energy → Rotation Speed
**Base**: User slider sets rotation speed (0.1-5.0x)
**Modulation**: Bass energy adds ±1.5x modulation
```dart
// User sets base
double baseRotationSpeed = 2.0;  // From slider

// Audio provides modulation
double bassEnergy = features.bassEnergy;  // 0-1
double modulationAmount = (bassEnergy - 0.5) * 3.0;  // -1.5 to +1.5

// Combine
double finalSpeed = (baseRotationSpeed + modulationAmount).clamp(0.1, 5.0);
visualProvider.setRotationSpeed(finalSpeed);
```

**UI Visualization**:
- Slider knob shows base value (white)
- Left ghost (red) shows negative modulation limit
- Right ghost (green) shows positive modulation limit
- Current position animated between ghosts

#### 2. Mid Energy → Tessellation Density
**Base**: User slider sets tessellation (3-10)
**Modulation**: Mid energy adds ±3 levels
```dart
int baseTessellation = 5;  // From slider
double midEnergy = features.midEnergy;  // 0-1
int modulationAmount = ((midEnergy - 0.5) * 6.0).round();  // -3 to +3
int finalTess = (baseTessellation + modulationAmount).clamp(3, 10);
visualProvider.setTessellationDensity(finalTess);
```

#### 3. High Energy → Vertex Brightness
**Base**: User slider sets brightness (0.0-1.0)
**Modulation**: High energy adds ±0.3
```dart
double baseBrightness = 0.7;  // From slider
double highEnergy = features.highEnergy;  // 0-1
double modulationAmount = (highEnergy - 0.5) * 0.6;  // -0.3 to +0.3
double finalBrightness = (baseBrightness + modulationAmount).clamp(0.0, 1.0);
visualProvider.setVertexBrightness(finalBrightness);
```

#### 4. Spectral Centroid → Hue Shift
**Base**: User slider sets hue (0-360°)
**Modulation**: Spectral centroid adds ±90°
```dart
double baseHue = 180.0;  // From slider
double centroid = features.spectralCentroid;  // 0-8000 Hz
double normalizedCentroid = (centroid / 4000.0 - 1.0);  // -1 to +1
double modulationAmount = normalizedCentroid * 90.0;  // -90° to +90°
double finalHue = (baseHue + modulationAmount) % 360.0;
visualProvider.setHueShift(finalHue);
```

#### 5. RMS Amplitude → Glow Intensity
**Base**: User slider sets glow (0.0-3.0)
**Modulation**: RMS adds ±1.5
```dart
double baseGlow = 1.0;  // From slider
double rms = features.rms;  // 0-1
double modulationAmount = (rms - 0.5) * 3.0;  // -1.5 to +1.5
double finalGlow = (baseGlow + modulationAmount).clamp(0.0, 3.0);
visualProvider.setGlowIntensity(finalGlow);
```

#### 6. Stereo Width → RGB Split
**Base**: User slider sets RGB split (0.0-10.0)
**Modulation**: Stereo width adds ±5.0
```dart
double baseRGBSplit = 2.0;  // From slider
double stereoWidth = features.stereoWidth;  // 0-1
double modulationAmount = (stereoWidth - 0.5) * 10.0;  // -5.0 to +5.0
double finalRGBSplit = (baseRGBSplit + modulationAmount).clamp(0.0, 10.0);
visualProvider.setRGBSplitAmount(finalRGBSplit);
```

---

### Visual → Audio Mappings

#### 1. Rotation XW → Oscillator 1 Frequency
**Base**: MIDI note number sets base frequency
**Modulation**: Rotation XW adds ±2 semitones
```dart
int baseMIDINote = 60;  // Middle C
double baseFreq = midiToFrequency(baseMIDINote);

double rotationXW = visualProvider.getRotationAngle('XW');  // 0-2π
double modulationSemitones = sin(rotationXW) * 2.0;  // -2 to +2 semitones
double modulationRatio = pow(2.0, modulationSemitones / 12.0);
double finalFreq = baseFreq * modulationRatio;

synthesizerEngine.oscillator1.baseFrequency = finalFreq;
```

#### 2. Rotation YW → Oscillator 2 Frequency
**Base**: MIDI note + detune offset
**Modulation**: Rotation YW adds ±2 semitones
```dart
double baseFreq = midiToFrequency(baseMIDINote) * 1.005;  // Slight detune

double rotationYW = visualProvider.getRotationAngle('YW');
double modulationSemitones = sin(rotationYW) * 2.0;
double modulationRatio = pow(2.0, modulationSemitones / 12.0);
double finalFreq = baseFreq * modulationRatio;

synthesizerEngine.oscillator2.baseFrequency = finalFreq;
```

#### 3. Rotation ZW → Filter Cutoff
**Base**: User slider sets cutoff (200-8000 Hz)
**Modulation**: Rotation ZW adds ±40%
```dart
double baseCutoff = 1000.0;  // From slider

double rotationZW = visualProvider.getRotationAngle('ZW');
double modulationPercent = sin(rotationZW) * 0.4;  // -0.4 to +0.4
double finalCutoff = baseCutoff * (1.0 + modulationPercent);

synthesizerEngine.filter.baseCutoff = finalCutoff;
```

#### 4. Morph Parameter → Wavetable Position
**Direct Sync** (no modulation needed)
```dart
double morph = visualProvider.getMorphParameter();  // 0-1
synthesizerEngine.setWavetablePosition(morph);
```

#### 5. Projection Distance → Reverb Mix
**Base**: User slider sets reverb mix (0.0-1.0)
**Modulation**: Projection distance adds ±0.3
```dart
double baseReverbMix = 0.3;  // From slider

double projDistance = visualProvider.getProjectionDistance();  // 5-15
double normalized = (projDistance - 10.0) / 5.0;  // -1 to +1
double modulationAmount = normalized * 0.3;  // -0.3 to +0.3
double finalMix = (baseReverbMix + modulationAmount).clamp(0.0, 1.0);

synthesizerEngine.setReverbMix(finalMix);
```

#### 6. Layer Depth → Delay Time
**Base**: User slider sets delay time (0-500ms)
**Modulation**: Layer depth adds ±250ms
```dart
double baseDelayTime = 250.0;  // From slider

double layerDepth = visualProvider.getLayerSeparation();  // 0-5
double normalized = (layerDepth - 2.5) / 2.5;  // -1 to +1
double modulationAmount = normalized * 250.0;  // -250 to +250ms
double finalTime = (baseDelayTime + modulationAmount).clamp(0.0, 500.0);

synthesizerEngine.setDelayTime(finalTime);
```

---

### Missing Connections (To Implement)

#### 7. Chaos Amount → Noise Injection
**Base**: User slider sets base noise (0.0-1.0)
**Modulation**: Visual chaos parameter (if added) modulates ±0.3
```dart
double baseNoise = 0.1;  // From slider

// TODO: Add chaos parameter to VisualProvider
double chaosAmount = visualProvider.getChaosAmount();  // 0-1
double modulationAmount = (chaosAmount - 0.5) * 0.6;  // -0.3 to +0.3
double finalNoise = (baseNoise + modulationAmount).clamp(0.0, 1.0);

synthesizerEngine.setNoiseAmount(finalNoise);
```

#### 8. Glow Intensity → Attack Time
**Base**: Geometry sets base attack time
**Modulation**: Glow intensity scales attack ±50%
```dart
double baseAttack = 0.02;  // 20ms from geometry

double glow = visualProvider.glowIntensity;  // 0-3
double normalized = (glow - 1.5) / 1.5;  // -1 to +1
double modulationRatio = 1.0 + (normalized * 0.5);  // 0.5x to 1.5x
double finalAttack = baseAttack * modulationRatio;

synthesizerEngine.setEnvelopeAttack(finalAttack);
```

#### 9. Tessellation Density → Polyphony
**Direct Mapping** (tessellation affects voice count)
```dart
int tessellation = visualProvider.tessellationDensity;  // 3-10
int voiceCount = ((tessellation - 3) / 7.0 * 7.0 + 1.0).round();  // 1-8 voices

synthesizerEngine.setVoiceCount(voiceCount);
```

---

## UI Visualization System

### RGB Ghosting Design

For each slider with audio reactivity:

```
┌────────────────────────────────────┐
│    [R]  ●--------[G]               │  ← Slider track
│         ↑        ↑                 │
│         │        │                 │
│    Negative  Current  Positive     │
│     Limit   Value     Limit        │
└────────────────────────────────────┘

Legend:
● = User's base setting (white/cyan)
[R] = Red ghost (max negative modulation)
[G] = Green ghost (max positive modulation)
Current position animates based on audio
```

### Implementation Example

```dart
class AudioReactiveSlider extends StatelessWidget {
  final double baseValue;        // User's setting
  final double modulationRange;  // ±modulation amount
  final double currentModulation;  // Real-time from audio

  @override
  Widget build(BuildContext context) {
    final minGhost = baseValue - modulationRange;
    final maxGhost = baseValue + modulationRange;
    final currentValue = baseValue + currentModulation;

    return Stack(
      children: [
        // Track with gradient showing modulation range
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: [
                (minGhost / maxSliderValue),
                (baseValue / maxSliderValue),
                (maxGhost / maxSliderValue),
              ],
              colors: [
                Colors.red.withOpacity(0.3),    // Negative modulation
                Colors.white,                    // Base value
                Colors.green.withOpacity(0.3),   // Positive modulation
              ],
            ),
          ),
        ),

        // Red ghost marker (negative limit)
        Positioned(
          left: (minGhost / maxSliderValue) * sliderWidth,
          child: Container(
            width: 2,
            height: 20,
            color: Colors.red.withOpacity(0.5),
          ),
        ),

        // Green ghost marker (positive limit)
        Positioned(
          left: (maxGhost / maxSliderValue) * sliderWidth,
          child: Container(
            width: 2,
            height: 20,
            color: Colors.green.withOpacity(0.5),
          ),
        ),

        // White base marker (user's setting)
        Positioned(
          left: (baseValue / maxSliderValue) * sliderWidth,
          child: Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.cyan, width: 2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Animated current value indicator
        AnimatedPositioned(
          duration: Duration(milliseconds: 16),  // 60 FPS
          left: (currentValue / maxSliderValue) * sliderWidth,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.cyan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.8),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## Implementation Checklist

### Phase 1: Core Architecture (8-12 hours)

- [ ] **Create ParameterState class** (2h)
  - Stores base, modulation range, current modulation
  - Computes final value
  - Emits updates for UI

- [ ] **Refactor AudioToVisualModulator** (3h)
  - Change from direct setting to base + modulation
  - Store user base values separately
  - Apply modulation over base

- [ ] **Refactor VisualToAudioModulator** (3h)
  - Change from direct frequency modulation to base + modulation
  - Preserve MIDI note as base frequency
  - Apply rotation modulation over base

- [ ] **Update ParameterBridge** (2h)
  - Pass base values to modulators
  - Compute final values before setting
  - Track base vs modulated values for UI

### Phase 2: Missing Connections (4-6 hours)

- [ ] **Connect chaos → noise** (1h)
  - Add chaos parameter getter to VisualProvider (if missing)
  - Map chaos to noise amount in VisualToAudioModulator

- [ ] **Connect glow → attack time** (1h)
  - Map glow intensity to envelope attack scaling

- [ ] **Connect tessellation → polyphony** (1h)
  - Already partially implemented, verify correctness

- [ ] **Add RGB split modulation** (1h)
  - Connect stereo width to RGB split in AudioToVisualModulator

- [ ] **Fix rotation animation timer** (2h)
  - Add timer loop to VisualProvider.startAnimation()
  - Call updateRotations() at 60 FPS
  - Fix velocity calculation bug (lines 209-211)

### Phase 3: UI Visualization (8-10 hours)

- [ ] **Create AudioReactiveSlider widget** (4h)
  - RGB ghosting visualization
  - Base value marker (white)
  - Negative limit ghost (red)
  - Positive limit ghost (green)
  - Animated current value indicator

- [ ] **Update all parameter controls** (4h)
  - Replace standard sliders with AudioReactiveSlider
  - Wire up base value, modulation range, current value
  - Add modulation depth control (per parameter)

- [ ] **Add modulation depth controls** (2h)
  - Global modulation depth slider
  - Per-parameter modulation enable/disable
  - Modulation range adjustment

### Phase 4: Testing & Polish (6-8 hours)

- [ ] **Test all 6 audio→visual mappings** (2h)
  - Verify base + modulation works
  - Check clamping to valid ranges
  - Confirm UI shows correct values

- [ ] **Test all 6 visual→audio mappings** (2h)
  - Verify oscillator modulation preserves base frequency
  - Check filter modulation over base cutoff
  - Confirm MIDI note base is preserved

- [ ] **Test missing connections** (2h)
  - Verify chaos → noise
  - Verify glow → attack
  - Verify tessellation → polyphony

- [ ] **UI polish** (2h)
  - Smooth animations (60 FPS)
  - Clear visual feedback
  - Responsive touch targets

---

## Success Criteria

### Functional Requirements

✅ **Base Value Persistence**
- User slider changes persist even when audio reactivity is active
- Disabling audio reactivity returns to user's base values
- Base values saved/loaded with presets

✅ **Modulation Clarity**
- UI clearly shows: base, current, and modulation range
- RGB ghosts visualize modulation limits
- Animated indicator shows real-time modulated value

✅ **Non-Interference**
- Audio reactivity doesn't "fight" user input
- Slider adjustments update base, modulation continues over new base
- No jarring jumps when enabling/disabling reactivity

✅ **All Mappings Connected**
- 6 audio→visual mappings working (bass, mid, high, centroid, RMS, stereo width)
- 6 visual→audio mappings working (rot XW/YW/ZW, morph, projection, layer depth)
- 3 missing connections implemented (chaos→noise, glow→attack, tess→poly)

### Performance Requirements

✅ **60 FPS maintained**
- Parameter bridge runs at stable 60 Hz
- UI animations smooth at 60 FPS
- No dropped frames during modulation

✅ **Low Latency**
- Audio analysis to visual update: <16ms
- Visual state to audio modulation: <16ms
- User slider to base value update: <5ms

---

## Estimated Timeline

| Phase | Tasks | Hours | Priority |
|-------|-------|-------|----------|
| **Phase 1** | Core architecture refactor | 8-12h | CRITICAL |
| **Phase 2** | Missing connections | 4-6h | HIGH |
| **Phase 3** | UI visualization | 8-10h | HIGH |
| **Phase 4** | Testing & polish | 6-8h | MEDIUM |
| **Total** | Complete implementation | **26-36h** | 1-2 weeks |

---

## Conclusion

The Synth-VIB3+ audio-visual coupling has a **solid foundation** but needs the **base + modulation architecture** to work correctly. This plan provides:

1. **Clear separation** between user control and audio reactivity
2. **Visual feedback** showing base vs modulated values
3. **Complete mappings** for all parameters
4. **Professional UI** with RGB ghosting

**Immediate next steps**:
1. Implement ParameterState class
2. Refactor modulators to use base + modulation
3. Create AudioReactiveSlider widget
4. Connect missing parameters

With this architecture, users will have **full control** while audio reactivity adds **dynamic expression** without interference.

---

**A Paul Phillips Manifestation**
Paul@clearseassolutions.com
"The Revolution Will Not be in a Structured Format"
© 2025 Paul Phillips - Clear Seas Solutions LLC
