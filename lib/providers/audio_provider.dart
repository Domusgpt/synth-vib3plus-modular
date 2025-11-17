/**
 * Audio Provider
 *
 * Manages the synthesizer engine and audio analyzer, providing
 * state management for the audio synthesis system.
 *
 * Responsibilities:
 * - SynthesizerEngine instance and control
 * - AudioAnalyzer instance
 * - Audio buffer management
 * - Microphone input handling
 * - Audio output to speakers
 * - Current audio feature state
 *
 * A Paul Phillips Manifestation
 */

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import '../audio/audio_analyzer.dart';
import '../audio/synthesizer_engine.dart';
import '../synthesis/synthesis_branch_manager.dart';
import '../ui/theme/synth_theme.dart';

class AudioProvider with ChangeNotifier {
  // Core audio systems
  late final SynthesizerEngine synthesizerEngine;
  late final AudioAnalyzer audioAnalyzer;
  late final SynthesisBranchManager synthesisBranchManager;

  // Audio buffer management
  Float32List? _currentBuffer;
  final int bufferSize = 512;
  final double sampleRate = 44100.0;

  // Current audio features (from analysis)
  AudioFeatures? _currentFeatures;

  // Synthesizer state
  int _currentNote = 60; // Middle C
  bool _isPlaying = false;
  double _masterVolume = 0.7;

  // Performance metrics
  int _buffersGenerated = 0;
  DateTime _lastMetricsCheck = DateTime.now();

  AudioProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    synthesizerEngine = SynthesizerEngine(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );

    audioAnalyzer = AudioAnalyzer(
      fftSize: 2048,
      sampleRate: sampleRate,
    );

    synthesisBranchManager = SynthesisBranchManager(
      sampleRate: sampleRate,
    );

    // Setup PCM audio output (static method)
    await FlutterPcmSound.setup(
      sampleRate: sampleRate.toInt(),
      channelCount: 1,  // Mono
    );

    // Set feed callback to handle buffer requests
    FlutterPcmSound.setFeedCallback((int remainingFrames) {
      _feedAudioCallback(remainingFrames);
    });

    // Set threshold for callback (trigger when less than 2048 frames remain)
    await FlutterPcmSound.setFeedThreshold(2048);

    debugPrint('✅ AudioProvider initialized with PCM audio output');
  }

  // Getters
  SynthesizerEngine get synth => synthesizerEngine;
  AudioAnalyzer get analyzer => audioAnalyzer;
  Float32List? get currentBuffer => _currentBuffer;
  AudioFeatures? get currentFeatures => _currentFeatures;
  int get currentNote => _currentNote;
  bool get isPlaying => _isPlaying;
  double get masterVolume => _masterVolume;
  int get voiceCount => synthesizerEngine.voiceCount;

  /// Get current audio buffer for analysis
  Float32List? getCurrentBuffer() {
    return _currentBuffer;
  }

  /// Get current voice count
  int getVoiceCount() {
    return synthesizerEngine.voiceCount;
  }

  /// Start audio generation and playback
  Future<void> startAudio() async {
    if (_isPlaying) return;

    _isPlaying = true;
    _lastMetricsCheck = DateTime.now();
    _buffersGenerated = 0;

    // Start the PCM audio feed
    FlutterPcmSound.start();

    notifyListeners();
    debugPrint('▶️  Audio started');
  }

  /// Callback when PCM buffer needs more data
  void _feedAudioCallback(int remainingFrames) {
    if (!_isPlaying) return;

    // Generate multiple buffers to keep ahead of playback
    const buffersToGenerate = 4;
    for (int i = 0; i < buffersToGenerate; i++) {
      _generateAudioBuffer();
    }
  }

  /// Stop audio generation and playback
  Future<void> stopAudio() async {
    _isPlaying = false;
    // PCM audio will stop when no more data is fed
    notifyListeners();
    debugPrint('⏸️  Audio stopped');
  }

  /// Generate next audio buffer
  void _generateAudioBuffer() {
    try {
      // Calculate base frequency for current note
      double baseFrequency = _midiNoteToFrequency(_currentNote);

      // Apply pitch bend (static offset in semitones)
      final pitchBendRatio = pow(2.0, _pitchBendSemitones / 12.0);
      double frequency = baseFrequency * pitchBendRatio;

      // Apply vibrato (periodic LFO modulation)
      if (_vibratoDepth > 0.0) {
        // Vibrato LFO at 5 Hz, depth in semitones (0-1 maps to 0-0.5 semitones)
        final vibratoLFO = sin(_vibratoPhase) * _vibratoDepth * 0.5;
        final vibratoRatio = pow(2.0, vibratoLFO / 12.0);
        frequency *= vibratoRatio;

        // Advance vibrato phase
        _vibratoPhase += 2.0 * pi * _vibratoRate * bufferSize / sampleRate;
        if (_vibratoPhase >= 2.0 * pi) {
          _vibratoPhase -= 2.0 * pi;
        }
      }

      // Generate buffer using Synthesis Branch Manager (routes to Direct/FM/Ring Mod)
      // This applies: polytope core routing + voice character + sound family
      Float32List rawBuffer = synthesisBranchManager.generateBuffer(bufferSize, frequency);

      // Apply global effects from synthesis engine (filter, reverb, delay)
      // This maintains the effect chain while using the branch manager for core synthesis
      _currentBuffer = synthesizerEngine.applyEffectsToBuffer(rawBuffer);

      // Analyze the buffer
      if (_currentBuffer != null && _currentBuffer!.isNotEmpty) {
        _currentFeatures = audioAnalyzer.extractFeatures(_currentBuffer!);

        // Convert Float32List to Int16List for PCM output
        // PCM 16-bit signed format: -32768 to 32767
        final int16Buffer = Int16List(_currentBuffer!.length);
        for (int i = 0; i < _currentBuffer!.length; i++) {
          // Clamp to -1.0 to 1.0 and scale to int16 range
          final sample = _currentBuffer![i].clamp(-1.0, 1.0);
          int16Buffer[i] = (sample * 32767).round();
        }

        // Feed buffer to PCM audio output (static method)
        FlutterPcmSound.feed(
          PcmArrayInt16.fromList(int16Buffer.toList()),
        );
      }

      _buffersGenerated++;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error generating audio buffer: $e');
    }
  }

  /// Convert MIDI note to frequency (Hz)
  double _midiNoteToFrequency(int midiNote) {
    // A4 (MIDI 69) = 440 Hz
    // Each semitone is 2^(1/12) ratio
    return 440.0 * pow(2.0, (midiNote - 69) / 12.0);
  }

  /// Play a note (MIDI note number)
  void playNote(int midiNote) {
    _currentNote = midiNote;
    synthesizerEngine.setNote(midiNote);
    synthesisBranchManager.noteOn(); // Trigger envelope in branch manager
    synthesizerEngine.filterEnvelope.noteOn(); // Trigger filter envelope

    if (!_isPlaying) {
      startAudio();
    }

    notifyListeners();
  }

  /// Stop current note
  void stopNote() {
    synthesisBranchManager.noteOff(); // Start release phase
    synthesizerEngine.filterEnvelope.noteOff(); // Start filter envelope release
    stopAudio();
  }

  /// Set geometry (0-23) for synthesis
  void setGeometry(int geometry) {
    synthesisBranchManager.setGeometry(geometry);
    debugPrint('🎵 Geometry set to: $geometry (${synthesisBranchManager.configString})');
    notifyListeners();
  }

  /// Set visual system (updates sound family)
  void setVisualSystem(String systemName) {
    VisualSystem system;
    switch (systemName.toLowerCase()) {
      case 'quantum':
        system = VisualSystem.quantum;
        break;
      case 'faceted':
        system = VisualSystem.faceted;
        break;
      case 'holographic':
        system = VisualSystem.holographic;
        break;
      default:
        system = VisualSystem.quantum;
    }
    _currentVisualSystem = system;
    synthesisBranchManager.setVisualSystem(system);
    debugPrint('🎨 Visual system set to: ${system.name}');
    notifyListeners();
  }

  /// Get current synthesis configuration
  String getSynthesisConfig() {
    return synthesisBranchManager.configString;
  }

  /// Set master volume
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    synthesizerEngine.masterVolume = _masterVolume;
    notifyListeners();
  }

  /// Set oscillator waveform
  void setOscillator1Waveform(Waveform waveform) {
    synthesizerEngine.oscillator1.waveform = waveform;
    notifyListeners();
  }

  void setOscillator2Waveform(Waveform waveform) {
    synthesizerEngine.oscillator2.waveform = waveform;
    notifyListeners();
  }

  /// Set filter parameters
  void setFilterType(FilterType type) {
    synthesizerEngine.filter.type = type;
    notifyListeners();
  }

  void setFilterCutoff(double cutoff) {
    synthesizerEngine.filter.baseCutoff = cutoff.clamp(20.0, 20000.0);
    notifyListeners();
  }

  void setFilterResonance(double resonance) {
    synthesizerEngine.filter.resonance = resonance.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Set reverb parameters
  void setReverbRoomSize(double roomSize) {
    synthesizerEngine.reverb.roomSize = roomSize.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setReverbDamping(double damping) {
    synthesizerEngine.reverb.damping = damping.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Set delay parameters
  void setDelayFeedback(double feedback) {
    synthesizerEngine.delay.feedback = feedback.clamp(0.0, 0.95);
    notifyListeners();
  }

  void setDelayMix(double mix) {
    synthesizerEngine.delay.mix = mix.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Set voice count (called by visual modulator)
  void setVoiceCount(int count) {
    synthesizerEngine.setVoiceCount(count);
    notifyListeners();
  }

  /// Process microphone input (for audio-reactive mode)
  Future<void> startMicrophoneInput() async {
    // TODO: Implement microphone input
    // This requires platform-specific audio input API
    // Will use flutter_sound or audio_session for microphone capture
    debugPrint('🎤 Microphone input not yet implemented');
  }

  void stopMicrophoneInput() {
    // TODO: Stop microphone input
  }

  /// Get audio feature for specific band
  double getBassEnergy() => _currentFeatures?.bassEnergy ?? 0.0;
  double getMidEnergy() => _currentFeatures?.midEnergy ?? 0.0;
  double getHighEnergy() => _currentFeatures?.highEnergy ?? 0.0;
  double getSpectralCentroid() => _currentFeatures?.spectralCentroid ?? 0.0;
  double getRMS() => _currentFeatures?.rms ?? 0.0;
  double getStereoWidth() => _currentFeatures?.stereoWidth ?? 0.0;

  /// Get performance metrics
  Map<String, dynamic> getMetrics() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastMetricsCheck).inMilliseconds;
    final buffersPerSecond = elapsed > 0 ? (_buffersGenerated * 1000.0 / elapsed) : 0.0;

    return {
      'buffersPerSecond': buffersPerSecond.toStringAsFixed(1),
      'isPlaying': _isPlaying,
      'currentNote': _currentNote,
      'masterVolume': _masterVolume,
      'voiceCount': synthesizerEngine.voiceCount,
    };
  }

  // ============================================================================
  // MISSING METHODS ADDED FOR UI INTEGRATION
  // ============================================================================

  // Note control (polyphonic)
  final List<int> _activeNotes = [];

  List<int> get activeNotes => List.unmodifiable(_activeNotes);

  void noteOn(int midiNote) {
    if (!_activeNotes.contains(midiNote)) {
      _activeNotes.add(midiNote);
      playNote(midiNote);
    }
  }

  void noteOff(int midiNote) {
    _activeNotes.remove(midiNote);
    if (_activeNotes.isEmpty) {
      stopNote();
    } else {
      // Switch to last active note
      playNote(_activeNotes.last);
    }
  }

  // Modulation control
  double _pitchBendSemitones = 0.0;
  double _vibratoDepth = 0.0;
  double _vibratoPhase = 0.0; // Phase accumulator for vibrato LFO
  final double _vibratoRate = 5.0; // Hz (typical vibrato speed)

  void setPitchBend(double semitones) {
    _pitchBendSemitones = semitones.clamp(-12.0, 12.0);
    notifyListeners();
  }

  void setVibratoDepth(double depth) {
    _vibratoDepth = depth.clamp(0.0, 1.0);
    notifyListeners();
  }

  // Portamento/Glide control (from synther-refactored)
  double get portamentoTime => synthesizerEngine.portamentoTime;

  void setPortamentoTime(double seconds) {
    synthesizerEngine.setPortamentoTime(seconds);
    notifyListeners();
  }

  // Oscillator mix and detuning
  double _mixBalance = 0.5; // 0.0 = Osc1 only, 1.0 = Osc2 only
  double _oscillator1Detune = 0.0;
  double _oscillator2Detune = 0.0;

  double get mixBalance => _mixBalance;
  double get oscillator1Detune => _oscillator1Detune;
  double get oscillator2Detune => _oscillator2Detune;

  void setMixBalance(double balance) {
    _mixBalance = balance.clamp(0.0, 1.0);
    // NOTE: Mix balance is now handled by SynthesisBranchManager voice characters
    // Each geometry has its own carefully tuned harmonic balance
    synthesizerEngine.mixBalance = _mixBalance;
    notifyListeners();
  }

  void setOscillator1Detune(double cents) {
    _oscillator1Detune = cents.clamp(-100.0, 100.0);
    // NOTE: Detune is now handled by SynthesisBranchManager voice characters
    // Each geometry has its own musical detuning (0-12 cents)
    // This could be exposed as additional micro-tuning in future
    notifyListeners();
  }

  void setOscillator2Detune(double cents) {
    _oscillator2Detune = cents.clamp(-100.0, 100.0);
    // NOTE: Detune is now handled by SynthesisBranchManager voice characters
    // Each geometry has its own musical detuning (0-12 cents)
    // This could be exposed as additional micro-tuning in future
    notifyListeners();
  }

  // Envelope parameters (using local state until engine implementation)
  double _envelopeAttack = 0.01;
  double _envelopeDecay = 0.1;
  double _envelopeSustain = 0.7;
  double _envelopeRelease = 0.3;

  double get envelopeAttack => _envelopeAttack;
  double get envelopeDecay => _envelopeDecay;
  double get envelopeSustain => _envelopeSustain;
  double get envelopeRelease => _envelopeRelease;

  void setEnvelopeAttack(double seconds) {
    _envelopeAttack = seconds.clamp(0.001, 5.0);
    synthesizerEngine.setEnvelopeAttack(_envelopeAttack);
    notifyListeners();
  }

  void setEnvelopeDecay(double seconds) {
    _envelopeDecay = seconds.clamp(0.001, 5.0);
    synthesizerEngine.setEnvelopeDecay(_envelopeDecay);
    notifyListeners();
  }

  void setEnvelopeSustain(double level) {
    _envelopeSustain = level.clamp(0.0, 1.0);
    synthesizerEngine.setEnvelopeSustain(_envelopeSustain);
    notifyListeners();
  }

  void setEnvelopeRelease(double seconds) {
    _envelopeRelease = seconds.clamp(0.001, 10.0);
    synthesizerEngine.setEnvelopeRelease(_envelopeRelease);
    notifyListeners();
  }

  // Filter parameters (additional getters)
  double get filterCutoff => synthesizerEngine.filter.baseCutoff;
  double get filterResonance => synthesizerEngine.filter.resonance;
  double _filterEnvelopeAmount = 0.0;

  double get filterEnvelopeAmount => _filterEnvelopeAmount;

  void setFilterEnvelopeAmount(double amount) {
    _filterEnvelopeAmount = amount.clamp(0.0, 1.0);
    synthesizerEngine.filterEnvelopeAmount = _filterEnvelopeAmount;
    notifyListeners();
  }

  // Reverb parameters (additional getters)
  double get reverbMix => synthesizerEngine.reverb.mix;
  double get reverbRoomSize => synthesizerEngine.reverb.roomSize;
  double get reverbDamping => synthesizerEngine.reverb.damping;

  void setReverbMix(double mix) {
    synthesizerEngine.reverb.mix = mix.clamp(0.0, 1.0);
    notifyListeners();
  }

  // Delay parameters (additional getters)
  double get delayTime => synthesizerEngine.delay.delayTime;
  double get delayFeedback => synthesizerEngine.delay.feedback;
  double get delayMix => synthesizerEngine.delay.mix;

  void setDelayTime(double seconds) {
    synthesizerEngine.delay.delayTime = seconds.clamp(0.001, 2.0);
    notifyListeners();
  }

  // Synthesis branch information
  String get currentSynthesisBranch {
    return synthesisBranchManager.configString;
  }

  void setSynthesisBranch(int branch) {
    // Branch is encoded as geometry index (0-23)
    setGeometry(branch);
  }

  // System colors (derived from visual system)
  VisualSystem _currentVisualSystem = VisualSystem.quantum;

  SystemColors get systemColors {
    switch (_currentVisualSystem) {
      case VisualSystem.quantum:
        return SystemColors.quantum;
      case VisualSystem.faceted:
        return SystemColors.faceted;
      case VisualSystem.holographic:
        return SystemColors.holographic;
      default:
        return SystemColors.quantum;
    }
  }

  @override
  void dispose() {
    stopAudio();
    FlutterPcmSound.release();
    super.dispose();
  }
}
