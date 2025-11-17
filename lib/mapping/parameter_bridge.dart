/**
 * VIB34D + Synther Parameter Bridge (Base + Modulation Architecture)
 *
 * Orchestrates bidirectional parameter flow between audio synthesis
 * and 4D visual rendering systems using base + modulation pattern.
 *
 * Architecture:
 * - User/engine sets BASE values for all parameters
 * - Real-time analysis provides ±MODULATION over base values
 * - Final values = base + modulation (sent to audio/visual systems)
 *
 * Audio → Visual: FFT analysis modulates visual parameters
 *   - Bass energy → rotation speed (±1.5x)
 *   - Mid energy → tessellation density (±3 levels)
 *   - High energy → vertex brightness (±0.3)
 *   - Spectral centroid → hue shift (±90°)
 *   - RMS amplitude → glow intensity (±1.5)
 *   - Stereo width → RGB split (±5.0)
 *
 * Visual → Audio: 4D rotation & geometry modulate synthesis
 *   - XW rotation → oscillator 1 detune (±2 semitones)
 *   - YW rotation → oscillator 2 detune (±2 semitones)
 *   - ZW rotation → filter cutoff (±40%)
 *   - Morph parameter → wavetable position (±0.5)
 *   - Projection distance → reverb mix (±30%)
 *   - Layer depth → delay time (±250ms)
 *
 * A Paul Phillips Manifestation
 * Paul@clearseassolutions.com
 */

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'audio_to_visual.dart';
import 'visual_to_audio.dart';
import '../models/mapping_preset.dart';
import '../models/parameter_state.dart';
import '../providers/audio_provider.dart';
import '../providers/visual_provider.dart';

class ParameterBridge with ChangeNotifier {
  // Modulation systems
  late final AudioToVisualModulator audioToVisual;
  late final VisualToAudioModulator visualToAudio;

  // Providers
  final AudioProvider audioProvider;
  final VisualProvider visualProvider;

  // Current mapping configuration
  MappingPreset _currentPreset = MappingPreset.defaultPreset();

  // Update timer (60 FPS)
  Timer? _updateTimer;
  bool _isRunning = false;

  // Performance metrics
  int _frameCount = 0;
  DateTime _lastFPSCheck = DateTime.now();
  double _currentFPS = 0.0;

  ParameterBridge({
    required this.audioProvider,
    required this.visualProvider,
  }) {
    // Initialize modulation systems
    audioToVisual = AudioToVisualModulator(
      audioProvider: audioProvider,
      visualProvider: visualProvider,
    );

    visualToAudio = VisualToAudioModulator(
      audioProvider: audioProvider,
      visualProvider: visualProvider,
    );

    // Connect modulators for cross-parameter feedback (e.g., glow → attack/reverb)
    visualToAudio.setAudioToVisualModulator(audioToVisual);
  }

  // Getters
  MappingPreset get currentPreset => _currentPreset;
  bool get isRunning => _isRunning;
  double get currentFPS => _currentFPS;

  /// Start the parameter bridge update loop
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _lastFPSCheck = DateTime.now();
    _frameCount = 0;

    // 60 FPS update rate
    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60 Hz
      (_) => _update(),
    );

    debugPrint('🌉 ParameterBridge started (60 FPS)');
    debugPrint('   Audio→Visual: ${_currentPreset.audioReactiveEnabled ? "ENABLED" : "disabled"}');
    debugPrint('   Visual→Audio: ${_currentPreset.visualReactiveEnabled ? "ENABLED" : "disabled"}');

    notifyListeners();
  }

  /// Stop the parameter bridge
  void stop() {
    _updateTimer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  /// Main update loop called at 60 FPS
  void _update() {
    try {
      // Audio → Visual modulation (if enabled in preset)
      if (_currentPreset.audioReactiveEnabled) {
        final audioBuffer = audioProvider.getCurrentBuffer();
        if (audioBuffer != null && audioBuffer.isNotEmpty) {
          audioToVisual.updateFromAudio(audioBuffer);
        }
      }

      // Visual → Audio modulation (if enabled in preset)
      if (_currentPreset.visualReactiveEnabled) {
        visualToAudio.updateFromVisuals();
      }

      // Update FPS counter
      _frameCount++;
      final now = DateTime.now();
      final elapsed = now.difference(_lastFPSCheck).inMilliseconds;
      if (elapsed >= 1000) {
        _currentFPS = _frameCount / (elapsed / 1000.0);
        _frameCount = 0;
        _lastFPSCheck = now;
      }
    } catch (e) {
      debugPrint('ParameterBridge update error: $e');
    }
  }

  /// Load a mapping preset
  Future<void> loadPreset(MappingPreset preset) async {
    _currentPreset = preset;

    // Apply preset to both modulation systems
    audioToVisual.applyPreset(preset);
    visualToAudio.applyPreset(preset);

    notifyListeners();
  }

  /// Save current mappings as a new preset
  Future<MappingPreset> saveAsPreset(String name, String description) async {
    final preset = MappingPreset(
      name: name,
      description: description,
      audioReactiveEnabled: _currentPreset.audioReactiveEnabled,
      visualReactiveEnabled: _currentPreset.visualReactiveEnabled,
      audioToVisualMappings: audioToVisual.exportMappings(),
      visualToAudioMappings: visualToAudio.exportMappings(),
    );

    // TODO: Save to local storage and optionally to Firebase
    return preset;
  }

  /// Toggle audio-reactive mode
  void setAudioReactive(bool enabled) {
    _currentPreset = _currentPreset.copyWith(audioReactiveEnabled: enabled);
    notifyListeners();
  }

  /// Toggle visual-reactive mode
  void setVisualReactive(bool enabled) {
    _currentPreset = _currentPreset.copyWith(visualReactiveEnabled: enabled);
    notifyListeners();
  }

  // ============================================================================
  // PARAMETER STATE ACCESS (Base + Modulation Architecture)
  // ============================================================================

  /// Get all Audio→Visual parameter states (for UI display)
  Map<String, ParameterState> getAudioToVisualParameters() {
    return audioToVisual.getAllParameters();
  }

  /// Get all Visual→Audio parameter states (for UI display)
  Map<String, ParameterState> getVisualToAudioParameters() {
    return visualToAudio.getAllParameters();
  }

  /// Get specific parameter state by name (searches both directions)
  ParameterState? getParameter(String name) {
    // Try audio→visual parameters first
    final audioToVisualParams = audioToVisual.getAllParameters();
    if (audioToVisualParams.containsKey(name)) {
      return audioToVisualParams[name];
    }

    // Try visual→audio parameters
    final visualToAudioParams = visualToAudio.getAllParameters();
    if (visualToAudioParams.containsKey(name)) {
      return visualToAudioParams[name];
    }

    return null;
  }

  /// Set base value for an Audio→Visual parameter
  void setAudioToVisualBase(String paramName, double value) {
    audioToVisual.setParameterBase(paramName, value);
    notifyListeners();
  }

  /// Set base value for a Visual→Audio parameter
  void setVisualToAudioBase(String paramName, double value) {
    visualToAudio.setParameterBase(paramName, value);
    notifyListeners();
  }

  /// Enable/disable modulation globally for Audio→Visual
  void setAudioToVisualModulationEnabled(bool enabled) {
    audioToVisual.setModulationEnabled(enabled);
    notifyListeners();
  }

  /// Enable/disable modulation globally for Visual→Audio
  void setVisualToAudioModulationEnabled(bool enabled) {
    visualToAudio.setModulationEnabled(enabled);
    notifyListeners();
  }

  /// Enable/disable ALL modulation (both directions)
  void setAllModulationEnabled(bool enabled) {
    audioToVisual.setModulationEnabled(enabled);
    visualToAudio.setModulationEnabled(enabled);
    notifyListeners();
  }

  /// Get current state of all parameters (for debugging/UI)
  Map<String, dynamic> getParameterSnapshot() {
    return {
      'audioToVisual': audioToVisual.getAllParameters().map(
        (name, param) => MapEntry(name, param.toMap()),
      ),
      'visualToAudio': visualToAudio.getAllParameters().map(
        (name, param) => MapEntry(name, param.toMap()),
      ),
      'audioReactiveEnabled': _currentPreset.audioReactiveEnabled,
      'visualReactiveEnabled': _currentPreset.visualReactiveEnabled,
      'isRunning': _isRunning,
      'currentFPS': _currentFPS,
    };
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
