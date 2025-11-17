/**
 * Visual Bridge Module - VIB3+ WebView Communication
 *
 * HYBRID WRAPPER: Wraps existing VisualProvider with professional
 * module infrastructure (logging, diagnostics, health monitoring).
 *
 * Manages WebView initialization, VIB3+ engine loading,
 * JavaScript bridge, and parameter synchronization.
 *
 * A Paul Phillips Manifestation
 */

import 'package:webview_flutter/webview_flutter.dart';
import '../core/synth_module.dart';
import '../core/synth_logger.dart';
import '../providers/visual_provider.dart';

class VisualBridgeModule extends SynthModule {
  @override
  String get name => 'Visual Bridge Module';

  late final VisualProvider provider;

  bool _isInitialized = false;
  DateTime? _startTime;

  // Performance tracking
  int _parameterUpdateCount = 0;
  int _systemSwitchCount = 0;
  int _geometrySwitchCount = 0;

  @override
  List<Type> get dependencies => [];

  @override
  Future<void> initialize() async {
    _startTime = DateTime.now();

    SynthLogger.visualLoad('assets/vib3_dist/index.html');

    // Create VisualProvider
    provider = VisualProvider();

    // Wait for provider to be ready
    await Future.delayed(const Duration(milliseconds: 100));

    _isInitialized = true;

    // Note: WebView controller will be set externally via setWebViewController()
    SynthLogger.visualReady();
  }

  @override
  Future<void> dispose() async {
    if (provider.isAnimating) {
      provider.stopAnimation();
    }
    _isInitialized = false;
  }

  @override
  bool get isHealthy {
    return _isInitialized;
  }

  @override
  Map<String, dynamic> getDiagnostics() {
    final uptime = _startTime != null ? DateTime.now().difference(_startTime!) : Duration.zero;

    return {
      'vib3Loaded': _isInitialized,
      'currentSystem': provider.currentSystem,
      'currentGeometry': provider.currentGeometry,
      'isAnimating': provider.isAnimating,
      'currentFPS': provider.currentFPS.toStringAsFixed(1),
      'parameterUpdates': _parameterUpdateCount,
      'systemSwitches': _systemSwitchCount,
      'geometrySwitches': _geometrySwitchCount,
      'uptime': '${uptime.inMinutes}:${(uptime.inSeconds % 60).toString().padLeft(2, '0')}',
      'healthy': isHealthy,
    };
  }

  // ============================================================================
  // PUBLIC API (Delegates to VisualProvider + Logging)
  // ============================================================================

  /// Get WebView controller (for embedding in UI)
  WebViewController? get controller => null; // Provider manages this internally

  /// Check if VIB3+ is ready
  bool get isReady => _isInitialized;

  /// Get current system
  String get currentSystem => provider.currentSystem;

  /// Get current geometry
  int get currentGeometry => provider.currentGeometry;

  /// Update VIB3+ parameter (with logging)
  Future<void> updateParameter(String paramName, double value) async {
    if (!_isInitialized) return;

    // Map parameter names to provider methods
    switch (paramName) {
      case 'rotationSpeed':
        provider.setRotationSpeed(value);
        break;
      case 'tessellationDensity':
        provider.setTessellationDensity(value.toInt());
        break;
      case 'vertexBrightness':
        provider.setVertexBrightness(value);
        break;
      case 'hueShift':
        provider.setHueShift(value);
        break;
      case 'glowIntensity':
        provider.setGlowIntensity(value);
        break;
      case 'morphParameter':
        provider.setMorphParameter(value);
        break;
      case 'projectionDistance':
        provider.setProjectionDistance(value);
        break;
      case 'layerSeparation':
        provider.setLayerSeparation(value);
        break;
      case 'scale':
        provider.setScale(value);
        break;
      case 'edgeThickness':
        provider.setEdgeThickness(value);
        break;
      case 'particleDensity':
        provider.setParticleDensity(value);
        break;
    }

    _parameterUpdateCount++;
    SynthLogger.parameterUpdate(paramName, value);
  }

  /// Switch VIB3+ system (quantum/faceted/holographic) (with logging)
  Future<void> switchSystem(String systemName) async {
    if (!_isInitialized) return;

    if (provider.currentSystem == systemName) return;

    final previousSystem = provider.currentSystem;

    await provider.switchSystem(systemName);
    _systemSwitchCount++;

    SynthLogger.systemSwitch(previousSystem, systemName);
    SynthLogger.systemSwitched(systemName);

    // Log system info
    _logSystemInfo(systemName);
  }

  /// Switch geometry (0-23) (with logging)
  Future<void> switchGeometry(int geometryIndex) async {
    if (!_isInitialized) return;

    if (geometryIndex < 0 || geometryIndex > 23) {
      SynthLogger.warning('VisualBridge', 'Invalid geometry index: $geometryIndex');
      return;
    }

    final oldGeometry = provider.currentGeometry;
    provider.setGeometry(geometryIndex);
    _geometrySwitchCount++;

    SynthLogger.geometrySwitch(oldGeometry, geometryIndex);
  }

  /// Get current visual state for audio modulation
  Map<String, double> getVisualState() {
    if (!_isInitialized) {
      return _getDefaultVisualState();
    }

    return {
      'rotationXW': provider.rotationXW,
      'rotationYW': provider.rotationYW,
      'rotationZW': provider.rotationZW,
      'rotationXY': provider.rotationXY,
      'rotationXZ': provider.rotationXZ,
      'rotationYZ': provider.rotationYZ,
      'morphParameter': provider.morphParameter,
      'rotationSpeed': provider.rotationSpeed,
    };
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  /// Log system information
  void _logSystemInfo(String systemName) {
    switch (systemName) {
      case 'quantum':
        SynthLogger.systemInfo(
          'Quantum',
          vertices: 120,
          complexity: 0.8,
          synthesisMode: 'Pure harmonic synthesis',
        );
        break;
      case 'faceted':
        SynthLogger.systemInfo(
          'Faceted',
          vertices: 600,
          complexity: 0.95,
          synthesisMode: 'Geometric hybrid synthesis',
        );
        break;
      case 'holographic':
        SynthLogger.systemInfo(
          'Holographic',
          vertices: 2400,
          complexity: 1.0,
          synthesisMode: 'Spectral rich synthesis',
        );
        break;
    }
  }

  /// Get default visual state when VIB3+ not ready
  Map<String, double> _getDefaultVisualState() {
    return {
      'rotationXW': 0.0,
      'rotationYW': 0.0,
      'rotationZW': 0.0,
      'rotationXY': 0.0,
      'rotationXZ': 0.0,
      'rotationYZ': 0.0,
      'morphParameter': 0.0,
      'rotationSpeed': 1.0,
    };
  }
}
