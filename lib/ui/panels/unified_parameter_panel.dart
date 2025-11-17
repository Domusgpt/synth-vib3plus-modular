///
/// Unified Parameter Panel - Audio-Visual Parity
///
/// Each control affects BOTH sound and visuals simultaneously.
/// Visual reactivity is always on - parameters naturally emerge
/// from the hybrid control philosophy.
///
/// Every slider shows:
/// - 🎵 Sonic effect (what it does to sound)
/// - 🎨 Visual effect (what it does to visualization)
/// - Base value (user control) ± Audio modulation (automatic)
///
/// A Paul Phillips Manifestation
///

library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/synth_theme.dart';
import '../components/dual_parameter_slider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/visual_provider.dart';

class UnifiedParameterPanel extends StatelessWidget {
  const UnifiedParameterPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final visualProvider = Provider.of<VisualProvider>(context);
    // Parameter coupling is handled by ParameterCouplingModule automatically
    final systemColors = audioProvider.systemColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SynthTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================================================================
          // SECTION 1: TIMBRE & ARTICULATION
          // ================================================================
          _buildSectionHeader('TIMBRE & ARTICULATION', systemColors),
          const SizedBox(height: SynthTheme.spacingSmall),

          DualParameterSlider(
            label: 'Morph',
            value: visualProvider.morphParameter,
            min: 0.0,
            max: 1.0,
            sonicEffect: '🎵 Wavetable crossfade (sine→saw)',
            visualEffect: '🎨 Geometry morph (smooth→angular)',
            onChanged: (value) {
              // Set visual morph parameter
              visualProvider.setMorphParameter(value);
              // Set audio wavetable position
              audioProvider.synthesizerEngine.setWavetablePosition(value);
            },
            systemColors: systemColors,
          ),

          // TODO: Re-enable Chaos slider once chaos parameter is properly integrated
          // DualParameterSlider(
          //   label: 'Chaos',
          //   value: 0.2,
          //   min: 0.0,
          //   max: 1.0,
          //   sonicEffect: '🎵 Noise injection (0-30%)',
          //   visualEffect: '🎨 Vertex randomization',
          //   onChanged: (value) {
          //     audioProvider.synthesizerEngine.setNoiseAmount(value);
          //   },
          //   systemColors: systemColors,
          // ),

          DualParameterSlider(
            label: 'Attack',
            value: audioProvider.envelopeAttack * 1000.0, // Convert to ms
            min: 1.0,
            max: 2000.0,
            sonicEffect: '🎵 Note onset time',
            visualEffect: '🎨 Glow bloom speed',
            onChanged: (value) {
              final seconds = value / 1000.0;
              audioProvider.setEnvelopeAttack(seconds);
              // Visual glow attack is derived from audio in parameter bridge
            },
            systemColors: systemColors,
            unit: 'ms',
          ),

          DualParameterSlider(
            label: 'Release',
            value: audioProvider.envelopeRelease * 1000.0,
            min: 10.0,
            max: 5000.0,
            sonicEffect: '🎵 Note fade time',
            visualEffect: '🎨 Glow decay speed',
            onChanged: (value) {
              final seconds = value / 1000.0;
              audioProvider.setEnvelopeRelease(seconds);
            },
            systemColors: systemColors,
            unit: 'ms',
          ),

          const SizedBox(height: SynthTheme.spacingLarge),

          // ================================================================
          // SECTION 2: SPECTRAL SHAPING
          // ================================================================
          _buildSectionHeader('SPECTRAL SHAPING', systemColors),
          const SizedBox(height: SynthTheme.spacingSmall),

          DualParameterSlider(
            label: 'Filter Cutoff',
            value: audioProvider.filterCutoff,
            min: 20.0,
            max: 20000.0,
            sonicEffect: '🎵 Frequency brightness',
            visualEffect: '🎨 Vertex brightness',
            onChanged: (value) {
              audioProvider.setFilterCutoff(value);
              // Visual brightness modulation happens in bridge
            },
            systemColors: systemColors,
            unit: 'Hz',
            logarithmic: true,
          ),

          DualParameterSlider(
            label: 'Resonance',
            value: audioProvider.filterResonance,
            min: 0.0,
            max: 1.0,
            sonicEffect: '🎵 Filter peak emphasis',
            visualEffect: '🎨 Edge definition',
            onChanged: (value) {
              audioProvider.setFilterResonance(value);
              // Edge thickness derived in bridge
            },
            systemColors: systemColors,
          ),

          DualParameterSlider(
            label: 'Oscillator Mix',
            value: audioProvider.mixBalance,
            min: 0.0,
            max: 1.0,
            sonicEffect: '🎵 OSC1 ← → OSC2',
            visualEffect: '🎨 Layer balance',
            onChanged: (value) {
              audioProvider.setMixBalance(value);
            },
            systemColors: systemColors,
          ),

          const SizedBox(height: SynthTheme.spacingLarge),

          // ================================================================
          // SECTION 3: SPATIAL DEPTH
          // ================================================================
          _buildSectionHeader('SPATIAL DEPTH', systemColors),
          const SizedBox(height: SynthTheme.spacingSmall),

          DualParameterSlider(
            label: 'Reverb',
            value: audioProvider.reverbMix,
            min: 0.0,
            max: 1.0,
            sonicEffect: '🎵 Spatial wetness',
            visualEffect: '🎨 Projection distance',
            onChanged: (value) {
              audioProvider.setReverbMix(value);
              visualProvider.setProjectionDistance(5.0 + (value * 10.0));
            },
            systemColors: systemColors,
          ),

          DualParameterSlider(
            label: 'Reverb Size',
            value: audioProvider.reverbRoomSize,
            min: 0.0,
            max: 1.0,
            sonicEffect: '🎵 Room dimensions',
            visualEffect: '🎨 Scale expansion',
            onChanged: (value) {
              audioProvider.setReverbRoomSize(value);
              visualProvider.setScale(0.5 + (value * 1.5));
            },
            systemColors: systemColors,
          ),

          DualParameterSlider(
            label: 'Delay Time',
            value: audioProvider.delayTime,
            min: 1.0,
            max: 2000.0,
            sonicEffect: '🎵 Echo timing',
            visualEffect: '🎨 Layer separation',
            onChanged: (value) {
              audioProvider.setDelayTime(value);
              visualProvider.setLayerDepth(value / 400.0); // 0-5 range
            },
            systemColors: systemColors,
            unit: 'ms',
          ),

          DualParameterSlider(
            label: 'Delay Feedback',
            value: audioProvider.delayFeedback,
            min: 0.0,
            max: 0.95,
            sonicEffect: '🎵 Echo repetitions',
            visualEffect: '🎨 Shimmer trails',
            onChanged: (value) {
              audioProvider.setDelayFeedback(value);
              visualProvider.setShimmerSpeed(value * 10.0);
            },
            systemColors: systemColors,
          ),

          const SizedBox(height: SynthTheme.spacingLarge),

          // ================================================================
          // SECTION 4: COMPLEXITY & DENSITY
          // ================================================================
          _buildSectionHeader('COMPLEXITY & DENSITY', systemColors),
          const SizedBox(height: SynthTheme.spacingSmall),

          _buildInfoText(
            '🎵 Polyphony: ${audioProvider.voiceCount} voices active',
            '🎨 Tessellation: Auto-mapped from polyphony',
            systemColors,
          ),

          _buildInfoText(
            '🎵 System: ${audioProvider.currentSynthesisBranch}',
            '🎨 Visual: ${visualProvider.currentSystem}',
            systemColors,
          ),

          const SizedBox(height: SynthTheme.spacingLarge),

          // ================================================================
          // SECTION 5: AUTOMATIC AUDIO REACTIVITY
          // ================================================================
          _buildSectionHeader('AUDIO REACTIVITY (ALWAYS ON)', systemColors),
          const SizedBox(height: SynthTheme.spacingSmall),

          _buildReactivityInfo(systemColors),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, SystemColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SynthTheme.spacingSmall,
        vertical: SynthTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colors.primary,
            width: 3.0,
          ),
        ),
      ),
      child: Text(
        title,
        style: SynthTheme.textStyleHeading.copyWith(
          color: colors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoText(
      String sonicText, String visualText, SystemColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SynthTheme.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sonicText,
            style: SynthTheme.textStyleBody.copyWith(
              color: colors.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            visualText,
            style: SynthTheme.textStyleBody.copyWith(
              color: colors.secondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactivityInfo(SystemColors colors) {
    return Container(
      padding: const EdgeInsets.all(SynthTheme.spacingMedium),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(SynthTheme.radiusMedium),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Audio → Visual Coupling (60 FPS)',
            style: SynthTheme.textStyleBody.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SynthTheme.spacingSmall),
          _buildReactivityItem('Bass Energy → XY Rotation', colors),
          _buildReactivityItem('Mid Energy → XZ Rotation', colors),
          _buildReactivityItem(
              'High Energy → YZ Rotation + Vertex Brightness', colors),
          _buildReactivityItem(
              'RMS Amplitude → Rotation Speed + Scale', colors),
          _buildReactivityItem('Spectral Centroid → Hue Shift + Glow', colors),
          _buildReactivityItem('Spectral Flux → Morph Modulation', colors),
          _buildReactivityItem('Noise Content → Chaos Modulation', colors),
          _buildReactivityItem(
              'Transients → 4D Rotation + Particle Density', colors),
          _buildReactivityItem('Polyphony → Tessellation Density', colors),
          const SizedBox(height: SynthTheme.spacingSmall),
          Text(
            'All visual parameters automatically modulate based on sound analysis. '
            'Sliders set BASE values - audio reactivity adds ± modulation on top.',
            style: SynthTheme.textStyleCaption.copyWith(
              color: colors.primary.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactivityItem(String text, SystemColors colors) {
    return Padding(
      padding: const EdgeInsets.only(
        left: SynthTheme.spacingSmall,
        top: 4,
      ),
      child: Row(
        children: [
          Icon(
            Icons.arrow_forward,
            size: 12,
            color: colors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: SynthTheme.textStyleCaption.copyWith(
                color: colors.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
