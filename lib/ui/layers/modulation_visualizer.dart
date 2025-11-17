///
/// Modulation Visualizer
///
/// Visual representation of active parameter modulations.
/// Shows animated connection lines between source and target
/// parameters with strength indicators and color coding.
///
/// Features:
/// - Curved bezier connection lines
/// - Animated particle flow along paths
/// - Color-coded by source type (audio/visual/LFO)
/// - Strength-based thickness and opacity
/// - Audio-reactive pulsing
///
/// Part of the Next-Generation UI Redesign (v3.0)
///
/// A Paul Phillips Manifestation
////

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../effects/glassmorphic_container.dart';

// ============================================================================
// MODULATION SOURCE
// ============================================================================

/// Type of modulation source
enum ModulationSourceType {
  audio, // Audio features (RMS, spectral, etc.)
  visual, // Visual parameters (rotation, morph, etc.)
  lfo, // LFO modulator
  envelope, // Envelope
  manual, // User control
}

/// Modulation source
class ModulationSource {
  final String id;
  final String label;
  final ModulationSourceType type;
  final Offset position; // Screen position
  double currentValue; // 0-1

  ModulationSource({
    required this.id,
    required this.label,
    required this.type,
    required this.position,
    this.currentValue = 0.0,
  });

  /// Get color for source type
  Color get color {
    switch (type) {
      case ModulationSourceType.audio:
        return DesignTokens.audioMid;
      case ModulationSourceType.visual:
        return DesignTokens.stateActive;
      case ModulationSourceType.lfo:
        return DesignTokens.stateSuccess;
      case ModulationSourceType.envelope:
        return DesignTokens.stateWarning;
      case ModulationSourceType.manual:
        return DesignTokens.selected;
    }
  }
}

/// Modulation target
class ModulationTarget {
  final String id;
  final String label;
  final Offset position; // Screen position

  ModulationTarget({
    required this.id,
    required this.label,
    required this.position,
  });
}

// ============================================================================
// MODULATION CONNECTION
// ============================================================================

/// Connection between source and target
class ModulationConnection {
  final ModulationSource source;
  final ModulationTarget target;
  double strength; // 0-1, modulation depth
  bool enabled;
  double animationPhase; // 0-1, for animated particles

  ModulationConnection({
    required this.source,
    required this.target,
    this.strength = 0.5,
    this.enabled = true,
  }) : animationPhase = 0.0;

  /// Update animation
  void update(double dt) {
    if (!enabled) return;
    animationPhase = (animationPhase + dt * 0.5) % 1.0; // 2-second loop
  }

  /// Get control point for bezier curve
  Offset get controlPoint {
    final midX = (source.position.dx + target.position.dx) / 2;
    final midY = (source.position.dy + target.position.dy) / 2;

    // Arc upward for visual separation
    final arcHeight = -50.0 - (strength * 50.0); // Stronger = higher arc

    return Offset(midX, midY + arcHeight);
  }

  /// Evaluate point along bezier curve (t = 0-1)
  Offset evaluateCurve(double t) {
    final t1 = 1.0 - t;
    return Offset(
      t1 * t1 * source.position.dx +
          2 * t1 * t * controlPoint.dx +
          t * t * target.position.dx,
      t1 * t1 * source.position.dy +
          2 * t1 * t * controlPoint.dy +
          t * t * target.position.dy,
    );
  }
}

// ============================================================================
// MODULATION VISUALIZER
// ============================================================================

/// Visualizes all active modulation connections
class ModulationVisualizer {
  final List<ModulationConnection> connections = [];
  bool enabled;
  bool showLabels;
  bool showParticles;
  double particleCount; // Particles per connection

  ModulationVisualizer({
    this.enabled = true,
    this.showLabels = true,
    this.showParticles = true,
    this.particleCount = 5,
  });

  // ============================================================================
  // CONNECTION MANAGEMENT
  // ============================================================================

  /// Add modulation connection
  void addConnection(ModulationConnection connection) {
    // Remove existing connection with same source/target
    connections.removeWhere((c) =>
        c.source.id == connection.source.id &&
        c.target.id == connection.target.id);

    connections.add(connection);
  }

  /// Remove connection
  void removeConnection(String sourceId, String targetId) {
    connections
        .removeWhere((c) => c.source.id == sourceId && c.target.id == targetId);
  }

  /// Update connection strength
  void updateStrength(String sourceId, String targetId, double strength) {
    final connection = connections.firstWhere(
      (c) => c.source.id == sourceId && c.target.id == targetId,
      orElse: () => throw Exception('Connection not found'),
    );
    connection.strength = strength.clamp(0.0, 1.0);
  }

  /// Clear all connections
  void clearAll() {
    connections.clear();
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update all connections
  void update(double dt, {AudioFeatures? audioFeatures}) {
    if (!enabled) return;

    for (final connection in connections) {
      connection.update(dt);

      // Audio-reactive strength modulation
      if (audioFeatures != null) {
        final pulse = 1.0 + (audioFeatures.rms * 0.3);
        // Don't modify base strength, just use for visual pulsing
      }
    }
  }

  // ============================================================================
  // RENDERING
  // ============================================================================

  /// Paint all connections
  void paint(Canvas canvas, Size size, {AudioFeatures? audioFeatures}) {
    if (!enabled || connections.isEmpty) return;

    for (final connection in connections) {
      if (!connection.enabled) continue;

      _paintConnection(canvas, connection, audioFeatures: audioFeatures);

      if (showParticles) {
        _paintParticles(canvas, connection);
      }

      if (showLabels) {
        _paintLabels(canvas, connection);
      }
    }
  }

  /// Paint single connection line
  void _paintConnection(
    Canvas canvas,
    ModulationConnection connection, {
    AudioFeatures? audioFeatures,
  }) {
    final path = Path();
    path.moveTo(connection.source.position.dx, connection.source.position.dy);
    path.quadraticBezierTo(
      connection.controlPoint.dx,
      connection.controlPoint.dy,
      connection.target.position.dx,
      connection.target.position.dy,
    );

    // Audio-reactive pulsing
    double pulse = 1.0;
    if (audioFeatures != null) {
      pulse = 1.0 + (audioFeatures.rms * connection.source.currentValue * 0.5);
    }

    // Opacity based on strength and audio
    final opacity = (connection.strength * 0.7 + 0.3) * pulse;

    // Width based on strength
    final strokeWidth = 1.0 + (connection.strength * 3.0);

    // Create gradient along path
    final paint = Paint()
      ..shader = _createConnectionGradient(connection, pulse)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth / 2);

    canvas.drawPath(path, paint);
  }

  /// Create gradient shader for connection
  Shader _createConnectionGradient(
      ModulationConnection connection, double pulse) {
    final sourceColor = connection.source.color;
    final targetColor = DesignTokens.stateActive;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        sourceColor.withOpacity((connection.strength * 0.7 + 0.3) * pulse),
        sourceColor.withOpacity((connection.strength * 0.5 + 0.2) * pulse),
        targetColor.withOpacity((connection.strength * 0.3 + 0.1) * pulse),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromPoints(
      connection.source.position,
      connection.target.position,
    ));
  }

  /// Paint particles flowing along connection
  void _paintParticles(Canvas canvas, ModulationConnection connection) {
    final particleSize = 2.0 + (connection.strength * 2.0);
    final color = connection.source.color;

    // Draw particles at intervals along path
    for (int i = 0; i < particleCount; i++) {
      final t = ((connection.animationPhase + (i / particleCount)) % 1.0);
      final position = connection.evaluateCurve(t);

      // Fade particles at start/end
      final opacity = connection.strength * (1.0 - (t - 0.5).abs() * 2);

      final paint = Paint()
        ..color = color.withOpacity(opacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize);

      canvas.drawCircle(position, particleSize, paint);
    }
  }

  /// Paint source/target labels
  void _paintLabels(Canvas canvas, ModulationConnection connection) {
    // Source label
    _paintLabel(
      canvas,
      connection.source.position,
      connection.source.label,
      connection.source.color,
      isSource: true,
    );

    // Target label
    _paintLabel(
      canvas,
      connection.target.position,
      connection.target.label,
      DesignTokens.stateActive,
      isSource: false,
    );

    // Strength indicator at midpoint
    final midPoint = connection.evaluateCurve(0.5);
    _paintStrengthIndicator(canvas, midPoint, connection.strength);
  }

  /// Paint single label
  void _paintLabel(Canvas canvas, Offset position, String text, Color color,
      {required bool isSource}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: DesignTokens.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Offset label from connection point
    final offset = isSource
        ? Offset(position.dx - textPainter.width - 8,
            position.dy - textPainter.height / 2)
        : Offset(position.dx + 8, position.dy - textPainter.height / 2);

    // Draw background
    final bgRect = Rect.fromLTWH(
      offset.dx - 4,
      offset.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      bgPaint,
    );

    // Draw text
    textPainter.paint(canvas, offset);
  }

  /// Paint strength indicator
  void _paintStrengthIndicator(
      Canvas canvas, Offset position, double strength) {
    final size = 16.0;
    final rect = Rect.fromCenter(
      center: position,
      width: size,
      height: size,
    );

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, size / 2, bgPaint);

    // Strength arc
    final arcPaint = Paint()
      ..color = DesignTokens.stateActive.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2, // Start at top
      strength * 2 * math.pi, // Arc based on strength
      false,
      arcPaint,
    );

    // Percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(strength * 100).round()}%',
        style: DesignTokens.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Get active connection count
  int get activeCount => connections.where((c) => c.enabled).length;

  /// Set enabled state
  void setEnabled(bool value) {
    enabled = value;
  }

  /// Dispose of visualizer
  void dispose() {
    clearAll();
  }
}
