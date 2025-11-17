/**
 * Audio Reactive Slider Widget
 *
 * Visual slider that displays base + modulation architecture:
 * - White thumb: Base value (user-controlled)
 * - Red ghost: Negative modulation limit (base - modulationDepth)
 * - Green ghost: Positive modulation limit (base + modulationDepth)
 * - Cyan ghost: Current final value (base + currentModulation, animated)
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/material.dart';
import '../../models/parameter_state.dart';
import '../theme/synth_theme.dart';

class AudioReactiveSlider extends StatelessWidget {
  final String label;
  final ParameterState parameterState;
  final ValueChanged<double> onChanged;
  final String? units;
  final int? decimalPlaces;
  final bool showModulationLimits;
  final bool enabled;

  const AudioReactiveSlider({
    Key? key,
    required this.label,
    required this.parameterState,
    required this.onChanged,
    this.units,
    this.decimalPlaces = 2,
    this.showModulationLimits = true,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: parameterState,
      builder: (context, _) {
        final baseValue = parameterState.baseValue;
        final finalValue = parameterState.finalValue;
        final negativeLimit = parameterState.negativeLimit;
        final positiveLimit = parameterState.positiveLimit;
        final minValue = parameterState.minValue;
        final maxValue = parameterState.maxValue;
        final modulationEnabled = parameterState.modulationEnabled;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label and value display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: SynthTheme.textPrimary,
                  ),
                ),
                _buildValueDisplay(baseValue, finalValue, modulationEnabled),
              ],
            ),
            const SizedBox(height: 4),

            // Custom slider with RGB ghosting
            SizedBox(
              height: 40,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    children: [
                      // Track background
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 18,
                        height: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: SynthTheme.surfaceDim.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Modulation range indicator (if enabled)
                      if (showModulationLimits && modulationEnabled)
                        _buildModulationRange(
                          width,
                          minValue,
                          maxValue,
                          negativeLimit,
                          positiveLimit,
                        ),

                      // Ghost thumbs (Red/Green limits + Cyan current)
                      if (showModulationLimits && modulationEnabled) ...[
                        _buildGhostThumb(
                          width,
                          minValue,
                          maxValue,
                          negativeLimit,
                          Colors.red.withOpacity(0.4),
                          'MIN',
                        ),
                        _buildGhostThumb(
                          width,
                          minValue,
                          maxValue,
                          positiveLimit,
                          Colors.green.withOpacity(0.4),
                          'MAX',
                        ),
                        _buildGhostThumb(
                          width,
                          minValue,
                          maxValue,
                          finalValue,
                          Colors.cyan.withOpacity(0.6),
                          'NOW',
                        ),
                      ],

                      // Main slider (base value control)
                      Slider(
                        value: baseValue,
                        min: minValue,
                        max: maxValue,
                        onChanged: enabled ? onChanged : null,
                        activeColor: SynthTheme.primary,
                        inactiveColor: SynthTheme.surfaceDim,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Modulation status indicator
            if (showModulationLimits)
              _buildModulationStatus(modulationEnabled, parameterState.currentModulation),
          ],
        );
      },
    );
  }

  /// Build value display showing base and final values
  Widget _buildValueDisplay(double baseValue, double finalValue, bool modulationEnabled) {
    final baseStr = baseValue.toStringAsFixed(decimalPlaces ?? 2);
    final finalStr = finalValue.toStringAsFixed(decimalPlaces ?? 2);
    final unitsStr = units ?? '';

    if (!modulationEnabled || (baseValue - finalValue).abs() < 0.001) {
      // No modulation active - show single value
      return Text(
        '$baseStr$unitsStr',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: SynthTheme.textPrimary,
        ),
      );
    } else {
      // Modulation active - show base + final
      return Row(
        children: [
          Text(
            '$baseStr',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SynthTheme.textSecondary,
            ),
          ),
          const Text(
            ' → ',
            style: TextStyle(
              fontSize: 10,
              color: SynthTheme.textSecondary,
            ),
          ),
          Text(
            '$finalStr$unitsStr',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
        ],
      );
    }
  }

  /// Build modulation range indicator
  Widget _buildModulationRange(
    double width,
    double minValue,
    double maxValue,
    double negativeLimit,
    double positiveLimit,
  ) {
    final range = maxValue - minValue;
    final negPos = (negativeLimit - minValue) / range;
    final posPos = (positiveLimit - minValue) / range;

    return Positioned(
      left: negPos * width,
      right: (1.0 - posPos) * width,
      top: 18,
      height: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.2),
              Colors.yellow.withOpacity(0.2),
              Colors.green.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Build ghost thumb indicator
  Widget _buildGhostThumb(
    double width,
    double minValue,
    double maxValue,
    double value,
    Color color,
    String label,
  ) {
    final range = maxValue - minValue;
    final normalizedPosition = (value - minValue) / range;

    return Positioned(
      left: normalizedPosition * width - 10,
      top: 10,
      child: Column(
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          // Ghost thumb
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.8),
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build modulation status indicator
  Widget _buildModulationStatus(bool enabled, double currentModulation) {
    if (!enabled) {
      return const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text(
          'Modulation: OFF',
          style: TextStyle(
            fontSize: 10,
            color: SynthTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final modStr = currentModulation >= 0 ? '+' : '';
    final modVal = currentModulation.toStringAsFixed(decimalPlaces ?? 2);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Mod: $modStr$modVal ${units ?? ''}',
        style: TextStyle(
          fontSize: 10,
          color: currentModulation.abs() > 0.01 ? Colors.cyan : SynthTheme.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// Integer version of AudioReactiveSlider for discrete parameters
class AudioReactiveIntSlider extends StatelessWidget {
  final String label;
  final IntParameterState parameterState;
  final ValueChanged<int> onChanged;
  final String? units;
  final bool showModulationLimits;
  final bool enabled;

  const AudioReactiveIntSlider({
    Key? key,
    required this.label,
    required this.parameterState,
    required this.onChanged,
    this.units,
    this.showModulationLimits = true,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AudioReactiveSlider(
      label: label,
      parameterState: parameterState,
      onChanged: (value) => onChanged(value.round()),
      units: units,
      decimalPlaces: 0,
      showModulationLimits: showModulationLimits,
      enabled: enabled,
    );
  }
}
