/**
 * Visual System Enum
 *
 * Represents the three visual/synthesis systems in Synth-VIB3+.
 * Each system has distinct visual aesthetics and sonic characteristics.
 *
 * This is the single source of truth for visual system types,
 * used throughout the application for consistency.
 *
 * A Paul Phillips Manifestation
 */

/// Visual system types - unified enum for the entire application
enum VisualSystem {
  /// Quantum System: Pure harmonic synthesis with precise mathematical forms
  /// Visual: Cyan color, precise geometries
  /// Audio: Sine-dominant, high resonance (Q: 8-12), minimal noise
  quantum,

  /// Faceted System: Geometric hybrid synthesis with sharp polygonal forms
  /// Visual: Magenta color, angular geometries
  /// Audio: Square/triangle waves, moderate resonance (Q: 4-8), balanced spectrum
  faceted,

  /// Holographic System: Spectral rich synthesis with flowing atmospheric forms
  /// Visual: Amber color, flowing geometries
  /// Audio: Sawtooth-based, low resonance (Q: 2-4), high reverb, complex harmonics
  holographic,
}

/// Extension methods for VisualSystem enum
extension VisualSystemExtension on VisualSystem {
  /// Get the system name as a string (lowercase)
  String get displayName {
    switch (this) {
      case VisualSystem.quantum:
        return 'quantum';
      case VisualSystem.faceted:
        return 'faceted';
      case VisualSystem.holographic:
        return 'holographic';
    }
  }

  /// Get the system's primary color (for UI)
  int get colorHex {
    switch (this) {
      case VisualSystem.quantum:
        return 0xFF00FFFF; // Cyan
      case VisualSystem.faceted:
        return 0xFFFF00FF; // Magenta
      case VisualSystem.holographic:
        return 0xFFFFAA00; // Amber
    }
  }

  /// Get the system's description
  String get description {
    switch (this) {
      case VisualSystem.quantum:
        return 'Pure harmonic synthesis with mathematical precision';
      case VisualSystem.faceted:
        return 'Geometric hybrid synthesis with balanced richness';
      case VisualSystem.holographic:
        return 'Spectral rich synthesis with complex overtones';
    }
  }

  /// Parse from string (case-insensitive)
  static VisualSystem fromString(String value) {
    switch (value.toLowerCase()) {
      case 'quantum':
        return VisualSystem.quantum;
      case 'faceted':
        return VisualSystem.faceted;
      case 'holographic':
        return VisualSystem.holographic;
      default:
        return VisualSystem.quantum; // Default fallback
    }
  }
}
