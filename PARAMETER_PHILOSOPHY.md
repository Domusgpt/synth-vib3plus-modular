# Parameter Control Philosophy: Audio-Reactive vs User-Controlled

## Core Principle: Hybrid Control System

**Every parameter has TWO components:**
1. **Base value** (User-controlled via UI)
2. **Audio modulation** (Reactive to sound, adds/subtracts from base)

```
Final Value = Base Value ± (Audio Modulation × Modulation Depth)
```

---

## THE 15+ VISUAL PARAMETERS

### Category 1: PURE AUDIO-REACTIVE (No User Control)
**User cannot set these - they are ONLY driven by audio**

#### 1. **Rotation Speed** (6D rotation rates)
- **Audio Driver**: Overall amplitude (RMS)
- **Mapping**: Louder sound → faster rotation
- **Range**: 0-360°/sec
- **Why**: Creates immediate visual feedback for dynamics
- **Visual Systems:**
  - Quantum: Precise, mathematical rotation speed
  - Faceted: Angular, stepped rotation speeds
  - Holographic: Smooth, flowing rotation speeds

#### 2. **Color/Hue**
- **Audio Driver**: Pitch (fundamental frequency)
- **Mapping**:
  - Low notes (C2-C4) → Red/Orange/Yellow (warm colors)
  - Mid notes (C4-C6) → Green/Cyan (neutral)
  - High notes (C6-C8) → Blue/Purple/Magenta (cool)
- **Range**: 0-360° hue wheel
- **Why**: Visual representation of pitch, like synesthesia
- **Note Mapping Example**:
  - C → Red (0°)
  - D → Orange (30°)
  - E → Yellow (60°)
  - F → Yellow-Green (90°)
  - G → Green (120°)
  - A → Cyan (180°)
  - B → Blue (240°)

#### 3. **Glow Intensity**
- **Audio Driver**: High-frequency content (spectral centroid)
- **Mapping**: Brighter timbre → more glow/bloom
- **Range**: 0.0-3.0
- **Why**: Visual indicator of harmonic richness

---

### Category 2: HYBRID (User Base + Audio Modulation)
**User sets base value, audio adds variation**

#### 4. **6D Rotations** (XY, XZ, YZ, XW, YW, ZW)
- **User Control**: Base rotation angles (0-360° each axis)
- **Audio Modulation**: ± rotation based on frequency bands
  - XY rotation: ± by bass content (20-200 Hz)
  - XZ rotation: ± by mid content (200-2kHz)
  - YZ rotation: ± by high content (2kHz-20kHz)
  - XW rotation: ± by attack transients
  - YW rotation: ± by amplitude envelope
  - ZW rotation: ± by overall RMS
- **Modulation Depth**: User-adjustable (0-100%)
- **Why**: User sets overall orientation, audio adds life

#### 5. **Morph Parameter**
- **User Control**: Base morph position (0.0-1.0)
- **Audio Modulation**: ± by spectral flux (rate of timbre change)
- **Modulation Depth**: 0-50% (half range max)
- **Effect**:
  - Visual: Interpolates between geometry variants
  - Sonic: Crossfades between waveforms
- **Why**: User sets base form, audio adds organic movement

#### 6. **Tessellation Density**
- **User Control**: Base density (1-10)
- **Audio Modulation**: ± by polyphony (number of active notes)
- **Effect**:
  - Visual: More/fewer subdivisions
  - Sonic: More/fewer voices
- **Why**: User sets complexity, audio reveals note count

#### 7. **Chaos Amount**
- **User Control**: Base chaos (0.0-1.0)
- **Audio Modulation**: + by noise content in audio signal
- **Effect**:
  - Visual: Randomizes vertex positions
  - Sonic: Adds noise injection + filter randomization
- **Why**: User sets base instability, audio increases with noisy signals

#### 8. **Layer Depth** (Z-axis layering)
- **User Control**: Base layer separation (0.0-1.0)
- **Audio Modulation**: ± by stereo width
- **Effect**:
  - Visual: Separates geometry layers
  - Sonic: Delay time (0-500ms)
- **Why**: User sets spatial depth, audio reflects stereo field

#### 9. **Projection Distance** (4D→3D projection)
- **User Control**: Base projection distance (1.0-5.0)
- **Audio Modulation**: ± by reverb amount in signal
- **Effect**:
  - Visual: How far 4D object is from 3D "camera"
  - Sonic: Reverb mix (0-100%)
- **Why**: User sets perspective, audio reflects ambience

#### 10. **Scale/Size**
- **User Control**: Base scale (0.5-2.0)
- **Audio Modulation**: ± by amplitude (RMS)
- **Effect**: Visual size pulses with volume
- **Why**: Creates breathing, living feeling

#### 11. **Vertex Brightness**
- **User Control**: Base brightness (0.0-1.0)
- **Audio Modulation**: + by high-frequency content
- **Effect**: Bright sounds → bright vertices
- **Why**: Visual feedback for timbre

#### 12. **Edge Thickness**
- **User Control**: Base thickness (0.1-1.0)
- **Audio Modulation**: + by mid-range content (500Hz-2kHz)
- **Effect**: Thicker edges for fuller sound
- **Why**: Visual representation of body/presence

#### 13. **Particle Density** (atmospheric effects)
- **User Control**: Base particle count (0-1000)
- **Audio Modulation**: + by transient density
- **Effect**: More particles during busy passages
- **Why**: Visual complexity matches sonic complexity

#### 14. **Warp Amount** (geometric distortion)
- **User Control**: Base warp (0.0-1.0)
- **Audio Modulation**: ± by filter resonance peaks
- **Effect**: Warps geometry when resonance is high
- **Why**: Visual representation of filter sweeps

#### 15. **Shimmer Speed** (vertex animation)
- **User Control**: Base shimmer rate (0-10 Hz)
- **Audio Modulation**: + by vibrato/tremolo depth
- **Effect**: Faster shimmer with modulation
- **Why**: Shows active modulation sources

---

### Category 3: PURE USER-CONTROLLED (No Audio Reactivity)
**User has complete control, audio doesn't affect these**

#### 16. **System Selection** (Quantum/Faceted/Holographic)
- **User Control**: Toggle between 3 systems
- **Audio Effect**: Changes sound family (pure/geometric/rich)
- **Why**: Deliberate artistic choice, not reactive

#### 17. **Geometry Selection** (0-23)
- **User Control**: Select specific polytope
- **Audio Effect**: Changes voice character + synthesis branch
- **Why**: Deliberate sound design choice

#### 18. **Camera Position** (orbit controls)
- **User Control**: XY position, zoom, tilt
- **Audio Effect**: None
- **Why**: View angle shouldn't affect sound

---

## MODULATION DEPTH CONTROLS

**For each Hybrid parameter, user can adjust modulation depth:**

```
Depth = 0%     → Audio has NO effect (pure user control)
Depth = 50%    → Audio modulates ±50% of range
Depth = 100%   → Audio can modulate full range
```

**UI Implementation:**
- Slider for base value
- Toggle + depth slider for audio modulation
- Visual indicator showing: `Base ← Current → Base + Mod`

---

## AUDIO ANALYSIS ENGINE

**Real-time audio feature extraction (60 FPS):**

1. **RMS Amplitude**: Overall loudness
2. **Spectral Centroid**: Brightness (center of spectral mass)
3. **Spectral Flux**: Rate of timbre change
4. **Fundamental Frequency**: Pitch (via FFT or autocorrelation)
5. **Frequency Bands**: Bass, mid, treble energy
6. **Transient Density**: Attack detection
7. **Stereo Width**: L-R correlation
8. **Envelope Follower**: Amplitude over time
9. **Polyphony**: Number of active notes
10. **Noise Content**: Harmonic-to-noise ratio

---

## SONIC → VISUAL EXAMPLES

### Example 1: Simple Bass Note
- **Pitch**: C2 (65 Hz) → **Color**: Deep red
- **Amplitude**: -12dB → **Rotation Speed**: Moderate
- **Timbre**: Dark (lowpass) → **Glow**: Minimal
- **Result**: Slow-rotating dark red form

### Example 2: Bright Chord
- **Pitch**: E5+G5+B5 → **Color**: Yellow-green average
- **Amplitude**: -6dB → **Rotation Speed**: Fast
- **Timbre**: Bright (highpass) → **Glow**: High
- **Polyphony**: 3 notes → **Tessellation**: 3 subdivisions
- **Result**: Fast-rotating glowing multi-layered form

### Example 3: Noisy Texture
- **Pitch**: No fundamental → **Color**: Neutral gray
- **Noise Content**: High → **Chaos**: Increased
- **Transients**: Many → **Particle Density**: High
- **Result**: Chaotic, particle-filled, unstable form

---

## IMPLEMENTATION PRIORITIES

### Phase 1: Audio Analysis (Week 1)
1. Implement AudioAnalyzer with 10 feature extractors
2. 60 FPS update loop
3. Smooth parameter interpolation

### Phase 2: Hybrid Parameters (Week 1-2)
1. Add base value sliders for all 15 parameters
2. Add modulation depth controls
3. Implement Audio → Visual mappings

### Phase 3: Visual Systems (Week 2)
1. Pass all 15 parameters to WebView
2. Update VIB3+ shaders to respond to parameters
3. Test all 72 combinations (3 systems × 24 geometries)

### Phase 4: Polish (Week 3)
1. Optimize performance (maintain 60 FPS)
2. Add preset system (save parameter sets)
3. Add modulation visualization (show audio driving visuals)

---

## UI MOCKUP: Parameter Panel

```
┌─────────────────────────────────────┐
│ MORPH PARAMETER                     │
│                                     │
│ Base:  [========•===] 0.65         │
│                                     │
│ Audio Mod: [ON]  Depth: [====•] 40%│
│ Driver: Spectral Flux               │
│                                     │
│ Current: 0.65 → 0.78 (live)        │
│          ▲base  ▲modulated         │
└─────────────────────────────────────┘
```

---

## THE VISION: TRUE SYNTH