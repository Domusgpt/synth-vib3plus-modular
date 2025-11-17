///
/// Parameter Registry System
///
/// Centralized parameter definitions with metadata for:
/// - Validation and range clamping
/// - Alias support for backward compatibility
/// - Visualizer target mapping
/// - Automatic parameter discovery
///
/// Adopted from synther-refactored architecture
/// A Paul Phillips Manifestation
///

library;

import 'dart:math' as math;

/// Parameter value range with curve metadata
class ParameterRange {
  final double min;
  final double max;
  final double defaultValue;
  final CurveType curve;

  const ParameterRange({
    required this.min,
    required this.max,
    required this.defaultValue,
    this.curve = CurveType.linear,
  });

  /// Clamp value to range
  double clamp(double value) => value.clamp(min, max);

  /// Normalize value to 0-1
  double normalize(double value) {
    final clamped = clamp(value);
    return (clamped - min) / (max - min);
  }

  /// Denormalize from 0-1 to range
  double denormalize(double normalized) {
    return min + (normalized.clamp(0.0, 1.0) * (max - min));
  }

  /// Apply curve to normalized value
  double applyCurve(double normalized) {
    switch (curve) {
      case CurveType.linear:
        return normalized;
      case CurveType.exponential:
        return math.pow(normalized, 2.0).toDouble();
      case CurveType.logarithmic:
        return math.sqrt(normalized);
    }
  }
}

/// Curve types for parameter scaling
enum CurveType {
  linear,
  exponential,
  logarithmic,
}

/// Parameter descriptor with full metadata
class ParameterDescriptor {
  final String name;
  final ParameterRange range;
  final String visualizerTarget;
  final List<String> aliases;
  final List<String> extractionHints;
  final String category;
  final String description;

  const ParameterDescriptor({
    required this.name,
    required this.range,
    required this.visualizerTarget,
    this.aliases = const [],
    this.extractionHints = const [],
    this.category = 'general',
    this.description = '',
  });

  /// Check if key matches this parameter (name or alias)
  bool matches(String key) {
    final normalized = key.trim().toLowerCase();
    if (name.toLowerCase() == normalized) return true;
    return aliases.any((alias) => alias.toLowerCase() == normalized);
  }
}

/// Central parameter registry
class ParameterRegistry {
  static final Map<String, ParameterDescriptor> _descriptors = {};
  static const double epsilon = 1e-6;

  /// Register a parameter
  static void register(ParameterDescriptor descriptor) {
    _descriptors[descriptor.name.toLowerCase()] = descriptor;
  }

  /// Register multiple parameters
  static void registerAll(List<ParameterDescriptor> descriptors) {
    for (final descriptor in descriptors) {
      register(descriptor);
    }
  }

  /// Get canonical parameter name from any alias
  static String? canonicalName(String key) {
    final normalized = key.trim().toLowerCase();

    // Direct match
    if (_descriptors.containsKey(normalized)) {
      return normalized;
    }

    // Check aliases
    for (final entry in _descriptors.entries) {
      if (entry.value.matches(key)) {
        return entry.key;
      }
    }

    return null;
  }

  /// Get parameter descriptor
  static ParameterDescriptor? descriptorFor(String key) {
    final canonical = canonicalName(key);
    return canonical != null ? _descriptors[canonical] : null;
  }

  /// Clamp value to parameter range
  static double clamp(String paramName, double value) {
    final descriptor = descriptorFor(paramName);
    return descriptor?.range.clamp(value) ?? value;
  }

  /// Canonicalize parameter map (resolve aliases and clamp values)
  static Map<String, double> canonicalize(Map<String, dynamic> values) {
    final result = <String, double>{};

    for (final entry in values.entries) {
      final canonical = canonicalName(entry.key);
      if (canonical == null) continue;

      final descriptor = _descriptors[canonical]!;
      double value;

      // Type coercion
      if (entry.value is bool) {
        value = entry.value ? 1.0 : 0.0;
      } else if (entry.value is int) {
        value = entry.value.toDouble();
      } else if (entry.value is double) {
        value = entry.value;
      } else if (entry.value is String) {
        value = double.tryParse(entry.value) ?? descriptor.range.defaultValue;
      } else {
        value = descriptor.range.defaultValue;
      }

      result[canonical] = descriptor.range.clamp(value);
    }

    return result;
  }

  /// Expand canonical parameters with aliases for downstream consumers
  static Map<String, double> expandWithAliases(Map<String, double> canonical) {
    final result = <String, double>{};

    for (final entry in canonical.entries) {
      final descriptor = _descriptors[entry.key];
      if (descriptor == null) continue;

      // Add canonical name
      result[descriptor.name] = entry.value;

      // Add all aliases
      for (final alias in descriptor.aliases) {
        result[alias] = entry.value;
      }
    }

    return result;
  }

  /// Compare two values with epsilon tolerance
  static bool valuesEqual(double a, double b) {
    return (a - b).abs() < epsilon;
  }

  /// Get all parameters in category
  static List<ParameterDescriptor> getCategory(String category) {
    return _descriptors.values
        .where((desc) => desc.category == category)
        .toList();
  }

  /// Get all registered parameter names
  static List<String> getAllNames() {
    return _descriptors.keys.toList();
  }

  /// Clear all registrations (for testing)
  static void clear() {
    _descriptors.clear();
  }
}

/// Initialize default parameter registry for Synth-VIB3+
void initializeDefaultParameterRegistry() {
  ParameterRegistry.clear();

  ParameterRegistry.registerAll([
    // === VISUAL SYSTEM PARAMETERS ===

    ParameterDescriptor(
      name: 'rotationSpeed',
      range: ParameterRange(min: 0.1, max: 5.0, defaultValue: 1.0),
      visualizerTarget: 'rotationSpeed',
      aliases: ['rotation_speed', 'rot-speed', 'speed'],
      category: 'visual',
      description: 'Base rotation speed multiplier',
    ),

    ParameterDescriptor(
      name: 'tessellationDensity',
      range: ParameterRange(min: 3.0, max: 10.0, defaultValue: 5.0),
      visualizerTarget: 'tessellationDensity',
      aliases: ['tessellation', 'density', 'subdivisions'],
      category: 'visual',
      description: 'Geometry subdivision level',
    ),

    ParameterDescriptor(
      name: 'vertexBrightness',
      range: ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.8),
      visualizerTarget: 'vertexBrightness',
      aliases: ['brightness', 'vertex_brightness'],
      category: 'visual',
      description: 'Vertex intensity',
    ),

    ParameterDescriptor(
      name: 'hueShift',
      range: ParameterRange(min: 0.0, max: 360.0, defaultValue: 180.0),
      visualizerTarget: 'hueShift',
      aliases: ['hue', 'color_shift', 'hue-shift'],
      category: 'visual',
      description: 'Color hue offset in degrees',
    ),

    ParameterDescriptor(
      name: 'glowIntensity',
      range: ParameterRange(min: 0.0, max: 3.0, defaultValue: 1.0),
      visualizerTarget: 'glowIntensity',
      aliases: ['glow', 'bloom', 'glow_intensity'],
      category: 'visual',
      description: 'Bloom/glow amount',
    ),

    ParameterDescriptor(
      name: 'morphParameter',
      range: ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.0),
      visualizerTarget: 'morph',
      aliases: ['morph', 'geometry_morph'],
      category: 'visual',
      description: 'Geometry morph amount',
    ),

    // === 4D ROTATION PARAMETERS ===

    ParameterDescriptor(
      name: 'rotationXW',
      range: ParameterRange(min: 0.0, max: 6.28318, defaultValue: 0.0),
      visualizerTarget: 'rot4dXW',
      aliases: ['xw_rotation', 'rot_xw'],
      category: 'rotation',
      description: '4D rotation in XW plane',
    ),

    ParameterDescriptor(
      name: 'rotationYW',
      range: ParameterRange(min: 0.0, max: 6.28318, defaultValue: 0.0),
      visualizerTarget: 'rot4dYW',
      aliases: ['yw_rotation', 'rot_yw'],
      category: 'rotation',
      description: '4D rotation in YW plane',
    ),

    ParameterDescriptor(
      name: 'rotationZW',
      range: ParameterRange(min: 0.0, max: 6.28318, defaultValue: 0.0),
      visualizerTarget: 'rot4dZW',
      aliases: ['zw_rotation', 'rot_zw'],
      category: 'rotation',
      description: '4D rotation in ZW plane',
    ),

    // === AUDIO SYNTHESIS PARAMETERS ===

    ParameterDescriptor(
      name: 'masterVolume',
      range: ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.7),
      visualizerTarget: '',
      aliases: ['volume', 'master', 'gain'],
      category: 'audio',
      description: 'Master output volume',
    ),

    ParameterDescriptor(
      name: 'filterCutoff',
      range: ParameterRange(
          min: 20.0,
          max: 20000.0,
          defaultValue: 1000.0,
          curve: CurveType.exponential),
      visualizerTarget: '',
      aliases: ['cutoff', 'filter_cutoff', 'lpf_freq'],
      category: 'audio',
      description: 'Filter cutoff frequency in Hz',
    ),

    ParameterDescriptor(
      name: 'filterResonance',
      range: ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.7),
      visualizerTarget: '',
      aliases: ['resonance', 'filter_resonance', 'q'],
      category: 'audio',
      description: 'Filter resonance/Q',
    ),

    ParameterDescriptor(
      name: 'reverbMix',
      range: ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.3),
      visualizerTarget: '',
      aliases: ['reverb', 'reverb_mix', 'wet'],
      category: 'audio',
      description: 'Reverb wet/dry mix',
    ),

    ParameterDescriptor(
      name: 'reverbRoomSize',
      range: ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.7),
      visualizerTarget: '',
      aliases: ['room_size', 'reverb_size'],
      category: 'audio',
      description: 'Reverb room size',
    ),

    ParameterDescriptor(
      name: 'delayTime',
      range: ParameterRange(min: 0.0, max: 2000.0, defaultValue: 250.0),
      visualizerTarget: '',
      aliases: ['delay', 'delay_time'],
      category: 'audio',
      description: 'Delay time in milliseconds',
    ),

    ParameterDescriptor(
      name: 'delayFeedback',
      range: ParameterRange(min: 0.0, max: 0.95, defaultValue: 0.4),
      visualizerTarget: '',
      aliases: ['feedback', 'delay_feedback'],
      category: 'audio',
      description: 'Delay feedback amount',
    ),

    ParameterDescriptor(
      name: 'delayMix',
      range: ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.3),
      visualizerTarget: '',
      aliases: ['delay_wet', 'delay_mix'],
      category: 'audio',
      description: 'Delay wet/dry mix',
    ),

    // === ENVELOPE PARAMETERS ===

    ParameterDescriptor(
      name: 'envelopeAttack',
      range: ParameterRange(
          min: 0.001,
          max: 5.0,
          defaultValue: 0.01,
          curve: CurveType.exponential),
      visualizerTarget: '',
      aliases: ['attack', 'env_attack'],
      category: 'envelope',
      description: 'Envelope attack time in seconds',
    ),

    ParameterDescriptor(
      name: 'envelopeDecay',
      range: ParameterRange(
          min: 0.001,
          max: 5.0,
          defaultValue: 0.1,
          curve: CurveType.exponential),
      visualizerTarget: '',
      aliases: ['decay', 'env_decay'],
      category: 'envelope',
      description: 'Envelope decay time in seconds',
    ),

    ParameterDescriptor(
      name: 'envelopeSustain',
      range: ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.7),
      visualizerTarget: '',
      aliases: ['sustain', 'env_sustain'],
      category: 'envelope',
      description: 'Envelope sustain level',
    ),

    ParameterDescriptor(
      name: 'envelopeRelease',
      range: ParameterRange(
          min: 0.001,
          max: 10.0,
          defaultValue: 0.3,
          curve: CurveType.exponential),
      visualizerTarget: '',
      aliases: ['release', 'env_release'],
      category: 'envelope',
      description: 'Envelope release time in seconds',
    ),

    // === GEOMETRY/SYSTEM PARAMETERS ===

    ParameterDescriptor(
      name: 'geometry',
      range: ParameterRange(min: 0.0, max: 23.0, defaultValue: 0.0),
      visualizerTarget: 'geometry',
      aliases: ['geom', 'shape', 'polytope'],
      category: 'system',
      description: 'Geometry index (0-23)',
    ),

    ParameterDescriptor(
      name: 'projectionDistance',
      range: ParameterRange(min: 5.0, max: 15.0, defaultValue: 8.0),
      visualizerTarget: 'projectionDistance',
      aliases: ['distance', 'proj_dist', 'camera_dist'],
      category: 'visual',
      description: 'Camera projection distance',
    ),

    ParameterDescriptor(
      name: 'layerSeparation',
      range: ParameterRange(min: 0.0, max: 5.0, defaultValue: 2.0),
      visualizerTarget: 'layerDepth',
      aliases: ['layer_depth', 'separation'],
      category: 'visual',
      description: 'Holographic layer depth',
    ),
  ]);
}
