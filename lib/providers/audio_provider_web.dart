/**
 * Web-Compatible Audio Provider
 *
 * Provides a graceful fallback for web platform where flutter_pcm_sound
 * is not available. Shows UI placeholders and messages about mobile app.
 *
 * Philosophy: Work everywhere, adapt gracefully, show what's possible.
 *
 * A Paul Phillips Manifestation
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/platform_capabilities.dart';

/// Web-compatible audio features (simulated)
class AudioFeatures {
  final double rms;
  final double spectralCentroid;
  final bool transient;
  final double bassEnergy;
  final double dominantFrequency;

  const AudioFeatures({
    this.rms = 0.0,
    this.spectralCentroid = 0.0,
    this.transient = false,
    this.bassEnergy = 0.0,
    this.dominantFrequency = 440.0,
  });
}

/// Web-compatible audio provider (graceful fallback)
class AudioProviderWeb with ChangeNotifier {
  // Simulated state (no actual audio on web)
  int _currentNote = 60; // Middle C
  bool _isPlaying = false;
  double _masterVolume = 0.7;
  double _filterCutoff = 1000.0;
  int _voiceCount = 0;

  // Simulated audio features
  AudioFeatures _currentFeatures = const AudioFeatures();

  // Platform message shown to user
  String get platformMessage => PlatformMessages.getFeatureUnavailableMessage('Real-time Audio Synthesis');

  // Getters
  int get currentNote => _currentNote;
  bool get isPlaying => _isPlaying;
  double get masterVolume => _masterVolume;
  double get filterCutoff => _filterCutoff;
  int get voiceCount => _voiceCount;
  AudioFeatures? get currentFeatures => _currentFeatures;

  // Check if audio is available
  bool get isAudioAvailable => PlatformCapabilities.supportsAudioSynthesis;

  // Simulated methods (no-op on web)
  void playNote(int midiNote) {
    if (!isAudioAvailable) {
      debugPrint('Audio not available on web - download mobile app');
      return;
    }

    _currentNote = midiNote;
    _isPlaying = true;
    _voiceCount++;
    notifyListeners();

    // Auto-release after 500ms (simulated)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_voiceCount > 0) _voiceCount--;
      _isPlaying = false;
      notifyListeners();
    });
  }

  void stopNote(int midiNote) {
    if (_voiceCount > 0) _voiceCount--;
    _isPlaying = false;
    notifyListeners();
  }

  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setFilterCutoff(double cutoff) {
    _filterCutoff = cutoff.clamp(20.0, 20000.0);
    notifyListeners();
  }

  void setFilterResonance(double resonance) {
    // No-op on web
    notifyListeners();
  }

  // Cleanup (no-op on web)
  @override
  void dispose() {
    debugPrint('AudioProviderWeb disposed');
    super.dispose();
  }
}

/// Factory to create appropriate audio provider based on platform
class AudioProviderFactory {
  static dynamic create() {
    if (PlatformCapabilities.supportsAudioSynthesis) {
      // On mobile, use the real AudioProvider
      // This would normally import '../providers/audio_provider.dart'
      // but we can't do that here due to conditional compilation
      throw UnimplementedError('Use real AudioProvider on mobile');
    } else {
      // On web, use the web-compatible fallback
      return AudioProviderWeb();
    }
  }
}
