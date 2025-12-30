/**
 * VIB3 Geometry Library
 *
 * Comprehensive 24-geometry system combining 8 base geometries with 3 core variants.
 * Provides encoding, decoding, and metadata for the full 4D polytope space.
 *
 * Integrated from vib34d-vib3plus repository.
 *
 * A Paul Phillips Manifestation
 * © 2025 Clear Seas Solutions LLC
 */

/// Base geometry types (0-7)
enum BaseGeometry {
  tetrahedron,    // 0: Fundamental, minimal filtering
  hypercube,      // 1: Complex, dual oscillators with detune
  sphere,         // 2: Smooth, filtered harmonics
  torus,          // 3: Cyclic, rhythmic phase modulation
  kleinBottle,    // 4: Twisted, asymmetric stereo
  fractal,        // 5: Recursive, self-modulating
  wave,           // 6: Flowing, sweeping filters
  crystal,        // 7: Crystalline, sharp attack transients
}

/// Core variant types (determines synthesis branch)
enum CoreVariant {
  base,              // 0: Direct synthesis (geometries 0-7)
  hypersphere,       // 1: FM synthesis (geometries 8-15)
  hypertetrahedron,  // 2: Ring modulation (geometries 16-23)
}

/// Metadata for a specific geometry configuration
class GeometryMetadata {
  final int index;              // Combined index (0-23)
  final BaseGeometry base;      // Base geometry (0-7)
  final CoreVariant core;       // Core variant (0-2)
  final String baseName;        // Human-readable base name
  final String coreName;        // Human-readable core name
  final String fullName;        // Complete descriptive name

  const GeometryMetadata({
    required this.index,
    required this.base,
    required this.core,
    required this.baseName,
    required this.coreName,
    required this.fullName,
  });

  @override
  String toString() => '$fullName (index: $index)';
}

/// Rendering variation parameters for a geometry
class VariationParameters {
  final double gridDensity;     // Tessellation density (3-8)
  final double morphFactor;     // Morphing amount (0-2)
  final double chaos;           // Chaos/randomness (0-1)
  final double speed;           // Animation speed multiplier
  final double hue;             // Color hue shift (0-360)

  const VariationParameters({
    required this.gridDensity,
    required this.morphFactor,
    required this.chaos,
    required this.speed,
    required this.hue,
  });

  /// Create default parameters
  factory VariationParameters.defaults() {
    return const VariationParameters(
      gridDensity: 5.0,
      morphFactor: 1.0,
      chaos: 0.2,
      speed: 1.0,
      hue: 200.0,
    );
  }

  VariationParameters copyWith({
    double? gridDensity,
    double? morphFactor,
    double? chaos,
    double? speed,
    double? hue,
  }) {
    return VariationParameters(
      gridDensity: gridDensity ?? this.gridDensity,
      morphFactor: morphFactor ?? this.morphFactor,
      chaos: chaos ?? this.chaos,
      speed: speed ?? this.speed,
      hue: hue ?? this.hue,
    );
  }
}

/// Main geometry library with static utilities
class GeometryLibrary {
  // Base geometry names (0-7)
  static const Map<BaseGeometry, String> _baseNames = {
    BaseGeometry.tetrahedron: 'Tetrahedron',
    BaseGeometry.hypercube: 'Hypercube',
    BaseGeometry.sphere: 'Sphere',
    BaseGeometry.torus: 'Torus',
    BaseGeometry.kleinBottle: 'Klein Bottle',
    BaseGeometry.fractal: 'Fractal',
    BaseGeometry.wave: 'Wave',
    BaseGeometry.crystal: 'Crystal',
  };

  // Core variant names
  static const Map<CoreVariant, String> _coreNames = {
    CoreVariant.base: 'Base',
    CoreVariant.hypersphere: 'Hypersphere',
    CoreVariant.hypertetrahedron: 'Hypertetrahedron',
  };

  // Synthesis branch descriptions
  static const Map<CoreVariant, String> _synthesisDescriptions = {
    CoreVariant.base: 'Direct Synthesis',
    CoreVariant.hypersphere: 'FM Synthesis',
    CoreVariant.hypertetrahedron: 'Ring Modulation',
  };

  /// Encode a geometry index from base and core indices
  ///
  /// Returns combined index (0-23) from base (0-7) and core (0-2)
  static int encodeGeometryIndex(int baseIndex, int coreIndex) {
    final normalizedBase = baseIndex % 8;
    final normalizedCore = coreIndex % 3;
    return normalizedCore * 8 + normalizedBase;
  }

  /// Decode a geometry index into base and core components
  ///
  /// Returns a record with base (0-7) and core (0-2) indices
  static ({int base, int core}) decodeGeometryIndex(int geometryIndex) {
    final normalizedIndex = geometryIndex % 24;
    final core = normalizedIndex ~/ 8;
    final base = normalizedIndex % 8;
    return (base: base, core: core);
  }

  /// Get metadata for a specific geometry index
  static GeometryMetadata describeGeometry(int geometryIndex) {
    final decoded = decodeGeometryIndex(geometryIndex);
    final base = BaseGeometry.values[decoded.base];
    final core = CoreVariant.values[decoded.core];

    final baseName = _baseNames[base]!;
    final coreName = _coreNames[core]!;
    final synthesisType = _synthesisDescriptions[core]!;

    return GeometryMetadata(
      index: geometryIndex % 24,
      base: base,
      core: core,
      baseName: baseName,
      coreName: coreName,
      fullName: '$coreName $baseName ($synthesisType)',
    );
  }

  /// Get all geometry metadata (0-23)
  static List<GeometryMetadata> listAllGeometries() {
    return List.generate(24, (index) => describeGeometry(index));
  }

  /// Get variation parameters for a specific geometry and level
  ///
  /// Applies geometry-specific and core-specific adjustments to base parameters
  static VariationParameters getVariationParameters({
    required int geometryIndex,
    required int variationLevel,
    VariationParameters? baseParams,
  }) {
    final base = baseParams ?? VariationParameters.defaults();
    final decoded = decodeGeometryIndex(geometryIndex);
    final baseGeometry = BaseGeometry.values[decoded.base];
    final coreVariant = CoreVariant.values[decoded.core];

    // Base geometry-specific multipliers
    double gridMultiplier = 1.0;
    double morphMultiplier = 1.0;
    double chaosMultiplier = 1.0;
    double speedMultiplier = 1.0;
    double hueShift = 0.0;

    // Apply base geometry characteristics
    switch (baseGeometry) {
      case BaseGeometry.tetrahedron:
        gridMultiplier = 0.8;
        morphMultiplier = 0.7;
        chaosMultiplier = 0.5;
        speedMultiplier = 0.9;
        hueShift = 0;
        break;
      case BaseGeometry.hypercube:
        gridMultiplier = 1.2;
        morphMultiplier = 1.3;
        chaosMultiplier = 0.8;
        speedMultiplier = 1.0;
        hueShift = 30;
        break;
      case BaseGeometry.sphere:
        gridMultiplier = 1.0;
        morphMultiplier = 1.5;
        chaosMultiplier = 0.3;
        speedMultiplier = 0.8;
        hueShift = 60;
        break;
      case BaseGeometry.torus:
        gridMultiplier = 1.1;
        morphMultiplier = 1.2;
        chaosMultiplier = 0.6;
        speedMultiplier = 1.3;
        hueShift = 90;
        break;
      case BaseGeometry.kleinBottle:
        gridMultiplier = 1.3;
        morphMultiplier = 1.8;
        chaosMultiplier = 1.2;
        speedMultiplier = 1.1;
        hueShift = 120;
        break;
      case BaseGeometry.fractal:
        gridMultiplier = 0.5;
        morphMultiplier = 2.0;
        chaosMultiplier = 1.5;
        speedMultiplier = 1.2;
        hueShift = 180;
        break;
      case BaseGeometry.wave:
        gridMultiplier = 0.9;
        morphMultiplier = 1.4;
        chaosMultiplier = 0.4;
        speedMultiplier = 1.5;
        hueShift = 240;
        break;
      case BaseGeometry.crystal:
        gridMultiplier = 1.4;
        morphMultiplier = 0.8;
        chaosMultiplier = 0.2;
        speedMultiplier = 0.7;
        hueShift = 300;
        break;
    }

    // Apply core variant adjustments
    switch (coreVariant) {
      case CoreVariant.base:
        // No additional adjustments for base
        break;
      case CoreVariant.hypersphere:
        gridMultiplier *= 1.1;
        morphMultiplier *= 1.2;
        speedMultiplier *= 0.9;
        hueShift += 120;
        break;
      case CoreVariant.hypertetrahedron:
        gridMultiplier *= 1.2;
        chaosMultiplier *= 1.3;
        speedMultiplier *= 1.1;
        hueShift += 240;
        break;
    }

    // Apply variation level (0-based)
    final levelMultiplier = 1.0 + (variationLevel * 0.1);

    return VariationParameters(
      gridDensity: (base.gridDensity * gridMultiplier * levelMultiplier).clamp(3.0, 8.0),
      morphFactor: (base.morphFactor * morphMultiplier).clamp(0.0, 2.0),
      chaos: (base.chaos * chaosMultiplier).clamp(0.0, 1.0),
      speed: (base.speed * speedMultiplier).clamp(0.1, 3.0),
      hue: (base.hue + hueShift) % 360.0,
    );
  }

  /// Get the synthesis branch name for a geometry
  static String getSynthesisBranch(int geometryIndex) {
    final decoded = decodeGeometryIndex(geometryIndex);
    final core = CoreVariant.values[decoded.core];
    return _synthesisDescriptions[core]!;
  }

  /// Get the sound family for a geometry based on visual system
  ///
  /// visualSystem: 0 = Quantum, 1 = Faceted, 2 = Holographic
  static String getSoundFamily(int visualSystem) {
    switch (visualSystem) {
      case 0:
        return 'Quantum (Pure Harmonic)';
      case 1:
        return 'Faceted (Geometric Hybrid)';
      case 2:
        return 'Holographic (Spectral Rich)';
      default:
        return 'Unknown';
    }
  }

  /// Check if a geometry uses FM synthesis
  static bool usesFMSynthesis(int geometryIndex) {
    final decoded = decodeGeometryIndex(geometryIndex);
    return decoded.core == 1; // Hypersphere core
  }

  /// Check if a geometry uses ring modulation
  static bool usesRingModulation(int geometryIndex) {
    final decoded = decodeGeometryIndex(geometryIndex);
    return decoded.core == 2; // Hypertetrahedron core
  }
}
