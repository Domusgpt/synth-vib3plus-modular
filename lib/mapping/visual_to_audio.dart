/**
 * Visual → Audio Modulation System (Base + Modulation Architecture)
 *
 * Maps visual parameter state to audio synthesis parameters using base + modulation:
 * - User/synthesis engine sets BASE values
 * - Visual state provides ±MODULATION over the base
 * - Final value = base + modulation (sent to synthesis engine)
 *
 * Mappings:
 * - XW Rotation → Oscillator 1 Detune (base 0.0, ±2.0 semitones)
 * - YW Rotation → Oscillator 2 Detune (base 0.0, ±2.0 semitones)
 * - ZW Rotation → Filter Cutoff Mod (base 0.0, ±40%)
 * - Morph → Wavetable Position (base 0.5, ±0.5)
 * - Projection Distance → Reverb Mix (base from visual system, ±30%)
 * - Layer Depth → Delay Time (base 250ms, ±250ms)
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../providers/audio_provider.dart';
import '../providers/visual_provider.dart';
import '../models/mapping_preset.dart';
import '../models/parameter_state.dart';
import 'audio_to_visual.dart'; // For ParameterMapping and MappingCurve

class VisualToAudioModulator {
  final AudioProvider audioProvider;
  final VisualProvider visualProvider;

  // Parameter states (base + modulation architecture)
  late final ParameterState osc1DetuneParam;
  late final ParameterState osc2DetuneParam;
  late final ParameterState filterCutoffParam;
  late final ParameterState wavetableParam;
  late final ParameterState reverbMixParam;
  late final ParameterState delayTimeParam;

  // Mapping configuration
  Map<String, ParameterMapping> _mappings = {};

  VisualToAudioModulator({
    required this.audioProvider,
    required this.visualProvider,
  }) {
    _initializeParameterStates();
    _initializeDefaultMappings();
  }

  void _initializeParameterStates() {
    // Oscillator 1 Detune: base 0.0 semitones, ±2.0 semitones modulation
    osc1DetuneParam = ParameterState(
      name: 'osc1Detune',
      initialValue: 0.0,
      minValue: -2.0,
      maxValue: 2.0,
      modulationDepth: 2.0,
    );

    // Oscillator 2 Detune: base 0.0 semitones, ±2.0 semitones modulation
    osc2DetuneParam = ParameterState(
      name: 'osc2Detune',
      initialValue: 0.0,
      minValue: -2.0,
      maxValue: 2.0,
      modulationDepth: 2.0,
    );

    // Filter Cutoff Modulation: base 0.0, ±0.4 (40%) modulation
    filterCutoffParam = ParameterState(
      name: 'filterCutoffMod',
      initialValue: 0.0,
      minValue: 0.0,
      maxValue: 0.8,
      modulationDepth: 0.4,
    );

    // Wavetable Position: base 0.5, ±0.5 modulation
    wavetableParam = ParameterState(
      name: 'wavetablePosition',
      initialValue: 0.5,
      minValue: 0.0,
      maxValue: 1.0,
      modulationDepth: 0.5,
    );

    // Reverb Mix: base 0.3, ±0.3 modulation
    reverbMixParam = ParameterState(
      name: 'reverbMix',
      initialValue: 0.3,
      minValue: 0.0,
      maxValue: 1.0,
      modulationDepth: 0.3,
    );

    // Delay Time: base 250ms, ±250ms modulation
    delayTimeParam = ParameterState(
      name: 'delayTime',
      initialValue: 250.0,
      minValue: 0.0,
      maxValue: 500.0,
      modulationDepth: 250.0,
    );
  }

  void _initializeDefaultMappings() {
    _mappings = {
      'rotationXW_to_osc1Freq': ParameterMapping(
        sourceParam: 'rotationXW',
        targetParam: 'oscillator1Frequency',
        minRange: -2.0, // -2 semitones
        maxRange: 2.0,  // +2 semitones
        curve: MappingCurve.sinusoidal,
      ),
      'rotationYW_to_osc2Freq': ParameterMapping(
        sourceParam: 'rotationYW',
        targetParam: 'oscillator2Frequency',
        minRange: -2.0,
        maxRange: 2.0,
        curve: MappingCurve.sinusoidal,
      ),
      'rotationZW_to_filterCutoff': ParameterMapping(
        sourceParam: 'rotationZW',
        targetParam: 'filterCutoff',
        minRange: 0.0,  // 0% modulation
        maxRange: 0.8,  // 80% modulation (±40%)
        curve: MappingCurve.sinusoidal,
      ),
      'morphParameter_to_wavetable': ParameterMapping(
        sourceParam: 'morphParameter',
        targetParam: 'wavetablePosition',
        minRange: 0.0,
        maxRange: 1.0,
        curve: MappingCurve.linear,
      ),
      'projectionDistance_to_reverb': ParameterMapping(
        sourceParam: 'projectionDistance',
        targetParam: 'reverbMix',
        minRange: 0.0,
        maxRange: 1.0,
        curve: MappingCurve.exponential,
      ),
      'layerDepth_to_delay': ParameterMapping(
        sourceParam: 'layerDepth',
        targetParam: 'delayTime',
        minRange: 0.0,    // 0ms
        maxRange: 500.0,  // 500ms
        curve: MappingCurve.linear,
      ),
    };
  }

  // Debug logging state (only log significant changes to avoid spam)
  double _lastLoggedRotXW = -999.0;
  double _lastLoggedRotYW = -999.0;
  double _lastLoggedRotZW = -999.0;
  int _updateCounter = 0;

  /// Main update function called at 60 FPS (Base + Modulation Architecture)
  void updateFromVisuals() {
    // Extract visual state as normalized values (0-1)
    final rotXW = _normalizeRotation(visualProvider.getRotationAngle('XW'));
    final rotYW = _normalizeRotation(visualProvider.getRotationAngle('YW'));
    final rotZW = _normalizeRotation(visualProvider.getRotationAngle('ZW'));
    final morph = visualProvider.getMorphParameter();
    final projectionDist = _normalizeProjectionDistance(visualProvider.getProjectionDistance());
    final layerDepth = _normalizeLayerDepth(visualProvider.getLayerSeparation());

    // Calculate modulation amounts (centered at 0, range -1 to +1)
    final rotXWMod = (rotXW - 0.5) * 2.0;  // -1 to +1
    final rotYWMod = (rotYW - 0.5) * 2.0;
    final rotZWMod = (rotZW - 0.5) * 2.0;
    final morphMod = (morph - 0.5) * 2.0;
    final projMod = (projectionDist - 0.5) * 2.0;
    final layerMod = (layerDepth - 0.5) * 2.0;

    // Apply modulation to parameter states
    osc1DetuneParam.setModulation(rotXWMod * osc1DetuneParam.modulationDepth);
    osc2DetuneParam.setModulation(rotYWMod * osc2DetuneParam.modulationDepth);
    filterCutoffParam.setModulation(rotZWMod * filterCutoffParam.modulationDepth);
    wavetableParam.setModulation(morphMod * wavetableParam.modulationDepth);
    reverbMixParam.setModulation(projMod * reverbMixParam.modulationDepth);
    delayTimeParam.setModulation(layerMod * delayTimeParam.modulationDepth);

    // Update audio provider with FINAL values (base + modulation)
    audioProvider.synthesizerEngine.modulateOscillator1Frequency(osc1DetuneParam.finalValue);
    audioProvider.synthesizerEngine.modulateOscillator2Frequency(osc2DetuneParam.finalValue);
    audioProvider.synthesizerEngine.modulateFilterCutoff(filterCutoffParam.finalValue);
    audioProvider.synthesizerEngine.setWavetablePosition(wavetableParam.finalValue);
    audioProvider.synthesizerEngine.setReverbMix(reverbMixParam.finalValue);
    audioProvider.synthesizerEngine.setDelayTime(delayTimeParam.finalValue);

    // Special case: vertex count to voice count (discrete mapping)
    final vertexCount = visualProvider.getActiveVertexCount();
    final voiceCount = _mapVertexCountToVoices(vertexCount);
    audioProvider.setVoiceCount(voiceCount);

    // Sync geometry to synthesis branch manager
    _syncGeometryToAudio();

    // Sync visual system to sound family
    _syncVisualSystemToAudio();

    // Debug logging: Log every 60 frames (1 second) OR when significant change
    _updateCounter++;
    if (_updateCounter >= 60 || _hasSignificantChange(rotXW, rotYW, rotZW)) {
      _logModulationState(rotXW, rotYW, rotZW, morph);
      _updateCounter = 0;
    }
  }

  /// Check if visual parameters changed significantly (>5%)
  bool _hasSignificantChange(double rotXW, double rotYW, double rotZW) {
    return (rotXW - _lastLoggedRotXW).abs() > 0.05 ||
           (rotYW - _lastLoggedRotYW).abs() > 0.05 ||
           (rotZW - _lastLoggedRotZW).abs() > 0.05;
  }

  /// Log current modulation state for debugging (shows BASE + MODULATION)
  void _logModulationState(double rotXW, double rotYW, double rotZW, double morph) {
    debugPrint('🔊 Visual→Audio [Base+Mod]: '
      'rotXW=${rotXW.toStringAsFixed(2)}→osc1=${osc1DetuneParam.baseValue.toStringAsFixed(1)}+${osc1DetuneParam.currentModulation.toStringAsFixed(2)}=${osc1DetuneParam.finalValue.toStringAsFixed(2)}st | '
      'rotYW=${rotYW.toStringAsFixed(2)}→osc2=${osc2DetuneParam.baseValue.toStringAsFixed(1)}+${osc2DetuneParam.currentModulation.toStringAsFixed(2)}=${osc2DetuneParam.finalValue.toStringAsFixed(2)}st | '
      'rotZW=${rotZW.toStringAsFixed(2)}→filter=${filterCutoffParam.baseValue.toStringAsFixed(2)}+${filterCutoffParam.currentModulation.toStringAsFixed(2)}=${filterCutoffParam.finalValue.toStringAsFixed(2)} | '
      'morph=${morph.toStringAsFixed(2)}→wave=${wavetableParam.baseValue.toStringAsFixed(2)}+${wavetableParam.currentModulation.toStringAsFixed(2)}=${wavetableParam.finalValue.toStringAsFixed(2)}');

    _lastLoggedRotXW = rotXW;
    _lastLoggedRotYW = rotYW;
    _lastLoggedRotZW = rotZW;
  }

  /// Sync geometry changes to audio provider
  void _syncGeometryToAudio() {
    final geometry = visualProvider.currentGeometry;
    // Visual provider uses 0-7, but synthesis manager uses 0-23
    // Need to calculate full geometry index from system + geometry
    final systemOffset = _getSystemOffset(visualProvider.currentSystem);
    final fullGeometry = systemOffset + geometry;
    audioProvider.setGeometry(fullGeometry);
  }

  /// Get geometry offset based on current visual system
  int _getSystemOffset(String system) {
    // Each system has 8 base geometries (0-7)
    // But they map to different polytope cores in the synthesis manager:
    // - Quantum system → geometries 0-7 (Base core)
    // - Faceted system → geometries 8-15 (Hypersphere core)
    // - Holographic system → geometries 16-23 (Hypertetrahedron core)
    switch (system.toLowerCase()) {
      case 'quantum':
        return 0;  // Base core (Direct synthesis)
      case 'faceted':
        return 8;  // Hypersphere core (FM synthesis)
      case 'holographic':
        return 16; // Hypertetrahedron core (Ring modulation)
      default:
        return 0;
    }
  }

  /// Sync visual system to audio sound family
  void _syncVisualSystemToAudio() {
    final system = visualProvider.currentSystem;
    audioProvider.setVisualSystem(system);
  }

  // ============================================================================
  // PUBLIC API FOR UI ACCESS
  // ============================================================================

  /// Get all parameter states (for UI display)
  Map<String, ParameterState> getAllParameters() {
    return {
      'osc1Detune': osc1DetuneParam,
      'osc2Detune': osc2DetuneParam,
      'filterCutoffMod': filterCutoffParam,
      'wavetablePosition': wavetableParam,
      'reverbMix': reverbMixParam,
      'delayTime': delayTimeParam,
    };
  }

  /// Set base value for a parameter (from UI slider or synthesis engine)
  void setParameterBase(String paramName, double value) {
    switch (paramName) {
      case 'osc1Detune':
        osc1DetuneParam.setBaseValue(value);
        break;
      case 'osc2Detune':
        osc2DetuneParam.setBaseValue(value);
        break;
      case 'filterCutoffMod':
        filterCutoffParam.setBaseValue(value);
        break;
      case 'wavetablePosition':
        wavetableParam.setBaseValue(value);
        break;
      case 'reverbMix':
        reverbMixParam.setBaseValue(value);
        break;
      case 'delayTime':
        delayTimeParam.setBaseValue(value);
        break;
    }
  }

  /// Enable/disable modulation globally
  void setModulationEnabled(bool enabled) {
    osc1DetuneParam.setModulationEnabled(enabled);
    osc2DetuneParam.setModulationEnabled(enabled);
    filterCutoffParam.setModulationEnabled(enabled);
    wavetableParam.setModulationEnabled(enabled);
    reverbMixParam.setModulationEnabled(enabled);
    delayTimeParam.setModulationEnabled(enabled);
  }

  /// Normalize rotation angle (0-2π) to (0-1)
  double _normalizeRotation(double angle) {
    return (angle % (2.0 * math.pi)) / (2.0 * math.pi);
  }

  /// Normalize projection distance (5-15) to (0-1)
  double _normalizeProjectionDistance(double distance) {
    return ((distance - 5.0) / 10.0).clamp(0.0, 1.0);
  }

  /// Normalize layer depth (0-5) to (0-1)
  double _normalizeLayerDepth(double depth) {
    return (depth / 5.0).clamp(0.0, 1.0);
  }

  /// Map vertex count to voice count (logarithmic scaling)
  int _mapVertexCountToVoices(int vertexCount) {
    // Map 10-10000 vertices to 1-16 voices logarithmically
    if (vertexCount < 10) return 1;
    if (vertexCount > 10000) return 16;

    final normalized = (math.log(vertexCount) - math.log(10)) /
                       (math.log(10000) - math.log(10));

    return (1 + normalized * 15).round().clamp(1, 16);
  }

  void applyPreset(MappingPreset preset) {
    _mappings = preset.visualToAudioMappings;
  }

  Map<String, ParameterMapping> exportMappings() {
    return Map.from(_mappings);
  }

  /// Advanced mapping: Use rotation velocity for dynamic modulation
  void enableVelocityModulation(bool enabled) {
    if (enabled) {
      // Track rotation velocity and map to filter resonance
      final velocity = visualProvider.getRotationVelocity();
      final resonance = (velocity * 0.5).clamp(0.0, 0.9);
      audioProvider.synthesizerEngine.filter.resonance = resonance;
    }
  }

  /// Advanced mapping: Use geometry complexity for harmonic richness
  void enableComplexityHarmonics(bool enabled) {
    if (enabled) {
      final complexity = visualProvider.getGeometryComplexity();
      // Higher complexity = more oscillator mixing
      final mixBalance = complexity.clamp(0.0, 1.0);
      audioProvider.synthesizerEngine.mixBalance = mixBalance;
    }
  }

  /// Get current modulation state for debugging/UI display
  Map<String, dynamic> getModulationState() {
    return {
      'rotationXW': visualProvider.getRotationAngle('XW'),
      'rotationYW': visualProvider.getRotationAngle('YW'),
      'rotationZW': visualProvider.getRotationAngle('ZW'),
      'morphParameter': visualProvider.getMorphParameter(),
      'projectionDistance': visualProvider.getProjectionDistance(),
      'layerDepth': visualProvider.getLayerSeparation(),
      'vertexCount': visualProvider.getActiveVertexCount(),
      'voiceCount': audioProvider.getVoiceCount(),
      'osc1FreqMod': audioProvider.synthesizerEngine.oscillator1.frequencyModulation,
      'osc2FreqMod': audioProvider.synthesizerEngine.oscillator2.frequencyModulation,
      'filterCutoffMod': audioProvider.synthesizerEngine.filter.cutoffModulation,
    };
  }
}
