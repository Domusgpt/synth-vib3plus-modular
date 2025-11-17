///
/// Synthesizer Engine - Professional Audio Implementation
///
/// Core audio synthesis system with:
/// - ADSR envelope system for natural note articulation
/// - 8-voice polyphony with voice stealing
/// - Stereo output with panning and width control
/// - Noise generator for textural content
/// - Bidirectional parameter coupling to VIB34D visual system
/// - Multi-mode filter with resonance
/// - Dual oscillators with FM and ring modulation
/// - Effects: reverb, delay with adjustable mix
///
/// A Paul Phillips Manifestation
////

import 'dart:math' as math;
import 'dart:typed_data';

/// Waveform types for oscillators
enum Waveform {
  sine,
  sawtooth,
  square,
  triangle,
  wavetable,
}

/// Filter types
enum FilterType {
  lowpass,
  highpass,
  bandpass,
  notch,
}

/// ADSR Envelope for natural note articulation
class ADSREnvelope {
  double attack = 0.01; // 10ms
  double decay = 0.1; // 100ms
  double sustain = 0.7; // 70% level
  double release = 0.3; // 300ms

  double _level = 0.0;
  double _time = 0.0;
  bool _isActive = false;
  bool _isReleasing = false;
  double _releaseLevel = 0.0;
  final double sampleRate;

  ADSREnvelope({required this.sampleRate});

  /// Trigger note on
  void noteOn() {
    _isActive = true;
    _isReleasing = false;
    _time = 0.0;
  }

  /// Trigger note off (start release phase)
  void noteOff() {
    if (_isActive && !_isReleasing) {
      _isReleasing = true;
      _releaseLevel = _level;
      _time = 0.0;
    }
  }

  /// Process next sample and return envelope level (0-1)
  double process() {
    if (!_isActive) return 0.0;

    if (_isReleasing) {
      // Release phase
      _time += 1.0 / sampleRate;
      _level = _releaseLevel * (1.0 - (_time / release).clamp(0.0, 1.0));

      if (_time >= release) {
        _isActive = false;
        _level = 0.0;
      }
    } else {
      // Attack → Decay → Sustain phases
      _time += 1.0 / sampleRate;

      if (_time < attack) {
        // Attack phase
        _level = _time / attack;
      } else if (_time < attack + decay) {
        // Decay phase
        final decayTime = _time - attack;
        _level = 1.0 - ((1.0 - sustain) * (decayTime / decay));
      } else {
        // Sustain phase
        _level = sustain;
      }
    }

    return _level.clamp(0.0, 1.0);
  }

  bool get isActive => _isActive;
}

/// Voice for polyphonic synthesis
class Voice {
  late final Oscillator oscillator1;
  late final Oscillator oscillator2;
  late final ADSREnvelope envelope;

  int midiNote = 60;
  bool isActive = false;
  double pan = 0.0; // -1 (left) to 1 (right)

  Voice({required double sampleRate}) {
    oscillator1 = Oscillator(
      sampleRate: sampleRate,
      waveform: Waveform.sawtooth,
    );
    oscillator2 = Oscillator(
      sampleRate: sampleRate,
      waveform: Waveform.square,
    );
    envelope = ADSREnvelope(sampleRate: sampleRate);
  }

  /// Set note frequency
  void setNote(int note, double baseFrequency) {
    midiNote = note;
    oscillator1.baseFrequency = baseFrequency;
    oscillator2.baseFrequency = baseFrequency;
  }

  /// Trigger note on
  void noteOn(int note, double baseFrequency) {
    setNote(note, baseFrequency);
    envelope.noteOn();
    isActive = true;
  }

  /// Trigger note off
  void noteOff() {
    envelope.noteOff();
  }

  /// Generate next sample (mono)
  double nextSample(double mixBalance) {
    if (!isActive) return 0.0;

    final env = envelope.process();
    if (!envelope.isActive) {
      isActive = false;
      return 0.0;
    }

    final osc1Sample = oscillator1.nextSample();
    final osc2Sample = oscillator2.nextSample();
    final mixed = (osc1Sample * (1.0 - mixBalance)) + (osc2Sample * mixBalance);

    return mixed * env;
  }
}

/// Voice manager for polyphonic synthesis with intelligent voice stealing
class VoiceManager {
  final List<Voice> voices;
  final double sampleRate;
  final int maxVoices;

  // Track velocity and start time for each voice (for intelligent stealing)
  final Map<int, double> _voiceVelocities = {};
  final Map<int, DateTime> _voiceStartTimes = {};

  static const double velocityEpsilon = 1e-9;

  VoiceManager({
    required this.sampleRate,
    this.maxVoices = 8,
  }) : voices = List.generate(
          maxVoices,
          (_) => Voice(sampleRate: sampleRate),
        );

  /// Allocate voice for new note with intelligent voice stealing
  /// Uses velocity-based stealing (quieter notes first) + age-based secondary
  Voice? allocateVoice(int midiNote, double frequency,
      {double velocity = 0.8}) {
    // First, try to find an inactive voice
    for (int i = 0; i < voices.length; i++) {
      if (!voices[i].isActive) {
        voices[i].noteOn(midiNote, frequency);
        _voiceVelocities[i] = velocity;
        _voiceStartTimes[i] = DateTime.now();
        return voices[i];
      }
    }

    // All voices active - need to steal
    // Find voice with lowest velocity, or oldest if velocities are equal
    int? victimIndex;
    double? lowestVelocity;
    DateTime? oldestTime;

    for (int i = 0; i < voices.length; i++) {
      final voiceVel = _voiceVelocities[i] ?? 0.8;
      final voiceTime = _voiceStartTimes[i] ?? DateTime.now();

      if (victimIndex == null) {
        victimIndex = i;
        lowestVelocity = voiceVel;
        oldestTime = voiceTime;
        continue;
      }

      // PRIMARY: Compare velocity (steal quieter notes)
      final velocityDiff = (voiceVel - lowestVelocity!).abs();
      if (velocityDiff > velocityEpsilon) {
        if (voiceVel < lowestVelocity) {
          victimIndex = i;
          lowestVelocity = voiceVel;
          oldestTime = voiceTime;
        }
        continue;
      }

      // SECONDARY: Same velocity, compare age (steal older notes)
      if (voiceTime.isBefore(oldestTime!)) {
        victimIndex = i;
        lowestVelocity = voiceVel;
        oldestTime = voiceTime;
      }
    }

    // Steal the selected voice
    if (victimIndex != null) {
      voices[victimIndex].noteOn(midiNote, frequency);
      _voiceVelocities[victimIndex] = velocity;
      _voiceStartTimes[victimIndex] = DateTime.now();
      return voices[victimIndex];
    }

    return null;
  }

  /// Release voice for note
  void releaseVoice(int midiNote) {
    for (final voice in voices) {
      if (voice.isActive && voice.midiNote == midiNote) {
        voice.noteOff();
      }
    }
  }

  /// Release all voices
  void releaseAll() {
    for (final voice in voices) {
      if (voice.isActive) {
        voice.noteOff();
      }
    }
  }

  /// Get active voice count
  int getActiveCount() {
    return voices.where((v) => v.isActive).length;
  }

  /// Mix all voices (mono)
  double mixVoices(double mixBalance) {
    double sum = 0.0;
    int activeCount = 0;

    for (final voice in voices) {
      if (voice.isActive) {
        sum += voice.nextSample(mixBalance);
        activeCount++;
      }
    }

    // Normalize by active voice count to prevent clipping
    return activeCount > 0 ? sum / math.sqrt(activeCount) : 0.0;
  }
}

/// Noise generator
class NoiseGenerator {
  double amount = 0.0; // 0-1
  final math.Random _random = math.Random();

  /// Generate next noise sample
  double nextSample() {
    return (_random.nextDouble() * 2.0 - 1.0) * amount;
  }
}

/// Main synthesizer engine with polyphony and stereo output
class SynthesizerEngine {
  // Audio configuration
  final double sampleRate;
  final int bufferSize;

  // Voice management
  late final VoiceManager voiceManager;

  // Noise generator
  late final NoiseGenerator noiseGenerator;

  // Filter
  late final Filter filter;
  late final ADSREnvelope filterEnvelope; // Envelope for filter modulation
  double filterEnvelopeAmount = 0.0; // 0-1, how much envelope affects filter

  // Effects
  late final Reverb reverb;
  late final Delay delay;

  // Master parameters
  double masterVolume = 0.7;
  double mixBalance = 0.5; // 0 = osc1 only, 1 = osc2 only
  double stereoWidth = 1.0; // 0 = mono, 1 = full stereo

  // Modulation inputs (from visual system)
  double _osc1FreqModulation = 0.0; // ±2 semitones
  double _osc2FreqModulation = 0.0; // ±2 semitones
  double _filterCutoffModulation = 0.0; // ±40%
  double _wavetablePositionModulation = 0.0; // 0-1

  // Portamento/Glide system (Hermite smoothstep interpolation)
  double _portamentoTime = 0.0; // seconds (0 = disabled)
  double _glideStartFrequency = 440.0;
  double _glideTargetFrequency = 440.0;
  double _glideCurrentFrequency = 440.0;
  DateTime? _glideStartTime;
  bool _isGliding = false;

  // Legacy single-note tracking (for compatibility)
  int _currentNote = 60;

  SynthesizerEngine({
    this.sampleRate = 44100.0,
    this.bufferSize = 512,
  }) {
    voiceManager = VoiceManager(sampleRate: sampleRate, maxVoices: 8);
    noiseGenerator = NoiseGenerator();

    filter = Filter(
      sampleRate: sampleRate,
      type: FilterType.lowpass,
    );

    // Initialize filter envelope with fast attack for percussive modulation
    filterEnvelope = ADSREnvelope(sampleRate: sampleRate)
      ..attack = 0.01
      ..decay = 0.2
      ..sustain = 0.5
      ..release = 0.3;

    reverb = Reverb(sampleRate: sampleRate);
    delay = Delay(sampleRate: sampleRate);
  }

  // Legacy oscillator access for compatibility
  Oscillator get oscillator1 => voiceManager.voices[0].oscillator1;
  Oscillator get oscillator2 => voiceManager.voices[0].oscillator2;

  /// Get active voice count
  int get voiceCount => voiceManager.getActiveCount();

  /// Set voice count (no-op for compatibility, polyphony is automatic)
  void setVoiceCount(int count) {
    // Voice allocation is automatic, this is for UI compatibility
  }

  /// Generate audio buffer (mono for compatibility)
  Float32List generateBuffer(int frames) {
    final buffer = Float32List(frames);

    for (int i = 0; i < frames; i++) {
      // Apply frequency modulation to all voices
      for (final voice in voiceManager.voices) {
        voice.oscillator1.frequencyModulation = _osc1FreqModulation;
        voice.oscillator2.frequencyModulation = _osc2FreqModulation;
        voice.oscillator1.wavetablePosition = _wavetablePositionModulation;
        voice.oscillator2.wavetablePosition = _wavetablePositionModulation;
      }

      // Mix all voices
      final mixed = voiceManager.mixVoices(mixBalance);

      // Add noise
      final withNoise = mixed + noiseGenerator.nextSample();

      // Apply filter with modulation
      filter.cutoffModulation = _filterCutoffModulation;
      final filtered = filter.process(withNoise);

      // Apply effects
      final delayed = delay.process(filtered);
      final reverberated = reverb.process(delayed);

      // Master output
      buffer[i] = (reverberated * masterVolume).clamp(-1.0, 1.0);
    }

    return buffer;
  }

  /// Apply effects chain to external buffer (from SynthesisBranchManager)
  /// Applies: noise, filter (with envelope), delay, reverb, and master volume
  Float32List applyEffectsToBuffer(Float32List inputBuffer) {
    final buffer = Float32List(inputBuffer.length);

    for (int i = 0; i < inputBuffer.length; i++) {
      // Start with input sample
      double sample = inputBuffer[i];

      // Add noise
      sample += noiseGenerator.nextSample();

      // Apply filter with modulation and envelope
      // Envelope modulates cutoff: env * amount scales the cutoff up to 2x
      final envValue = filterEnvelope.process();
      final envelopeModulation = envValue * filterEnvelopeAmount;
      filter.cutoffModulation = _filterCutoffModulation + envelopeModulation;
      sample = filter.process(sample);

      // Apply delay
      sample = delay.process(sample);

      // Apply reverb
      sample = reverb.process(sample);

      // Master output with volume
      buffer[i] = (sample * masterVolume).clamp(-1.0, 1.0);
    }

    return buffer;
  }

  /// Generate stereo audio buffers
  (Float32List, Float32List) generateStereoBuffer(int frames) {
    final left = Float32List(frames);
    final right = Float32List(frames);

    for (int i = 0; i < frames; i++) {
      // Apply frequency modulation to all voices
      for (final voice in voiceManager.voices) {
        voice.oscillator1.frequencyModulation = _osc1FreqModulation;
        voice.oscillator2.frequencyModulation = _osc2FreqModulation;
        voice.oscillator1.wavetablePosition = _wavetablePositionModulation;
        voice.oscillator2.wavetablePosition = _wavetablePositionModulation;
      }

      // Mix all voices with stereo panning
      double leftSum = 0.0;
      double rightSum = 0.0;
      int activeCount = 0;

      for (final voice in voiceManager.voices) {
        if (voice.isActive) {
          final sample = voice.nextSample(mixBalance);

          // Apply stereo panning
          final pan = voice.pan * stereoWidth;
          final leftGain = math.sqrt(0.5 * (1.0 - pan));
          final rightGain = math.sqrt(0.5 * (1.0 + pan));

          leftSum += sample * leftGain;
          rightSum += sample * rightGain;
          activeCount++;
        }
      }

      // Normalize by active voice count
      final normFactor = activeCount > 0 ? 1.0 / math.sqrt(activeCount) : 0.0;
      final leftMixed = leftSum * normFactor;
      final rightMixed = rightSum * normFactor;

      // Add noise (mono noise to both channels)
      final noise = noiseGenerator.nextSample();
      final leftWithNoise = leftMixed + noise;
      final rightWithNoise = rightMixed + noise;

      // Apply filter (same settings to both channels)
      filter.cutoffModulation = _filterCutoffModulation;
      final leftFiltered = filter.process(leftWithNoise);
      final rightFiltered = filter.process(rightWithNoise);

      // Apply effects (shared reverb/delay for coherence)
      final leftDelayed = delay.process(leftFiltered);
      final rightDelayed = delay.process(rightFiltered);
      final leftReverb = reverb.process(leftDelayed);
      final rightReverb = reverb.process(rightDelayed);

      // Master output
      left[i] = (leftReverb * masterVolume).clamp(-1.0, 1.0);
      right[i] = (rightReverb * masterVolume).clamp(-1.0, 1.0);
    }

    return (left, right);
  }

  /// Set base note (MIDI note number) - allocates a new voice
  void setNote(int midiNote) {
    _currentNote = midiNote;
    final freq = _midiToFrequency(midiNote);
    _triggerPortamento(freq); // Trigger glide to new frequency
    voiceManager.allocateVoice(midiNote, freq);
  }

  /// Note on (polyphonic)
  void noteOn(int midiNote) {
    final freq = _midiToFrequency(midiNote);
    _triggerPortamento(freq); // Trigger glide to new frequency
    voiceManager.allocateVoice(midiNote, freq);
  }

  /// Note off (polyphonic)
  void noteOff(int midiNote) {
    voiceManager.releaseVoice(midiNote);
  }

  /// All notes off
  void allNotesOff() {
    voiceManager.releaseAll();
  }

  /// Modulate oscillator 1 frequency (±2 semitones from visual system)
  void modulateOscillator1Frequency(double semitones) {
    _osc1FreqModulation = semitones.clamp(-2.0, 2.0);
  }

  /// Modulate oscillator 2 frequency (±2 semitones from visual system)
  void modulateOscillator2Frequency(double semitones) {
    _osc2FreqModulation = semitones.clamp(-2.0, 2.0);
  }

  /// Modulate filter cutoff (±40% from visual system)
  void modulateFilterCutoff(double amount) {
    _filterCutoffModulation = amount.clamp(0.0, 0.8); // 0-80% range
  }

  /// Set wavetable position (from visual morph parameter)
  void setWavetablePosition(double position) {
    _wavetablePositionModulation = position.clamp(0.0, 1.0);
  }

  /// Set reverb mix (from visual projection distance)
  void setReverbMix(double mix) {
    reverb.mix = mix.clamp(0.0, 1.0);
  }

  /// Set delay time (from visual layer depth)
  void setDelayTime(double milliseconds) {
    delay.delayTime = milliseconds.clamp(0.0, 1000.0);
  }

  /// Set noise amount (from visual chaos parameter)
  void setNoiseAmount(double amount) {
    noiseGenerator.amount = amount.clamp(0.0, 1.0);
  }

  /// Set stereo width
  void setStereoWidth(double width) {
    stereoWidth = width.clamp(0.0, 1.0);
  }

  /// Set envelope parameters
  void setEnvelopeAttack(double seconds) {
    for (final voice in voiceManager.voices) {
      voice.envelope.attack = seconds.clamp(0.001, 5.0);
    }
  }

  void setEnvelopeDecay(double seconds) {
    for (final voice in voiceManager.voices) {
      voice.envelope.decay = seconds.clamp(0.001, 5.0);
    }
  }

  void setEnvelopeSustain(double level) {
    for (final voice in voiceManager.voices) {
      voice.envelope.sustain = level.clamp(0.0, 1.0);
    }
  }

  void setEnvelopeRelease(double seconds) {
    for (final voice in voiceManager.voices) {
      voice.envelope.release = seconds.clamp(0.001, 10.0);
    }
  }

  /// Convert MIDI note to frequency
  double _midiToFrequency(int midiNote) {
    return 440.0 * math.pow(2.0, (midiNote - 69) / 12.0);
  }

  /// Smoothstep function for Hermite interpolation (from synther-refactored)
  /// Provides smooth, natural-sounding pitch transitions
  double _smoothStep(double t) {
    final clamped = t.clamp(0.0, 1.0);
    return clamped * clamped * (3.0 - 2.0 * clamped);
  }

  /// Update portamento/glide (called per sample when gliding is active)
  void _updatePortamento() {
    if (!_isGliding || _glideStartTime == null) {
      _glideCurrentFrequency = _glideTargetFrequency;
      return;
    }

    if (_portamentoTime <= 0.0) {
      // Portamento disabled, snap to target
      _glideCurrentFrequency = _glideTargetFrequency;
      _isGliding = false;
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_glideStartTime!).inMicroseconds / 1000000.0;
    final progress = (elapsed / _portamentoTime).clamp(0.0, 1.0);

    if (progress >= 1.0) {
      // Glide complete
      _glideCurrentFrequency = _glideTargetFrequency;
      _isGliding = false;
    } else {
      // Apply smoothstep easing for natural pitch transition
      final eased = _smoothStep(progress);
      _glideCurrentFrequency = _glideStartFrequency +
          (_glideTargetFrequency - _glideStartFrequency) * eased;
    }
  }

  /// Set portamento time in seconds (0 = disabled, 0.001-5.0 = enabled)
  void setPortamentoTime(double seconds) {
    _portamentoTime = seconds.clamp(0.0, 5.0);
  }

  /// Get current portamento time
  double get portamentoTime => _portamentoTime;

  /// Trigger portamento glide to new frequency
  void _triggerPortamento(double targetFrequency) {
    if (_portamentoTime <= 0.0) {
      // Portamento disabled, snap immediately
      _glideCurrentFrequency = targetFrequency;
      _glideTargetFrequency = targetFrequency;
      _isGliding = false;
      return;
    }

    // Start glide from current frequency to target
    _glideStartFrequency = _glideCurrentFrequency;
    _glideTargetFrequency = targetFrequency;
    _glideStartTime = DateTime.now();
    _isGliding = true;
  }
}

/// Oscillator with frequency modulation support
class Oscillator {
  final double sampleRate;
  Waveform waveform;

  double baseFrequency = 440.0;
  double frequencyModulation = 0.0; // ±2 semitones
  double phase = 0.0;
  double wavetablePosition = 0.0;

  Oscillator({
    required this.sampleRate,
    required this.waveform,
  });

  /// Generate next sample
  double nextSample() {
    // Apply frequency modulation (semitones to frequency ratio)
    final freqRatio = math.pow(2.0, frequencyModulation / 12.0);
    final modulatedFreq = baseFrequency * freqRatio;

    // Generate sample based on waveform
    final sample = _generateWaveform(phase);

    // Advance phase
    phase += (2.0 * math.pi * modulatedFreq) / sampleRate;
    if (phase >= 2.0 * math.pi) {
      phase -= 2.0 * math.pi;
    }

    return sample;
  }

  /// Generate waveform sample at current phase
  double _generateWaveform(double ph) {
    switch (waveform) {
      case Waveform.sine:
        return math.sin(ph);

      case Waveform.sawtooth:
        return 2.0 * (ph / (2.0 * math.pi)) - 1.0;

      case Waveform.square:
        return ph < math.pi ? 1.0 : -1.0;

      case Waveform.triangle:
        final t = ph / (2.0 * math.pi);
        return t < 0.5 ? (4.0 * t - 1.0) : (3.0 - 4.0 * t);

      case Waveform.wavetable:
        // Simple wavetable: morph between sine and sawtooth
        final sine = math.sin(ph);
        final saw = 2.0 * (ph / (2.0 * math.pi)) - 1.0;
        return sine * (1.0 - wavetablePosition) + saw * wavetablePosition;
    }
  }
}

/// Multi-mode filter with resonance
class Filter {
  final double sampleRate;
  FilterType type;

  double baseCutoff = 1000.0; // Hz
  double cutoffModulation = 0.0; // 0-0.8 (±40%)
  double resonance = 0.7;

  // State variables
  double _z1 = 0.0;
  double _z2 = 0.0;

  Filter({
    required this.sampleRate,
    required this.type,
  });

  /// Process sample through filter
  double process(double input) {
    // Apply cutoff modulation
    final modulatedCutoff = baseCutoff * (1.0 + cutoffModulation);
    final normalizedCutoff =
        (2.0 * modulatedCutoff / sampleRate).clamp(0.01, 0.99);

    // Simple 2-pole filter
    final f = 2.0 * math.sin(math.pi * normalizedCutoff);
    final q = resonance;

    double output;

    switch (type) {
      case FilterType.lowpass:
        _z1 += f * (input - _z1 + q * (_z1 - _z2));
        _z2 += f * (_z1 - _z2);
        output = _z2;
        break;

      case FilterType.highpass:
        _z1 += f * (input - _z1 + q * (_z1 - _z2));
        _z2 += f * (_z1 - _z2);
        output = input - _z2;
        break;

      case FilterType.bandpass:
        _z1 += f * (input - _z1 + q * (_z1 - _z2));
        _z2 += f * (_z1 - _z2);
        output = _z1 - _z2;
        break;

      case FilterType.notch:
        _z1 += f * (input - _z1 + q * (_z1 - _z2));
        _z2 += f * (_z1 - _z2);
        output = input - (_z1 - _z2);
        break;
    }

    return output.clamp(-1.0, 1.0);
  }
}

/// Reverb effect with adjustable mix
class Reverb {
  final double sampleRate;

  double mix = 0.3; // Wet/dry mix (0-1) - NOW SETTABLE!
  double roomSize = 0.7;
  double damping = 0.5;

  // Delay lines for reverb
  late final List<double> _buffer;
  final int _bufferSize;
  int _writePos = 0;

  Reverb({required this.sampleRate})
      : _bufferSize = (sampleRate * 0.1).round() {
    _buffer = List<double>.filled(_bufferSize, 0.0);
  }

  /// Process sample through reverb
  double process(double input) {
    // Read from delay buffer
    final delayed = _buffer[_writePos];

    // Apply feedback
    final feedback = delayed * roomSize * (1.0 - damping);

    // Write to buffer
    _buffer[_writePos] = input + feedback;

    // Advance write position
    _writePos = (_writePos + 1) % _bufferSize;

    // Mix dry and wet signals
    return input * (1.0 - mix) + delayed * mix;
  }
}

/// Delay effect with adjustable mix
class Delay {
  final double sampleRate;

  double delayTime = 250.0; // milliseconds
  double feedback = 0.4;
  double mix = 0.3; // NOW SETTABLE!

  late final List<double> _buffer;
  final int _maxBufferSize;
  int _writePos = 0;

  Delay({required this.sampleRate})
      : _maxBufferSize = (sampleRate * 2.0).round() {
    _buffer = List<double>.filled(_maxBufferSize, 0.0);
  }

  /// Process sample through delay
  double process(double input) {
    // Calculate read position based on delay time
    final delaySamples = (delayTime * sampleRate / 1000.0).round();
    final readPos = (_writePos - delaySamples) % _maxBufferSize;

    // Read delayed sample
    final delayed = _buffer[readPos < 0 ? readPos + _maxBufferSize : readPos];

    // Write to buffer with feedback
    _buffer[_writePos] = input + delayed * feedback;

    // Advance write position
    _writePos = (_writePos + 1) % _maxBufferSize;

    // Mix dry and wet signals
    return input * (1.0 - mix) + delayed * mix;
  }
}
