# Integration Usage Guide

## Quick Start - Using the Integrated Application

The fully integrated version of Synth-VIB3+ is available in `lib/ui/screens/integrated_main_screen.dart`.

### Option 1: Switch to Integrated Version (Recommended)

Edit `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'core/synth_app_initializer.dart';
import 'ui/screens/integrated_main_screen.dart';  // Changed from synth_main_screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final modules = await initializeSynthModules();
  runApp(IntegratedSynthApp(modules: modules));  // Changed from SynthVIB3App
}
```

### Option 2: Keep Both Versions

Add a constant at the top of `main.dart`:

```dart
const bool USE_INTEGRATED_VERSION = true;  // Toggle here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final modules = await initializeSynthModules();

  if (USE_INTEGRATED_VERSION) {
    runApp(IntegratedSynthApp(modules: modules));
  } else {
    runApp(SynthVIB3App(modules: modules));
  }
}
```

---

## Features Available in Integrated Version

### 🎹 **Multi-Touch Gestures**

The integrated version automatically recognizes advanced gestures system-wide:

| Gesture | Action |
|---------|--------|
| **3-Finger Swipe Left/Right** | Navigate between presets |
| **4-Finger Tap** | Toggle performance monitor |
| **Pinch** | Adjust UI scale |

These work anywhere on the screen, even while performing on the XY pad.

### 📊 **Performance Monitoring**

**Compact Overlay (Always Visible)**
- Top-right corner
- Shows FPS and latency
- Color-coded health indicator (green/yellow/red)
- Tap to open full monitor

**Full Performance Dashboard**
- Real-time graphs (FPS, latency, update rate)
- System health warnings
- Historical data (5 minutes)
- Toggle with 4-finger tap or Performance button

### 🎨 **Preset Browser**

**Access**: Tap the "Presets" button (bottom-left floating button)

**Features:**
- Search by name, tags, author, description
- Filter by category, visual system, synthesis type
- Sort by name, date, rating, recent usage
- Favorites system (tap star on preset cards)
- Visual preset cards with geometry preview
- Bulk operations (select multiple, export, delete)

**Usage:**
1. Tap "Presets" button
2. Search or filter to find presets
3. Tap any preset card to load it
4. Star to favorite
5. Long-press for multi-select
6. Tap X to close

### 🔗 **Modulation Matrix**

**Access**: Tap the "Matrix" button (bottom-left floating button)

**Features:**
- Drag sources (left) to targets (right) to create connections
- Adjust connection strength with bottom slider
- Toggle bipolar mode for ±modulation
- Animated flow visualization shows modulation in real-time
- Color-coded by source type

**Usage:**
1. Tap "Matrix" button
2. Drag from a source to a target
3. Click the connection line to select it
4. Adjust strength slider at bottom
5. Toggle bipolar if needed
6. Delete connection with delete button
7. Tap X to close

**Example Modulation Sources:**
- LFO 1-4
- ADSR Envelopes
- Audio RMS
- Gesture Input
- Sequencer Steps
- Randomizer

**Example Modulation Targets:**
- Filter Cutoff
- Oscillator Detune
- Reverb Mix
- Visual Rotation Speed
- Glow Intensity
- Geometry Morph

### ❓ **Context-Sensitive Help**

**Access**: Tap the "Help" button (bottom-left floating button)

**Features:**
- Context-aware help for current screen
- Search help topics
- Rich tooltips with icons
- Quick reference for gestures
- Video tutorial links (when available)

**Usage:**
1. Tap "Help" button
2. Search or browse topics
3. Click any topic to expand
4. Tap "Gestures" for gesture reference
5. Tap X to close

### 🎮 **Haptic Feedback**

Automatic tactile feedback for all interactions:

**Basic Feedback:**
- Button presses: Light haptic
- Preset loading: Pattern (medium → light)
- Parameter changes: Selection haptic
- Errors: Triple pulse pattern
- Success: Rising pattern

**Musical Feedback:**
- Note triggers: Pitch-scaled vibrations
- Higher frequency = lighter haptic
- Lower frequency = heavier haptic

**Configuration:**
All haptics can be enabled/disabled globally. See `HapticManager` documentation.

---

## Floating Action Buttons

Four buttons in bottom-left corner:

1. **Help** (🔵 Cyan)
   - Opens context-sensitive help
   - Light haptic on press

2. **Presets** (🟣 Purple)
   - Opens preset browser
   - Medium haptic on press
   - 3-finger swipe also navigates presets

3. **Matrix** (🟢 Holographic)
   - Opens modulation matrix
   - Medium haptic on press

4. **Perf** (🟡 Yellow)
   - Opens full performance monitor
   - Selection haptic on press
   - 4-finger tap also toggles

---

## Integration Manager Usage (Advanced)

The `ComponentIntegrationManager` is automatically created and available via Provider.

### Accessing the Integration Manager

```dart
final integrationManager = Provider.of<ComponentIntegrationManager>(context);
```

### Registering Your Own Components

If you create custom components, register them:

```dart
class MyCustomControl extends StatefulWidget {
  @override
  State<MyCustomControl> createState() => _MyCustomControlState();
}

class _MyCustomControlState extends State<MyCustomControl> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final integrationManager = context.read<ComponentIntegrationManager>();
      integrationManager.registerComponent(
        id: 'my_custom_control',
        type: ComponentType.slider,  // or appropriate type
        key: _key,
      );
    });
  }

  @override
  void dispose() {
    final integrationManager = context.read<ComponentIntegrationManager>();
    integrationManager.unregisterComponent('my_custom_control');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: _key, /* ... */);
  }
}
```

### Binding Parameters

```dart
// In initState or after registration
integrationManager.bindParameter(ParameterBinding(
  componentId: 'my_custom_control',
  parameterId: 'filter_cutoff',
  bidirectional: true,
  sensitivity: 1.0,
  transform: (value) => math.pow(value, 2.0),  // Exponential curve
));
```

### Triggering Haptic Feedback

```dart
// Basic haptic
integrationManager.triggerHaptic('my_component', HapticType.medium);

// Musical haptic
integrationManager.triggerMusicalHaptic('my_component', frequency: 440.0);
```

### Spawning Particles

```dart
integrationManager.spawnInteractionParticles(
  'my_component',
  Offset(100, 100),
  intensity: 0.8,
  color: DesignTokens.quantum,
);
```

### Adding Trails

```dart
integrationManager.addComponentTrail(
  'my_component',
  pointerId: event.pointer,
  position: event.localPosition,
  pressure: event.pressure,
);
```

---

## Gesture System Usage (Advanced)

### Custom Gesture Handlers

```dart
final gestureSystem = GestureRecognitionSystem();

// Two-finger rotate
gestureSystem.on(GestureType.twoFingerRotate, (gesture) {
  final angle = gesture.angle;
  visualProvider.adjustRotation(angle);
});

// Pinch
gestureSystem.on(GestureType.pinch, (gesture) {
  final scale = gesture.metadata['scale'] as double;
  layoutProvider.updateUIScale(scale);
});

// Three-finger swipe
gestureSystem.on(GestureType.threeFingerSwipe, (gesture) {
  if (gesture.direction == 'left') {
    presetManager.nextPreset();
  } else if (gesture.direction == 'right') {
    presetManager.previousPreset();
  }
});
```

### Wrapping with Listener

```dart
Listener(
  onPointerDown: gestureSystem.handlePointerDown,
  onPointerMove: gestureSystem.handlePointerMove,
  onPointerUp: gestureSystem.handlePointerUp,
  onPointerCancel: gestureSystem.handlePointerCancel,
  child: yourWidget,
)
```

---

## Performance Tracking (Advanced)

### Creating Tracker

```dart
final tracker = PerformanceTracker();
```

### Recording Metrics

```dart
// Record frames (usually in SchedulerBinding callback)
void _onFrame(Duration timestamp) {
  tracker.recordFrame();
  SchedulerBinding.instance.addPostFrameCallback(_onFrame);
}

// Record parameter updates
tracker.recordParameterUpdate();

// Record audio latency
tracker.recordAudioLatency(latencyMs);
```

### Getting Snapshots

```dart
final metrics = tracker.snapshot(
  memoryUsage: getCurrentMemoryMB(),
  cpuUsage: getCurrentCpuPercent(),
  activeVoices: audioProvider.voiceCount,
  particleCount: animationLayer.particleCount,
  webViewLatency: visualBridge.latencyMs,
);

// Check health
if (metrics.hasCriticalIssues) {
  print('Performance degraded!');
}
```

---

## Haptic Configuration

### Global Settings

```dart
// Enable/disable
HapticManager.instance.setEnabled(true);

// Intensity (0.1 - 2.0)
HapticManager.instance.setIntensity(1.5);
```

### Manual Triggering

```dart
// Basic
await HapticManager.light();
await HapticManager.medium();
await HapticManager.heavy();
await HapticManager.selection();

// Musical
await HapticManager.musicalNote(440.0);  // A4
await HapticManager.musicalChord([261.63, 329.63, 392.00]);  // C major

// Patterns
await HapticManager.playPattern(HapticPatterns.noteOn);
await HapticManager.playPattern(HapticPatterns.presetLoad);
await HapticManager.playPattern(HapticPatterns.ascendingScale);
```

---

## Keyboard Shortcuts (Future Enhancement)

The integrated version is ready for keyboard shortcuts. To add them, listen for key events and trigger actions:

```dart
KeyboardListener(
  focusNode: FocusNode(),
  onKeyEvent: (event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyP:
          // Toggle preset browser
          break;
        case LogicalKeyboardKey.keyM:
          // Toggle modulation matrix
          break;
        case LogicalKeyboardKey.keyH:
          // Toggle help
          break;
      }
    }
  },
  child: yourWidget,
)
```

---

## Performance Targets

The integration layer is designed to maintain these targets:

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| **FPS** | 60 | <55 | <30 |
| **Audio Latency** | <10ms | >15ms | >30ms |
| **Parameter Update Rate** | 60 Hz | <55 Hz | <30 Hz |

The performance monitor will show:
- **Green**: All metrics healthy
- **Yellow**: Performance warnings
- **Red**: Critical performance issues

---

## Troubleshooting

### Performance Issues

1. Check performance monitor for bottlenecks
2. Disable particles if FPS drops:
   ```dart
   integrationManager.enableParticles = false;
   ```
3. Reduce modulation connections
4. Lower audio buffer size (at cost of latency)

### Gestures Not Working

1. Ensure `Listener` is wrapping the gesture target
2. Check gesture thresholds aren't too high
3. Verify multi-touch is supported on device

### Haptics Not Working

1. Check device supports haptics
2. Ensure haptics are enabled:
   ```dart
   HapticManager.instance.setEnabled(true);
   ```
3. Try basic haptic first:
   ```dart
   await HapticManager.medium();
   ```

---

## Next Steps

1. **Explore Presets**: Open preset browser and try different sounds
2. **Create Modulations**: Open modulation matrix and route audio to filter
3. **Check Performance**: Monitor FPS and latency while playing
4. **Learn Gestures**: Use 3-finger swipe to navigate presets
5. **Read Help**: Tap help button for detailed component guides

---

## Complete Usage Example

Here's a complete workflow using all integrated features:

1. **Launch App**
   - Compact performance overlay shows in top-right
   - All systems ready

2. **Browse Presets**
   - Tap "Presets" button (bottom-left)
   - Search for "quantum"
   - Tap "Quantum Waves" preset
   - Preset loads with haptic feedback

3. **Add Modulation**
   - Tap "Matrix" button
   - Drag "Audio RMS" source to "Filter Cutoff" target
   - Adjust strength to 0.7
   - Filter now reacts to audio level

4. **Play Notes**
   - Touch XY pad anywhere
   - Hear sound + feel haptic feedback
   - See particles spawn at touch point
   - Watch trail follow your finger
   - Filter modulates with audio

5. **Check Performance**
   - Tap compact overlay (top-right)
   - See FPS graph, latency graph
   - Verify all metrics are green

6. **Navigate Presets**
   - While playing, swipe 3 fingers left
   - Next preset loads seamlessly
   - Haptic feedback confirms change

7. **Get Help**
   - Tap "Help" button
   - Search "XY Pad"
   - Read about multi-touch control
   - Try suggested gestures

---

**The integrated version provides "an extra dimension of ability" through seamless coordination of all systems.**

A Paul Phillips Manifestation
"The Revolution Will Not be in a Structured Format"
© 2025 Paul Phillips - Clear Seas Solutions LLC
