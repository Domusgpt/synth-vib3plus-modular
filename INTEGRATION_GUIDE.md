// Component Integration Manager usage example
final integrationManager = ComponentIntegrationManager(
  audioProvider: audioProvider,
  visualProvider: visualProvider,
  layoutProvider: layoutProvider,
  parameterBridge: parameterBridge,
  enableHaptics: true,
  enableParticles: true,
);

// Register components
integrationManager.registerComponent(
  id: 'main_xy_pad',
  type: ComponentType.xyPad,
  key: GlobalKey(),
);

// Bind to parameters
integrationManager.bindParameter(ParameterBinding(
  componentId: 'main_xy_pad',
  parameterId: 'filter_cutoff',
  bidirectional: true,
  sensitivity: 1.0,
));

// Update from component
integrationManager.updateParameterFromComponent('main_xy_pad', 0.75);

// Spawn particles on interaction
integrationManager.spawnInteractionParticles(
  'main_xy_pad',
  Offset(100, 100),
  intensity: 0.8,
);

// Trigger haptic feedback
integrationManager.triggerHaptic('main_xy_pad', HapticType.medium);
```

## 2. Gesture Recognition System

```dart
final gestureSystem = GestureRecognitionSystem();

// Register gesture handlers
gestureSystem.on(GestureType.pinch, (gesture) {
  // Handle pinch-to-zoom
  final scale = gesture.metadata['scale'] as double;
  layoutProvider.updateUIScale(scale);
});

gestureSystem.on(GestureType.twoFingerRotate, (gesture) {
  // Handle rotation
  visualProvider.rotateView(gesture.angle);
});

gestureSystem.on(GestureType.threeFingerSwipe, (gesture) {
  // Navigate presets
  if (gesture.velocity.dx > 0) {
    presetManager.nextPreset();
  } else {
    presetManager.previousPreset();
  }
});

// In your widget
@override
Widget build(BuildContext context) {
  return Listener(
    onPointerDown: gestureSystem.handlePointerDown,
    onPointerMove: gestureSystem.handlePointerMove,
    onPointerUp: gestureSystem.handlePointerUp,
    child: yourChild,
  );
}
```

## 3. Component Usage Examples

### XY Performance Pad

```dart
XYPerformancePad(
  config: XYPadConfig.production,  // Grid + trails
  xParameter: XYParameter.frequency,
  yParameter: XYParameter.filterCutoff,
  onTouchUpdate: (touches) {
    for (final touch in touches) {
      final normalized = touch.normalized(size);
      // Send to audio engine
      audioProvider.setFrequency(normalized.dx);
      audioProvider.setFilterCutoff(normalized.dy);

      // Add trail
      integrationManager.addComponentTrail(
        'xy_pad',
        touch.pointerId,
        touch.position,
        pressure: touch.pressure,
      );
    }
  },
  onTouchStart: () {
    integrationManager.triggerHaptic('xy_pad', HapticType.light);
  },
  audioFeatures: audioProvider.currentAudioFeatures,
  color: DesignTokens.quantum,
  label: 'Performance Pad',
)
```

### Orb Controller

```dart
OrbController(
  config: OrbConfig.performance,
  onPitchBendChange: (value) {
    audioProvider.setPitchBend(value);
    integrationManager.updateParameterFromComponent('orb', value);
  },
  onVibratoChange: (value) {
    audioProvider.setVibratoDepth(value);
  },
  onTouchStart: () {
    integrationManager.spawnInteractionParticles(
      'orb',
      orbPosition,
      color: DesignTokens.holographic,
    );
  },
  audioFeatures: audioProvider.currentAudioFeatures,
)
```

### Enhanced Slider

```dart
EnhancedSlider(
  config: SliderConfig.standard,
  label: 'Filter Cutoff',
  value: filterCutoff,
  parameterType: ParameterType.filter,
  onChanged: (value) {
    audioProvider.setFilterCutoff(value);
    integrationManager.updateParameterFromComponent('filter_slider', value);
  },
  onChangeStart: () {
    integrationManager.triggerHaptic('filter_slider', HapticType.selection);
  },
  modulationAmount: modulationMatrix.getModulationAmount('lfo1', 'filter'),
  audioFeatures: audioProvider.currentAudioFeatures,
  valueFormatter: (value) => '${(value * 20000).toInt()} Hz',
)
```

### Radial Knob

```dart
RadialKnob(
  config: KnobConfig.large,
  label: 'Resonance',
  value: resonance,
  parameterType: ParameterType.filter,
  onChanged: (value) {
    audioProvider.setResonance(value);
  },
  modulationAmount: modulationMatrix.getModulationAmount('envelope', 'resonance'),
  audioFeatures: audioProvider.currentAudioFeatures,
)
```

### LED Ladder

```dart
LEDLadder(
  config: LEDLadderConfig.standard,
  label: 'Waveform',
  value: waveformIndex,
  onChanged: (index) {
    audioProvider.setWaveform(index);
    integrationManager.triggerMusicalHaptic('waveform_ladder', 440.0 * (index + 1));
  },
  parameterType: ParameterType.modulation,
  audioFeatures: audioProvider.currentAudioFeatures,
)
```

## 4. Layout Integration

### Resizable Panel with Components

```dart
ResizablePanel(
  config: PanelConfig.customizable,
  initialPosition: GridPosition(2, 1),
  initialSize: GridUnits.unit3x3,
  title: 'Filter Controls',
  audioFeatures: audioProvider.currentAudioFeatures,
  enableAudioReactivity: true,
  child: Column(
    children: [
      EnhancedSlider(
        label: 'Cutoff',
        value: cutoff,
        onChanged: (v) => audioProvider.setFilterCutoff(v),
      ),
      RadialKnob(
        label: 'Resonance',
        value: resonance,
        onChanged: (v) => audioProvider.setResonance(v),
      ),
      LEDLadder(
        label: 'Type',
        value: filterType,
        onChanged: (v) => audioProvider.setFilterType(v),
      ),
    ],
  ),
)
```

### Layout Provider Integration

```dart
// Load preset
layoutProvider.loadPresetById('factory_production');

// Get all panels
final panels = layoutProvider.panels;

// Update panel position
layoutProvider.updatePanelPosition('xy_pad', GridPosition(5, 5));

// Save custom layout
layoutProvider.saveAsUserPreset(
  'My Custom Layout',
  'Perfect for live performance',
);

// Export/import
final jsonString = layoutProvider.exportLayout();
layoutProvider.importLayout(jsonString);
```

## 5. Animation Layer Integration

### Setting Up Animation Layer

```dart
AnimationLayer(
  config: AnimationLayerConfig.full,
  audioStream: audioProvider.audioFeaturesStream,
  child: Stack(
    children: [
      // VIB3+ visualization
      VIB34DWidget(),

      // UI components overlay
      yourUIComponents,
    ],
  ),
)
```

### Accessing Animation Layer

```dart
// Get reference in build context
final animationLayer = context.animationLayer;

// Spawn effects
animationLayer?.spawnNoteParticle(
  position: Offset(100, 100),
  frequency: 440.0,
  velocity: 0.8,
);

animationLayer?.spawnBurst(
  position: tapPosition,
  color: Colors.cyan,
  intensity: 1.0,
  count: 10,
);

// Add modulation visualization
animationLayer?.addModulation(
  source: ModulationSource(
    id: 'lfo1',
    label: 'LFO 1',
    type: ModulationSourceType.lfo,
    position: lfoPosition,
  ),
  target: ModulationTarget(
    id: 'filter_cutoff',
    label: 'Filter Cutoff',
    position: filterPosition,
  ),
  strength: 0.75,
);
```

## 6. Haptic Feedback Integration

### Using Haptic Manager

```dart
// Simple haptics
HapticManager.light();      // Light tap
HapticManager.medium();     // Medium impact
HapticManager.heavy();      // Heavy impact
HapticManager.selection();  // Selection change

// Pattern-based
await HapticPatterns.noteOn();
await HapticPatterns.presetLoad();
await HapticPatterns.systemSwitch();

// Musical (pitch-scaled)
HapticManager.musicalNote(440.0);  // A4
HapticManager.musicalNote(880.0);  // A5

// Configure intensity
HapticManager.setIntensity(1.5);  // 150% intensity
HapticManager.setEnabled(true);
```

## 7. Complete Widget Tree Example

```dart
class SynthVib3PlusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => VisualProvider()),
        ChangeNotifierProvider(create: (_) => LayoutProvider()),
        ChangeNotifierProvider(create: (_) => ComponentIntegrationManager(
          audioProvider: context.read<AudioProvider>(),
          visualProvider: context.read<VisualProvider>(),
          layoutProvider: context.read<LayoutProvider>(),
        )),
      ],
      child: Consumer<LayoutProvider>(
        builder: (context, layoutProvider, _) {
          return AnimationLayer(
            config: AnimationLayerConfig.full,
            audioStream: context.read<AudioProvider>().audioFeaturesStream,
            child: GridContainer(
              config: GridConfig.standard,
              showGrid: false,
              children: [
                // XY Pad
                ResizablePanel(
                  config: PanelConfig.customizable,
                  initialPosition: GridPosition(4, 5),
                  initialSize: GridUnits.unit3x3,
                  child: XYPerformancePad(
                    config: XYPadConfig.performance,
                    // ... configuration
                  ),
                ),

                // Orb Controller
                ResizablePanel(
                  config: PanelConfig.customizable,
                  initialPosition: GridPosition(1, 1),
                  initialSize: GridUnits.unit2x2,
                  child: OrbController(
                    config: OrbConfig.performance,
                    // ... configuration
                  ),
                ),

                // Parameter Controls Panel
                ResizablePanel(
                  config: PanelConfig.customizable,
                  initialPosition: GridPosition(0, 10),
                  initialSize: GridUnits(12, 2),
                  title: 'Parameters',
                  child: Row(
                    children: [
                      EnhancedSlider(/* ... */),
                      RadialKnob(/* ... */),
                      LEDLadder(/* ... */),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## 8. Performance Optimization Tips

### Efficient Component Registration

```dart
// Register components in initState
@override
void initState() {
  super.initState();

  final integration = context.read<ComponentIntegrationManager>();
  integration.registerComponent(
    id: widget.id,
    type: ComponentType.xyPad,
    key: _key,
  );
}

// Unregister in dispose
@override
void dispose() {
  context.read<ComponentIntegrationManager>().unregisterComponent(widget.id);
  super.dispose();
}
```

### Throttling Updates

```dart
// Use timer to throttle parameter updates
Timer? _updateTimer;

void _throttledUpdate(double value) {
  _updateTimer?.cancel();
  _updateTimer = Timer(const Duration(milliseconds: 16), () {
    integrationManager.updateParameterFromComponent(id, value);
  });
}
```

### Conditional Particle Spawning

```dart
// Only spawn particles when visible and enabled
if (mounted && widget.enableParticles && _isVisible) {
  integrationManager.spawnInteractionParticles(id, position);
}
```

## 9. State Persistence

### Saving/Loading Complete State

```dart
// Save entire app state
final appState = {
  'layout': layoutProvider.toJson(),
  'audio': audioProvider.toJson(),
  'visual': visualProvider.toJson(),
  'presets': presetManager.exportAll(),
};

await SharedPreferences.getInstance()
  .then((prefs) => prefs.setString('app_state', jsonEncode(appState)));

// Load state
final prefs = await SharedPreferences.getInstance();
final stateJson = prefs.getString('app_state');
if (stateJson != null) {
  final state = jsonDecode(stateJson);
  layoutProvider.fromJson(state['layout']);
  audioProvider.fromJson(state['audio']);
  visualProvider.fromJson(state['visual']);
}
```

## 10. Advanced Features

### Macro Controls

```dart
// Create macro that controls multiple parameters
final macro = MacroControl(
  name: 'Brightness',
  targets: [
    MacroTarget('filter_cutoff', 0.0, 1.0),
    MacroTarget('resonance', 0.2, 0.8),
    MacroTarget('glow_intensity', 0.5, 1.0),
  ],
);

// Control macro
macro.setValue(0.75);  // Sets all targets proportionally
```

### MIDI Learn

```dart
// Enable MIDI learn for parameter
integrationManager.enableMIDILearn('filter_cutoff', (midiCC) {
  // Bind MIDI CC to parameter
  midiManager.bind(midiCC, 'filter_cutoff');
});
```

### Automation Recording

```dart
// Start recording automation
automationRecorder.startRecording('filter_cutoff');

// Parameter changes are recorded
audioProvider.setFilterCutoff(0.75);

// Stop and save
final automation = automationRecorder.stopRecording();
automationManager.save('filter_sweep', automation);

// Playback
automationManager.play('filter_sweep');
```

---

## Summary

This integration guide demonstrates how all components work together:

1. **Component Integration Manager**: Central hub coordinating everything
2. **Gesture System**: Advanced multi-touch gesture recognition
3. **UI Components**: XY Pad, Orb, Sliders, Knobs, Ladders
4. **Layout System**: Resizable panels, grid layout, docking
5. **Animation Layer**: Particles, trails, modulation visualization
6. **Haptic Feedback**: Touch response throughout
7. **State Management**: Providers coordinating audio/visual/layout
8. **Persistence**: Save/load complete application state

Everything is designed to work together seamlessly, creating a unified, professional, audio-reactive synthesizer interface.

A Paul Phillips Manifestation
"The Revolution Will Not be in a Structured Format"
© 2025 Paul Phillips - Clear Seas Solutions LLC
