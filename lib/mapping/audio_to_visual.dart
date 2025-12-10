/**
 * Audio → Visual Modulation System (Base + Modulation Architecture)
 *
 * Maps real-time audio analysis to visual parameters using base + modulation:
 * - User sliders set BASE values
 * - Audio analysis provides ±MODULATION over the base
 * - Final value = base + modulation (clamped to valid range)
 *
 * Mappings:
 * - Bass Energy (20-250 Hz) → Rotation Speed (base ± 1.5x)
 * - Mid Energy (250-2000 Hz) → Tessellation Density (base ± 3 levels)
 * - High Energy (2000-8000 Hz) → Vertex Brightness (base ± 0.3)
 * - Spectral Centroid → Hue Shift (base ± 90°)
 * - RMS Amplitude → Glow Intensity (base ± 1.5)
 * - Stereo Width → RGB Split Amount (base ± 5.0)
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import '../providers/audio_provider.dart';
import '../providers/visual_provider.dart';
import '../models/mapping_preset.dart';
import '../models/parameter_state.dart';
import '../audio/audio_analyzer.dart';

class AudioToVisualModulator {
  final AudioProvider audioProvider;
  final VisualProvider visualProvider;

  // Audio analyzer
  final AudioAnalyzer analyzer = AudioAnalyzer();

  // Parameter states (base + modulation architecture)
  late final ParameterState rotationSpeedParam;
  late final IntParameterState tessellationParam;
  late final ParameterState brightnessParam;
  late final ParameterState hueShiftParam;
  late final ParameterState glowIntensityParam;
  late final ParameterState rgbSplitParam;

  // Mapping configuration
  Map<String, ParameterMapping> _mappings = {};

  // Debug logging state (only log significant changes)
  double _lastLoggedBass = -999.0;
  double _lastLoggedMid = -999.0;
  double _lastLoggedHigh = -999.0;
  int _updateCounter = 0;

  AudioToVisualModulator({
    required this.audioProvider,
    required this.visualProvider,
  }) {
    _initializeParameterStates();
    _initializeDefaultMappings();
  }

  void _initializeParameterStates() {
    // Rotation Speed: base 1.0x, ±1.5x modulation
    rotationSpeedParam = ParameterState(
      name: 'rotationSpeed',
      initialValue: 1.0,
      minValue: 0.1,
      maxValue: 5.0,
      modulationDepth: 1.5,
    );

    // Tessellation: base 5, ±3 modulation
    tessellationParam = IntParameterState(
      name: 'tessellationDensity',
      initialValue: 5,
      minValue: 3,
      maxValue: 10,
      modulationDepth: 3,
    );

    // Brightness: base 0.7, ±0.3 modulation
    brightnessParam = ParameterState(
      name: 'vertexBrightness',
      initialValue: 0.7,
      minValue: 0.0,
      maxValue: 1.0,
      modulationDepth: 0.3,
    );

    // Hue Shift: base 180°, ±90° modulation
    hueShiftParam = ParameterState(
      name: 'hueShift',
      initialValue: 180.0,
      minValue: 0.0,
      maxValue: 360.0,
      modulationDepth: 90.0,
    );

    // Glow Intensity: base 1.0, ±1.5 modulation
    glowIntensityParam = ParameterState(
      name: 'glowIntensity',
      initialValue: 1.0,
      minValue: 0.0,
      maxValue: 3.0,
      modulationDepth: 1.5,
    );

    // RGB Split: base 0.0, ±5.0 modulation
    rgbSplitParam = ParameterState(
      name: 'rgbSplitAmount',
      initialValue: 0.0,
      minValue: 0.0,
      maxValue: 10.0,
      modulationDepth: 5.0,
    );
  }

  void _initializeDefaultMappings() {
    _mappings = {
      'bassEnergy_to_rotationSpeed': ParameterMapping(
        sourceParam: 'bassEnergy',
        targetParam: 'rotationSpeed',
        minRange: 0.5,
        maxRange: 2.5,
        curve: MappingCurve.linear,
      ),
      'midEnergy_to_tessellationDensity': ParameterMapping(
        sourceParam: 'midEnergy',
        targetParam: 'tessellationDensity',
        minRange: 3.0,
        maxRange: 8.0,
        curve: MappingCurve.exponential,
      ),
      'highEnergy_to_vertexBrightness': ParameterMapping(
        sourceParam: 'highEnergy',
        targetParam: 'vertexBrightness',
        minRange: 0.5,
        maxRange: 1.0,
        curve: MappingCurve.linear,
      ),
      'spectralCentroid_to_hueShift': ParameterMapping(
        sourceParam: 'spectralCentroid',
        targetParam: 'hueShift',
        minRange: 0.0,
        maxRange: 360.0,
        curve: MappingCurve.linear,
      ),
      'rms_to_glowIntensity': ParameterMapping(
        sourceParam: 'rms',
        targetParam: 'glowIntensity',
        minRange: 0.0,
        maxRange: 3.0,
        curve: MappingCurve.exponential,
      ),
    };
  }

  /// Main update function called at 60 FPS (Base + Modulation Architecture)
  void updateFromAudio(Float32List audioBuffer) {
    // Perform FFT analysis
    final fftData = analyzer.computeFFT(audioBuffer);

    // Extract audio features (normalized to 0-1)
    final bassEnergy = analyzer.getBandEnergy(fftData, 20.0, 250.0);
    final midEnergy = analyzer.getBandEnergy(fftData, 250.0, 2000.0);
    final highEnergy = analyzer.getBandEnergy(fftData, 2000.0, 8000.0);
    final spectralCentroid = analyzer.computeSpectralCentroid(fftData);
    final rms = analyzer.computeRMS(audioBuffer);

    // Pseudo-stereo-width from spectral spread (until true stereo is implemented)
    // Higher spectral spread = wider perceived soundstage
    final stereoWidth = _computePseudoStereoWidth(fftData);

    // Calculate modulation amounts (centered at 0, range -1 to +1)
    final bassModulation = (bassEnergy - 0.5) * 2.0;  // -1 to +1
    final midModulation = (midEnergy - 0.5) * 2.0;
    final highModulation = (highEnergy - 0.5) * 2.0;
    final centroidModulation = (spectralCentroid / 4000.0 - 0.5) * 2.0;  // Normalize 0-8000Hz
    final rmsModulation = (rms - 0.5) * 2.0;
    final widthModulation = (stereoWidth - 0.5) * 2.0;

    // Apply modulation to parameter states
    rotationSpeedParam.setModulation(bassModulation * rotationSpeedParam.modulationDepth);
    tessellationParam.setModulation((midModulation * tessellationParam.modulationDepth).roundToDouble());
    brightnessParam.setModulation(highModulation * brightnessParam.modulationDepth);
    hueShiftParam.setModulation(centroidModulation * hueShiftParam.modulationDepth);
    glowIntensityParam.setModulation(rmsModulation * glowIntensityParam.modulationDepth);
    rgbSplitParam.setModulation(widthModulation * rgbSplitParam.modulationDepth);

    // Update visual provider with FINAL values (base + modulation)
    // Use batch update to reduce 360 async calls/sec to 60 calls/sec (6 params × 60 FPS)
    await visualProvider.updateVisualParametersBatch(
      rotationSpeed: rotationSpeedParam.finalValue,
      tessellationDensity: tessellationParam.finalValueInt,
      vertexBrightness: brightnessParam.finalValue,
      hueShift: hueShiftParam.finalValue,
      glowIntensity: glowIntensityParam.finalValue,
      rgbSplit: rgbSplitParam.finalValue,
    );

    // Debug logging: Log every 60 frames (1 second) OR when significant change
    _updateCounter++;
    if (_updateCounter >= 60 || _hasSignificantChange(bassEnergy, midEnergy, highEnergy)) {
      _logModulationState(bassEnergy, midEnergy, highEnergy, spectralCentroid, rms);
      _updateCounter = 0;
    }
  }

  // ============================================================================
  // PUBLIC API FOR UI ACCESS
  // ============================================================================

  /// Get all parameter states (for UI display)
  Map<String, ParameterState> getAllParameters() {
    return {
      'rotationSpeed': rotationSpeedParam,
      'tessellationDensity': tessellationParam,
      'vertexBrightness': brightnessParam,
      'hueShift': hueShiftParam,
      'glowIntensity': glowIntensityParam,
      'rgbSplitAmount': rgbSplitParam,
    };
  }

  /// Set base value for a parameter (from UI slider)
  void setParameterBase(String paramName, double value) {
    switch (paramName) {
      case 'rotationSpeed':
        rotationSpeedParam.setBaseValue(value);
        break;
      case 'tessellationDensity':
        tessellationParam.setBaseValue(value);
        break;
      case 'vertexBrightness':
        brightnessParam.setBaseValue(value);
        break;
      case 'hueShift':
        hueShiftParam.setBaseValue(value);
        break;
      case 'glowIntensity':
        glowIntensityParam.setBaseValue(value);
        break;
      case 'rgbSplitAmount':
        rgbSplitParam.setBaseValue(value);
        break;
    }
  }

  /// Enable/disable modulation globally
  void setModulationEnabled(bool enabled) {
    rotationSpeedParam.setModulationEnabled(enabled);
    tessellationParam.setModulationEnabled(enabled);
    brightnessParam.setModulationEnabled(enabled);
    hueShiftParam.setModulationEnabled(enabled);
    glowIntensityParam.setModulationEnabled(enabled);
    rgbSplitParam.setModulationEnabled(enabled);
  }

  /// Compute pseudo-stereo-width from spectral spread
  /// Until true stereo audio is implemented, estimate width from frequency distribution
  /// Higher spectral variance = wider perceived soundstage
  double _computePseudoStereoWidth(Float64List magnitudes) {
    // Calculate spectral centroid (mean frequency)
    double weightedSum = 0.0;
    double sum = 0.0;
    for (int i = 0; i < magnitudes.length; i++) {
      weightedSum += magnitudes[i] * i;
      sum += magnitudes[i];
    }
    final centroid = sum > 0.0 ? weightedSum / sum : 0.0;

    // Calculate spectral spread (variance)
    double variance = 0.0;
    for (int i = 0; i < magnitudes.length; i++) {
      final diff = i - centroid;
      variance += magnitudes[i] * diff * diff;
    }
    final spread = sum > 0.0 ? math.sqrt(variance / sum) : 0.0;

    // Normalize to 0-1 range (empirically tuned)
    final normalized = (spread / 512.0).clamp(0.0, 1.0);
    return normalized;
  }

  /// Check if audio features changed significantly (>10% energy change)
  bool _hasSignificantChange(double bass, double mid, double high) {
    return (bass - _lastLoggedBass).abs() > 0.1 ||
           (mid - _lastLoggedMid).abs() > 0.1 ||
           (high - _lastLoggedHigh).abs() > 0.1;
  }

  /// Log current modulation state for debugging (shows BASE + MODULATION)
  void _logModulationState(double bass, double mid, double high, double centroid, double rms) {
    debugPrint('🎨 Audio→Visual [Base+Mod]: '
      'bass=${(bass * 100).toStringAsFixed(0)}%→speed=${rotationSpeedParam.baseValue.toStringAsFixed(1)}+${rotationSpeedParam.currentModulation.toStringAsFixed(2)}=${rotationSpeedParam.finalValue.toStringAsFixed(2)}x | '
      'mid=${(mid * 100).toStringAsFixed(0)}%→tess=${tessellationParam.baseValueInt}+${tessellationParam.currentModulation.toStringAsFixed(1)}=${tessellationParam.finalValueInt} | '
      'high=${(high * 100).toStringAsFixed(0)}%→bright=${brightnessParam.baseValue.toStringAsFixed(2)}+${brightnessParam.currentModulation.toStringAsFixed(2)}=${brightnessParam.finalValue.toStringAsFixed(2)}');

    _lastLoggedBass = bass;
    _lastLoggedMid = mid;
    _lastLoggedHigh = high;
  }

  void _updateVisualParameter(String paramName, double value) {
    switch (paramName) {
      case 'rotationSpeed':
        visualProvider.setRotationSpeed(value);
        break;
      case 'tessellationDensity':
        visualProvider.setTessellationDensity(value.round());
        break;
      case 'vertexBrightness':
        visualProvider.setVertexBrightness(value);
        break;
      case 'hueShift':
        visualProvider.setHueShift(value);
        break;
      case 'glowIntensity':
        visualProvider.setGlowIntensity(value);
        break;
      case 'rgbSplitAmount':
        visualProvider.setRGBSplitAmount(value);
        break;
    }
  }

  void applyPreset(MappingPreset preset) {
    _mappings = preset.audioToVisualMappings;
  }

  Map<String, ParameterMapping> exportMappings() {
    return Map.from(_mappings);
  }
}

/// Parameter mapping configuration
class ParameterMapping {
  final String sourceParam;
  final String targetParam;
  final double minRange;
  final double maxRange;
  final MappingCurve curve;

  ParameterMapping({
    required this.sourceParam,
    required this.targetParam,
    required this.minRange,
    required this.maxRange,
    required this.curve,
  });

  /// Map source value (0-1) to target range using specified curve
  double map(double sourceValue) {
    // Clamp input to 0-1
    final normalized = sourceValue.clamp(0.0, 1.0);

    // Apply curve
    double curved;
    switch (curve) {
      case MappingCurve.linear:
        curved = normalized;
        break;
      case MappingCurve.exponential:
        curved = math.pow(normalized, 2.0).toDouble();
        break;
      case MappingCurve.logarithmic:
        curved = math.log(1.0 + normalized * (math.e - 1.0)) / math.log(math.e);
        break;
      case MappingCurve.sinusoidal:
        curved = (math.sin(normalized * math.pi - math.pi / 2) + 1.0) / 2.0;
        break;
    }

    // Scale to target range
    return minRange + (curved * (maxRange - minRange));
  }
}

enum MappingCurve {
  linear,
  exponential,
  logarithmic,
  sinusoidal,
}
