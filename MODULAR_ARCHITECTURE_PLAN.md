# Synth-VIB3+ Modular Architecture Plan
**Goal:** Match VIB3+ JavaScript's clean modular architecture in Flutter/Dart

---

## 🎯 Current State vs Target State

### Current (Basic)
```
main.dart
├── Providers (audio, visual, ui_state, tilt, parameter_bridge)
├── UI Widgets (screens, components, panels)
└── Audio/Visual implementations
```

**Problems:**
- Monolithic provider initialization
- No module lifecycle management
- Limited diagnostics
- No state history/undo
- Basic logging
- Hard to test in isolation

### Target (Modular - Like VIB3+)
```
main.dart
└── ModuleManager
    ├── AudioEngineModule ✅ Synthesis lifecycle
    ├── VisualBridgeModule ✅ WebView communication
    ├── ParameterCouplingModule ✅ Bidirectional modulation
    ├── StateManagerModule ✅ Undo/redo/presets
    ├── DiagnosticsModule ✅ System health
    ├── PerformanceModule ✅ FPS/latency tracking
    ├── PresetManagerModule ✅ Save/load/share
    ├── TiltSensorModule ✅ Device orientation
    └── TestSuiteModule ✅ Integration tests
```

**Benefits:**
- Clean initialization sequence
- Independent module testing
- Comprehensive diagnostics
- State management built-in
- Professional logging
- Easy to extend

---

## 📦 Module Specifications

### Core Module Interface

```dart
abstract class SynthModule {
  /// Module name for logging
  String get name;

  /// Initialize module (async)
  Future<void> initialize();

  /// Clean shutdown
  Future<void> dispose();

  /// Health check
  bool get isHealthy;

  /// Get diagnostic info
  Map<String, dynamic> getDiagnostics();

  /// Module dependencies (load order)
  List<Type> get dependencies => [];
}
```

---

### 1. AudioEngineModule

**Responsibilities:**
- Initialize PCM audio output
- Manage synthesis engine lifecycle
- Handle note on/off
- Track active voices
- Monitor audio latency

**Diagnostics:**
```json
{
  "sampleRate": 44100,
  "bufferSize": 512,
  "activeVoices": 4,
  "latency": "8.5ms",
  "isPlaying": true,
  "totalSamplesGenerated": 2048576
}
```

**Initialization Sequence:**
```
🔧 Loading Audio Engine Module...
📊 PCM setup: 44100 Hz, 512 samples, mono
✅ Audio Engine Module: Loaded
🎵 Ready for synthesis
```

---

### 2. VisualBridgeModule

**Responsibilities:**
- Initialize WebView controller
- Load VIB3+ inlined HTML
- Manage JavaScript bridge
- Handle parameter updates to VIB3+
- Monitor WebView health

**Diagnostics:**
```json
{
  "webViewReady": true,
  "vib3Loaded": true,
  "enginesAvailable": ["VIB34DIntegratedEngine", "QuantumEngine", "RealHolographicSystem", "NewPolychoraEngine"],
  "currentSystem": "faceted",
  "jsExecutionTime": "2.3ms avg"
}
```

**Initialization Sequence:**
```
🔧 Loading Visual Bridge Module...
📂 Loading VIB3+ from assets/vib3_dist/index.html
⏳ Waiting for VIB3+ initialization...
✅ VIB3+ engines loaded: 4/4
✅ Visual Bridge Module: Loaded
```

---

### 3. ParameterCouplingModule

**Responsibilities:**
- Start 60 FPS update loop
- Audio→Visual FFT modulation
- Visual→Audio geometry modulation
- Enable/disable coupling modes
- Track modulation metrics

**Diagnostics:**
```json
{
  "updateRate": "60 FPS",
  "audioToVisual": {
    "enabled": true,
    "lastUpdate": "2ms ago",
    "modulationsPerSecond": 60
  },
  "visualToAudio": {
    "enabled": true,
    "lastUpdate": "1ms ago",
    "modulationsPerSecond": 60
  }
}
```

**Initialization Sequence:**
```
🔧 Loading Parameter Coupling Module...
🌉 Starting 60 FPS update loop
✅ Audio→Visual modulation: ENABLED
✅ Visual→Audio modulation: ENABLED
✅ Parameter Coupling Module: Loaded
```

---

### 4. StateManagerModule

**Responsibilities:**
- Save/restore full synth state
- Undo/redo history (Ctrl+Z/Y)
- Preset management
- Share link generation
- Auto-save

**Diagnostics:**
```json
{
  "historySize": 15,
  "currentIndex": 8,
  "canUndo": true,
  "canRedo": true,
  "savedPresets": 12,
  "autoSaveEnabled": true,
  "lastSave": "5s ago"
}
```

**Initialization Sequence:**
```
🔧 Loading State Manager Module...
💾 Initializing state history (max 50 states)
⌨️ Shortcuts enabled: Ctrl+Z (undo), Ctrl+Y (redo)
✅ Auto-save enabled (5s delay)
✅ State Manager Module: Loaded
```

---

### 5. DiagnosticsModule

**Responsibilities:**
- System health monitoring
- Performance metrics collection
- Error tracking
- Debug overlay UI
- Export diagnostic report

**Diagnostics:**
```json
{
  "systemHealth": "healthy",
  "uptime": "00:15:32",
  "totalErrors": 0,
  "warnings": 2,
  "modules": {
    "audio": "healthy",
    "visual": "healthy",
    "coupling": "healthy"
  }
}
```

**Initialization Sequence:**
```
🔧 Loading Diagnostics Module...
🔬 System health monitoring: ENABLED
⌨️ Ctrl+Shift+D: Toggle debug overlay
✅ Diagnostics Module: Loaded
```

---

### 6. PerformanceModule

**Responsibilities:**
- FPS monitoring
- Frame drop detection
- Audio latency measurement
- Memory usage tracking
- Performance stats overlay

**Diagnostics:**
```json
{
  "fps": {
    "current": 59.8,
    "avg": 59.5,
    "min": 58.2,
    "drops": 3
  },
  "latency": {
    "audio": "8.5ms",
    "rendering": "16.7ms"
  },
  "memory": {
    "used": "145 MB",
    "peak": "152 MB"
  }
}
```

**Initialization Sequence:**
```
🔧 Loading Performance Module...
⚡ FPS monitoring: ENABLED
📊 Latency tracking: ENABLED
⌨️ Press P to toggle performance stats
✅ Performance Module: Loaded
```

---

### 7. PresetManagerModule

**Responsibilities:**
- Save/load presets locally
- Firebase cloud sync
- Import/export presets
- Preset categories
- Default presets

**Diagnostics:**
```json
{
  "localPresets": 12,
  "cloudPresets": 8,
  "currentPreset": "Ethereal Spaces",
  "lastSync": "2m ago",
  "cloudSyncEnabled": true
}
```

**Initialization Sequence:**
```
🔧 Loading Preset Manager Module...
💾 Loading default presets... (5 found)
☁️ Firebase sync: ENABLED
✅ Preset Manager Module: Loaded
```

---

### 8. TiltSensorModule

**Responsibilities:**
- Device orientation tracking
- Tilt calibration
- Map tilt to rotation
- Sensitivity adjustment
- Orb controller integration

**Diagnostics:**
```json
{
  "calibrated": true,
  "sensitivity": 2.5,
  "smoothing": 0.15,
  "currentTilt": {"x": 0.2, "y": -0.4},
  "mappedRotation": {"xw": 0.3, "yw": -0.6}
}
```

**Initialization Sequence:**
```
🔧 Loading Tilt Sensor Module...
🎯 Starting calibration (hold device steady)...
✅ Calibration complete: X=0.0, Y=9.78
🚀 Sensitivity: 2.5x, Smoothing: 0.15
✅ Tilt Sensor Module: Loaded
```

---

### 9. TestSuiteModule

**Responsibilities:**
- Integration test execution
- Parameter coupling tests
- System switching tests
- Performance benchmarks
- Test result reporting

**Diagnostics:**
```json
{
  "totalTests": 24,
  "passed": 22,
  "failed": 0,
  "skipped": 2,
  "lastRun": "5m ago",
  "coverage": "85%"
}
```

**Initialization Sequence:**
```
🔧 Loading Test Suite Module...
🧪 Registering 24 integration tests
💡 Run window.runAllTests() manually
✅ Test Suite Module: Loaded (auto-run disabled)
```

---

## 🏗️ Module Manager Implementation

```dart
class ModuleManager {
  final List<SynthModule> _modules = [];
  final Map<Type, SynthModule> _moduleMap = {};

  /// Register module
  void register(SynthModule module) {
    _modules.add(module);
    _moduleMap[module.runtimeType] = module;
  }

  /// Initialize all modules (respecting dependencies)
  Future<void> initializeAll() async {
    debugPrint('📦 Starting module initialization...\n');

    // Sort by dependencies
    final ordered = _topologicalSort();

    for (final module in ordered) {
      debugPrint('🔧 Loading ${module.name}...');

      try {
        await module.initialize();
        debugPrint('✅ ${module.name}: Loaded\n');
      } catch (e) {
        debugPrint('❌ ${module.name}: FAILED - $e\n');
        rethrow;
      }
    }

    debugPrint('✅ All modules loaded successfully\n');
    _printSystemSummary();
  }

  /// Get module by type
  T get<T extends SynthModule>() {
    return _moduleMap[T] as T;
  }

  /// System diagnostics
  void printDiagnostics() {
    debugPrint('🔬 System Diagnostics\n');

    for (final module in _modules) {
      final diag = module.getDiagnostics();
      debugPrint('📊 ${module.name}:');
      debugPrint('   ${diag}\n');
    }
  }

  /// Clean shutdown
  Future<void> disposeAll() async {
    debugPrint('🛑 Shutting down modules...\n');

    for (final module in _modules.reversed) {
      debugPrint('🔧 Disposing ${module.name}...');
      await module.dispose();
      debugPrint('✅ ${module.name}: Disposed\n');
    }
  }
}
```

---

## 📝 Enhanced Logging System

```dart
class SynthLogger {
  // Module lifecycle
  static void moduleLoad(String name) =>
    debugPrint('🔧 Loading $name...');

  static void moduleReady(String name) =>
    debugPrint('✅ $name: Loaded');

  static void moduleFailed(String name, Object error) =>
    debugPrint('❌ $name: FAILED - $error');

  // Parameter updates
  static void parameterUpdate(String param, dynamic value) =>
    debugPrint('💾 User parameter: $param = $value');

  // System events
  static void systemSwitch(String from, String to) =>
    debugPrint('🔄 System Switching: $from → $to');

  static void geometrySwitch(int from, int to) =>
    debugPrint('🔷 Geometry Switching: $from → $to');

  // Audio events
  static void noteOn(int note, double velocity) =>
    debugPrint('🎹 Note ON: $note (velocity: $velocity)');

  static void noteOff(int note) =>
    debugPrint('🎹 Note OFF: $note');

  // Performance
  static void fpsUpdate(double fps) =>
    debugPrint('⚡ FPS: ${fps.toStringAsFixed(1)}');

  static void latencyMeasured(double ms) =>
    debugPrint('⏱️ Latency: ${ms.toStringAsFixed(2)}ms');

  // State management
  static void stateSaved(int index, int total) =>
    debugPrint('📚 State saved to history ($index/$total)');

  static void undo(int index) =>
    debugPrint('⏮️ Undo: State ${index + 1}');

  static void redo(int index) =>
    debugPrint('⏭️ Redo: State ${index + 1}');
}
```

---

## 🚀 Main App Initialization (NEW)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create module manager
  final moduleManager = ModuleManager();

  // Register all modules
  moduleManager.register(AudioEngineModule());
  moduleManager.register(VisualBridgeModule());
  moduleManager.register(ParameterCouplingModule());
  moduleManager.register(StateManagerModule());
  moduleManager.register(DiagnosticsModule());
  moduleManager.register(PerformanceModule());
  moduleManager.register(PresetManagerModule());
  moduleManager.register(TiltSensorModule());
  moduleManager.register(TestSuiteModule());

  // Initialize all modules
  await moduleManager.initializeAll();

  // Run app
  runApp(SynthVib3App(moduleManager: moduleManager));
}
```

**Expected Output:**
```
📦 Starting module initialization...

🔧 Loading Audio Engine Module...
✅ Audio Engine Module: Loaded

🔧 Loading Visual Bridge Module...
✅ Visual Bridge Module: Loaded

🔧 Loading Parameter Coupling Module...
✅ Parameter Coupling Module: Loaded

🔧 Loading State Manager Module...
✅ State Manager Module: Loaded

🔧 Loading Diagnostics Module...
✅ Diagnostics Module: Loaded

🔧 Loading Performance Module...
✅ Performance Module: Loaded

🔧 Loading Preset Manager Module...
✅ Preset Manager Module: Loaded

🔧 Loading Tilt Sensor Module...
✅ Tilt Sensor Module: Loaded

🔧 Loading Test Suite Module...
✅ Test Suite Module: Loaded

✅ All modules loaded successfully

🚀 Synth-VIB3+ Ready
   - 9 modules initialized
   - Audio: 44100 Hz, 512 samples
   - Visual: VIB3+ 4 engines loaded
   - Coupling: 60 FPS bidirectional
   - Press Ctrl+Shift+D for diagnostics
```

---

## 📊 Benefits of This Architecture

### 1. Clean Separation of Concerns
Each module has ONE job and does it well

### 2. Easy Testing
Test modules in isolation with mocks

### 3. Better Error Handling
Module failures don't crash entire app

### 4. Comprehensive Diagnostics
Know exactly what's working and what isn't

### 5. Professional Logging
Every action is logged like VIB3+

### 6. State Management
Built-in undo/redo, presets, auto-save

### 7. Performance Monitoring
Real-time FPS, latency, memory tracking

### 8. Extensibility
Add new modules without touching existing code

### 9. Maintainability
Easy to understand, debug, and extend

### 10. Matches VIB3+ Quality
Same level of architecture as JavaScript codebase

---

## 🎯 Implementation Priority

**Phase 1: Core Modules (Week 1)**
1. Create ModuleManager + SynthModule interface
2. Implement AudioEngineModule
3. Implement VisualBridgeModule
4. Implement ParameterCouplingModule

**Phase 2: Management Modules (Week 2)**
5. Implement StateManagerModule (undo/redo)
6. Implement DiagnosticsModule
7. Implement PerformanceModule
8. Implement SynthLogger

**Phase 3: Feature Modules (Week 3)**
9. Implement PresetManagerModule
10. Implement TiltSensorModule
11. Implement TestSuiteModule
12. Integration testing

**Phase 4: Polish (Week 4)**
13. Debug overlay UI
14. Performance optimization
15. Documentation
16. Demo video

---

**A Paul Phillips Manifestation**
Paul@clearseassolutions.com
"The Revolution Will Not be in a Structured Format"
© 2025 Paul Phillips - Clear Seas Solutions LLC
