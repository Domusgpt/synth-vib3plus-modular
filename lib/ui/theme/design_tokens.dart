/**
 * Design Token System
 *
 * Unified design language for Synth-VIB3+ holographic interface.
 * Provides consistent colors, typography, spacing, and animations
 * across all components with audio-reactive capabilities.
 *
 * Part of the Next-Generation UI Redesign (v3.0)
 *
 * A Paul Phillips Manifestation
 */

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Design token system for Synth-VIB3+ v3.0
class DesignTokens {
  // ============================================================================
  // STATE COLORS
  // ============================================================================

  /// State Colors - Semantic meaning across all components
  static const Color stateActive = Color(0xFF00FFFF); // Cyan - active/enabled
  static const Color stateInactive = Color(0xFF404050); // Gray - inactive but enabled
  static const Color stateDisabled = Color(0xFF202028); // Dark gray - disabled
  static const Color stateWarning = Color(0xFFFFAA00); // Amber - warning state
  static const Color stateError = Color(0xFFFF3366); // Red - error state
  static const Color stateSuccess = Color(0xFF00FF88); // Green - success state

  // ============================================================================
  // SYSTEM COLORS (from visual systems)
  // ============================================================================

  /// Visual System Colors - Match the 3 synthesis systems
  static const Color quantum = Color(0xFF00FFFF); // Cyan - pure harmonic
  static const Color faceted = Color(0xFFFF00FF); // Magenta - geometric hybrid
  static const Color holographic = Color(0xFFFFAA00); // Amber - spectral rich

  // ============================================================================
  // INTERACTION STATE COLORS
  // ============================================================================

  /// Interaction States - Touch/gesture feedback
  static const Color hover = Color(0xFF88CCFF); // Light cyan - hovering
  static const Color pressed = Color(0xFF0088CC); // Dark cyan - pressed
  static const Color selected = Color(0xFF00FFCC); // Teal - selected/focused
  static const Color dragging = Color(0xFF00DDFF); // Bright cyan - dragging

  // ============================================================================
  // AUDIO REACTIVITY COLORS
  // ============================================================================

  /// Audio-Reactive Colors - Frequency band visualization
  static const Color audioLow = Color(0xFFFF3366); // Red - bass (20-250 Hz)
  static const Color audioMid = Color(0xFF00FF88); // Green - mid (250-2000 Hz)
  static const Color audioHigh = Color(0xFF00AAFF); // Blue - high (2000-8000 Hz)
  static const Color audioSilent = Color(0xFF303040); // Dark gray - no audio
  static const Color audioClipping = Color(0xFFFF0044); // Bright red - clipping warning

  // ============================================================================
  // GLASSMORPHIC LAYER DEFINITIONS
  // ============================================================================

  /// Base Layer - Background elements
  static const Color glassBaseBackground = Color(0x1A000000); // 10% black
  static const double glassBaseBlur = 10.0;
  static const Color glassBaseBorder = Color(0x1AFFFFFF); // 10% white
  static const double glassBaseBorderWidth = 1.0;

  /// Interactive Layer - UI controls
  static const Color glassInteractiveBackground = Color(0x33FFFFFF); // 20% white
  static const double glassInteractiveBlur = 20.0;
  static const Color glassInteractiveBorder = Color(0x40FFFFFF); // 25% white
  static const double glassInteractiveBorderWidth = 1.0;

  /// Elevated Layer - Modals, popups, floating panels
  static const Color glassElevatedBackground = Color(0x4DFFFFFF); // 30% white
  static const double glassElevatedBlur = 30.0;
  static const Color glassElevatedBorder = Color(0x66FFFFFF); // 40% white
  static const double glassElevatedBorderWidth = 1.5;

  // ============================================================================
  // TYPOGRAPHY SYSTEM
  // ============================================================================

  /// Display - Large titles and headers
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300, // Light
    letterSpacing: -0.5,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.25,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: Colors.white,
    height: 1.3,
  );

  /// Headlines - Section headers
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600, // Semi-bold
    letterSpacing: 0.15,
    color: Colors.white,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
    height: 1.4,
  );

  /// Body - Standard text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.25,
    color: Colors.white,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: Colors.white,
    height: 1.5,
  );

  /// Labels - UI control labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.5,
    color: Colors.white70,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.white70,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.white54,
    height: 1.3,
  );

  /// Values - Parameter values (monospace numbers)
  static const TextStyle valueLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: stateActive,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()], // Monospace digits
  );

  static const TextStyle valueMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: stateActive,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle valueSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: stateActive,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ============================================================================
  // SPACING SYSTEM (8pt Grid)
  // ============================================================================

  static const double spacing1 = 4.0; // 0.5× - tight spacing
  static const double spacing2 = 8.0; // 1× - normal spacing
  static const double spacing3 = 16.0; // 2× - loose spacing
  static const double spacing4 = 24.0; // 3× - section spacing
  static const double spacing5 = 32.0; // 4× - major spacing
  static const double spacing6 = 48.0; // 6× - page spacing

  /// Touch Targets - Minimum sizes for interactive elements
  static const double touchTargetMinimum = 48.0; // 48px minimum (Apple/Google)
  static const double touchTargetComfortable = 56.0; // 56px comfortable
  static const double touchTargetLarge = 72.0; // 72px large/important

  // ============================================================================
  // ANIMATION TIMINGS
  // ============================================================================

  /// Micro-interactions - Immediate feedback
  static const Duration micro = Duration(milliseconds: 100);

  /// Standard transitions - Normal UI changes
  static const Duration standard = Duration(milliseconds: 300);

  /// Complex animations - Multi-stage transitions
  static const Duration complex = Duration(milliseconds: 500);

  /// Audio-reactive - 60 FPS sync
  static const Duration reactive = Duration(milliseconds: 16); // ~60 FPS

  /// Slow emphasis - Attention-grabbing
  static const Duration slow = Duration(milliseconds: 800);

  // ============================================================================
  // ANIMATION CURVES
  // ============================================================================

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve snap = Curves.easeInOutCubic;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusFull = 9999.0; // Fully rounded

  // ============================================================================
  // ELEVATION / SHADOWS
  // ============================================================================

  static BoxShadow shadowSmall(Color color) => BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: 4,
        offset: const Offset(0, 2),
      );

  static BoxShadow shadowMedium(Color color) => BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      );

  static BoxShadow shadowLarge(Color color) => BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: 16,
        offset: const Offset(0, 8),
      );

  // ============================================================================
  // GLOW EFFECTS
  // ============================================================================

  static BoxShadow glowSubtle(Color color) => BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 4,
        spreadRadius: 0,
      );

  static BoxShadow glowMedium(Color color) => BoxShadow(
        color: color.withOpacity(0.5),
        blurRadius: 8,
        spreadRadius: 2,
      );

  static BoxShadow glowStrong(Color color) => BoxShadow(
        color: color.withOpacity(0.7),
        blurRadius: 16,
        spreadRadius: 4,
      );

  static BoxShadow glowIntense(Color color) => BoxShadow(
        color: color.withOpacity(0.9),
        blurRadius: 24,
        spreadRadius: 6,
      );

  // ============================================================================
  // AUDIO REACTIVITY MAPPINGS
  // ============================================================================

  /// Map RMS amplitude (0-1) to blur radius (10-30px)
  static double audioRMSToBlur(double rms) {
    return 10.0 + (rms.clamp(0.0, 1.0) * 20.0);
  }

  /// Map spectral centroid (0-8000 Hz) to opacity (0.2-0.5)
  static double spectralCentroidToOpacity(double centroid) {
    final normalized = (centroid / 8000.0).clamp(0.0, 1.0);
    return 0.2 + (normalized * 0.3);
  }

  /// Map transient detection (0-1) to glow radius (0-10px)
  static double transientToGlow(double transient) {
    return transient.clamp(0.0, 1.0) * 10.0;
  }

  /// Map dominant frequency (0-8000 Hz) to hue shift (±60°)
  static double dominantFreqToHueShift(double frequency) {
    final normalized = (frequency / 8000.0).clamp(0.0, 1.0);
    return (normalized - 0.5) * 120.0; // ±60° from base hue
  }

  /// Map bass energy (0-1) to border width (1-4px)
  static double bassEnergyToBorderWidth(double bassEnergy) {
    return 1.0 + (bassEnergy.clamp(0.0, 1.0) * 3.0);
  }

  // ============================================================================
  // STATE VISUALIZATION HELPERS
  // ============================================================================

  /// Get color for interaction state
  static Color getInteractionColor(InteractionState state, Color baseColor) {
    switch (state) {
      case InteractionState.idle:
        return baseColor;
      case InteractionState.hover:
        return _lighten(baseColor, 0.2);
      case InteractionState.pressed:
        return _darken(baseColor, 0.2);
      case InteractionState.dragging:
        return dragging;
      case InteractionState.released:
        return baseColor;
    }
  }

  /// Get color for functional state
  static Color getFunctionalColor(FunctionalState state, Color baseColor) {
    switch (state) {
      case FunctionalState.active:
        return baseColor;
      case FunctionalState.inactive:
        return _desaturate(baseColor, 0.5);
      case FunctionalState.disabled:
        return stateDisabled;
      case FunctionalState.loading:
        return _desaturate(baseColor, 0.3);
    }
  }

  /// Get glow intensity for state
  static double getGlowIntensity(InteractionState state) {
    switch (state) {
      case InteractionState.idle:
        return 0.0;
      case InteractionState.hover:
        return 4.0;
      case InteractionState.pressed:
        return 2.0;
      case InteractionState.dragging:
        return 6.0;
      case InteractionState.released:
        return 0.0;
    }
  }

  /// Get border width for state
  static double getBorderWidth(InteractionState state, {required bool isSelected}) {
    if (isSelected) return 2.0;

    switch (state) {
      case InteractionState.idle:
        return 1.0;
      case InteractionState.hover:
        return 1.5;
      case InteractionState.pressed:
      case InteractionState.dragging:
        return 2.0;
      case InteractionState.released:
        return 1.0;
    }
  }

  // ============================================================================
  // COLOR MANIPULATION UTILITIES
  // ============================================================================

  /// Lighten a color by percentage (0-1)
  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Darken a color by percentage (0-1)
  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Desaturate a color by percentage (0-1)
  static Color _desaturate(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation((hsl.saturation * (1.0 - amount)).clamp(0.0, 1.0)).toColor();
  }

  /// Adjust hue by degrees
  static Color adjustHue(Color color, double degrees) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withHue((hsl.hue + degrees) % 360.0).toColor();
  }

  /// Blend two colors with ratio
  static Color blend(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio.clamp(0.0, 1.0))!;
  }

  // ============================================================================
  // HOLOGRAPHIC GRADIENT GENERATOR
  // ============================================================================

  /// Generate holographic iridescent gradient
  static LinearGradient holographicGradient({
    required double audioIntensity,
    double baseHue = 180.0, // Start with cyan
  }) {
    final hueShift = audioIntensity * 60.0; // ±60° based on audio

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        HSLColor.fromAHSL(1.0, (baseHue + hueShift) % 360, 0.8, 0.5).toColor(),
        HSLColor.fromAHSL(1.0, (baseHue + hueShift + 60) % 360, 0.8, 0.5).toColor(),
        HSLColor.fromAHSL(1.0, (baseHue + hueShift + 120) % 360, 0.8, 0.5).toColor(),
        HSLColor.fromAHSL(1.0, (baseHue + hueShift + 180) % 360, 0.8, 0.5).toColor(),
      ],
      stops: const [0.0, 0.33, 0.66, 1.0],
    );
  }

  /// Generate audio-reactive radial gradient
  static RadialGradient audioReactiveGradient({
    required double rms,
    required Color centerColor,
  }) {
    final opacity = rms.clamp(0.0, 1.0);

    return RadialGradient(
      center: Alignment.center,
      radius: 0.5 + (rms * 0.5), // Expand with audio
      colors: [
        centerColor.withOpacity(opacity),
        centerColor.withOpacity(opacity * 0.5),
        centerColor.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}

// ============================================================================
// ENUMS FOR STATE MANAGEMENT
// ============================================================================

/// Interaction state (user input)
enum InteractionState {
  idle, // Default, no interaction
  hover, // Finger near (if detectable)
  pressed, // Touching
  dragging, // Moving while touching
  released, // Just released
}

/// Functional state (purpose/capability)
enum FunctionalState {
  active, // Enabled and current
  inactive, // Enabled but not current
  disabled, // Not interactive
  loading, // Processing
}

/// Audio state (reactivity)
enum AudioState {
  silent, // No audio input
  playing, // Audio active
  modulating, // Being modulated
  clipping, // Over threshold
}

/// Visual system type (maps to synthesis system)
enum VisualSystemType {
  quantum, // Cyan - pure harmonic
  faceted, // Magenta - geometric hybrid
  holographic, // Amber - spectral rich
}

// ============================================================================
// GLASSMORPHIC LAYER CONFIGURATION
// ============================================================================

/// Glassmorphic layer configuration
class GlassmorphicConfig {
  final Color backgroundColor;
  final double blurRadius;
  final Color borderColor;
  final double borderWidth;
  final double opacity;

  const GlassmorphicConfig({
    required this.backgroundColor,
    required this.blurRadius,
    required this.borderColor,
    required this.borderWidth,
    this.opacity = 1.0,
  });

  /// Base layer preset
  static const base = GlassmorphicConfig(
    backgroundColor: DesignTokens.glassBaseBackground,
    blurRadius: DesignTokens.glassBaseBlur,
    borderColor: DesignTokens.glassBaseBorder,
    borderWidth: DesignTokens.glassBaseBorderWidth,
  );

  /// Interactive layer preset
  static const interactive = GlassmorphicConfig(
    backgroundColor: DesignTokens.glassInteractiveBackground,
    blurRadius: DesignTokens.glassInteractiveBlur,
    borderColor: DesignTokens.glassInteractiveBorder,
    borderWidth: DesignTokens.glassInteractiveBorderWidth,
  );

  /// Elevated layer preset
  static const elevated = GlassmorphicConfig(
    backgroundColor: DesignTokens.glassElevatedBackground,
    blurRadius: DesignTokens.glassElevatedBlur,
    borderColor: DesignTokens.glassElevatedBorder,
    borderWidth: DesignTokens.glassElevatedBorderWidth,
  );

  /// Audio-reactive variant
  GlassmorphicConfig withAudioReactivity({
    required double rms,
    required double spectralCentroid,
  }) {
    return GlassmorphicConfig(
      backgroundColor: backgroundColor,
      blurRadius: DesignTokens.audioRMSToBlur(rms),
      borderColor: borderColor,
      borderWidth: borderWidth,
      opacity: DesignTokens.spectralCentroidToOpacity(spectralCentroid),
    );
  }
}
