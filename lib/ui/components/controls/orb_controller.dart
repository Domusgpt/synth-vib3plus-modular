/**
 * Orb Controller
 *
 * Enhanced 2D pitch bend/vibrato controller with holographic visuals,
 * audio-reactive glow, and auto-return functionality.
 *
 * Features:
 * - Resizable (small 80px to XL 200px diameter)
 * - Holographic gradient sphere
 * - Audio-reactive halo glow
 * - Crosshairs and connection line
 * - Pitch bend & vibrato readout
 * - Auto-return with spring physics
 * - Configurable range (±1 to ±12 semitones)
 * - Dockable or floating
 *
 * Part of the Next-Generation UI Redesign (v3.0) - Phase 3
 *
 * A Paul Phillips Manifestation
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../effects/glassmorphic_container.dart';
import '../base/reactive_component.dart';

// ============================================================================
// ORB SIZE
// ============================================================================

/// Orb diameter sizes
enum OrbSize {
  small, // 80px
  medium, // 120px
  large, // 160px
  xl, // 200px
}

extension OrbSizeExtension on OrbSize {
  double get diameter {
    switch (this) {
      case OrbSize.small:
        return 80.0;
      case OrbSize.medium:
        return 120.0;
      case OrbSize.large:
        return 160.0;
      case OrbSize.xl:
        return 200.0;
    }
  }
}

// ============================================================================
// ORB CONFIGURATION
// ============================================================================

/// Orb controller configuration
class OrbConfig {
  final OrbSize size;
  final double range; // ±semitones (1-12)
  final bool autoReturn;
  final double returnSpeed; // 0.1-1.0, higher = faster
  final bool showCrosshairs;
  final bool showConnectionLine;
  final bool showValue;
  final bool enableHolographic;

  const OrbConfig({
    this.size = OrbSize.medium,
    this.range = 2.0,
    this.autoReturn = true,
    this.returnSpeed = 0.5,
    this.showCrosshairs = true,
    this.showConnectionLine = true,
    this.showValue = true,
    this.enableHolographic = true,
  });

  /// Performance preset (large, ±2 semitones)
  static const performance = OrbConfig(
    size: OrbSize.large,
    range: 2.0,
    autoReturn: true,
    returnSpeed: 0.7,
    enableHolographic: true,
  );

  /// Production preset (medium, ±12 semitones)
  static const production = OrbConfig(
    size: OrbSize.medium,
    range: 12.0,
    autoReturn: false,
    returnSpeed: 0.5,
    showValue: true,
  );

  /// Minimal preset (small, auto-return)
  static const minimal = OrbConfig(
    size: OrbSize.small,
    range: 2.0,
    autoReturn: true,
    returnSpeed: 0.8,
    showCrosshairs: false,
    showValue: false,
  );
}

// ============================================================================
// ORB CONTROLLER WIDGET
// ============================================================================

/// Enhanced orb controller
class OrbController extends StatefulWidget {
  final OrbConfig config;
  final ValueChanged<Offset>? onPositionChange; // -1 to 1 for X/Y
  final ValueChanged<double>? onPitchBendChange;
  final ValueChanged<double>? onVibratoChange;
  final VoidCallback? onTouchStart;
  final VoidCallback? onTouchEnd;
  final AudioFeatures? audioFeatures;
  final Color? color;
  final String? label;

  const OrbController({
    Key? key,
    this.config = OrbConfig.performance,
    this.onPositionChange,
    this.onPitchBendChange,
    this.onVibratoChange,
    this.onTouchStart,
    this.onTouchEnd,
    this.audioFeatures,
    this.color,
    this.label,
  }) : super(key: key);

  @override
  State<OrbController> createState() => _OrbControllerState();
}

class _OrbControllerState extends State<OrbController> with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero; // -1 to 1
  bool _isDragging = false;
  late AnimationController _returnController;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1000 / widget.config.returnSpeed).round()),
    );
  }

  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OrbController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.returnSpeed != widget.config.returnSpeed) {
      _returnController.duration = Duration(
        milliseconds: (1000 / widget.config.returnSpeed).round(),
      );
    }
  }

  // ============================================================================
  // TOUCH HANDLING
  // ============================================================================

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _returnController.stop();
    widget.onTouchStart?.call();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final radius = widget.config.size.diameter / 2;
    final center = Offset(radius, radius);
    final localPosition = details.localPosition - center;

    // Clamp to circle
    final distance = localPosition.distance;
    final clamped = distance > radius ? localPosition / distance * radius : localPosition;

    // Normalize to -1 to 1
    setState(() {
      _position = clamped / radius;
    });

    _notifyPositionChange();
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    widget.onTouchEnd?.call();

    // Auto-return to center
    if (widget.config.autoReturn) {
      _returnToCenter();
    }
  }

  void _returnToCenter() {
    final startPosition = _position;

    _returnController.reset();
    _returnController.addListener(() {
      setState(() {
        _position = Offset.lerp(
          startPosition,
          Offset.zero,
          _returnController.value,
        )!;
      });
      _notifyPositionChange();
    });

    _returnController.forward();
  }

  void _notifyPositionChange() {
    widget.onPositionChange?.call(_position);

    // Calculate pitch bend (X axis)
    final pitchBend = _position.dx * widget.config.range;
    widget.onPitchBendChange?.call(pitchBend);

    // Calculate vibrato (Y axis magnitude)
    final vibrato = _position.dy.abs() * widget.config.range;
    widget.onVibratoChange?.call(vibrato);
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? DesignTokens.stateActive;
    final diameter = widget.config.size.diameter;

    // Calculate audio-reactive glow
    final glowIntensity = widget.audioFeatures != null
        ? DesignTokens.transientToGlow(widget.audioFeatures!.transient) * 2
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacing2),
            child: Text(
              widget.label!,
              style: DesignTokens.labelMedium.copyWith(
                color: effectiveColor,
              ),
            ),
          ),

        // Orb
        SizedBox(
          width: diameter,
          height: diameter,
          child: GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: CustomPaint(
              size: Size(diameter, diameter),
              painter: _OrbPainter(
                position: _position,
                isDragging: _isDragging,
                color: effectiveColor,
                glowIntensity: glowIntensity,
                audioFeatures: widget.audioFeatures,
                showCrosshairs: widget.config.showCrosshairs,
                showConnectionLine: widget.config.showConnectionLine,
                enableHolographic: widget.config.enableHolographic,
              ),
            ),
          ),
        ),

        // Value display
        if (widget.config.showValue)
          Padding(
            padding: const EdgeInsets.only(top: DesignTokens.spacing2),
            child: _buildValueDisplay(effectiveColor),
          ),
      ],
    );
  }

  Widget _buildValueDisplay(Color color) {
    final pitchBend = _position.dx * widget.config.range;
    final vibrato = _position.dy.abs() * widget.config.range;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing2,
        vertical: DesignTokens.spacing1,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bend: ${pitchBend.toStringAsFixed(1)}',
            style: DesignTokens.labelSmall.copyWith(color: color),
          ),
          const SizedBox(width: DesignTokens.spacing2),
          Text(
            'Vib: ${vibrato.toStringAsFixed(1)}',
            style: DesignTokens.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ORB PAINTER
// ============================================================================

class _OrbPainter extends CustomPainter {
  final Offset position; // -1 to 1
  final bool isDragging;
  final Color color;
  final double glowIntensity;
  final AudioFeatures? audioFeatures;
  final bool showCrosshairs;
  final bool showConnectionLine;
  final bool enableHolographic;

  _OrbPainter({
    required this.position,
    required this.isDragging,
    required this.color,
    required this.glowIntensity,
    this.audioFeatures,
    required this.showCrosshairs,
    required this.showConnectionLine,
    required this.enableHolographic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Current orb position (in pixels)
    final orbPosition = center +
        Offset(
          position.dx * radius * 0.8,
          position.dy * radius * 0.8,
        );

    // Draw crosshairs
    if (showCrosshairs) {
      _drawCrosshairs(canvas, center, radius);
    }

    // Draw connection line
    if (showConnectionLine && position.distance > 0.01) {
      _drawConnectionLine(canvas, center, orbPosition);
    }

    // Draw outer glow (audio-reactive)
    if (glowIntensity > 0 || audioFeatures != null) {
      _drawGlow(canvas, orbPosition, radius / 3);
    }

    // Draw holographic sphere
    if (enableHolographic) {
      _drawHolographicSphere(canvas, orbPosition, radius / 3);
    } else {
      _drawSimpleSphere(canvas, orbPosition, radius / 3);
    }

    // Draw center indicator
    _drawCenterIndicator(canvas, center);
  }

  void _drawCrosshairs(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Horizontal
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Vertical
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
  }

  void _drawConnectionLine(Canvas canvas, Offset center, Offset orbPosition) {
    final paint = Paint()
      ..color = color.withOpacity(isDragging ? 0.6 : 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(center, orbPosition, paint);
  }

  void _drawGlow(Canvas canvas, Offset position, double radius) {
    final audioIntensity = audioFeatures?.rms ?? 0.0;
    final totalGlow = glowIntensity + (audioIntensity * 10);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.5),
          color.withOpacity(0.2),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: position,
        radius: radius + totalGlow,
      ))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, totalGlow);

    canvas.drawCircle(position, radius + totalGlow, glowPaint);
  }

  void _drawHolographicSphere(Canvas canvas, Offset position, double radius) {
    // Audio-reactive hue shift
    final hueShift = audioFeatures != null
        ? DesignTokens.dominantFreqToHueShift(audioFeatures!.dominantFreq)
        : 0.0;

    // Holographic gradient
    final gradient = DesignTokens.holographicGradient(
      audioIntensity: audioFeatures?.rms ?? 0.0,
      baseHue: HSLColor.fromColor(color).hue + hueShift,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: position,
        radius: radius,
      ));

    canvas.drawCircle(position, radius, paint);

    // Specular highlight
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.5,
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: position,
        radius: radius,
      ));

    canvas.drawCircle(position, radius, highlightPaint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = isDragging ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(position, radius, borderPaint);
  }

  void _drawSimpleSphere(Canvas canvas, Offset position, double radius) {
    // Radial gradient
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.4),
        ],
      ).createShader(Rect.fromCircle(
        center: position,
        radius: radius,
      ));

    canvas.drawCircle(position, radius, paint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = isDragging ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(position, radius, borderPaint);
  }

  void _drawCenterIndicator(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, paint);

    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 4, borderPaint);
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.audioFeatures != audioFeatures;
  }
}
