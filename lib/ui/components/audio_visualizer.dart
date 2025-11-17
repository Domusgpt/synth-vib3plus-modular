///
/// Audio Visualizer Widget
///
/// Real-time waveform and spectrum display with multiple visualization modes.
/// Provides immediate visual feedback for synthesis and audio reactivity.
///
/// Features:
/// - Waveform display (time domain)
/// - Spectrum analyzer (frequency domain)
/// - Oscilloscope mode
/// - System-themed colors (Quantum/Faceted/Holographic)
/// - Smooth animations and transitions
///
/// A Paul Phillips Manifestation
///

library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../audio/audio_analyzer.dart';
import '../../providers/audio_provider.dart';
import '../../providers/visual_provider.dart';
import '../theme/design_tokens.dart';

enum VisualizerMode {
  waveform,
  spectrum,
  oscilloscope,
}

class AudioVisualizer extends StatefulWidget {
  final double height;
  final VisualizerMode mode;
  final bool showLabels;

  const AudioVisualizer({
    Key? key,
    this.height = 120.0,
    this.mode = VisualizerMode.spectrum,
    this.showLabels = true,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final visualProvider = Provider.of<VisualProvider>(context);
    final features = audioProvider.currentFeatures;

    if (features == null) {
      return _buildEmptyState(visualProvider.currentSystem);
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSystemColor(visualProvider.currentSystem).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Visualizer canvas
            CustomPaint(
              size: Size.infinite,
              painter: _VisualizerPainter(
                mode: widget.mode,
                features: features,
                systemColor: _getSystemColor(visualProvider.currentSystem),
                animationValue: _animationController.value,
              ),
            ),
            // Labels overlay
            if (widget.showLabels)
              _buildLabels(features, visualProvider.currentSystem),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String systemName) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSystemColor(systemName).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Play a note to visualize',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLabels(AudioFeatures features, String systemName) {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLabel('BASS', features.bassEnergy, Colors.red),
          _buildLabel('MID', features.midEnergy, Colors.green),
          _buildLabel('HIGH', features.highEnergy, Colors.blue),
          _buildLabel('RMS', features.rms, _getSystemColor(systemName)),
        ],
      ),
    );
  }

  Widget _buildLabel(String name, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSystemColor(String systemName) {
    switch (systemName.toLowerCase()) {
      case 'quantum':
        return DesignTokens.quantum;
      case 'faceted':
        return DesignTokens.faceted;
      case 'holographic':
        return DesignTokens.holographic;
      default:
        return DesignTokens.quantum;
    }
  }
}

class _VisualizerPainter extends CustomPainter {
  final VisualizerMode mode;
  final AudioFeatures features;
  final Color systemColor;
  final double animationValue;

  _VisualizerPainter({
    required this.mode,
    required this.features,
    required this.systemColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (mode) {
      case VisualizerMode.waveform:
        _drawWaveform(canvas, size);
        break;
      case VisualizerMode.spectrum:
        _drawSpectrum(canvas, size);
        break;
      case VisualizerMode.oscilloscope:
        _drawOscilloscope(canvas, size);
        break;
    }
  }

  void _drawWaveform(Canvas canvas, Size size) {
    // Draw center line
    final centerLinePaint = Paint()
      ..color = systemColor.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerLinePaint,
    );

    // Draw waveform from frequency spectrum
    final paint = Paint()
      ..color = systemColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final segments = 100;

    for (int i = 0; i < segments; i++) {
      final x = (i / segments) * size.width;

      // Combine different frequency bands for synthetic waveform
      final bassContribution = features.bassEnergy *
          math.sin(i * 0.5 + animationValue * math.pi * 2);
      final midContribution =
          features.midEnergy * math.sin(i * 1.5 + animationValue * math.pi * 4);
      final highContribution = features.highEnergy *
          math.sin(i * 3.0 + animationValue * math.pi * 8);

      final amplitude =
          (bassContribution + midContribution * 0.5 + highContribution * 0.3) /
              1.8;
      final y = size.height / 2 + amplitude * (size.height / 2 - 20);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw glow effect
    final glowPaint = Paint()
      ..color = systemColor.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);
  }

  void _drawSpectrum(Canvas canvas, Size size) {
    // Draw frequency bars
    final barCount = 32;
    final barWidth = size.width / barCount;
    final spacing = barWidth * 0.1;

    for (int i = 0; i < barCount; i++) {
      // Map bar to frequency ranges
      double barValue;
      if (i < 8) {
        // Bass range (0-8)
        barValue = features.bassEnergy;
      } else if (i < 20) {
        // Mid range (8-20)
        barValue = features.midEnergy;
      } else {
        // High range (20-32)
        barValue = features.highEnergy;
      }

      // Add some variation
      final variation =
          math.sin(i * 0.5 + animationValue * math.pi * 2) * 0.2 + 1.0;
      barValue *= variation;
      barValue = barValue.clamp(0.0, 1.0);

      final barHeight = barValue * (size.height - 40) + 10;
      final x = i * barWidth + spacing;

      // Color gradient based on frequency
      final hue = (i / barCount) * 120; // 0-120 degrees (red to green)
      final barColor = HSVColor.fromAHSV(1.0, hue, 0.8, 1.0).toColor();

      // Draw bar
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            barColor.withValues(alpha: 0.8),
            systemColor.withValues(alpha: 0.6),
          ],
        ).createShader(Rect.fromLTWH(
            x, size.height - barHeight, barWidth - spacing * 2, barHeight));

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          size.height - barHeight,
          barWidth - spacing * 2,
          barHeight,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(barRect, barPaint);

      // Draw glow
      if (barValue > 0.3) {
        final glowPaint = Paint()
          ..color = barColor.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawRRect(barRect, glowPaint);
      }
    }
  }

  void _drawOscilloscope(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = systemColor.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Vertical lines
    for (int i = 0; i <= 10; i++) {
      final x = (i / 10) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (int i = 0; i <= 5; i++) {
      final y = (i / 5) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw Lissajous curve (XY plot)
    final paint = Paint()
      ..color = systemColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final segments = 200;

    for (int i = 0; i < segments; i++) {
      final t = (i / segments) * math.pi * 2;

      // X: Bass + Mid modulation
      final xPhase =
          features.bassEnergy * math.sin(t * 2 + animationValue * math.pi * 2);
      final x = size.width / 2 + xPhase * (size.width / 2 - 20);

      // Y: Mid + High modulation
      final yPhase =
          features.midEnergy * math.sin(t * 3 + animationValue * math.pi * 3) +
              features.highEnergy * math.cos(t * 5);
      final y = size.height / 2 + yPhase * (size.height / 2 - 20);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw glow
    final glowPaint = Paint()
      ..color = systemColor.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    // Draw main path
    canvas.drawPath(path, paint);

    // Draw center dot
    final centerPaint = Paint()
      ..color = systemColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(_VisualizerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.features.rms != features.rms;
  }
}
