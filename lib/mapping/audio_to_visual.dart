///
/// Audio → Visual Modulation System
///
/// Maps real-time audio analysis to visual parameters:
/// - Bass Energy (20-250 Hz) → 4D Rotation Speed
/// - Mid Energy (250-2000 Hz) → Tessellation Density
/// - High Energy (2000-8000 Hz) → Vertex Brightness
/// - Spectral Centroid → Hue Shift
/// - RMS Amplitude → Glow Intensity
/// - Stereo Width → RGB Split Amount
///
/// A Paul Phillips Manifestation
////

import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import '../providers/audio_provider.dart';
import '../providers/visual_provider.dart';
import '../models/mapping_preset.dart';
import '../audio/audio_analyzer.dart';

class AudioToVisualModulator {
  final AudioProvider audioProvider;
  final VisualProvider visualProvider;

  // Audio analyzer
  final AudioAnalyzer analyzer = AudioAnalyzer();

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
    _initializeDefaultMappings();
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

  /// Main update function called at 60 FPS
  void updateFromAudio(Float32List audioBuffer) {
    // Perform FFT analysis
    final fftData = analyzer.computeFFT(audioBuffer);

    // Extract audio features
    final features = {
      'bassEnergy': analyzer.getBandEnergy(fftData, 20.0, 250.0),
      'midEnergy': analyzer.getBandEnergy(fftData, 250.0, 2000.0),
      'highEnergy': analyzer.getBandEnergy(fftData, 2000.0, 8000.0),
      'spectralCentroid': analyzer.computeSpectralCentroid(fftData),
      'rms': analyzer.computeRMS(audioBuffer),
      'stereoWidth': 0.5, // Placeholder - requires stereo buffer
    };

    // Apply each mapping
    _mappings.forEach((key, mapping) {
      final sourceValue = features[mapping.sourceParam] ?? 0.0;
      final mappedValue = mapping.map(sourceValue);

      // Update corresponding visual parameter
      _updateVisualParameter(mapping.targetParam, mappedValue);
    });

    // Debug logging: Log every 60 frames (1 second) OR when significant change
    _updateCounter++;
    if (_updateCounter >= 60 || _hasSignificantChange(features)) {
      _logModulationState(features);
      _updateCounter = 0;
    }
  }

  /// Check if audio features changed significantly (>10% energy change)
  bool _hasSignificantChange(Map<String, double> features) {
    final bass = features['bassEnergy'] ?? 0.0;
    final mid = features['midEnergy'] ?? 0.0;
    final high = features['highEnergy'] ?? 0.0;

    return (bass - _lastLoggedBass).abs() > 0.1 ||
        (mid - _lastLoggedMid).abs() > 0.1 ||
        (high - _lastLoggedHigh).abs() > 0.1;
  }

  /// Log current modulation state for debugging
  void _logModulationState(Map<String, double> features) {
    final bass = features['bassEnergy'] ?? 0.0;
    final mid = features['midEnergy'] ?? 0.0;
    final high = features['highEnergy'] ?? 0.0;
    final centroid = features['spectralCentroid'] ?? 0.0;
    final rms = features['rms'] ?? 0.0;

    // Get mapped visual values
    final rotSpeed = _mappings['bassEnergy_to_rotationSpeed']?.map(bass) ?? 0.0;
    final tessellation =
        _mappings['midEnergy_to_tessellationDensity']?.map(mid) ?? 0.0;
    final brightness =
        _mappings['highEnergy_to_vertexBrightness']?.map(high) ?? 0.0;
    final hue = _mappings['spectralCentroid_to_hueShift']?.map(centroid) ?? 0.0;
    final glow = _mappings['rms_to_glowIntensity']?.map(rms) ?? 0.0;

    debugPrint('🎨 Audio→Visual: '
        'bass=${(bass * 100).toStringAsFixed(0)}%→speed=${rotSpeed.toStringAsFixed(2)}x | '
        'mid=${(mid * 100).toStringAsFixed(0)}%→tess=${tessellation.toStringAsFixed(0)} | '
        'high=${(high * 100).toStringAsFixed(0)}%→bright=${brightness.toStringAsFixed(2)} | '
        'centroid=${centroid.toStringAsFixed(0)}Hz→hue=${hue.toStringAsFixed(0)}° | '
        'rms=${(rms * 100).toStringAsFixed(0)}%→glow=${glow.toStringAsFixed(2)}');

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
