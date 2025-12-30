/**
 * Visual State Model
 *
 * Represents a complete VIB34D visualization configuration using
 * the ACTUAL VIB3+ parameter names (not made-up ones).
 *
 * ACTUAL VIB3+ PARAMETERS (from assets/vib3_dist/index.html):
 * - geometry (0-23): Base geometry + core variant
 * - gridDensity (5-100): Mesh tessellation density
 * - morphFactor (0-2): Geometry morphing amount
 * - chaos (0-1): Noise/randomization amount
 * - speed (0.1-3): Animation/rotation speed
 * - hue (0-360): Color hue in degrees
 * - intensity (0-1): Brightness/glow intensity
 * - saturation (0-1): Color saturation
 * - rot4dXY, rot4dXZ, rot4dYZ: 3D rotations
 * - rot4dXW, rot4dYW, rot4dZW: 4D rotations (-6.28 to 6.28)
 * - dimension (1.0-4.0): Projection dimension
 *
 * A Paul Phillips Manifestation
 */

class VisualState {
  final String name;
  final String description;

  // System selection
  final String system; // 'quantum', 'holographic', 'faceted'

  // Geometry
  final int geometry; // 0-23 (0-7 base, 8-15 hypersphere, 16-23 hypertetrahedron)

  // Visual parameters (ACTUAL VIB3+ names)
  final double gridDensity;    // 5-100 (was tessellationDensity)
  final double morphFactor;    // 0-2
  final double chaos;          // 0-1
  final double speed;          // 0.1-3

  // Color parameters (ACTUAL VIB3+ names)
  final double hue;            // 0-360 (was hueShift)
  final double intensity;      // 0-1 (was vertexBrightness and glowIntensity)
  final double saturation;     // 0-1

  // 3D Rotation parameters
  final double rot4dXY;
  final double rot4dXZ;
  final double rot4dYZ;

  // 4D Rotation parameters (-6.28 to 6.28)
  final double rot4dXW;
  final double rot4dYW;
  final double rot4dZW;

  // Projection
  final double dimension;      // 1.0-4.0 (was projectionDistance/layerSeparation)

  const VisualState({
    required this.name,
    required this.description,
    required this.system,
    required this.geometry,
    required this.gridDensity,
    required this.morphFactor,
    required this.chaos,
    required this.speed,
    required this.hue,
    required this.intensity,
    required this.saturation,
    required this.rot4dXY,
    required this.rot4dXZ,
    required this.rot4dYZ,
    required this.rot4dXW,
    required this.rot4dYW,
    required this.rot4dZW,
    required this.dimension,
  });

  /// Default visual state
  factory VisualState.defaultState() {
    return const VisualState(
      name: 'Default',
      description: 'Balanced faceted visualization',
      system: 'faceted',
      geometry: 0,            // Tetrahedron
      gridDensity: 15.0,      // Medium density
      morphFactor: 1.0,       // Moderate morphing
      chaos: 0.2,             // Low chaos
      speed: 1.0,             // Normal speed
      hue: 200.0,             // Cyan-ish
      intensity: 0.5,         // Medium brightness
      saturation: 0.8,        // High saturation
      rot4dXY: 0.0,
      rot4dXZ: 0.0,
      rot4dYZ: 0.0,
      rot4dXW: 0.0,
      rot4dYW: 0.0,
      rot4dZW: 0.0,
      dimension: 3.5,         // Between 3D and 4D
    );
  }

  /// Intense visualization state
  factory VisualState.intense() {
    return const VisualState(
      name: 'Intense',
      description: 'High-energy visualization',
      system: 'holographic',
      geometry: 8,            // Hypersphere Tetrahedron
      gridDensity: 60.0,      // High density
      morphFactor: 2.0,       // Maximum morphing
      chaos: 0.8,             // High chaos
      speed: 2.5,             // Fast
      hue: 270.0,             // Purple
      intensity: 1.0,         // Maximum brightness
      saturation: 1.0,        // Maximum saturation
      rot4dXY: 1.0,
      rot4dXZ: 0.8,
      rot4dYZ: 0.6,
      rot4dXW: 2.0,
      rot4dYW: 1.5,
      rot4dZW: 1.0,
      dimension: 4.0,         // Full 4D
    );
  }

  /// Calm ambient state
  factory VisualState.ambient() {
    return const VisualState(
      name: 'Ambient',
      description: 'Calm, slow visualization',
      system: 'quantum',
      geometry: 2,            // Sphere
      gridDensity: 8.0,       // Low density
      morphFactor: 0.3,       // Minimal morphing
      chaos: 0.1,             // Very low chaos
      speed: 0.3,             // Slow
      hue: 180.0,             // Cyan
      intensity: 0.6,         // Medium-low brightness
      saturation: 0.7,        // Moderate saturation
      rot4dXY: 0.1,
      rot4dXZ: 0.1,
      rot4dYZ: 0.1,
      rot4dXW: 0.2,
      rot4dYW: 0.3,
      rot4dZW: 0.2,
      dimension: 2.5,         // Mostly 3D
    );
  }

  /// Serialize to JSON using ACTUAL VIB3+ parameter names
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'system': system,
      'geometry': geometry,
      'gridDensity': gridDensity,
      'morphFactor': morphFactor,
      'chaos': chaos,
      'speed': speed,
      'hue': hue,
      'intensity': intensity,
      'saturation': saturation,
      'rot4dXY': rot4dXY,
      'rot4dXZ': rot4dXZ,
      'rot4dYZ': rot4dYZ,
      'rot4dXW': rot4dXW,
      'rot4dYW': rot4dYW,
      'rot4dZW': rot4dZW,
      'dimension': dimension,
    };
  }

  /// Deserialize from JSON using ACTUAL VIB3+ parameter names
  factory VisualState.fromJson(Map<String, dynamic> json) {
    return VisualState(
      name: json['name'] as String,
      description: json['description'] as String,
      system: json['system'] as String,
      geometry: json['geometry'] as int,
      gridDensity: (json['gridDensity'] as num).toDouble(),
      morphFactor: (json['morphFactor'] as num).toDouble(),
      chaos: (json['chaos'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      hue: (json['hue'] as num).toDouble(),
      intensity: (json['intensity'] as num).toDouble(),
      saturation: (json['saturation'] as num).toDouble(),
      rot4dXY: (json['rot4dXY'] as num).toDouble(),
      rot4dXZ: (json['rot4dXZ'] as num).toDouble(),
      rot4dYZ: (json['rot4dYZ'] as num).toDouble(),
      rot4dXW: (json['rot4dXW'] as num).toDouble(),
      rot4dYW: (json['rot4dYW'] as num).toDouble(),
      rot4dZW: (json['rot4dZW'] as num).toDouble(),
      dimension: (json['dimension'] as num).toDouble(),
    );
  }

  /// Copy with modifications
  VisualState copyWith({
    String? name,
    String? description,
    String? system,
    int? geometry,
    double? gridDensity,
    double? morphFactor,
    double? chaos,
    double? speed,
    double? hue,
    double? intensity,
    double? saturation,
    double? rot4dXY,
    double? rot4dXZ,
    double? rot4dYZ,
    double? rot4dXW,
    double? rot4dYW,
    double? rot4dZW,
    double? dimension,
  }) {
    return VisualState(
      name: name ?? this.name,
      description: description ?? this.description,
      system: system ?? this.system,
      geometry: geometry ?? this.geometry,
      gridDensity: gridDensity ?? this.gridDensity,
      morphFactor: morphFactor ?? this.morphFactor,
      chaos: chaos ?? this.chaos,
      speed: speed ?? this.speed,
      hue: hue ?? this.hue,
      intensity: intensity ?? this.intensity,
      saturation: saturation ?? this.saturation,
      rot4dXY: rot4dXY ?? this.rot4dXY,
      rot4dXZ: rot4dXZ ?? this.rot4dXZ,
      rot4dYZ: rot4dYZ ?? this.rot4dYZ,
      rot4dXW: rot4dXW ?? this.rot4dXW,
      rot4dYW: rot4dYW ?? this.rot4dYW,
      rot4dZW: rot4dZW ?? this.rot4dZW,
      dimension: dimension ?? this.dimension,
    );
  }
}
