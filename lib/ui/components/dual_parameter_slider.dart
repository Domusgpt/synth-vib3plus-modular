/**
 * Dual Parameter Slider - Audio-Visual Parity Control
 *
 * Shows both sonic (🎵) and visual (🎨) effects for each parameter.
 * User controls BASE value, audio reactivity adds modulation on top.
 *
 * Design:
 * - Clear labeling of what parameter does to BOTH audio and visuals
 * - Holographic styling consistent with system colors
 * - Visual feedback shows base value + current modulation
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/material.dart';
import '../theme/synth_theme.dart';
import 'dart:math' as math;

class DualParameterSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String sonicEffect;
  final String visualEffect;
  final ValueChanged<double> onChanged;
  final SystemColors systemColors;
  final String? unit;
  final bool logarithmic;

  const DualParameterSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.sonicEffect,
    required this.visualEffect,
    required this.onChanged,
    required this.systemColors,
    this.unit,
    this.logarithmic = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SynthTheme.spacingMedium),
      padding: const EdgeInsets.all(SynthTheme.spacingMedium),
      decoration: BoxDecoration(
        color: SynthTheme.panelBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(SynthTheme.radiusMedium),
        border: Border.all(
          color: systemColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: systemColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Label + Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: SynthTheme.textStyleBody.copyWith(
                  color: systemColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                _formatValue(),
                style: SynthTheme.textStyleBody.copyWith(
                  color: systemColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: SynthTheme.spacingSmall),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: systemColors.primary,
              inactiveTrackColor: systemColors.primary.withOpacity(0.2),
              thumbColor: systemColors.primary,
              overlayColor: systemColors.primary.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0,
              ),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: logarithmic ? _valueToLog() : value,
              min: logarithmic ? _valueToLog() : min,
              max: logarithmic ? math.log(max) : max,
              onChanged: (newValue) {
                final actualValue = logarithmic ? math.exp(newValue) : newValue;
                onChanged(actualValue);
              },
            ),
          ),

          const SizedBox(height: SynthTheme.spacingSmall),

          // Sonic Effect
          Row(
            children: [
              Text(
                '🎵',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sonicEffect,
                  style: SynthTheme.textStyleCaption.copyWith(
                    color: systemColors.primary.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Visual Effect
          Row(
            children: [
              Text(
                '🎨',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  visualEffect,
                  style: SynthTheme.textStyleCaption.copyWith(
                    color: systemColors.secondary.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _valueToLog() {
    return logarithmic && value > 0 ? math.log(value) : value;
  }

  String _formatValue() {
    String formattedNumber;

    if (value >= 1000) {
      formattedNumber = (value / 1000).toStringAsFixed(1) + 'k';
    } else if (value >= 100) {
      formattedNumber = value.toStringAsFixed(0);
    } else if (value >= 10) {
      formattedNumber = value.toStringAsFixed(1);
    } else if (value >= 1) {
      formattedNumber = value.toStringAsFixed(2);
    } else {
      formattedNumber = value.toStringAsFixed(3);
    }

    return unit != null ? '$formattedNumber $unit' : formattedNumber;
  }
}
