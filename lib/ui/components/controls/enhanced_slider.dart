/**
 * Enhanced Slider
 *
 * Advanced parameter slider with multiple styles, value visualization,
 * modulation indicators, and musical curve mappings.
 *
 * Features:
 * - Multiple styles (horizontal, vertical)
 * - Value graph (historical values)
 * - Modulation indicator
 * - Range markers (min/mid/max)
 * - Color coding by parameter type
 * - Fine control mode (long-press)
 * - Double-tap to reset
 * - Audio-reactive visual effects
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
import '../../../audio/audio_analyzer.dart';

// ============================================================================
// SLIDER STYLE
// ============================================================================

/// Slider visual style
enum SliderStyle {
  linearHorizontal,  // Traditional horizontal
  linearVertical,    // Traditional vertical
}

// ============================================================================
// PARAMETER TYPE
// ============================================================================

/// Parameter type for color coding
enum ParameterType {
  frequency,   // Blue
  amplitude,   // Green
  time,        // Yellow
  modulation,  // Magenta
  filter,      // Cyan
  generic,     // White
}

extension ParameterTypeExtension on ParameterType {
  Color get color {
    switch (this) {
      case ParameterType.frequency:
        return const Color(0xFF00AAFF);  // Blue
      case ParameterType.amplitude:
        return const Color(0xFF00FF88);  // Green
      case ParameterType.time:
        return const Color(0xFFFFAA00);  // Yellow
      case ParameterType.modulation:
        return const Color(0xFFFF00FF);  // Magenta
      case ParameterType.filter:
        return const Color(0xFF00FFFF);  // Cyan
      case ParameterType.generic:
        return Colors.white;
    }
  }
}

// ============================================================================
// SLIDER CONFIGURATION
// ============================================================================

/// Enhanced slider configuration
class SliderConfig {
  final SliderStyle style;
  final ParameterType parameterType;
  final bool showValueGraph;
  final bool showModulation;
  final bool showRangeMarkers;
  final bool enableFineControl;
  final double fineControlFactor;  // 0.1 = 10x precision
  final double width;
  final double height;

  const SliderConfig({
    this.style = SliderStyle.linearHorizontal,
    this.parameterType = ParameterType.generic,
    this.showValueGraph = false,
    this.showModulation = true,
    this.showRangeMarkers = true,
    this.enableFineControl = true,
    this.fineControlFactor = 0.1,
    this.width = 200,
    this.height = 48,
  });

  /// Standard horizontal slider
  static const standard = SliderConfig(
    style: SliderStyle.linearHorizontal,
    showValueGraph: false,
    showModulation: true,
    width: 200,
    height: 48,
  );

  /// Compact horizontal slider
  static const compact = SliderConfig(
    style: SliderStyle.linearHorizontal,
    showValueGraph: false,
    showModulation: false,
    showRangeMarkers: false,
    width: 120,
    height: 32,
  );

  /// Vertical slider
  static const vertical = SliderConfig(
    style: SliderStyle.linearVertical,
    showValueGraph: false,
    showModulation: true,
    width: 48,
    height: 200,
  );
}

// ============================================================================
// ENHANCED SLIDER WIDGET
// ============================================================================

/// Enhanced parameter slider
class EnhancedSlider extends StatefulWidget {
  final SliderConfig config;
  final String label;
  final double value;          // 0-1
  final double defaultValue;   // 0-1
  final ValueChanged<double>? onChanged;
  final VoidCallback? onChangeStart;
  final VoidCallback? onChangeEnd;
  final double modulationAmount;  // 0-1, for visualization
  final AudioFeatures? audioFeatures;
  final String Function(double)? valueFormatter;  // Custom value display

  const EnhancedSlider({
    Key? key,
    this.config = SliderConfig.standard,
    required this.label,
    required this.value,
    this.defaultValue = 0.5,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.modulationAmount = 0.0,
    this.audioFeatures,
    this.valueFormatter,
  }) : super(key: key);

  @override
  State<EnhancedSlider> createState() => _EnhancedSliderState();
}

class _EnhancedSliderState extends State<EnhancedSlider> {
  bool _isDragging = false;
  bool _isFineControl = false;
  final List<double> _valueHistory = [];
  static const int maxHistoryLength = 50;

  @override
  void initState() {
    super.initState();
    _valueHistory.add(widget.value);
  }

  @override
  void didUpdateWidget(EnhancedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _valueHistory.add(widget.value);
      if (_valueHistory.length > maxHistoryLength) {
        _valueHistory.removeAt(0);
      }
    }
  }

  // ============================================================================
  // GESTURE HANDLING
  // ============================================================================

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    widget.onChangeStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final width = widget.config.style == SliderStyle.linearHorizontal
        ? widget.config.width
        : widget.config.height;

    final delta = widget.config.style == SliderStyle.linearHorizontal
        ? details.delta.dx
        : -details.delta.dy;  // Invert for vertical

    final sensitivity = _isFineControl
        ? widget.config.fineControlFactor
        : 1.0;

    final newValue = (widget.value + (delta / width) * sensitivity).clamp(0.0, 1.0);

    widget.onChanged?.call(newValue);
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _isFineControl = false;
    });
    widget.onChangeEnd?.call();
  }

  void _handleLongPress() {
    if (widget.config.enableFineControl) {
      setState(() {
        _isFineControl = true;
      });
    }
  }

  void _handleDoubleTap() {
    widget.onChanged?.call(widget.defaultValue);
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final color = widget.config.parameterType.color;
    final isHorizontal = widget.config.style == SliderStyle.linearHorizontal;

    return GestureDetector(
      onHorizontalDragStart: isHorizontal ? _handleDragStart : null,
      onHorizontalDragUpdate: isHorizontal ? _handleDragUpdate : null,
      onHorizontalDragEnd: isHorizontal ? _handleDragEnd : null,
      onVerticalDragStart: !isHorizontal ? _handleDragStart : null,
      onVerticalDragUpdate: !isHorizontal ? _handleDragUpdate : null,
      onVerticalDragEnd: !isHorizontal ? _handleDragEnd : null,
      onLongPress: _handleLongPress,
      onDoubleTap: _handleDoubleTap,
      child: SizedBox(
        width: widget.config.width,
        height: widget.config.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacing1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: DesignTokens.labelSmall.copyWith(color: color),
                  ),
                  Text(
                    _formatValue(widget.value),
                    style: DesignTokens.valueSmall.copyWith(color: color),
                  ),
                ],
              ),
            ),

            // Slider track
            Expanded(
              child: CustomPaint(
                size: Size(widget.config.width, widget.config.height - 20),
                painter: _SliderPainter(
                  value: widget.value,
                  modulationAmount: widget.modulationAmount,
                  isDragging: _isDragging,
                  isFineControl: _isFineControl,
                  color: color,
                  style: widget.config.style,
                  showValueGraph: widget.config.showValueGraph,
                  showModulation: widget.config.showModulation,
                  showRangeMarkers: widget.config.showRangeMarkers,
                  valueHistory: _valueHistory,
                  audioFeatures: widget.audioFeatures,
                ),
              ),
            ),

            // Fine control indicator
            if (_isFineControl)
              Padding(
                padding: const EdgeInsets.only(top: DesignTokens.spacing1),
                child: Text(
                  'Fine Control (${(widget.config.fineControlFactor * 100).toInt()}%)',
                  style: DesignTokens.labelSmall.copyWith(
                    color: color,
                    fontSize: 9,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (widget.valueFormatter != null) {
      return widget.valueFormatter!(value);
    }
    return '${(value * 100).toInt()}%';
  }
}

// ============================================================================
// SLIDER PAINTER
// ============================================================================

class _SliderPainter extends CustomPainter {
  final double value;
  final double modulationAmount;
  final bool isDragging;
  final bool isFineControl;
  final Color color;
  final SliderStyle style;
  final bool showValueGraph;
  final bool showModulation;
  final bool showRangeMarkers;
  final List<double> valueHistory;
  final AudioFeatures? audioFeatures;

  _SliderPainter({
    required this.value,
    required this.modulationAmount,
    required this.isDragging,
    required this.isFineControl,
    required this.color,
    required this.style,
    required this.showValueGraph,
    required this.showModulation,
    required this.showRangeMarkers,
    required this.valueHistory,
    this.audioFeatures,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (style == SliderStyle.linearHorizontal) {
      _paintHorizontal(canvas, size);
    } else {
      _paintVertical(canvas, size);
    }
  }

  void _paintHorizontal(Canvas canvas, Size size) {
    final trackY = size.height / 2;
    final thumbX = value * size.width;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, trackY),
      Offset(size.width, trackY),
      trackPaint,
    );

    // Value fill
    final fillPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, trackY),
      Offset(thumbX, trackY),
      fillPaint,
    );

    // Range markers
    if (showRangeMarkers) {
      _drawRangeMarkers(canvas, size, trackY);
    }

    // Modulation indicator
    if (showModulation && modulationAmount > 0) {
      _drawModulation(canvas, size, trackY, thumbX);
    }

    // Value graph
    if (showValueGraph && valueHistory.length > 1) {
      _drawValueGraph(canvas, size);
    }

    // Thumb
    _drawThumb(canvas, Offset(thumbX, trackY));
  }

  void _paintVertical(Canvas canvas, Size size) {
    final trackX = size.width / 2;
    final thumbY = size.height - (value * size.height);

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(trackX, 0),
      Offset(trackX, size.height),
      trackPaint,
    );

    // Value fill
    final fillPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(trackX, size.height),
      Offset(trackX, thumbY),
      fillPaint,
    );

    // Thumb
    _drawThumb(canvas, Offset(trackX, thumbY));
  }

  void _drawRangeMarkers(Canvas canvas, Size size, double trackY) {
    final markerPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Min
    canvas.drawLine(
      Offset(0, trackY - 4),
      Offset(0, trackY + 4),
      markerPaint,
    );

    // Mid
    canvas.drawLine(
      Offset(size.width / 2, trackY - 4),
      Offset(size.width / 2, trackY + 4),
      markerPaint,
    );

    // Max
    canvas.drawLine(
      Offset(size.width, trackY - 4),
      Offset(size.width, trackY + 4),
      markerPaint,
    );
  }

  void _drawModulation(Canvas canvas, Size size, double trackY, double thumbX) {
    final modRange = modulationAmount * size.width / 2;

    final modPaint = Paint()
      ..color = DesignTokens.stateWarning.withOpacity(0.3)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset((thumbX - modRange).clamp(0.0, size.width), trackY),
      Offset((thumbX + modRange).clamp(0.0, size.width), trackY),
      modPaint,
    );
  }

  void _drawValueGraph(Canvas canvas, Size size) {
    if (valueHistory.length < 2) return;

    final path = Path();
    path.moveTo(0, size.height - (valueHistory.first * size.height));

    for (int i = 1; i < valueHistory.length; i++) {
      final x = (i / (valueHistory.length - 1)) * size.width;
      final y = size.height - (valueHistory[i] * size.height);
      path.lineTo(x, y);
    }

    final graphPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, graphPaint);
  }

  void _drawThumb(Canvas canvas, Offset position) {
    // Outer ring
    final outerPaint = Paint()
      ..color = isDragging ? color : color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final outerRadius = isDragging ? 12.0 : 10.0;
    canvas.drawCircle(position, outerRadius, outerPaint);

    // Inner fill
    final innerPaint = Paint()
      ..color = color.withOpacity(isDragging ? 0.8 : 0.6);

    canvas.drawCircle(position, outerRadius - 4, innerPaint);

    // Fine control indicator
    if (isFineControl) {
      final finePaint = Paint()
        ..color = DesignTokens.stateWarning
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(position, outerRadius + 4, finePaint);
    }

    // Audio-reactive glow
    if (audioFeatures != null && audioFeatures!.rms > 0.1) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(audioFeatures!.rms * 0.5),
            color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(
          center: position,
          radius: outerRadius + 10,
        ))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(position, outerRadius + 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return oldDelegate.value != value ||
           oldDelegate.modulationAmount != modulationAmount ||
           oldDelegate.isDragging != isDragging ||
           oldDelegate.isFineControl != isFineControl ||
           oldDelegate.audioFeatures != audioFeatures;
  }
}
