/**
 * Universal Synth-VIB3+ Application
 *
 * Works on BOTH mobile (Android/iOS) AND web platforms with
 * graceful feature degradation.
 *
 * Philosophy: Embrace the platform, use what's available, show what's possible.
 * This is OUR product - make it work everywhere!
 *
 * Mobile: 100% features (audio, visualization, sensors, haptics)
 * Web: UI showcase (gestures, presets, modulation, help) + "Download App" prompts
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

// Core platform detection
import 'core/platform_capabilities.dart';

// Conditional imports based on platform
import 'providers/layout_provider.dart';
import 'providers/ui_state_provider.dart';

// Integration systems (work on all platforms)
import 'integration/component_integration_manager.dart';
import 'ui/gestures/gesture_recognition_system.dart';
import 'ui/components/debug/performance_monitor.dart';
import 'ui/haptics/haptic_manager.dart';

// UI components (work on all platforms)
import 'ui/components/presets/preset_browser.dart';
import 'ui/components/modulation/modulation_matrix.dart';
import 'ui/help/help_overlay.dart';
import 'ui/theme/design_tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show platform info
  debugPrint('=================================================');
  debugPrint('Synth-VIB3+ Universal Edition');
  debugPrint('Platform: ${PlatformCapabilities.platformName}');
  debugPrint('Features Available: ${PlatformCapabilities.availabilityPercentage.toStringAsFixed(0)}%');
  debugPrint('=================================================');

  if (kIsWeb) {
    // Web version - UI showcase
    runApp(const UniversalSynthApp(platformMode: PlatformMode.web));
  } else {
    // Mobile version - full features
    // Would need to initialize modules here
    runApp(const UniversalSynthApp(platformMode: PlatformMode.mobile));
  }
}

enum PlatformMode {
  mobile,  // Full features
  web,     // UI showcase
}

class UniversalSynthApp extends StatelessWidget {
  final PlatformMode platformMode;

  const UniversalSynthApp({
    Key? key,
    required this.platformMode,
  }) : super(key: key);

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
      home: UniversalMainScreen(platformMode: platformMode),
    );
  }
}

class UniversalMainScreen extends StatefulWidget {
  final PlatformMode platformMode;

  const UniversalMainScreen({
    Key? key,
    required this.platformMode,
  }) : super(key: key);

  @override
  State<UniversalMainScreen> createState() => _UniversalMainScreenState();
}

class _UniversalMainScreenState extends State<UniversalMainScreen> {
  // Integration systems
  late GestureRecognitionSystem _gestureSystem;
  late PerformanceTracker _performanceTracker;

  // UI state
  bool _showWelcomeDialog = true;
  bool _showPerformanceMonitor = false;
  bool _showPresetBrowser = false;
  bool _showModulationMatrix = false;
  bool _showHelp = false;

  @override
  void initState() {
    super.initState();

    // Initialize systems
    _performanceTracker = PerformanceTracker();
    _gestureSystem = GestureRecognitionSystem();

    // Setup gesture handlers
    _setupGestureHandlers();

    // Configure haptics based on platform
    if (FeatureFlags.enableHaptics) {
      HapticManager.instance.setEnabled(true);
      HapticManager.instance.setIntensity(1.0);
    }

    // Show welcome dialog on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showWelcomeDialog) {
        _showWelcomeDialog = false;
        _showPlatformWelcome();
      }
    });
  }

  void _setupGestureHandlers() {
    // Three-finger swipe: Navigate presets
    _gestureSystem.on(GestureType.threeFingerSwipe, (gesture) {
      if (FeatureFlags.enableHaptics) {
        HapticManager.light();
      }
      // TODO: Navigate presets
    });

    // Four-finger tap: Toggle performance monitor
    _gestureSystem.on(GestureType.fourFingerTap, (gesture) {
      setState(() {
        _showPerformanceMonitor = !_showPerformanceMonitor;
      });
      if (FeatureFlags.enableHaptics) {
        HapticManager.selection();
      }
    });
  }

  void _showPlatformWelcome() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF00FFFF)),
            const SizedBox(width: 12),
            Text(
              widget.platformMode == PlatformMode.web
                  ? 'Web Demo Mode'
                  : 'Welcome!',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          PlatformMessages.welcomeMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          if (widget.platformMode == PlatformMode.web)
            TextButton(
              onPressed: () {
                // TODO: Open download page
                Navigator.pop(context);
              },
              child: const Text('Download Mobile App'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UIStateProvider()),
        ChangeNotifierProvider(create: (_) => LayoutProvider()),
        // Add more providers based on platform mode
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Stack(
          children: [
            // Main content area
            Center(
              child: _buildMainContent(),
            ),

            // Platform badge (web only)
            if (PlatformConfig.showPlatformBadge)
              Positioned(
                top: 16,
                left: 16,
                child: _buildPlatformBadge(),
              ),

            // Floating action buttons
            Positioned(
              left: 16,
              bottom: 80,
              child: _buildFloatingActionButtons(),
            ),

            // Performance overlay (if enabled)
            if (_showPerformanceMonitor)
              _buildPerformanceMonitor(),

            // Preset browser
            if (_showPresetBrowser)
              _buildPresetBrowser(),

            // Modulation matrix
            if (_showModulationMatrix)
              _buildModulationMatrix(),

            // Help overlay
            if (_showHelp)
              HelpOverlay(
                context: HelpContext.mainScreen,
                onClose: () {
                  setState(() => _showHelp = false);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (widget.platformMode == PlatformMode.web) {
      return _buildWebShowcase();
    } else {
      return _buildMobileInterface();
    }
  }

  Widget _buildWebShowcase() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo/Title
          const Icon(
            Icons.graphic_eq,
            size: 120,
            color: Color(0xFF00FFFF),
          ),
          const SizedBox(height: 24),
          const Text(
            'Synth-VIB3+',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Holographic Audio-Visual Synthesizer',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 48),

          // Feature showcases
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildFeatureCard(
                'Multi-Touch Gestures',
                '2-5 finger gesture recognition system',
                Icons.touch_app,
                available: true,
                onTap: () {
                  setState(() => _showHelp = true);
                },
              ),
              _buildFeatureCard(
                'Preset Browser',
                'Search, filter, and manage presets',
                Icons.library_music,
                available: true,
                onTap: () {
                  setState(() => _showPresetBrowser = true);
                },
              ),
              _buildFeatureCard(
                'Modulation Matrix',
                'Visual parameter routing system',
                Icons.account_tree,
                available: true,
                onTap: () {
                  setState(() => _showModulationMatrix = true);
                },
              ),
              _buildFeatureCard(
                'Real-Time Audio',
                'Low-latency synthesis engine',
                Icons.audiotrack,
                available: false,
                mobileOnly: true,
              ),
              _buildFeatureCard(
                '4D Visualization',
                'VIB3+ holographic rendering',
                Icons.bubble_chart,
                available: false,
                mobileOnly: true,
              ),
              _buildFeatureCard(
                'Haptic Feedback',
                'Musical tactile response',
                Icons.vibration,
                available: false,
                mobileOnly: true,
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Download button
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open download page
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Mobile App for Full Experience'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFFF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon, {
    required bool available,
    bool mobileOnly = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: available
              ? const Color(0xFF1A1A2E)
              : Colors.black38,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: available
                ? const Color(0xFF00FFFF).withOpacity(0.5)
                : Colors.white24,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: available
                  ? const Color(0xFF00FFFF)
                  : Colors.white38,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: available ? Colors.white : Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: available ? Colors.white70 : Colors.white38,
              ),
              textAlign: TextAlign.center,
            ),
            if (mobileOnly) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6600).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Mobile Only',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFFF6600),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInterface() {
    return const Center(
      child: Text(
        'Full Mobile Interface Here\n(Requires modular initialization)',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPlatformBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FFFF).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.web, size: 16, color: Color(0xFF00FFFF)),
          const SizedBox(width: 8),
          Text(
            PlatformMessages.platformBadge,
            style: const TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFAB(Icons.help_outline, 'Help', const Color(0xFF00FFFF), () {
          setState(() => _showHelp = !_showHelp);
          if (FeatureFlags.enableHaptics) HapticManager.light();
        }),
        const SizedBox(height: 12),
        _buildFAB(Icons.library_music, 'Presets', const Color(0xFF88CCFF), () {
          setState(() => _showPresetBrowser = !_showPresetBrowser);
          if (FeatureFlags.enableHaptics) HapticManager.medium();
        }),
        const SizedBox(height: 12),
        _buildFAB(Icons.account_tree, 'Matrix', const Color(0xFFFF00AA), () {
          setState(() => _showModulationMatrix = !_showModulationMatrix);
          if (FeatureFlags.enableHaptics) HapticManager.medium();
        }),
        const SizedBox(height: 12),
        _buildFAB(Icons.speed, 'Perf', const Color(0xFFFFAA00), () {
          setState(() => _showPerformanceMonitor = !_showPerformanceMonitor);
          if (FeatureFlags.enableHaptics) HapticManager.selection();
        }),
      ],
    );
  }

  Widget _buildFAB(IconData icon, String tooltip, Color color, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildPerformanceMonitor() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: PerformanceMonitor(
          tracker: _performanceTracker,
          width: 500,
          height: 700,
          showGraphs: true,
          showWarnings: true,
        ),
      ),
    );
  }

  Widget _buildPresetBrowser() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: PresetBrowser(
          presets: _getDemoPresets(),
          width: 900,
          height: 700,
          onPresetSelected: (preset) {
            if (FeatureFlags.enableHaptics) {
              HapticManager.playPattern(HapticPatterns.presetLoad);
            }
            setState(() => _showPresetBrowser = false);
          },
        ),
      ),
    );
  }

  Widget _buildModulationMatrix() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: ModulationMatrix(
          sources: _getDemoSources(),
          targets: _getDemoTargets(),
          connections: const [],
          width: 900,
          height: 700,
          onConnectionCreated: (connection) {
            if (FeatureFlags.enableHaptics) {
              HapticManager.selection();
            }
          },
        ),
      ),
    );
  }

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
    ];
  }

  List<ModulationSource> _getDemoSources() {
    return const [
      ModulationSource(
        id: 'lfo1',
        label: 'LFO 1',
        type: ModulationSourceType.lfo,
        color: Color(0xFF00FFFF),
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
      ),
    ];
  }
}
