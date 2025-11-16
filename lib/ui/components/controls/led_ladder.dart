/**
 * LED Ladder
 *
 * Discrete step control with LED-style visualization. Perfect for
 * parameters with discrete values (filter types, waveforms, etc.).
 *
 * Features:
 * - Vertical LED bar visualization
 * - Discrete steps (tap to select)
 * - Drag to sweep through values
 * - Glow effect on active LEDs
 * - Audio-reactive brightness
 * - Labels for each step (optional)
 * - Color coding by value
 *
 * Part of the Next-Generation UI Redesign (v3.0) - Phase 3
 *
 * A Paul Phillips Manifestation
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../base/reactive_component.dart';
import 'enhanced_slider.dart';  // For ParameterType
import '../../../audio/audio_analyzer.dart';  // For AudioFeatures

// ============================================================================
// LED LADDER CONFIGURATION
// ============================================================================

/// LED ladder configuration
class LEDLadderConfig {
  final int stepCount;
  final double width;
  final double height;
  final bool showLabels;
  final List<String>? stepLabels;
  final bool enableDrag;
  final bool colorCoded;  // Gradient from bottom to top

  const LEDLadderConfig({
    this.stepCount = 8,
    this.width = 48.0,
    this.height = 200.0,
    this.showLabels = false,
    this.stepLabels,
    this.enableDrag = true,
    this.colorCoded = false,
  });

  /// Standard ladder (8 steps)
  static const standard = LEDLadderConfig(
    stepCount: 8,
    width: 48.0,
    height: 200.0,
  );

  /// Compact ladder (5 steps)
  static const compact = LEDLadderConfig(
    stepCount: 5,
    width: 40.0,
    height: 120.0,
  );

  /// Large ladder (12 steps with labels)
  static const large = LEDLadderConfig(
    stepCount: 12,
    width: 60.0,
    height: 300.0,
    showLabels: true,
  );
}

// ============================================================================
// LED LADDER WIDGET
// ============================================================================

/// LED ladder discrete control
class LEDLadder extends StatefulWidget {
  final LEDLadderConfig config;
  final String label;
  final int value;             // 0 to stepCount-1
  final int defaultValue;
  final ValueChanged<int>? onChanged;
  final ParameterType parameterType;
  final AudioFeatures? audioFeatures;

  const LEDLadder({
    Key? key,
    this.config = LEDLadderConfig.standard,
    required this.label,
    required this.value,
    this.defaultValue = 0,
    this.onChanged,
    this.parameterType = ParameterType.generic,
    this.audioFeatures,
  }) : super(key: key);

  @override
  State<LEDLadder> createState() => _LEDLadderState();
}

class _LEDLadderState extends State<LEDLadder> {
  bool _isDragging = false;

  // ============================================================================
  // GESTURE HANDLING
  // ============================================================================

  void _handleTapDown(TapDownDetails details) {
    _updateValueFromPosition(details.localPosition.dy);
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.config.enableDrag) return;

    setState(() {
      _isDragging = true;
    });
    _updateValueFromPosition(details.localPosition.dy);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.config.enableDrag) return;

    _updateValueFromPosition(details.localPosition.dy);
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  void _updateValueFromPosition(double y) {
    final stepHeight = widget.config.height / widget.config.stepCount;

    // Invert Y (top = highest value)
    final step = ((widget.config.height - y) / stepHeight)
        .floor()
        .clamp(0, widget.config.stepCount - 1);

    if (step != widget.value) {
      widget.onChanged?.call(step);
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
    final color = widget.parameterType.color;

    return GestureDetector(
      onTapDown: _handleTapDown,
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

          // LED ladder
          SizedBox(
            width: widget.config.width,
            height: widget.config.height,
            child: CustomPaint(
              painter: _LEDLadderPainter(
                value: widget.value,
                stepCount: widget.config.stepCount,
                color: color,
                isDragging: _isDragging,
                colorCoded: widget.config.colorCoded,
                audioFeatures: widget.audioFeatures,
              ),
            ),
          ),

          // Value text
          const SizedBox(height: DesignTokens.spacing1),
          Text(
            _getValueLabel(widget.value),
            style: DesignTokens.valueSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _getValueLabel(int value) {
    if (widget.config.stepLabels != null &&
        value < widget.config.stepLabels!.length) {
      return widget.config.stepLabels![value];
    }
    return '${value + 1}';
  }
}

// ============================================================================
// LED LADDER PAINTER
// ============================================================================

class _LEDLadderPainter extends CustomPainter {
  final int value;
  final int stepCount;
  final Color color;
  final bool isDragging;
  final bool colorCoded;
  final AudioFeatures? audioFeatures;

  _LEDLadderPainter({
    required this.value,
    required this.stepCount,
    required this.color,
    required this.isDragging,
    required this.colorCoded,
    this.audioFeatures,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stepHeight = size.height / stepCount;
    final ledHeight = stepHeight - 4;  // 4px gap
    final ledWidth = size.width - 8;   // 4px margin each side

    // Audio-reactive brightness
    final brightnessFactor = audioFeatures != null
        ? 1.0 + (audioFeatures!.rms * 0.5)
        : 1.0;

    // Draw each LED
    for (int i = 0; i < stepCount; i++) {
      // Y position (inverted - 0 at bottom)
      final y = size.height - ((i + 1) * stepHeight);
      final isActive = i <= value;

      // Color for this LED
      Color ledColor;
      if (colorCoded) {
        // Gradient from red (bottom) to green (top)
        final t = i / (stepCount - 1);
        ledColor = Color.lerp(
          const Color(0xFFFF3366),  // Red
          const Color(0xFF00FF88),  // Green
          t,
        )!;
      } else {
        ledColor = color;
      }

      // Draw LED
      _drawLED(
        canvas,
        Offset(4, y + 2),
        Size(ledWidth, ledHeight),
        ledColor,
        isActive,
        i == value,  // Highlight current value
        brightnessFactor,
      );
    }
  }

  void _drawLED(
    Canvas canvas,
    Offset position,
    Size size,
    Color color,
    bool isActive,
    bool isCurrent,
    double brightness,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
      const Radius.circular(2),
    );

    // Background (inactive state)
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1);

    canvas.drawRRect(rect, bgPaint);

    if (isActive) {
      // Active LED
      final ledPaint = Paint()
        ..color = color.withOpacity(0.8 * brightness);

      canvas.drawRRect(rect, ledPaint);

      // Glow effect
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(0.6 * brightness),
            color.withOpacity(0.0),
          ],
        ).createShader(rect.outerRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isCurrent ? 4 : 2);

      canvas.drawRRect(rect, glowPaint);

      // Current value highlight
      if (isCurrent) {
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawRRect(rect, highlightPaint);
      }
    }

    // Border
    final borderPaint = Paint()
      ..color = isActive ? color : color.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(_LEDLadderPainter oldDelegate) {
    return oldDelegate.value != value ||
           oldDelegate.isDragging != isDragging ||
           oldDelegate.audioFeatures != audioFeatures;
  }
}
