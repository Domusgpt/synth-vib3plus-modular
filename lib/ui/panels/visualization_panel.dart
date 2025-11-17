///
/// Visualization Panel
///
/// Panel for audio visualization and modulation indicators.
/// Provides real-time visual feedback for audio-visual coupling.
///
/// Features:
/// - Waveform/Spectrum/Oscilloscope visualizer
/// - Active modulation indicators
/// - Mode switching
/// - Compact layout for bottom bezel
///
/// A Paul Phillips Manifestation
///

library;

import 'package:flutter/material.dart';
import '../components/audio_visualizer.dart';
import '../components/modulation_indicator.dart';

class VisualizationPanel extends StatefulWidget {
  const VisualizationPanel({super.key});

  @override
  State<VisualizationPanel> createState() => _VisualizationPanelState();
}

class _VisualizationPanelState extends State<VisualizationPanel> {
  VisualizerMode _currentMode = VisualizerMode.spectrum;
  bool _showModulations = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode selector
          _buildModeSelector(),
          const SizedBox(height: 16),

          // Visualizer
          AudioVisualizer(
            height: 120,
            mode: _currentMode,
            showLabels: true,
          ),

          const SizedBox(height: 16),

          // Modulations toggle
          _buildModulationsToggle(),

          const SizedBox(height: 8),

          // Modulation indicators
          if (_showModulations) const CompactModulationIndicator(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Text(
          'Visualizer Mode:',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              _buildModeButton('Spectrum', VisualizerMode.spectrum),
              const SizedBox(width: 8),
              _buildModeButton('Waveform', VisualizerMode.waveform),
              const SizedBox(width: 8),
              _buildModeButton('Scope', VisualizerMode.oscilloscope),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, VisualizerMode mode) {
    final isSelected = _currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.cyan.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? Colors.cyan.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.cyan : Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModulationsToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showModulations = !_showModulations;
        });
      },
      child: Row(
        children: [
          Icon(
            _showModulations ? Icons.visibility : Icons.visibility_off,
            color: Colors.white.withValues(alpha: 0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Show Active Modulations',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Icon(
            _showModulations ? Icons.expand_less : Icons.expand_more,
            color: Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
        ],
      ),
    );
  }
}
