///
/// Audio Analyzer
///
/// Performs real-time FFT analysis and audio feature extraction
/// for driving visual parameter modulation in the VIB34D system.
///
/// Features:
/// - FFT computation with configurable window size
/// - Frequency band energy extraction (bass, mid, high)
/// - Spectral centroid calculation
/// - RMS amplitude computation
/// - Stereo width analysis
///
/// A Paul Phillips Manifestation
////

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:fftea/fftea.dart';

class AudioAnalyzer {
  // FFT Configuration
  late final FFT _fft;
  final int fftSize;
  final double sampleRate;

  // Frequency bands (Hz)
  static const double bassMin = 20.0;
  static const double bassMax = 250.0;
  static const double midMin = 250.0;
  static const double midMax = 2000.0;
  static const double highMin = 2000.0;
  static const double highMax = 8000.0;

  // Windowing function
  late final Float64List _hanningWindow;

  // Working buffers
  late final Float64List _windowedBuffer;
  late final Float64List _magnitudes;

  // Previous frame data for spectral flux
  Float64List? _previousMagnitudes;

  // Previous RMS for transient detection
  double _previousRMS = 0.0;

  // Transient history for density calculation
  final List<int> _transientTimestamps = [];
  static const int transientWindowMs = 1000; // 1 second window

  AudioAnalyzer({
    this.fftSize = 2048,
    this.sampleRate = 44100.0,
  }) {
    _fft = FFT(fftSize);
    _hanningWindow = _generateHanningWindow(fftSize);
    _windowedBuffer = Float64List(fftSize);
    _magnitudes = Float64List(fftSize ~/ 2);
  }

  /// Generate Hanning window for FFT
  Float64List _generateHanningWindow(int size) {
    final window = Float64List(size);
    for (int i = 0; i < size; i++) {
      window[i] = 0.5 * (1.0 - math.cos(2.0 * math.pi * i / (size - 1)));
    }
    return window;
  }

  /// Compute FFT and return magnitude spectrum
  Float64List computeFFT(Float32List audioBuffer) {
    // Apply windowing function
    for (int i = 0; i < fftSize && i < audioBuffer.length; i++) {
      _windowedBuffer[i] = audioBuffer[i].toDouble() * _hanningWindow[i];
    }

    // Pad with zeros if needed
    for (int i = audioBuffer.length; i < fftSize; i++) {
      _windowedBuffer[i] = 0.0;
    }

    // Perform FFT
    final fftResult = _fft.realFft(_windowedBuffer);

    // Compute magnitudes (only positive frequencies)
    for (int i = 0; i < _magnitudes.length; i++) {
      final real = fftResult[i].x;
      final imag = fftResult[i].y;
      _magnitudes[i] = math.sqrt(real * real + imag * imag);
    }

    return _magnitudes;
  }

  /// Get energy in a specific frequency band
  double getBandEnergy(Float64List magnitudes, double minFreq, double maxFreq) {
    final minBin = _freqToBin(minFreq);
    final maxBin = _freqToBin(maxFreq);

    double energy = 0.0;
    int count = 0;

    for (int i = minBin; i <= maxBin && i < magnitudes.length; i++) {
      energy += magnitudes[i];
      count++;
    }

    return count > 0 ? energy / count : 0.0;
  }

  /// Extract all frequency band energies at once
  AudioFeatures extractFeatures(Float32List audioBuffer) {
    final magnitudes = computeFFT(audioBuffer);
    final rms = computeRMS(audioBuffer);

    // Detect transients
    final isTransient = detectTransient(rms);

    return AudioFeatures(
      bassEnergy: getBandEnergy(magnitudes, bassMin, bassMax),
      midEnergy: getBandEnergy(magnitudes, midMin, midMax),
      highEnergy: getBandEnergy(magnitudes, highMin, highMax),
      spectralCentroid: computeSpectralCentroid(magnitudes),
      spectralFlux: computeSpectralFlux(magnitudes),
      fundamentalFreq: detectPitch(audioBuffer),
      rms: rms,
      stereoWidth: 0.5, // Placeholder - requires stereo buffer
      transientDensity: getTransientDensity(),
      noiseContent: computeNoiseContent(magnitudes),
    );
  }

  /// Compute spectral centroid (brightness measure)
  double computeSpectralCentroid(Float64List magnitudes) {
    double weightedSum = 0.0;
    double sum = 0.0;

    for (int i = 0; i < magnitudes.length; i++) {
      final freq = _binToFreq(i);
      weightedSum += magnitudes[i] * freq;
      sum += magnitudes[i];
    }

    return sum > 0.0 ? weightedSum / sum : 0.0;
  }

  /// Compute RMS amplitude
  double computeRMS(Float32List audioBuffer) {
    double sumSquares = 0.0;

    for (int i = 0; i < audioBuffer.length; i++) {
      sumSquares += audioBuffer[i] * audioBuffer[i];
    }

    return math.sqrt(sumSquares / audioBuffer.length);
  }

  /// Compute stereo width from left/right channels
  double computeStereoWidth(Float32List leftChannel, Float32List rightChannel) {
    double diffSum = 0.0;
    double sumSum = 0.0;

    final length = math.min(leftChannel.length, rightChannel.length);

    for (int i = 0; i < length; i++) {
      final mid = (leftChannel[i] + rightChannel[i]) / 2.0;
      final side = (leftChannel[i] - rightChannel[i]) / 2.0;

      diffSum += side.abs();
      sumSum += mid.abs();
    }

    return sumSum > 0.0 ? diffSum / sumSum : 0.0;
  }

  /// Compute spectral flux (rate of timbre change)
  double computeSpectralFlux(Float64List magnitudes) {
    if (_previousMagnitudes == null) {
      _previousMagnitudes = Float64List.fromList(magnitudes);
      return 0.0;
    }

    double flux = 0.0;
    final length = math.min(magnitudes.length, _previousMagnitudes!.length);

    for (int i = 0; i < length; i++) {
      final diff = magnitudes[i] - _previousMagnitudes![i];
      // Only count positive changes (increases in energy)
      if (diff > 0) {
        flux += diff * diff;
      }
    }

    // Update previous magnitudes for next frame
    _previousMagnitudes = Float64List.fromList(magnitudes);

    return math.sqrt(flux / length);
  }

  /// Detect fundamental frequency using autocorrelation
  double detectPitch(Float32List audioBuffer) {
    // Autocorrelation method for pitch detection
    final minPeriod = (sampleRate / 1000.0).round(); // 1000 Hz max
    final maxPeriod = (sampleRate / 60.0).round(); // 60 Hz min

    double maxCorrelation = 0.0;
    int bestPeriod = minPeriod;

    for (int period = minPeriod; period <= maxPeriod; period++) {
      double correlation = 0.0;
      int count = 0;

      for (int i = 0; i < audioBuffer.length - period; i++) {
        correlation += audioBuffer[i] * audioBuffer[i + period];
        count++;
      }

      if (count > 0) {
        correlation /= count;
        if (correlation > maxCorrelation) {
          maxCorrelation = correlation;
          bestPeriod = period;
        }
      }
    }

    // Convert period to frequency
    return maxCorrelation > 0.01 ? sampleRate / bestPeriod : 0.0;
  }

  /// Detect transients (attack onsets)
  bool detectTransient(double currentRMS, {double threshold = 1.5}) {
    final ratio = _previousRMS > 0.0 ? currentRMS / _previousRMS : 1.0;
    final isTransient = ratio > threshold;

    _previousRMS = currentRMS;

    if (isTransient) {
      final now = DateTime.now().millisecondsSinceEpoch;
      _transientTimestamps.add(now);

      // Clean up old timestamps (older than 1 second)
      _transientTimestamps
          .removeWhere((timestamp) => now - timestamp > transientWindowMs);
    }

    return isTransient;
  }

  /// Get transient density (number of transients per second)
  double getTransientDensity() {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Clean up old timestamps
    _transientTimestamps
        .removeWhere((timestamp) => now - timestamp > transientWindowMs);

    return _transientTimestamps.length.toDouble();
  }

  /// Compute harmonic-to-noise ratio (HNR)
  double computeNoiseContent(Float64List magnitudes) {
    // Simple HNR estimation: compare spectral peaks to overall energy
    // Lower HNR = more noise content

    // Find spectral peaks (harmonics)
    double peakEnergy = 0.0;
    double totalEnergy = 0.0;

    for (int i = 1; i < magnitudes.length - 1; i++) {
      totalEnergy += magnitudes[i];

      // Peak detection: local maximum
      if (magnitudes[i] > magnitudes[i - 1] &&
          magnitudes[i] > magnitudes[i + 1]) {
        peakEnergy += magnitudes[i];
      }
    }

    if (totalEnergy == 0.0) return 1.0; // All noise if no signal

    final hnr = peakEnergy / totalEnergy;
    // Return noise content (inverse of HNR)
    return 1.0 - hnr.clamp(0.0, 1.0);
  }

  /// Convert frequency to FFT bin index
  int _freqToBin(double freq) {
    return (freq * fftSize / sampleRate)
        .round()
        .clamp(0, _magnitudes.length - 1);
  }

  /// Convert FFT bin index to frequency
  double _binToFreq(int bin) {
    return bin * sampleRate / fftSize;
  }

  /// Normalize magnitude values to 0-1 range with smoothing
  double normalizeEnergy(double energy,
      {double maxExpected = 1.0, double smoothing = 0.8}) {
    final normalized = (energy / maxExpected).clamp(0.0, 1.0);
    return math.pow(normalized, smoothing).toDouble();
  }
}

/// Audio features extracted from analysis
class AudioFeatures {
  final double bassEnergy; // 20-250 Hz
  final double midEnergy; // 250-2000 Hz
  final double highEnergy; // 2000-8000 Hz
  final double spectralCentroid; // Brightness (Hz)
  final double spectralFlux; // Rate of timbre change
  final double fundamentalFreq; // Pitch (Hz)
  final double rms; // Amplitude
  final double stereoWidth; // Stereo spread (0-1)
  final double transientDensity; // Transients per second
  final double noiseContent; // 0=harmonic, 1=noisy

  const AudioFeatures({
    required this.bassEnergy,
    required this.midEnergy,
    required this.highEnergy,
    required this.spectralCentroid,
    required this.spectralFlux,
    required this.fundamentalFreq,
    required this.rms,
    required this.stereoWidth,
    required this.transientDensity,
    required this.noiseContent,
  });

  /// Compute overall energy (weighted average)
  double get totalEnergy =>
      (bassEnergy * 0.4) + (midEnergy * 0.35) + (highEnergy * 0.25);

  /// Normalize all features to 0-1 range
  AudioFeatures normalize({
    double bassMax = 2.0,
    double midMax = 1.5,
    double highMax = 1.0,
    double centroidMax = 8000.0,
    double fluxMax = 0.5,
    double pitchMax = 1000.0,
    double rmsMax = 0.5,
    double transientMax = 10.0,
  }) {
    return AudioFeatures(
      bassEnergy: (bassEnergy / bassMax).clamp(0.0, 1.0),
      midEnergy: (midEnergy / midMax).clamp(0.0, 1.0),
      highEnergy: (highEnergy / highMax).clamp(0.0, 1.0),
      spectralCentroid: (spectralCentroid / centroidMax).clamp(0.0, 1.0),
      spectralFlux: (spectralFlux / fluxMax).clamp(0.0, 1.0),
      fundamentalFreq: (fundamentalFreq / pitchMax).clamp(0.0, 1.0),
      rms: (rms / rmsMax).clamp(0.0, 1.0),
      stereoWidth: stereoWidth.clamp(0.0, 1.0),
      transientDensity: (transientDensity / transientMax).clamp(0.0, 1.0),
      noiseContent: noiseContent.clamp(0.0, 1.0),
    );
  }

  @override
  String toString() {
    return 'AudioFeatures('
        'bass: ${bassEnergy.toStringAsFixed(3)}, '
        'mid: ${midEnergy.toStringAsFixed(3)}, '
        'high: ${highEnergy.toStringAsFixed(3)}, '
        'centroid: ${spectralCentroid.toStringAsFixed(1)} Hz, '
        'flux: ${spectralFlux.toStringAsFixed(3)}, '
        'pitch: ${fundamentalFreq.toStringAsFixed(1)} Hz, '
        'rms: ${rms.toStringAsFixed(3)}, '
        'width: ${stereoWidth.toStringAsFixed(3)}, '
        'transients: ${transientDensity.toStringAsFixed(1)}/s, '
        'noise: ${noiseContent.toStringAsFixed(3)})';
  }
}
