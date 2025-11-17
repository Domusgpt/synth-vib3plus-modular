///
/// Modulation Indicator Widget
///
/// Real-time visual feedback for parameter modulation showing active
/// audio-visual coupling with animated meters and value displays.
///
/// Displays:
/// - Audio → Visual modulations (5 mappings)
/// - Visual → Audio modulations (6 mappings)
/// - Modulation depth with color-coded meters
/// - Current values and ranges
///
/// A Paul Phillips Manifestation
///

library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/visual_provider.dart';
import '../theme/design_tokens.dart';

class ModulationIndicator extends StatefulWidget {
  final bool showAudioToVisual;
  final bool showVisualToAudio;
  final bool compact;

  const ModulationIndicator({
    super.key,
    this.showAudioToVisual = true,
    this.showVisualToAudio = true,
    this.compact = false,
  });

  @override
  State<ModulationIndicator> createState() => _ModulationIndicatorState();
}

class _ModulationIndicatorState extends State<ModulationIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final visualProvider = Provider.of<VisualProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.quantum.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          if (widget.showAudioToVisual) ...[
            _buildSectionTitle('Audio → Visual', Colors.green),
            const SizedBox(height: 8),
            _buildAudioToVisualModulations(audioProvider, visualProvider),
            if (widget.showVisualToAudio) const SizedBox(height: 16),
          ],
          if (widget.showVisualToAudio) ...[
            _buildSectionTitle('Visual → Audio', Colors.blue),
            const SizedBox(height: 8),
            _buildVisualToAudioModulations(audioProvider, visualProvider),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.sync_alt,
          color: DesignTokens.quantum,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Active Modulations',
          style: TextStyle(
            color: DesignTokens.quantum,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green
                    .withValues(alpha: 0.5 + _pulseController.value * 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.5),
                    blurRadius: 4 + _pulseController.value * 4,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAudioToVisualModulations(
    AudioProvider audioProvider,
    VisualProvider visualProvider,
  ) {
    final features = audioProvider.currentFeatures;
    if (features == null) {
      return _buildNoDataMessage('Play audio to see modulations');
    }

    return Column(
      children: [
        _buildModulationMeter(
          'Bass → Rotation Speed',
          features.bassEnergy,
          '${(features.bassEnergy * 2.0 + 0.5).toStringAsFixed(2)}x',
          Colors.red,
        ),
        _buildModulationMeter(
          'Mid → Tessellation',
          features.midEnergy,
          (features.midEnergy * 5 + 3).toStringAsFixed(0),
          Colors.orange,
        ),
        _buildModulationMeter(
          'High → Brightness',
          features.highEnergy,
          (features.highEnergy * 0.5 + 0.5).toStringAsFixed(2),
          Colors.yellow,
        ),
        _buildModulationMeter(
          'Centroid → Hue Shift',
          features.spectralCentroid / 8000.0,
          '${(features.spectralCentroid / 8000.0 * 360).toStringAsFixed(0)}°',
          Colors.cyan,
        ),
        _buildModulationMeter(
          'RMS → Glow',
          features.rms,
          (features.rms * 3.0).toStringAsFixed(2),
          Colors.white,
        ),
      ],
    );
  }

  Widget _buildVisualToAudioModulations(
    AudioProvider audioProvider,
    VisualProvider visualProvider,
  ) {
    return Column(
      children: [
        _buildModulationMeter(
          'XW Rotation → Osc1 Freq',
          (visualProvider.rotationXW.abs() / math.pi).clamp(0.0, 1.0),
          '${(visualProvider.rotationXW / math.pi * 2).toStringAsFixed(2)} st',
          Colors.purple,
        ),
        _buildModulationMeter(
          'YW Rotation → Osc2 Freq',
          (visualProvider.rotationYW.abs() / math.pi).clamp(0.0, 1.0),
          '${(visualProvider.rotationYW / math.pi * 2).toStringAsFixed(2)} st',
          Colors.pink,
        ),
        _buildModulationMeter(
          'ZW Rotation → Filter Cutoff',
          (visualProvider.rotationZW.abs() / math.pi).clamp(0.0, 1.0),
          '${(visualProvider.rotationZW / math.pi * 40).toStringAsFixed(0)}%',
          Colors.blue,
        ),
        _buildModulationMeter(
          'Morph → Wavetable',
          visualProvider.morphParameter,
          '${(visualProvider.morphParameter * 100).toStringAsFixed(0)}%',
          Colors.teal,
        ),
        _buildModulationMeter(
          'Projection → Reverb',
          visualProvider.projectionDistance.clamp(0.0, 1.0),
          '${(visualProvider.projectionDistance * 100).toStringAsFixed(0)}%',
          Colors.indigo,
        ),
        _buildModulationMeter(
          'Layer Depth → Delay',
          visualProvider.layerSeparation.clamp(0.0, 1.0),
          '${(visualProvider.layerSeparation * 500).toStringAsFixed(0)} ms',
          Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildModulationMeter(
    String label,
    double value,
    String displayValue,
    Color color,
  ) {
    value = value.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: widget.compact ? 120 : 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: widget.compact ? 9 : 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Meter bar
          Expanded(
            child: Stack(
              children: [
                // Background
                Container(
                  height: widget.compact ? 12 : 16,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Filled portion
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: widget.compact ? 12 : 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.6),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: value > 0.3
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Value display
          SizedBox(
            width: widget.compact ? 40 : 50,
            child: Text(
              displayValue,
              style: TextStyle(
                color: color,
                fontSize: widget.compact ? 9 : 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

/// Compact version for minimal space usage
class CompactModulationIndicator extends StatelessWidget {
  const CompactModulationIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulationIndicator(
      showAudioToVisual: true,
      showVisualToAudio: true,
      compact: true,
    );
  }
}
