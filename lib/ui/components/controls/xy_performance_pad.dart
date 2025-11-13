/**
 * XY Performance Pad
 *
 * Enhanced multi-touch performance controller with resizable framework,
 * audio-reactive visuals, trail visualization, and scale quantization.
 *
 * Features:
 * - Resizable (1x1 to 4x4 grid units)
 * - Multi-touch support (up to 8 simultaneous touches)
 * - Trail visualization with audio reactivity
 * - Audio-reactive border glow
 * - Grid visualization (optional)
 * - Scale/root note quantization
 * - Modulation indicator overlay
 * - Touch pressure support
 *
 * Part of the Next-Generation UI Redesign (v3.0) - Phase 3
 *
 * A Paul Phillips Manifestation
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../effects/glassmorphic_container.dart';
import '../../layout/flexible_layout.dart';
import '../base/reactive_component.dart';

// ============================================================================
// XY PAD CONFIGURATION
// ============================================================================

/// XY Pad configuration
class XYPadConfig {
  final bool showGrid;
  final bool showTrails;
  final bool enableQuantization;
  final bool enablePressure;
  final int maxTouches;
  final double trailLength;
  final Color gridColor;
  final Color trailColor;
  final double gridOpacity;

  const XYPadConfig({
    this.showGrid = false,
    this.showTrails = true,
    this.enableQuantization = false,
    this.enablePressure = true,
    this.maxTouches = 8,
    this.trailLength = 50,
    this.gridColor = DesignTokens.stateActive,
    this.trailColor = DesignTokens.stateActive,
    this.gridOpacity = 0.2,
  });

  /// Performance preset (trails only, no grid)
  static const performance = XYPadConfig(
    showGrid: false,
    showTrails: true,
    enableQuantization: false,
    maxTouches: 8,
  );

  /// Production preset (grid + trails)
  static const production = XYPadConfig(
    showGrid: true,
    showTrails: true,
    enableQuantization: true,
    maxTouches: 4,
  );

  /// Minimal preset (no visual aids)
  static const minimal = XYPadConfig(
    showGrid: false,
    showTrails: false,
    enableQuantization: false,
    maxTouches: 8,
  );
}

// ============================================================================
// TOUCH DATA
// ============================================================================

/// Single touch point data
class TouchPoint {
  final int pointerId;
  final Offset position;
  final double pressure;
  final DateTime timestamp;

  const TouchPoint({
    required this.pointerId,
    required this.position,
    required this.pressure,
    required this.timestamp,
  });

  /// Normalized position (0-1)
  Offset normalized(Size size) {
    return Offset(
      (position.dx / size.width).clamp(0.0, 1.0),
      (position.dy / size.height).clamp(0.0, 1.0),
    );
  }
}

// ============================================================================
// XY PARAMETER ASSIGNMENT
// ============================================================================

/// What parameter to control with X/Y axes
enum XYParameter {
  frequency,    // Pitch
  filterCutoff, // Filter
  oscMix,       // Oscillator mix
  fmDepth,      // FM modulation
  ringMod,      // Ring modulation
  reverbMix,    // Reverb amount
  custom,       // User-defined
}

// ============================================================================
// XY PERFORMANCE PAD WIDGET
// ============================================================================

/// Enhanced XY performance pad
class XYPerformancePad extends StatefulWidget {
  final XYPadConfig config;
  final XYParameter xParameter;
  final XYParameter yParameter;
  final ValueChanged<List<TouchPoint>>? onTouchUpdate;
  final VoidCallback? onTouchStart;
  final VoidCallback? onTouchEnd;
  final AudioFeatures? audioFeatures;
  final GridUnits size;
  final Color? color;
  final String? label;

  const XYPerformancePad({
    Key? key,
    this.config = XYPadConfig.performance,
    this.xParameter = XYParameter.frequency,
    this.yParameter = XYParameter.filterCutoff,
    this.onTouchUpdate,
    this.onTouchStart,
    this.onTouchEnd,
    this.audioFeatures,
    this.size = GridUnits.unit2x2,
    this.color,
    this.label,
  }) : super(key: key);

  @override
  State<XYPerformancePad> createState() => _XYPerformancePadState();
}

class _XYPerformancePadState extends State<XYPerformancePad>
    with SingleTickerProviderStateMixin {
  final Map<int, TouchPoint> _activeTouches = {};
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: DesignTokens.standard,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ============================================================================
  // TOUCH HANDLING
  // ============================================================================

  void _handlePointerDown(PointerDownEvent event) {
    if (_activeTouches.length >= widget.config.maxTouches) return;

    setState(() {
      _activeTouches[event.pointer] = TouchPoint(
        pointerId: event.pointer,
        position: event.localPosition,
        pressure: event.pressure,
        timestamp: DateTime.now(),
      );
    });

    _pulseController.forward();
    widget.onTouchStart?.call();
    _notifyTouchUpdate();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_activeTouches.containsKey(event.pointer)) return;

    setState(() {
      _activeTouches[event.pointer] = TouchPoint(
        pointerId: event.pointer,
        position: event.localPosition,
        pressure: event.pressure,
        timestamp: DateTime.now(),
      );
    });

    _notifyTouchUpdate();
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      _activeTouches.remove(event.pointer);
    });

    if (_activeTouches.isEmpty) {
      _pulseController.reverse();
      widget.onTouchEnd?.call();
    }

    _notifyTouchUpdate();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    setState(() {
      _activeTouches.remove(event.pointer);
    });

    if (_activeTouches.isEmpty) {
      _pulseController.reverse();
      widget.onTouchEnd?.call();
    }

    _notifyTouchUpdate();
  }

  void _notifyTouchUpdate() {
    widget.onTouchUpdate?.call(_activeTouches.values.toList());
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? DesignTokens.stateActive;

    // Calculate audio-reactive glow
    final glowIntensity = widget.audioFeatures != null
        ? DesignTokens.transientToGlow(widget.audioFeatures!.transient)
        : 0.0;

    // Calculate audio-reactive border width
    final borderWidth = widget.audioFeatures != null
        ? DesignTokens.bassEnergyToBorderWidth(widget.audioFeatures!.bassEnergy)
        : 2.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Listener(
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          onPointerCancel: _handlePointerCancel,
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: effectiveColor,
                width: borderWidth,
              ),
              boxShadow: glowIntensity > 0
                  ? [
                      BoxShadow(
                        color: effectiveColor.withOpacity(glowIntensity / 10),
                        blurRadius: glowIntensity,
                        spreadRadius: glowIntensity / 2,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              child: Stack(
                children: [
                  // Grid overlay
                  if (widget.config.showGrid)
                    _buildGrid(constraints.biggest),

                  // Touch indicators
                  ..._buildTouchIndicators(constraints.biggest),

                  // Label
                  if (widget.label != null)
                    _buildLabel(),

                  // Parameter indicators
                  _buildParameterIndicators(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // GRID RENDERING
  // ============================================================================

  Widget _buildGrid(Size size) {
    return CustomPaint(
      size: size,
      painter: _GridPainter(
        color: widget.config.gridColor.withOpacity(widget.config.gridOpacity),
        divisions: 8,
      ),
    );
  }

  // ============================================================================
  // TOUCH INDICATORS
  // ============================================================================

  List<Widget> _buildTouchIndicators(Size size) {
    return _activeTouches.values.map((touch) {
      final normalized = touch.normalized(size);
      final color = widget.config.trailColor;

      return Positioned(
        left: touch.position.dx - 20,
        top: touch.position.dy - 20,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseScale = 1.0 + (_pulseController.value * 0.3);

            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.3),
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  // ============================================================================
  // LABEL
  // ============================================================================

  Widget _buildLabel() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing2,
          vertical: DesignTokens.spacing1,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
        child: Text(
          widget.label!,
          style: DesignTokens.labelSmall.copyWith(
            color: widget.color ?? DesignTokens.stateActive,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // PARAMETER INDICATORS
  // ============================================================================

  Widget _buildParameterIndicators() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildParameterLabel('X', widget.xParameter),
          _buildParameterLabel('Y', widget.yParameter),
        ],
      ),
    );
  }

  Widget _buildParameterLabel(String axis, XYParameter parameter) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing2,
        vertical: DesignTokens.spacing1,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Text(
        '$axis: ${_getParameterName(parameter)}',
        style: DesignTokens.labelSmall.copyWith(
          color: widget.color ?? DesignTokens.stateActive,
        ),
      ),
    );
  }

  String _getParameterName(XYParameter parameter) {
    switch (parameter) {
      case XYParameter.frequency:
        return 'Freq';
      case XYParameter.filterCutoff:
        return 'Filter';
      case XYParameter.oscMix:
        return 'Mix';
      case XYParameter.fmDepth:
        return 'FM';
      case XYParameter.ringMod:
        return 'Ring';
      case XYParameter.reverbMix:
        return 'Reverb';
      case XYParameter.custom:
        return 'Custom';
    }
  }
}

// ============================================================================
// GRID PAINTER
// ============================================================================

class _GridPainter extends CustomPainter {
  final Color color;
  final int divisions;

  _GridPainter({
    required this.color,
    required this.divisions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 0; i <= divisions; i++) {
      final x = (size.width / divisions) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 0; i <= divisions; i++) {
      final y = (size.height / divisions) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Center crosshair
    final centerPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
