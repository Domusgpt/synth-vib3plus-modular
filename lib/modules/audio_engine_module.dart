/**
 * Audio Engine Module - Professional Synthesis Lifecycle Management
 *
 * HYBRID WRAPPER: Wraps existing AudioProvider with professional
 * module infrastructure (logging, diagnostics, health monitoring).
 *
 * Manages PCM audio output, synthesis engine, voice management,
 * and audio performance monitoring.
 *
 * A Paul Phillips Manifestation
 */

import '../core/synth_module.dart';
import '../core/synth_logger.dart';
import '../providers/audio_provider.dart';
import '../audio/audio_analyzer.dart';

class AudioEngineModule extends SynthModule {
  @override
  String get name => 'Audio Engine Module';

  late final AudioProvider provider;

  bool _isInitialized = false;
  DateTime? _startTime;

  // Performance tracking
  int _noteOnCount = 0;
  int _noteOffCount = 0;

  @override
  List<Type> get dependencies => [];

  @override
  Future<void> initialize() async {
    _startTime = DateTime.now();

    // Create and initialize AudioProvider
    provider = AudioProvider();

    // Wait a moment for provider initialization
    await Future.delayed(const Duration(milliseconds: 100));

    SynthLogger.audioInit(
      sampleRate: 44100,
      bufferSize: 512,
      channels: 1,
    );

    _isInitialized = true;
    SynthLogger.audioReady();
  }

  @override
  Future<void> dispose() async {
    if (provider.isPlaying) {
      await provider.stopAudio();
    }
    _isInitialized = false;
  }

  @override
  bool get isHealthy {
    return _isInitialized && provider.currentFeatures != null;
  }

  @override
  Map<String, dynamic> getDiagnostics() {
    final uptime = _startTime != null ? DateTime.now().difference(_startTime!) : Duration.zero;

    return {
      'sampleRate': 44100,
      'bufferSize': 512,
      'activeVoices': provider.getVoiceCount(),
      'isPlaying': provider.isPlaying,
      'uptime': '${uptime.inMinutes}:${(uptime.inSeconds % 60).toString().padLeft(2, '0')}',
      'notesTriggered': _noteOnCount,
      'notesReleased': _noteOffCount,
      'activeNotes': provider.activeNotes.length,
      'healthy': isHealthy,
    };
  }

  // ============================================================================
  // PUBLIC API (Delegates to AudioProvider + Logging)
  // ============================================================================

  /// Play a note (with logging)
  void noteOn(int noteNumber, double velocity) {
    if (!_isInitialized) {
      SynthLogger.warning('AudioEngine', 'noteOn called before initialization');
      return;
    }

    provider.noteOn(noteNumber);
    _noteOnCount++;

    SynthLogger.noteOn(noteNumber, velocity);

    // Start audio if not playing
    if (!provider.isPlaying) {
      provider.startAudio();
    }
  }

  /// Stop a note (with logging)
  void noteOff(int noteNumber) {
    if (!_isInitialized) return;

    provider.noteOff(noteNumber);
    _noteOffCount++;

    SynthLogger.noteOff(noteNumber);
  }

  /// Get current FFT features for audio→visual modulation
  Map<String, double> getAudioFeatures() {
    if (!_isInitialized || provider.currentFeatures == null) {
      return {
        'bassEnergy': 0.0,
        'midEnergy': 0.0,
        'highEnergy': 0.0,
        'spectralCentroid': 0.0,
        'rms': 0.0,
      };
    }

    final features = provider.currentFeatures!;
    return {
      'bassEnergy': features.bassEnergy,
      'midEnergy': features.midEnergy,
      'highEnergy': features.highEnergy,
      'spectralCentroid': features.spectralCentroid,
      'rms': features.rms,
      'fundamentalFreq': features.fundamentalFreq,
      'spectralFlux': features.spectralFlux,
      'transientDensity': features.transientDensity,
      'noiseContent': features.noiseContent,
      'stereoWidth': features.stereoWidth,
    };
  }

  /// Switch visual system (quantum/faceted/holographic)
  void switchSystem(String systemName) {
    if (!_isInitialized) return;

    provider.setVisualSystem(systemName);

    SynthLogger.systemSwitch(
      provider.getSynthesisConfig().split(' - ')[0],
      systemName,
    );
  }

  /// Switch geometry (0-23)
  void switchGeometry(int geometryIndex) {
    if (!_isInitialized) return;

    final oldConfig = provider.getSynthesisConfig();
    provider.setGeometry(geometryIndex);
    final newConfig = provider.getSynthesisConfig();

    SynthLogger.geometrySwitch(
      geometryIndex - 1 < 0 ? 0 : geometryIndex - 1,
      geometryIndex,
    );
  }
}
