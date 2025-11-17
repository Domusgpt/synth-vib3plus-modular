///
/// Trail System
///
/// Visual history of touch movements. Creates smooth, fading trails
/// that follow finger movements across the interface, providing
/// immediate visual feedback for gestures and XY pad interactions.
///
/// Features:
/// - Pressure-sensitive width
/// - Time-based fade out
/// - Color gradient support
/// - Audio-reactive brightness
/// - Smooth bezier interpolation
///
/// Part of the Next-Generation UI Redesign (v3.0)
///
/// A Paul Phillips Manifestation
///

library;

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../effects/glassmorphic_container.dart';

// ============================================================================
// TRAIL POINT MODEL
// ============================================================================

/// Single point in a touch trail
class TrailPoint {
  final Offset position;
  final double pressure; // 0-1, touch pressure
  final DateTime timestamp;
  final double velocity; // Speed at this point

  TrailPoint(
    this.position,
    this.pressure,
    this.timestamp, {
    this.velocity = 0.0,
  });

  /// Age in seconds
  double get ageSeconds {
    return DateTime.now().difference(timestamp).inMilliseconds / 1000.0;
  }

  /// Opacity based on age (fade out over 2 seconds)
  double get opacity {
    final age = ageSeconds;
    if (age > 2.0) return 0.0;
    return 1.0 - (age / 2.0);
  }
}

// ============================================================================
// TOUCH TRAIL
// ============================================================================

/// Trail for a single touch/gesture
class TouchTrail {
  final List<TrailPoint> points = [];
  Color color;
  double maxLength; // Maximum points to keep
  double fadeTime; // Seconds before points disappear
  double baseWidth; // Base stroke width
  bool enabled;

  TouchTrail({
    this.color = DesignTokens.stateActive,
    this.maxLength = 50,
    this.fadeTime = 2.0,
    this.baseWidth = 3.0,
    this.enabled = true,
  });

  // ============================================================================
  // POINT MANAGEMENT
  // ============================================================================

  /// Add new point to trail
  void addPoint(Offset position, {double pressure = 1.0}) {
    if (!enabled) return;

    // Calculate velocity
    double velocity = 0.0;
    if (points.isNotEmpty) {
      final lastPoint = points.last;
      final distance = (position - lastPoint.position).distance;
      final timeDelta =
          DateTime.now().difference(lastPoint.timestamp).inMilliseconds /
              1000.0;
      if (timeDelta > 0) {
        velocity = distance / timeDelta;
      }
    }

    points.add(TrailPoint(
      position,
      pressure.clamp(0.0, 1.0),
      DateTime.now(),
      velocity: velocity,
    ));

    // Remove old points
    _pruneOldPoints();
  }

  /// Remove points that are too old or exceed max length
  void _pruneOldPoints() {
    // Remove by age
    points.removeWhere((point) => point.ageSeconds > fadeTime);

    // Remove by count
    while (points.length > maxLength) {
      points.removeAt(0);
    }
  }

  /// Update trail (called each frame)
  void update(double dt, {AudioFeatures? audioFeatures}) {
    _pruneOldPoints();

    // Audio-reactive color shift
    if (audioFeatures != null) {
      final hueShift =
          DesignTokens.dominantFreqToHueShift(audioFeatures.dominantFreq);
      color = DesignTokens.adjustHue(color, hueShift * dt * 60);
    }
  }

  // ============================================================================
  // RENDERING
  // ============================================================================

  /// Paint the trail
  void paint(Canvas canvas, {AudioFeatures? audioFeatures}) {
    if (!enabled || points.length < 2) return;

    // Audio-reactive brightness
    double brightnessFactor = 1.0;
    if (audioFeatures != null) {
      brightnessFactor = 1.0 + (audioFeatures.rms * 0.5);
    }

    // Draw trail segments
    for (int i = 1; i < points.length; i++) {
      final startPoint = points[i - 1];
      final endPoint = points[i];

      // Calculate opacity (fade based on age)
      final opacity =
          math.min(startPoint.opacity, endPoint.opacity) * brightnessFactor;
      if (opacity <= 0.0) continue;

      // Calculate width (pressure-sensitive + velocity-based)
      final avgPressure = (startPoint.pressure + endPoint.pressure) / 2;
      final velocityFactor =
          (1.0 - (endPoint.velocity / 1000.0).clamp(0.0, 0.5));
      final width = baseWidth * avgPressure * velocityFactor;

      // Draw segment
      final paint = Paint()
        ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, width / 2);

      canvas.drawLine(
        startPoint.position,
        endPoint.position,
        paint,
      );
    }
  }

  /// Paint with smooth bezier curves
  void paintSmooth(Canvas canvas, {AudioFeatures? audioFeatures}) {
    if (!enabled || points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.position.dx, points.first.position.dy);

    // Create smooth curve through points
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      // Calculate control point (midpoint)
      final controlX = (current.position.dx + next.position.dx) / 2;
      final controlY = (current.position.dy + next.position.dy) / 2;

      path.quadraticBezierTo(
        current.position.dx,
        current.position.dy,
        controlX,
        controlY,
      );
    }

    // Final point
    final last = points.last;
    path.lineTo(last.position.dx, last.position.dy);

    // Audio-reactive brightness
    double brightnessFactor = 1.0;
    if (audioFeatures != null) {
      brightnessFactor = 1.0 + (audioFeatures.rms * 0.5);
    }

    // Draw path with gradient opacity
    final paint = Paint()
      ..shader = _createGradientShader(path.getBounds(), brightnessFactor)
      ..strokeWidth = baseWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, baseWidth / 2);

    canvas.drawPath(path, paint);
  }

  /// Create gradient shader for trail
  Shader _createGradientShader(Rect bounds, double brightnessFactor) {
    // Calculate colors based on point ages
    final colors = <Color>[];
    final stops = <double>[];

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final opacity = point.opacity * brightnessFactor;
      colors.add(color.withValues(alpha: opacity.clamp(0.0, 1.0)));
      stops.add(i / (points.length - 1));
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: stops,
    ).createShader(bounds);
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Get number of points
  int get length => points.length;

  /// Check if trail is empty
  bool get isEmpty => points.isEmpty;

  /// Clear all points
  void clear() {
    points.clear();
  }

  /// Get trail bounds
  Rect? get bounds {
    if (points.isEmpty) return null;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      minX = math.min(minX, point.position.dx);
      minY = math.min(minY, point.position.dy);
      maxX = math.max(maxX, point.position.dx);
      maxY = math.max(maxY, point.position.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

// ============================================================================
// TRAIL SYSTEM
// ============================================================================

/// Manages multiple trails (multi-touch support)
class TrailSystem {
  final Map<int, TouchTrail> _trails = {}; // Pointer ID → Trail
  Color defaultColor;
  double maxLength;
  double fadeTime;
  double baseWidth;
  bool enabled;
  bool smoothRendering; // Use bezier curves

  TrailSystem({
    this.defaultColor = DesignTokens.stateActive,
    this.maxLength = 50,
    this.fadeTime = 2.0,
    this.baseWidth = 3.0,
    this.enabled = true,
    this.smoothRendering = true,
  });

  // ============================================================================
  // TRAIL MANAGEMENT
  // ============================================================================

  /// Add point to trail for given pointer
  void addPoint(int pointerId, Offset position, {double pressure = 1.0}) {
    if (!enabled) return;

    // Create trail if doesn't exist
    if (!_trails.containsKey(pointerId)) {
      _trails[pointerId] = TouchTrail(
        color: defaultColor,
        maxLength: maxLength,
        fadeTime: fadeTime,
        baseWidth: baseWidth,
        enabled: true,
      );
    }

    _trails[pointerId]!.addPoint(position, pressure: pressure);
  }

  /// Remove trail for pointer
  void removeTrail(int pointerId) {
    _trails.remove(pointerId);
  }

  /// Clear all trails
  void clearAll() {
    _trails.clear();
  }

  /// Update all trails
  void update(double dt, {AudioFeatures? audioFeatures}) {
    if (!enabled) return;

    // Update each trail
    for (final trail in _trails.values) {
      trail.update(dt, audioFeatures: audioFeatures);
    }

    // Remove empty trails
    _trails.removeWhere((_, trail) => trail.isEmpty);
  }

  // ============================================================================
  // RENDERING
  // ============================================================================

  /// Paint all trails
  void paint(Canvas canvas, {AudioFeatures? audioFeatures}) {
    if (!enabled) return;

    for (final trail in _trails.values) {
      if (smoothRendering) {
        trail.paintSmooth(canvas, audioFeatures: audioFeatures);
      } else {
        trail.paint(canvas, audioFeatures: audioFeatures);
      }
    }
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Get number of active trails
  int get activeCount => _trails.length;

  /// Get total point count across all trails
  int get totalPoints =>
      _trails.values.fold(0, (sum, trail) => sum + trail.length);

  /// Set enabled state
  void setEnabled(bool value) {
    enabled = value;
    if (!enabled) {
      clearAll();
    }
  }

  /// Set default color for new trails
  void setColor(Color color) {
    defaultColor = color;
  }

  /// Dispose of trail system
  void dispose() {
    clearAll();
  }
}
