///
/// Parameter Coupling Module - Bidirectional Audio↔Visual Modulation
///
/// Orchestrates 60 FPS parameter coupling between audio synthesis
/// and VIB3+ visualization. Runs two independent modulation systems:
/// - Audio→Visual: FFT analysis modulates rotation, tessellation, colors
/// - Visual→Audio: 6D rotation modulates oscillators, filters, effects
///
/// IMPORTANT: Audio reactivity is ALWAYS ON - this is a core feature,
/// not optional. The 19 ELEGANT_PAIRINGS are always active. User sliders
/// set BASE values, and audio analysis adds ± modulation on top.
///
/// Enable/disable methods exist for debugging only and should NEVER be
/// exposed in the UI.
///
/// A Paul Phillips Manifestation
////

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/synth_module.dart';
import '../core/synth_logger.dart';
import '../mapping/audio_to_visual.dart';
import '../mapping/visual_to_audio.dart';
import 'audio_engine_module.dart';
import 'visual_bridge_module.dart';

class ParameterCouplingModule extends SynthModule {
  @override
  String get name => 'Parameter Coupling Module';

  @override
  List<Type> get dependencies => [
        AudioEngineModule,
        VisualBridgeModule,
      ];

  late AudioEngineModule _audioModule;
  late VisualBridgeModule _visualModule;

  late AudioToVisualModulator _audioToVisual;
  late VisualToAudioModulator _visualToAudio;

  Timer? _updateTimer;
  bool _isRunning = false;

  // Configuration
  bool _audioReactiveEnabled = true;
  bool _visualReactiveEnabled = true;
  double _updateRate = 60.0; // FPS

  // Performance tracking
  int _updateCount = 0;
  DateTime? _startTime;
  final List<double> _updateDurations = [];
  double _averageUpdateTime = 0.0;

  @override
  Future<void> initialize() async {
    // Modulators will be created in setDependencies() after dependencies are injected
    // Don't start the timer yet - wait for explicit start()
  }

  @override
  Future<void> dispose() async {
    await stop();
  }

  @override
  bool get isHealthy {
    return _isRunning &&
        _averageUpdateTime < 16.67; // Less than one frame at 60 FPS
  }

  @override
  Map<String, dynamic> getDiagnostics() {
    final uptime = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    final actualRate = _updateCount > 0 && uptime.inSeconds > 0
        ? _updateCount / uptime.inSeconds
        : 0.0;

    return {
      'updateRate': '$_updateRate FPS (target)',
      'actualRate': '${actualRate.toStringAsFixed(1)} FPS',
      'audioToVisual': {
        'enabled': _audioReactiveEnabled,
        'modulationsPerSecond': actualRate,
      },
      'visualToAudio': {
        'enabled': _visualReactiveEnabled,
        'modulationsPerSecond': actualRate,
      },
      'averageUpdateTime': '${_averageUpdateTime.toStringAsFixed(2)}ms',
      'totalUpdates': _updateCount,
      'uptime':
          '${uptime.inMinutes}:${(uptime.inSeconds % 60).toString().padLeft(2, '0')}',
      'healthy': isHealthy,
    };
  }

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  /// Set module dependencies (called by ModuleManager after initialization)
  void setDependencies(AudioEngineModule audio, VisualBridgeModule visual) {
    _audioModule = audio;
    _visualModule = visual;

    // Create modulators with the actual provider instances
    _audioToVisual = AudioToVisualModulator(
      audioProvider: audio.provider,
      visualProvider: visual.provider,
    );
    _visualToAudio = VisualToAudioModulator(
      audioProvider: audio.provider,
      visualProvider: visual.provider,
    );
  }

  /// Start the 60 FPS update loop
  void start() {
    if (_isRunning) return;

    SynthLogger.couplingStart();

    _startTime = DateTime.now();
    _updateCount = 0;

    final intervalMs = (1000.0 / _updateRate).round();
    _updateTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      _onUpdate,
    );

    _isRunning = true;

    SynthLogger.couplingEnabled(
      audioToVisual: _audioReactiveEnabled,
      visualToAudio: _visualReactiveEnabled,
    );
  }

  /// Stop the update loop
  Future<void> stop() async {
    if (!_isRunning) return;

    _updateTimer?.cancel();
    _updateTimer = null;
    _isRunning = false;
  }

  // ============================================================================
  // CONFIGURATION (DEBUG ONLY - NOT FOR UI)
  // ============================================================================

  /// Enable/disable audio→visual modulation
  /// ⚠️ DEBUG ONLY - Audio reactivity should ALWAYS be on in production
  void setAudioReactive(bool enabled) {
    if (_audioReactiveEnabled != enabled) {
      _audioReactiveEnabled = enabled;
      SynthLogger.info('Audio→Visual: ${enabled ? "ENABLED" : "disabled"}');
    }
  }

  /// Enable/disable visual→audio modulation
  /// ⚠️ DEBUG ONLY - Visual reactivity should ALWAYS be on in production
  void setVisualReactive(bool enabled) {
    if (_visualReactiveEnabled != enabled) {
      _visualReactiveEnabled = enabled;
      SynthLogger.info('Visual→Audio: ${enabled ? "ENABLED" : "disabled"}');
    }
  }

  /// Set update rate (FPS)
  void setUpdateRate(double fps) {
    if (fps < 1.0 || fps > 120.0) {
      SynthLogger.warning(
          'ParameterCoupling', 'Invalid FPS: $fps (must be 1-120)');
      return;
    }

    _updateRate = fps;

    // Restart timer if running
    if (_isRunning) {
      stop();
      start();
    }
  }

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Check if coupling is active
  bool get isRunning => _isRunning;

  /// Get audio→visual modulator
  AudioToVisualModulator get audioToVisual => _audioToVisual;

  /// Get visual→audio modulator
  VisualToAudioModulator get visualToAudio => _visualToAudio;

  /// Manually trigger a single update (for testing)
  void manualUpdate() {
    _performUpdate();
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  /// Timer callback - executes at 60 FPS
  void _onUpdate(Timer timer) {
    _performUpdate();
  }

  /// Perform one update cycle
  void _performUpdate() {
    final startTime = DateTime.now();

    try {
      // Audio → Visual modulation
      if (_audioReactiveEnabled) {
        final audioBuffer = _audioModule.provider.getCurrentBuffer();
        if (audioBuffer != null && audioBuffer.isNotEmpty) {
          _audioToVisual.updateFromAudio(audioBuffer);
        }
      }

      // Visual → Audio modulation
      if (_visualReactiveEnabled) {
        // Note: getVisualState is async, so we need to handle it differently
        // For now, we'll use cached state from the visual module
        _visualToAudio.updateFromVisuals();
      }

      _updateCount++;

      // Track update duration
      final elapsed =
          DateTime.now().difference(startTime).inMicroseconds / 1000.0;
      _recordUpdateDuration(elapsed);

      // Performance warning if update takes too long
      if (elapsed > 16.67) {
        SynthLogger.performanceWarning(
            'Parameter coupling update took ${elapsed.toStringAsFixed(2)}ms (>16.67ms)');
      }
    } catch (e, stackTrace) {
      SynthLogger.error('ParameterCoupling', 'Update failed: $e');
      if (kDebugMode) {
        debugPrint(stackTrace.toString());
      }
    }
  }

  /// Record update duration for performance tracking
  void _recordUpdateDuration(double durationMs) {
    _updateDurations.add(durationMs);

    // Keep only last 60 samples (1 second)
    if (_updateDurations.length > 60) {
      _updateDurations.removeAt(0);
    }

    _averageUpdateTime =
        _updateDurations.reduce((a, b) => a + b) / _updateDurations.length;
  }
}
