/**
 * Enhanced Oscillator with Anti-Aliasing
 *
 * Professional oscillator implementation with:
 * - PolyBLEP anti-aliasing for square and sawtooth
 * - Multiple waveform morphing
 * - Phase modulation (FM) support
 * - Pulse width modulation for square wave
 * - Sync and sub-oscillator support
 *
 * A Paul Phillips Manifestation
 */

import 'dart:math' as math;
import 'audio_enhancements.dart';

enum EnhancedWaveform {
  sine,
  sawtooth,
  square,
  triangle,
  pulse, // Variable pulse width
  noise,
}

class EnhancedOscillator {
  final double sampleRate;

  // Oscillator state
  double phase = 0.0;
  double baseFrequency = 440.0;
  EnhancedWaveform waveform = EnhancedWaveform.sawtooth;

  // Modulation
  double frequencyModulation = 0.0; // In semitones (±12)
  double phaseModulation = 0.0; // 0-1 for FM synthesis
  double pulseWidth = 0.5; // For pulse wave (0.1-0.9)

  // Wavetable position for morphing
  double wavetablePosition = 0.0; // 0-1

  // Sub-oscillator
  bool enableSubOscillator = false;
  double subOscillatorLevel = 0.0;
  double subPhase = 0.0;

  // Hard sync
  bool enableSync = false;
  double syncFrequency = 440.0;
  double syncPhase = 0.0;

  // Anti-aliasing
  double _lastPhaseIncrement = 0.0;

  // Random number generator for noise
  final math.Random _random = math.Random();

  EnhancedOscillator({required this.sampleRate});

  /// Generate next sample
  double nextSample() {
    // Calculate frequency with modulation
    final freqRatio = math.pow(2.0, frequencyModulation / 12.0);
    final frequency = baseFrequency * freqRatio;
    final phaseIncrement = frequency / sampleRate;

    // Store for anti-aliasing
    _lastPhaseIncrement = phaseIncrement;

    // Handle sync
    if (enableSync) {
      final syncIncrement = syncFrequency / sampleRate;
      syncPhase += syncIncrement;
      if (syncPhase >= 1.0) {
        syncPhase -= 1.0;
        phase = 0.0; // Hard reset phase on sync
      }
    }

    // Apply phase modulation (FM)
    final modulatedPhase = (phase + phaseModulation).remainder(1.0);

    // Generate waveform
    double sample = _generateWaveform(modulatedPhase, phaseIncrement);

    // Add sub-oscillator (one octave down)
    if (enableSubOscillator && subOscillatorLevel > 0.0) {
      subPhase += phaseIncrement * 0.5; // Half frequency
      if (subPhase >= 1.0) subPhase -= 1.0;
      final subSample = _generateWaveform(subPhase, phaseIncrement * 0.5);
      sample = sample * (1.0 - subOscillatorLevel) + subSample * subOscillatorLevel;
    }

    // Advance phase
    phase += phaseIncrement;
    if (phase >= 1.0) phase -= 1.0;

    return sample;
  }

  /// Generate waveform with anti-aliasing
  double _generateWaveform(double ph, double phaseInc) {
    switch (waveform) {
      case EnhancedWaveform.sine:
        return math.sin(ph * 2.0 * math.pi);

      case EnhancedWaveform.sawtooth:
        return PolyBLEP.sawtoothAA(ph, phaseInc);

      case EnhancedWaveform.square:
        return PolyBLEP.squareAA(ph, phaseInc);

      case EnhancedWaveform.triangle:
        return PolyBLEP.triangleAA(ph, phaseInc);

      case EnhancedWaveform.pulse:
        // Variable pulse width with anti-aliasing
        final pw = pulseWidth.clamp(0.1, 0.9);
        double sample = ph < pw ? 1.0 : -1.0;
        sample += PolyBLEP.polyBlep(ph, phaseInc);
        sample -= PolyBLEP.polyBlep((ph - pw + 1.0) % 1.0, phaseInc);
        return sample;

      case EnhancedWaveform.noise:
        return _random.nextDouble() * 2.0 - 1.0;
    }
  }

  /// Morph between waveforms using wavetable position
  double nextSampleMorphed() {
    // Use wavetable position to blend between waveforms
    final pos = wavetablePosition * 4.0; // 0-4 range for 5 waveforms
    final index = pos.floor();
    final frac = pos - index;

    final originalWaveform = waveform;

    // Generate samples from adjacent waveforms
    double sample1, sample2;

    // Save phase for consistent reading
    final savedPhase = phase;
    final savedSubPhase = subPhase;
    final savedSyncPhase = syncPhase;

    // First waveform
    waveform = _getWaveformByIndex(index);
    phase = savedPhase;
    subPhase = savedSubPhase;
    syncPhase = savedSyncPhase;
    sample1 = nextSample();

    // Second waveform
    waveform = _getWaveformByIndex(index + 1);
    phase = savedPhase;
    subPhase = savedSubPhase;
    syncPhase = savedSyncPhase;
    sample2 = nextSample();

    // Restore original waveform
    waveform = originalWaveform;

    // Crossfade between waveforms
    return sample1 * (1.0 - frac) + sample2 * frac;
  }

  EnhancedWaveform _getWaveformByIndex(int index) {
    switch (index % 5) {
      case 0:
        return EnhancedWaveform.sine;
      case 1:
        return EnhancedWaveform.triangle;
      case 2:
        return EnhancedWaveform.sawtooth;
      case 3:
        return EnhancedWaveform.square;
      case 4:
        return EnhancedWaveform.pulse;
      default:
        return EnhancedWaveform.sine;
    }
  }

  /// Reset oscillator phase
  void reset() {
    phase = 0.0;
    subPhase = 0.0;
    syncPhase = 0.0;
  }
}

/// LFO (Low Frequency Oscillator) for modulation
class LFO {
  final double sampleRate;
  double phase = 0.0;
  double frequency = 5.0; // Hz
  EnhancedWaveform waveform = EnhancedWaveform.sine;
  double depth = 1.0; // 0-1
  double offset = 0.0; // -1 to 1

  // Retrigger
  bool retrigger = false;

  // Sample and hold
  double _sampleHoldValue = 0.0;
  int _sampleHoldCounter = 0;

  LFO({required this.sampleRate});

  /// Get next LFO value (-1 to 1, scaled by depth)
  double nextValue() {
    final phaseIncrement = frequency / sampleRate;

    double value;

    switch (waveform) {
      case EnhancedWaveform.sine:
        value = math.sin(phase * 2.0 * math.pi);
        break;

      case EnhancedWaveform.triangle:
        if (phase < 0.5) {
          value = 4.0 * phase - 1.0;
        } else {
          value = 3.0 - 4.0 * phase;
        }
        break;

      case EnhancedWaveform.sawtooth:
        value = 2.0 * phase - 1.0;
        break;

      case EnhancedWaveform.square:
        value = phase < 0.5 ? 1.0 : -1.0;
        break;

      case EnhancedWaveform.noise:
        // Sample and hold random values
        if (_sampleHoldCounter <= 0) {
          _sampleHoldValue = math.Random().nextDouble() * 2.0 - 1.0;
          _sampleHoldCounter = (sampleRate / frequency).round();
        }
        _sampleHoldCounter--;
        value = _sampleHoldValue;
        break;

      default:
        value = 0.0;
    }

    // Advance phase
    phase += phaseIncrement;
    if (phase >= 1.0) phase -= 1.0;

    // Apply depth and offset
    return value * depth + offset;
  }

  /// Reset LFO phase (for retriggering)
  void reset() {
    phase = 0.0;
    _sampleHoldCounter = 0;
  }

  /// Get bipolar value (-1 to 1)
  double getBipolar() {
    return nextValue();
  }

  /// Get unipolar value (0 to 1)
  double getUnipolar() {
    return (nextValue() + 1.0) * 0.5;
  }
}

/// Multi-LFO system with routing matrix
class LFOSystem {
  final double sampleRate;
  final List<LFO> lfos;

  LFOSystem({required this.sampleRate, int lfoCount = 3})
      : lfos = List.generate(
            lfoCount, (_) => LFO(sampleRate: sampleRate));

  /// Get LFO by index
  LFO getLFO(int index) => lfos[index.clamp(0, lfos.length - 1)];

  /// Update all LFOs and return values
  List<double> process() {
    return lfos.map((lfo) => lfo.nextValue()).toList();
  }

  /// Reset all LFOs
  void resetAll() {
    for (final lfo in lfos) {
      lfo.reset();
    }
  }
}
