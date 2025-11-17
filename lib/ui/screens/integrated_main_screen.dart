///
/// Integrated Synth Application
///
/// Complete integration of all enhancement systems:
/// - Component Integration Manager
/// - Gesture Recognition System
/// - Performance Monitoring
/// - Preset Browser
/// - Modulation Matrix
/// - Haptic Feedback
/// - Context-Sensitive Help
///
/// This demonstrates the "extra dimension of ability" through
/// comprehensive system integration.
///
/// A Paul Phillips Manifestation
///

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/audio_provider.dart';
import '../../providers/visual_provider.dart';
import '../../providers/layout_provider.dart';
import '../../providers/ui_state_provider.dart';
import '../../providers/tilt_sensor_provider.dart';

// Integration Systems
import '../../integration/component_integration_manager.dart';
import '../gestures/gesture_recognition_system.dart';
import '../haptics/haptic_manager.dart';
import '../components/debug/performance_monitor.dart';

// UI Components
import '../components/presets/preset_browser.dart';
import '../components/modulation/modulation_matrix.dart';
import '../help/help_overlay.dart';
import '../theme/design_tokens.dart';

// Existing UI
import 'synth_main_screen.dart';
import '../../core/synth_app_initializer.dart';

/// Main integrated application
class IntegratedSynthApp extends StatelessWidget {
  final SynthModules modules;

  const IntegratedSynthApp({Key? key, required this.modules}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synth-VIB3+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF00FFFF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFFF),
          secondary: Color(0xFF88CCFF),
          surface: Color(0xFF1A1A2E),
        ),
      ),
      home: IntegratedMainScreen(modules: modules),
    );
  }
}

/// Integrated main screen with all enhancement systems
class IntegratedMainScreen extends StatefulWidget {
  final SynthModules modules;

  const IntegratedMainScreen({Key? key, required this.modules})
      : super(key: key);

  @override
  State<IntegratedMainScreen> createState() => _IntegratedMainScreenState();
}

class _IntegratedMainScreenState extends State<IntegratedMainScreen> {
  // Integration systems
  late ComponentIntegrationManager _integrationManager;
  late GestureRecognitionSystem _gestureSystem;
  late PerformanceTracker _performanceTracker;

  // UI state
  bool _showPerformanceMonitor = false;
  bool _showPresetBrowser = false;
  bool _showModulationMatrix = false;
  bool _showHelp = false;
  bool _compactPerformanceOverlay = true;

  @override
  void initState() {
    super.initState();

    // Initialize systems
    _performanceTracker = PerformanceTracker();
    _gestureSystem = GestureRecognitionSystem();

    // Setup gesture handlers
    _setupGestureHandlers();

    // Lock to fullscreen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    // Configure haptics
    HapticManager.instance.setEnabled(true);
    HapticManager.instance.setIntensity(1.0);

    // Start performance monitoring
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _gestureSystem.offAll();
    super.dispose();
  }

  void _setupGestureHandlers() {
    // Three-finger swipe: Navigate presets
    _gestureSystem.on(GestureType.threeFingerSwipe, (gesture) {
      if (gesture.velocity.dx > 0) {
        // Next preset
        HapticManager.playPattern(HapticPatterns.presetLoad);
        // TODO: Call preset manager
      } else {
        // Previous preset
        HapticManager.playPattern(HapticPatterns.presetLoad);
        // TODO: Call preset manager
      }
    });

    // Four-finger tap: Toggle performance monitor
    _gestureSystem.on(GestureType.fourFingerTap, (gesture) {
      setState(() {
        _showPerformanceMonitor = !_showPerformanceMonitor;
      });
      HapticManager.selection();
    });

    // Pinch: UI scale
    _gestureSystem.on(GestureType.pinch, (gesture) {
      final scale = gesture.metadata['scale'] as double?;
      if (scale != null) {
        // TODO: Update UI scale
      }
    });
  }

  void _onFrame(Duration timestamp) {
    _performanceTracker.recordFrame();
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Existing providers
        ChangeNotifierProvider(create: (_) => UIStateProvider()),
        ChangeNotifierProvider.value(value: widget.modules.visual.provider),
        ChangeNotifierProvider.value(value: widget.modules.audio.provider),
        ChangeNotifierProvider(create: (_) => TiltSensorProvider()),

        // Layout provider
        ChangeNotifierProvider(create: (_) => LayoutProvider()),

        // Integration manager (depends on other providers)
        ChangeNotifierProxyProvider4<AudioProvider, VisualProvider,
            LayoutProvider, UIStateProvider, ComponentIntegrationManager>(
          create: (context) => ComponentIntegrationManager(
            audioProvider: context.read<AudioProvider>(),
            visualProvider: context.read<VisualProvider>(),
            layoutProvider: context.read<LayoutProvider>(),
            enableHaptics: true,
            enableParticles: true,
            enableModulationViz: true,
          ),
          update: (context, audio, visual, layout, ui, previous) =>
              previous ??
              ComponentIntegrationManager(
                audioProvider: audio,
                visualProvider: visual,
                layoutProvider: layout,
                enableHaptics: true,
                enableParticles: true,
                enableModulationViz: true,
              ),
        ),
      ],
      child: _IntegratedMainContent(
        modules: widget.modules,
        gestureSystem: _gestureSystem,
        performanceTracker: _performanceTracker,
        showPerformanceMonitor: _showPerformanceMonitor,
        showPresetBrowser: _showPresetBrowser,
        showModulationMatrix: _showModulationMatrix,
        showHelp: _showHelp,
        compactPerformanceOverlay: _compactPerformanceOverlay,
        onTogglePerformanceMonitor: () {
          setState(() => _showPerformanceMonitor = !_showPerformanceMonitor);
          HapticManager.selection();
        },
        onTogglePresetBrowser: () {
          setState(() => _showPresetBrowser = !_showPresetBrowser);
          HapticManager.medium();
        },
        onToggleModulationMatrix: () {
          setState(() => _showModulationMatrix = !_showModulationMatrix);
          HapticManager.medium();
        },
        onToggleHelp: () {
          setState(() => _showHelp = !_showHelp);
          HapticManager.light();
        },
      ),
    );
  }
}

/// Main content with all integration features
class _IntegratedMainContent extends StatelessWidget {
  final SynthModules modules;
  final GestureRecognitionSystem gestureSystem;
  final PerformanceTracker performanceTracker;
  final bool showPerformanceMonitor;
  final bool showPresetBrowser;
  final bool showModulationMatrix;
  final bool showHelp;
  final bool compactPerformanceOverlay;
  final VoidCallback onTogglePerformanceMonitor;
  final VoidCallback onTogglePresetBrowser;
  final VoidCallback onToggleModulationMatrix;
  final VoidCallback onToggleHelp;

  const _IntegratedMainContent({
    Key? key,
    required this.modules,
    required this.gestureSystem,
    required this.performanceTracker,
    required this.showPerformanceMonitor,
    required this.showPresetBrowser,
    required this.showModulationMatrix,
    required this.showHelp,
    required this.compactPerformanceOverlay,
    required this.onTogglePerformanceMonitor,
    required this.onTogglePresetBrowser,
    required this.onToggleModulationMatrix,
    required this.onToggleHelp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final integrationManager =
        Provider.of<ComponentIntegrationManager>(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    // Track parameter updates
    integrationManager.addListener(() {
      performanceTracker.recordParameterUpdate();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Main synth interface
          Listener(
            onPointerDown: gestureSystem.handlePointerDown,
            onPointerMove: gestureSystem.handlePointerMove,
            onPointerUp: gestureSystem.handlePointerUp,
            onPointerCancel: gestureSystem.handlePointerCancel,
            child: SynthMainScreen(modules: modules),
          ),

          // Floating action buttons (bottom-left)
          Positioned(
            left: 16,
            bottom: 80,
            child: _buildFloatingActionButtons(context),
          ),

          // Compact performance overlay (top-right)
          if (compactPerformanceOverlay &&
              performanceTracker.history.isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onTogglePerformanceMonitor,
                child: CompactPerformanceOverlay(
                  metrics: performanceTracker.snapshot(
                    memoryUsage: 0,
                    cpuUsage: 0,
                    activeVoices: audioProvider.voiceCount,
                    particleCount: 0,
                    webViewLatency: 0,
                  ),
                ),
              ),
            ),

          // Full performance monitor
          if (showPerformanceMonitor) _buildFullPerformanceMonitor(context),

          // Preset browser
          if (showPresetBrowser) _buildPresetBrowser(context),

          // Modulation matrix
          if (showModulationMatrix) _buildModulationMatrix(context),

          // Help overlay
          if (showHelp)
            HelpOverlay(
              context: HelpContext.mainScreen,
              onClose: onToggleHelp,
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Help button
        _buildFAB(
          icon: Icons.help_outline,
          label: 'Help',
          color: DesignTokens.quantum,
          onPressed: onToggleHelp,
        ),
        const SizedBox(height: 12),

        // Preset browser button
        _buildFAB(
          icon: Icons.library_music,
          label: 'Presets',
          color: DesignTokens.faceted,
          onPressed: onTogglePresetBrowser,
        ),
        const SizedBox(height: 12),

        // Modulation matrix button
        _buildFAB(
          icon: Icons.account_tree,
          label: 'Matrix',
          color: DesignTokens.holographic,
          onPressed: onToggleModulationMatrix,
        ),
        const SizedBox(height: 12),

        // Performance monitor button
        _buildFAB(
          icon: Icons.speed,
          label: 'Perf',
          color: DesignTokens.stateWarning,
          onPressed: onTogglePerformanceMonitor,
        ),
      ],
    );
  }

  Widget _buildFAB({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticManager.light();
        onPressed();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildFullPerformanceMonitor(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Stack(
          children: [
            PerformanceMonitor(
              tracker: performanceTracker,
              width: 500,
              height: 700,
              showGraphs: true,
              showWarnings: true,
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  HapticManager.light();
                  onTogglePerformanceMonitor();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetBrowser(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Stack(
          children: [
            PresetBrowser(
              presets: _getDemoPresets(),
              width: 900,
              height: 700,
              onPresetSelected: (preset) {
                HapticManager.playPattern(HapticPatterns.presetLoad);
                // TODO: Load preset
                onTogglePresetBrowser();
              },
              onPresetFavorited: (preset) {
                HapticManager.selection();
                // TODO: Toggle favorite
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  HapticManager.light();
                  onTogglePresetBrowser();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulationMatrix(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Stack(
          children: [
            ModulationMatrix(
              sources: _getDemoSources(),
              targets: _getDemoTargets(),
              connections: const [],
              width: 900,
              height: 700,
              onConnectionCreated: (connection) {
                HapticManager.playPattern(HapticPatterns.parameterChange);
                // TODO: Create modulation route
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  HapticManager.light();
                  onToggleModulationMatrix();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Demo data
  List<PresetMetadata> _getDemoPresets() {
    return [
      PresetMetadata(
        id: 'demo_1',
        name: 'Quantum Waves',
        description: 'Flowing quantum pad with spectral shimmer',
        category: PresetCategory.pads,
        geometryIndex: 0,
        visualSystem: 'Quantum',
        synthesisType: 'Direct',
        isFactory: true,
        rating: 4.5,
        createdAt: DateTime.now(),
      ),
      PresetMetadata(
        id: 'demo_2',
        name: 'Hypersphere Lead',
        description: 'Cutting FM lead with harmonic richness',
        category: PresetCategory.leads,
        geometryIndex: 11,
        visualSystem: 'Faceted',
        synthesisType: 'FM',
        isFactory: true,
        isFavorite: true,
        rating: 5.0,
        createdAt: DateTime.now(),
      ),
      PresetMetadata(
        id: 'demo_3',
        name: 'Crystal Bass',
        description: 'Deep crystalline bass with sharp attack',
        category: PresetCategory.basses,
        geometryIndex: 7,
        visualSystem: 'Holographic',
        synthesisType: 'Direct',
        isFactory: true,
        rating: 4.0,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<ModulationSource> _getDemoSources() {
    return const [
      ModulationSource(
        id: 'lfo1',
        label: 'LFO 1',
        type: ModulationSourceType.lfo,
        color: Color(0xFF00FFFF),
        currentValue: 0.5,
      ),
      ModulationSource(
        id: 'env1',
        label: 'Envelope',
        type: ModulationSourceType.envelope,
        color: Color(0xFFFF00AA),
        currentValue: 0.0,
      ),
      ModulationSource(
        id: 'audio_rms',
        label: 'Audio RMS',
        type: ModulationSourceType.audioReactive,
        color: Color(0xFF00FF88),
        currentValue: 0.3,
      ),
    ];
  }

  List<ModulationTarget> _getDemoTargets() {
    return const [
      ModulationTarget(
        id: 'filter_cutoff',
        label: 'Filter Cutoff',
        category: 'Filter',
        color: Color(0xFFFFAA00),
        currentValue: 0.5,
      ),
      ModulationTarget(
        id: 'osc_detune',
        label: 'Oscillator Detune',
        category: 'Oscillator',
        color: Color(0xFF8800FF),
        currentValue: 0.0,
      ),
      ModulationTarget(
        id: 'reverb_mix',
        label: 'Reverb Mix',
        category: 'Effects',
        color: Color(0xFF00AAFF),
        currentValue: 0.3,
      ),
    ];
  }
}
