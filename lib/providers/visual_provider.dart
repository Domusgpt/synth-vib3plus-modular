///
/// Visual Provider
///
/// Manages the VIB34D visualization system state, providing
/// parameter control and state queries for the visual system.
///
/// Responsibilities:
/// - VIB34D system state (Quantum, Holographic, Faceted)
/// - 4D rotation angles (XW, YW, ZW planes)
/// - Visual parameters (tessellation, brightness, hue, glow, etc.)
/// - Geometry state (vertex count, morph parameter, complexity)
/// - Projection parameters (distance, layer depth)
/// - WebView bridge to JavaScript systems
///
/// A Paul Phillips Manifestation
///

library;

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../ui/theme/synth_theme.dart';

class VisualProvider with ChangeNotifier {
  // Current VIB34D system
  String _currentSystem = 'quantum'; // 'quantum', 'holographic', 'faceted'

  // 3D Rotation angles (radians, 0-2π)
  double _rotationXY = 0.0;
  double _rotationXZ = 0.0;
  double _rotationYZ = 0.0;

  // 4D Rotation angles (radians, 0-2π)
  double _rotationXW = 0.0;
  double _rotationYW = 0.0;
  double _rotationZW = 0.0;

  // Rotation velocity (for advanced modulation)
  double _rotationVelocityXW = 0.0;
  double _rotationVelocityYW = 0.0;
  double _rotationVelocityZW = 0.0;

  // Visual parameters
  double _rotationSpeed = 1.0; // Base rotation speed multiplier
  int _tessellationDensity = 5; // Subdivision level (3-8)
  double _vertexBrightness = 0.8; // Vertex intensity (0-1)
  double _hueShift = 180.0; // Color hue offset (0-360°)
  double _glowIntensity = 1.0; // Bloom/glow amount (0-3)
  double _rgbSplitAmount = 0.0; // Chromatic aberration (0-10)

  // Geometry state (ENHANCED FOR 72-COMBINATION MATRIX)
  int _activeVertexCount = 120; // Current vertex count
  double _morphParameter = 0.0; // Geometry morph (0-1)
  int _currentGeometry = 0; // Base geometry index (0-7)
  int _fullGeometryIndex =
      0; // Full geometry index (0-23) for 72-combination matrix
  double _geometryComplexity = 0.5; // Complexity measure (0-1)

  // Projection parameters
  double _projectionDistance = 8.0; // Camera distance (5-15)
  double _layerSeparation = 2.0; // Holographic layer depth (0-5)

  // WebView controller (for JavaScript bridge)
  WebViewController? _webViewController;

  // Animation state
  bool _isAnimating = false;

  VisualProvider() {
    debugPrint('✅ VisualProvider initialized');
  }

  // Getters
  String get currentSystem => _currentSystem;
  double get rotationXY => _rotationXY;
  double get rotationXZ => _rotationXZ;
  double get rotationYZ => _rotationYZ;
  double get rotationXW => _rotationXW;
  double get rotationYW => _rotationYW;
  double get rotationZW => _rotationZW;
  double get rotationSpeed => _rotationSpeed;
  int get tessellationDensity => _tessellationDensity;
  double get vertexBrightness => _vertexBrightness;
  double get hueShift => _hueShift;
  double get glowIntensity => _glowIntensity;
  double get rgbSplitAmount => _rgbSplitAmount;
  int get activeVertexCount => _activeVertexCount;
  double get morphParameter => _morphParameter;
  int get currentGeometry => _currentGeometry;
  int get fullGeometryIndex => _fullGeometryIndex; // Full 0-23 range
  double get projectionDistance => _projectionDistance;
  double get layerSeparation => _layerSeparation;
  bool get isAnimating => _isAnimating;

  /// Initialize WebView controller for VIB34D systems
  void setWebViewController(WebViewController controller) {
    _webViewController = controller;
    debugPrint('✅ WebView controller attached to VisualProvider');
  }

  /// Switch between VIB34D systems
  Future<void> switchSystem(String systemName) async {
    if (_currentSystem == systemName) return;

    final previousSystem = _currentSystem;
    _currentSystem = systemName;

    // Update full geometry index based on new system offset
    final newSystemOffset = _getSystemOffset(systemName);
    _fullGeometryIndex = newSystemOffset + _currentGeometry;

    debugPrint('🔄 System Switching: $previousSystem → $systemName');
    debugPrint(
        '   Full Geometry Updated: ${_getSystemOffset(previousSystem) + _currentGeometry} → $_fullGeometryIndex');

    // Update JavaScript system via WebView
    // VIB3+ uses window.switchSystem(), not window.vib34d.switchSystem()
    if (_webViewController != null) {
      try {
        await _webViewController!.runJavaScript(
            'if (window.switchSystem) { window.switchSystem("$systemName"); }');
        debugPrint('✅ VIB3+ system switched to $systemName');
      } catch (e) {
        debugPrint('❌ Error switching VIB3+ system: $e');
      }
    } else {
      debugPrint(
          '⚠️  WebView controller not initialized - system switch deferred');
    }

    // Update vertex count and complexity based on system
    switch (systemName) {
      case 'quantum':
        _activeVertexCount = 120; // Tesseract has 120 cells
        _geometryComplexity = 0.8;
        debugPrint(
            '   Quantum: vertices=120, complexity=0.8 (Pure harmonic synthesis)');
        break;
      case 'holographic':
        _activeVertexCount = 500; // 5 layers × 100 vertices
        _geometryComplexity = 0.9;
        debugPrint(
            '   Holographic: vertices=500, complexity=0.9 (Spectral rich synthesis)');
        break;
      case 'faceted':
        _activeVertexCount = 50; // Simpler geometry
        _geometryComplexity = 0.3;
        debugPrint(
            '   Faceted: vertices=50, complexity=0.3 (Geometric hybrid synthesis)');
        break;
    }

    notifyListeners();
  }

  /// Set rotation speed (from audio modulation)
  void setRotationSpeed(double speed) {
    _rotationSpeed = speed.clamp(0.1, 5.0);

    // Update JavaScript
    _updateJavaScriptParameter('rotationSpeed', _rotationSpeed);

    notifyListeners();
  }

  /// Set tessellation density (from audio modulation)
  void setTessellationDensity(int density) {
    _tessellationDensity = density.clamp(3, 10);

    // Update JavaScript
    _updateJavaScriptParameter('tessellationDensity', _tessellationDensity);

    notifyListeners();
  }

  /// Set vertex brightness (from audio modulation)
  void setVertexBrightness(double brightness) {
    _vertexBrightness = brightness.clamp(0.0, 1.0);

    // Update JavaScript
    _updateJavaScriptParameter('vertexBrightness', _vertexBrightness);

    notifyListeners();
  }

  /// Set hue shift (from audio modulation)
  void setHueShift(double hue) {
    _hueShift = hue % 360.0;

    // Update JavaScript
    _updateJavaScriptParameter('hueShift', _hueShift);

    notifyListeners();
  }

  /// Set glow intensity (from audio modulation)
  void setGlowIntensity(double intensity) {
    _glowIntensity = intensity.clamp(0.0, 3.0);

    // Update JavaScript
    _updateJavaScriptParameter('glowIntensity', _glowIntensity);

    notifyListeners();
  }

  /// Set RGB split amount (from audio modulation)
  void setRGBSplitAmount(double amount) {
    _rgbSplitAmount = amount.clamp(0.0, 10.0);

    // Update JavaScript
    _updateJavaScriptParameter('rgbSplitAmount', _rgbSplitAmount);

    notifyListeners();
  }

  /// Update rotation angles (internal animation or external control)
  void updateRotations(double deltaTime) {
    final dt = deltaTime * _rotationSpeed;

    // Calculate velocity
    _rotationVelocityXW = (_rotationXW - _rotationXW) / deltaTime;
    _rotationVelocityYW = (_rotationYW - _rotationYW) / deltaTime;
    _rotationVelocityZW = (_rotationZW - _rotationZW) / deltaTime;

    // Update angles
    _rotationXW = (_rotationXW + dt * 0.5) % (2.0 * math.pi);
    _rotationYW = (_rotationYW + dt * 0.7) % (2.0 * math.pi);
    _rotationZW = (_rotationZW + dt * 0.3) % (2.0 * math.pi);

    // Update JavaScript
    _updateJavaScriptParameter('rot4dXW', _rotationXW);
    _updateJavaScriptParameter('rot4dYW', _rotationYW);
    _updateJavaScriptParameter('rot4dZW', _rotationZW);

    notifyListeners();
  }

  /// Get rotation angle for specific plane (for visual→audio modulation)
  double getRotationAngle(String plane) {
    switch (plane.toUpperCase()) {
      case 'XW':
        return _rotationXW;
      case 'YW':
        return _rotationYW;
      case 'ZW':
        return _rotationZW;
      default:
        return 0.0;
    }
  }

  /// Get rotation velocity (for advanced modulation)
  double getRotationVelocity() {
    return math.sqrt(_rotationVelocityXW * _rotationVelocityXW +
        _rotationVelocityYW * _rotationVelocityYW +
        _rotationVelocityZW * _rotationVelocityZW);
  }

  /// Get morph parameter (for wavetable modulation)
  double getMorphParameter() {
    return _morphParameter;
  }

  /// Set morph parameter
  void setMorphParameter(double morph) {
    _morphParameter = morph.clamp(0.0, 1.0);
    _updateJavaScriptParameter('morphParameter', _morphParameter);
    notifyListeners();
  }

  /// Get projection distance (for reverb modulation)
  double getProjectionDistance() {
    return _projectionDistance;
  }

  /// Set projection distance
  void setProjectionDistance(double distance) {
    _projectionDistance = distance.clamp(5.0, 15.0);
    _updateJavaScriptParameter('projectionDistance', _projectionDistance);
    notifyListeners();
  }

  /// Get layer separation (for delay modulation)
  double getLayerSeparation() {
    return _layerSeparation;
  }

  /// Set layer separation
  void setLayerSeparation(double separation) {
    _layerSeparation = separation.clamp(0.0, 5.0);
    _updateJavaScriptParameter('layerSeparation', _layerSeparation);
    notifyListeners();
  }

  /// Get active vertex count (for voice count modulation)
  int getActiveVertexCount() {
    return _activeVertexCount;
  }

  /// Get geometry complexity (for harmonic richness modulation)
  double getGeometryComplexity() {
    return _geometryComplexity;
  }

  /// Set current base geometry (0-7) - LEGACY METHOD for backward compatibility
  void setGeometry(int geometryIndex) {
    final previousGeometry = _currentGeometry;
    _currentGeometry = geometryIndex.clamp(0, 7);

    // Update full geometry index based on current system
    final systemOffset = _getSystemOffset(_currentSystem);
    _fullGeometryIndex = systemOffset + _currentGeometry;

    if (previousGeometry != _currentGeometry) {
      debugPrint('🔷 Base Geometry: $previousGeometry → $_currentGeometry');
      debugPrint(
          '   Full Geometry: $_fullGeometryIndex (System: $_currentSystem, Offset: $systemOffset)');
    }

    _updateJavaScriptParameter('geometry', _currentGeometry);

    // Update vertex count based on geometry
    final previousVertexCount = _activeVertexCount;
    _activeVertexCount = _getVertexCountForGeometry(_currentGeometry);

    if (previousVertexCount != _activeVertexCount) {
      debugPrint('   Vertex count: $previousVertexCount → $_activeVertexCount');
    }

    notifyListeners();
  }

  /// Set full geometry index (0-23) for 72-combination matrix
  /// This automatically switches visual system if needed:
  /// - 0-7: Quantum system (Base core = Direct synthesis)
  /// - 8-15: Faceted system (Hypersphere core = FM synthesis)
  /// - 16-23: Holographic system (Hypertetrahedron core = Ring modulation)
  Future<void> setFullGeometry(int index) async {
    final clampedIndex = index.clamp(0, 23);
    final previousFullGeometry = _fullGeometryIndex;
    _fullGeometryIndex = clampedIndex;

    // Calculate derived values
    final coreIndex = clampedIndex ~/ 8; // 0, 1, or 2
    final baseGeometry = clampedIndex % 8; // 0-7

    // Determine target system based on core
    final targetSystem = _coreToSystem(coreIndex);

    debugPrint('🎯 Full Geometry Set: $previousFullGeometry → $clampedIndex');
    debugPrint('   Core: $coreIndex (${_coreNames[coreIndex]})');
    debugPrint(
        '   Base Geometry: $baseGeometry (${_geometryNames[baseGeometry]})');
    debugPrint('   Target System: $targetSystem');

    // Switch system if needed
    if (_currentSystem != targetSystem) {
      await switchSystem(targetSystem);
    }

    // Update base geometry
    _currentGeometry = baseGeometry;
    _updateJavaScriptParameter('geometry', _currentGeometry);

    // Update vertex count
    _activeVertexCount = _getVertexCountForGeometry(_currentGeometry);

    notifyListeners();
  }

  /// Get geometry offset based on current visual system
  /// This maps visual systems to polytope cores in the 72-combination matrix:
  /// - Quantum → Base core (0) → Geometries 0-7
  /// - Faceted → Hypersphere core (8) → Geometries 8-15
  /// - Holographic → Hypertetrahedron core (16) → Geometries 16-23
  int _getSystemOffset(String system) {
    switch (system.toLowerCase()) {
      case 'quantum':
        return 0; // Base core (Direct synthesis)
      case 'faceted':
        return 8; // Hypersphere core (FM synthesis)
      case 'holographic':
        return 16; // Hypertetrahedron core (Ring modulation)
      default:
        return 0;
    }
  }

  /// Map core index to visual system name
  String _coreToSystem(int coreIndex) {
    switch (coreIndex) {
      case 0:
        return 'quantum'; // Base → Quantum
      case 1:
        return 'faceted'; // Hypersphere → Faceted
      case 2:
        return 'holographic'; // Hypertetrahedron → Holographic
      default:
        return 'quantum';
    }
  }

  // Helper arrays for debug output
  static const _coreNames = ['Direct', 'FM', 'Ring Mod'];
  static const _geometryNames = [
    'Tetrahedron',
    'Hypercube',
    'Sphere',
    'Torus',
    'Klein Bottle',
    'Fractal',
    'Wave',
    'Crystal'
  ];

  /// Get vertex count for specific geometry
  int _getVertexCountForGeometry(int index) {
    // Approximate vertex counts for different 4D geometries
    const vertexCounts = [
      16, // 0: Tesseract (hypercube)
      120, // 1: 120-cell
      600, // 2: 600-cell
      8, // 3: 16-cell
      24, // 4: 24-cell
      50, // 5: Torus
      100, // 6: Sphere
      32, // 7: Klein bottle
    ];

    return index < vertexCounts.length ? vertexCounts[index] : 100;
  }

  /// Update JavaScript parameter via WebView
  /// VIB3+ uses window.updateParameter(name, value) API
  Future<void> _updateJavaScriptParameter(String name, dynamic value) async {
    if (_webViewController == null) return;

    try {
      await _webViewController!.runJavaScript(
          'if (window.updateParameter) { window.updateParameter("$name", $value); }');
    } catch (e) {
      debugPrint('⚠️  Error updating JS parameter $name: $e');
    }
  }

  /// Start animation loop
  void startAnimation() {
    _isAnimating = true;
    notifyListeners();
  }

  /// Stop animation loop
  void stopAnimation() {
    _isAnimating = false;
    notifyListeners();
  }

  /// Get visual state for debugging/UI
  Map<String, dynamic> getVisualState() {
    return {
      'system': _currentSystem,
      'rotationXW': _rotationXW,
      'rotationYW': _rotationYW,
      'rotationZW': _rotationZW,
      'rotationSpeed': _rotationSpeed,
      'tessellationDensity': _tessellationDensity,
      'vertexBrightness': _vertexBrightness,
      'hueShift': _hueShift,
      'glowIntensity': _glowIntensity,
      'rgbSplitAmount': _rgbSplitAmount,
      'activeVertexCount': _activeVertexCount,
      'morphParameter': _morphParameter,
      'projectionDistance': _projectionDistance,
      'layerSeparation': _layerSeparation,
      'isAnimating': _isAnimating,
    };
  }

  // ============================================================================
  // MISSING METHODS ADDED FOR UI INTEGRATION
  // ============================================================================

  // FPS tracking
  double _currentFPS = 60.0;
  int _frameCount = 0;
  DateTime _fpsLastCheck = DateTime.now();

  double get currentFPS => _currentFPS;

  void updateFPS() {
    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_fpsLastCheck).inMilliseconds;

    if (elapsed >= 1000) {
      _currentFPS = (_frameCount * 1000.0) / elapsed;
      _frameCount = 0;
      _fpsLastCheck = now;
      notifyListeners();
    }
  }

  // System colors (based on current visual system)
  SystemColors get systemColors {
    switch (_currentSystem.toLowerCase()) {
      case 'quantum':
        return SystemColors.quantum;
      case 'faceted':
        return SystemColors.faceted;
      case 'holographic':
        return SystemColors.holographic;
      default:
        return SystemColors.quantum;
    }
  }

  // System setter (alternative to switchSystem)
  void setSystem(String systemName) {
    switchSystem(systemName);
  }

  // 3D rotation setters
  void setRotationXY(double angle) {
    _rotationXY = angle % (2.0 * math.pi);
    _updateJavaScriptParameter('rot3dXY', _rotationXY);
    notifyListeners();
  }

  void setRotationXZ(double angle) {
    _rotationXZ = angle % (2.0 * math.pi);
    _updateJavaScriptParameter('rot3dXZ', _rotationXZ);
    notifyListeners();
  }

  void setRotationYZ(double angle) {
    _rotationYZ = angle % (2.0 * math.pi);
    _updateJavaScriptParameter('rot3dYZ', _rotationYZ);
    notifyListeners();
  }

  // 4D rotation setters
  void setRotationXW(double angle) {
    _rotationXW = angle % (2.0 * math.pi);
    _updateJavaScriptParameter('rot4dXW', _rotationXW);
    notifyListeners();
  }

  void setRotationYW(double angle) {
    _rotationYW = angle % (2.0 * math.pi);
    _updateJavaScriptParameter('rot4dYW', _rotationYW);
    notifyListeners();
  }

  void setRotationZW(double angle) {
    _rotationZW = angle % (2.0 * math.pi);
    _updateJavaScriptParameter('rot4dZW', _rotationZW);
    notifyListeners();
  }

  // Additional parameter setters for ParameterBridge integration

  /// Set overall scale (from audio modulation)
  void setScale(double scale) {
    final clampedScale = scale.clamp(0.5, 2.0);
    _updateJavaScriptParameter('scale', clampedScale);
    notifyListeners();
  }

  /// Set edge thickness (from audio modulation)
  void setEdgeThickness(double thickness) {
    final clampedThickness = thickness.clamp(0.1, 1.0);
    _updateJavaScriptParameter('edgeThickness', clampedThickness);
    notifyListeners();
  }

  /// Set particle density (from audio modulation)
  void setParticleDensity(double density) {
    final clampedDensity = density.clamp(0.0, 1000.0);
    _updateJavaScriptParameter('particleDensity', clampedDensity);
    notifyListeners();
  }

  /// Set warp amount (geometric distortion from audio)
  void setWarpAmount(double warp) {
    final clampedWarp = warp.clamp(0.0, 1.0);
    _updateJavaScriptParameter('warpAmount', clampedWarp);
    notifyListeners();
  }

  /// Set shimmer speed (vertex animation speed from audio)
  void setShimmerSpeed(double speed) {
    final clampedSpeed = speed.clamp(0.0, 10.0);
    _updateJavaScriptParameter('shimmerSpeed', clampedSpeed);
    notifyListeners();
  }

  /// Set chaos amount (vertex randomization from audio)
  void setChaosAmount(double chaos) {
    final clampedChaos = chaos.clamp(0.0, 1.0);
    _updateJavaScriptParameter('chaosAmount', clampedChaos);
    notifyListeners();
  }

  /// Set layer depth (holographic layer separation from audio)
  void setLayerDepth(double depth) {
    _layerSeparation = depth.clamp(0.0, 5.0);
    _updateJavaScriptParameter('layerDepth', _layerSeparation);
    notifyListeners();
  }

  // ========================================================================
  // SMART CANVAS LIFECYCLE MANAGEMENT
  // ========================================================================

  /// Batch update multiple parameters for better performance
  /// Uses the new window.updateParameters() API from smart canvas
  Future<void> updateBatchParameters(Map<String, dynamic> params) async {
    if (_webViewController == null) {
      debugPrint('⚠️ WebView not ready - cannot batch update parameters');
      return;
    }

    try {
      // Convert parameters to JSON-like object
      final paramsJson =
          params.entries.map((e) => '"${e.key}": ${e.value}').join(', ');

      await _webViewController!.runJavaScript(
          'if (window.updateParameters) { window.updateParameters({$paramsJson}); }');

      debugPrint('📦 Batch updated ${params.length} parameters');
    } catch (e) {
      debugPrint('❌ Failed to batch update parameters: $e');
    }
  }

  /// Query the Smart Canvas for current initialization state
  Future<Map<String, bool>> getSmartCanvasState() async {
    if (_webViewController == null) {
      return {
        'ready': false,
        'quantum': false,
        'faceted': false,
        'holographic': false,
      };
    }

    try {
      final result = await _webViewController!.runJavaScriptReturningResult('''
        (function() {
          if (!window.canvasManager) return JSON.stringify({ready: false});

          const manager = window.canvasManager;
          const initialized = manager.initializedSystems || new Set();

          return JSON.stringify({
            ready: true,
            quantum: initialized.has('quantum'),
            faceted: initialized.has('faceted'),
            holographic: initialized.has('holographic'),
            currentSystem: manager.currentSystem || 'unknown',
            fps: manager.fps || 0,
          });
        })()
      ''');

      // Parse the JSON result
      if (result is String) {
        // Remove quotes if present
        final jsonString = result.replaceAll('"', '');
        debugPrint('📊 Smart Canvas state: $jsonString');

        return {
          'ready': jsonString.contains('ready:true'),
          'quantum': jsonString.contains('quantum:true'),
          'faceted': jsonString.contains('faceted:true'),
          'holographic': jsonString.contains('holographic:true'),
        };
      }

      return {
        'ready': false,
        'quantum': false,
        'faceted': false,
        'holographic': false
      };
    } catch (e) {
      debugPrint('⚠️ Failed to query Smart Canvas state: $e');
      return {
        'ready': false,
        'quantum': false,
        'faceted': false,
        'holographic': false
      };
    }
  }

  /// Force initialization of a specific system (lazy loading)
  Future<void> ensureSystemInitialized(String system) async {
    if (_webViewController == null) {
      debugPrint('⚠️ WebView not ready - cannot initialize $system');
      return;
    }

    try {
      await _webViewController!.runJavaScript('''
        (async function() {
          if (window.canvasManager && window.canvasManager.initializeSystem) {
            console.log('🚀 Force initializing $system system...');
            await window.canvasManager.initializeSystem('$system');
          } else {
            console.warn('⚠️ Smart Canvas manager not available');
          }
        })()
      ''');

      debugPrint('✅ Ensured $system system is initialized');
    } catch (e) {
      debugPrint('❌ Failed to ensure $system initialization: $e');
    }
  }

  /// Toggle debug overlay in Smart Canvas
  Future<void> toggleSmartCanvasDebug() async {
    if (_webViewController == null) return;

    try {
      await _webViewController!
          .runJavaScript('if (window.toggleDebug) { window.toggleDebug(); }');
      debugPrint('🐛 Toggled Smart Canvas debug overlay');
    } catch (e) {
      debugPrint('⚠️ Failed to toggle debug: $e');
    }
  }

  @override
  void dispose() {
    stopAnimation();
    super.dispose();
  }
}
