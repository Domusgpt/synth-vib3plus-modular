///
/// Radial Knob
///
/// Circular parameter control with arc visualization, value display,
/// and audio-reactive visuals.
///
/// Features:
/// - Circular arc value indicator
/// - Drag to rotate control
/// - Value display at center
/// - Modulation indicator ring
/// - Fine control mode (vertical drag)
/// - Double-tap to reset
/// - Audio-reactive glow
/// - Tick marks for reference
///
/// Part of the Next-Generation UI Redesign (v3.0) - Phase 3
///
/// A Paul Phillips Manifestation
////

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../audio/audio_analyzer.dart';
import '../../theme/design_tokens.dart';
import '../base/reactive_component.dart';
import 'enhanced_slider.dart'; // For ParameterType

// ============================================================================
// KNOB CONFIGURATION
// ============================================================================

/// Radial knob configuration
class KnobConfig {
  final double size;
  final double minAngle; // Radians
  final double maxAngle; // Radians
  final bool showTicks;
  final int tickCount;
  final bool showValue;
  final bool showModulation;
  final bool enableFineControl;

  const KnobConfig({
    this.size = 80.0,
    this.minAngle = -2.356, // -3π/4 (225°)
    this.maxAngle = 2.356, // 3π/4 (225°)
    this.showTicks = true,
    this.tickCount = 11,
    this.showValue = true,
    this.showModulation = true,
    this.enableFineControl = true,
  });

  /// Standard knob (80px)
  static const standard = KnobConfig(
    size: 80.0,
    showTicks: true,
    showValue: true,
  );

  /// Large knob (120px)
  static const large = KnobConfig(
    size: 120.0,
    showTicks: true,
    showValue: true,
    tickCount: 21,
  );

  /// Compact knob (60px, no ticks)
  static const compact = KnobConfig(
    size: 60.0,
    showTicks: false,
    showValue: true,
  );
}

// ============================================================================
// RADIAL KNOB WIDGET
// ============================================================================

/// Radial knob control
class RadialKnob extends StatefulWidget {
  final KnobConfig config;
  final String label;
  final double value; // 0-1
  final double defaultValue; // 0-1
  final ValueChanged<double>? onChanged;
  final VoidCallback? onChangeStart;
  final VoidCallback? onChangeEnd;
  final double modulationAmount; // 0-1
  final ParameterType parameterType;
  final AudioFeatures? audioFeatures;
  final String Function(double)? valueFormatter;

  const RadialKnob({
    Key? key,
    this.config = KnobConfig.standard,
    required this.label,
    required this.value,
    this.defaultValue = 0.5,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.modulationAmount = 0.0,
    this.parameterType = ParameterType.generic,
    this.audioFeatures,
    this.valueFormatter,
  }) : super(key: key);

  @override
  State<RadialKnob> createState() => _RadialKnobState();
}

class _RadialKnobState extends State<RadialKnob> {
  bool _isDragging = false;
  bool _isFineControl = false;
  Offset? _dragStart;
  double? _valueAtDragStart;

  // ============================================================================
  // GESTURE HANDLING
  // ============================================================================

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStart = details.globalPosition;
      _valueAtDragStart = widget.value;
    });
    widget.onChangeStart?.call();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_dragStart == null || _valueAtDragStart == null) return;

    final delta = details.globalPosition - _dragStart!;

    // Vertical drag for fine control
    if (delta.dy.abs() > delta.dx.abs() && widget.config.enableFineControl) {
      if (!_isFineControl) {
        setState(() {
          _isFineControl = true;
        });
      }

      // Fine vertical control (10x precision)
      final sensitivity = -1.0 / (widget.config.size * 10);
      final newValue =
          (_valueAtDragStart! + (delta.dy * sensitivity)).clamp(0.0, 1.0);
      widget.onChanged?.call(newValue);
    } else {
      // Normal circular drag
      if (_isFineControl) {
        setState(() {
          _isFineControl = false;
        });
      }

      final sensitivity = 1.0 / widget.config.size;
      final newValue =
          (_valueAtDragStart! + (delta.dx * sensitivity)).clamp(0.0, 1.0);
      widget.onChanged?.call(newValue);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _isFineControl = false;
      _dragStart = null;
      _valueAtDragStart = null;
    });
    widget.onChangeEnd?.call();
  }

  void _handleDoubleTap() {
    widget.onChanged?.call(widget.defaultValue);
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final color = widget.parameterType.color;

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onDoubleTap: _handleDoubleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            widget.label,
            style: DesignTokens.labelSmall.copyWith(color: color),
          ),

          const SizedBox(height: DesignTokens.spacing1),

          // Knob
          SizedBox(
            width: widget.config.size,
            height: widget.config.size,
            child: CustomPaint(
              painter: _KnobPainter(
                value: widget.value,
                modulationAmount: widget.modulationAmount,
                isDragging: _isDragging,
                isFineControl: _isFineControl,
                color: color,
                config: widget.config,
                audioFeatures: widget.audioFeatures,
              ),
              child: widget.config.showValue
                  ? Center(
                      child: Text(
                        _formatValue(widget.value),
                        style: DesignTokens.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),

          // Fine control indicator
          if (_isFineControl)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacing1),
              child: Text(
                'Fine',
                style: DesignTokens.labelSmall.copyWith(
                  color: DesignTokens.stateWarning,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (widget.valueFormatter != null) {
      return widget.valueFormatter!(value);
    }
    return '${(value * 100).toInt()}';
  }
}

// ============================================================================
// KNOB PAINTER
// ============================================================================

class _KnobPainter extends CustomPainter {
  final double value;
  final double modulationAmount;
  final bool isDragging;
  final bool isFineControl;
  final Color color;
  final KnobConfig config;
  final AudioFeatures? audioFeatures;

  _KnobPainter({
    required this.value,
    required this.modulationAmount,
    required this.isDragging,
    required this.isFineControl,
    required this.color,
    required this.config,
    this.audioFeatures,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    _drawBackground(canvas, center, radius);

    // Draw ticks
    if (config.showTicks) {
      _drawTicks(canvas, center, radius);
    }

    // Draw modulation indicator
    if (config.showModulation && modulationAmount > 0) {
      _drawModulation(canvas, center, radius);
    }

    // Draw value arc
    _drawValueArc(canvas, center, radius);

    // Draw indicator line
    _drawIndicator(canvas, center, radius);

    // Draw audio-reactive glow
    if (audioFeatures != null && audioFeatures!.rms > 0.1) {
      _drawGlow(canvas, center, radius);
    }
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    // Outer circle
    final outerPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 4, outerPaint);

    // Border
    final borderPaint = Paint()
      ..color = color.withOpacity(isDragging ? 0.8 : 0.4)
      ..strokeWidth = isDragging ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 4, borderPaint);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < config.tickCount; i++) {
      final t = i / (config.tickCount - 1);
      final angle = config.minAngle + (config.maxAngle - config.minAngle) * t;

      final startRadius = radius - 12;
      final endRadius = i % 2 == 0 ? radius - 8 : radius - 10;

      final start = Offset(
        center.dx + math.cos(angle - math.pi / 2) * startRadius,
        center.dy + math.sin(angle - math.pi / 2) * startRadius,
      );

      final end = Offset(
        center.dx + math.cos(angle - math.pi / 2) * endRadius,
        center.dy + math.sin(angle - math.pi / 2) * endRadius,
      );

      canvas.drawLine(start, end, tickPaint);
    }
  }

  void _drawModulation(Canvas canvas, Offset center, double radius) {
    final currentAngle =
        config.minAngle + (config.maxAngle - config.minAngle) * value;
    final modRange = (config.maxAngle - config.minAngle) * modulationAmount / 2;

    final modPaint = Paint()
      ..color = DesignTokens.stateWarning.withOpacity(0.3)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final modPath = Path();
    modPath.addArc(
      Rect.fromCircle(center: center, radius: radius - 12),
      currentAngle - modRange - math.pi / 2,
      modRange * 2,
    );

    canvas.drawPath(modPath, modPaint);
  }

  void _drawValueArc(Canvas canvas, Offset center, double radius) {
    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.8),
        ],
        startAngle: config.minAngle,
        endAngle: config.minAngle + (config.maxAngle - config.minAngle) * value,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arcPath = Path();
    arcPath.addArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      config.minAngle - math.pi / 2,
      (config.maxAngle - config.minAngle) * value,
    );

    canvas.drawPath(arcPath, arcPaint);
  }

  void _drawIndicator(Canvas canvas, Offset center, double radius) {
    final angle = config.minAngle + (config.maxAngle - config.minAngle) * value;

    // Indicator line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final lineStart = Offset(
      center.dx + math.cos(angle - math.pi / 2) * (radius / 3),
      center.dy + math.sin(angle - math.pi / 2) * (radius / 3),
    );

    final lineEnd = Offset(
      center.dx + math.cos(angle - math.pi / 2) * (radius - 16),
      center.dy + math.sin(angle - math.pi / 2) * (radius - 16),
    );

    canvas.drawLine(lineStart, lineEnd, linePaint);

    // Center dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, dotPaint);
  }

  void _drawGlow(Canvas canvas, Offset center, double radius) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(audioFeatures!.rms * 0.5),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: center,
        radius: radius + 10,
      ))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius + 10, glowPaint);
  }

  @override
  bool shouldRepaint(_KnobPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.modulationAmount != modulationAmount ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.isFineControl != isFineControl ||
        oldDelegate.audioFeatures != audioFeatures;
  }
}
