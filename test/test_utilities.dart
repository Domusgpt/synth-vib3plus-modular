/**
 * Test Utilities for Synth-VIB3+ Testing
 *
 * Provides mock objects, test helpers, and utilities for comprehensive testing.
 *
 * A Paul Phillips Manifestation
 */

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synther_vib34d_holographic/audio/audio_analyzer.dart';
import 'package:synther_vib34d_holographic/synthesis/synthesis_branch_manager.dart';

/// Generate a simple sine wave for testing
Float32List generateTestSineWave({
  required double frequency,
  required double sampleRate,
  required int length,
  double amplitude = 1.0,
}) {
  final buffer = Float32List(length);
  for (int i = 0; i < length; i++) {
    final time = i / sampleRate;
    buffer[i] = amplitude * (0.5 * (1.0 + (2.0 * 3.14159 * frequency * time).sin()));
  }
  return buffer;
}

/// Generate a multi-frequency test signal (complex waveform)
Float32List generateComplexWaveform({
  required List<double> frequencies,
  required List<double> amplitudes,
  required double sampleRate,
  required int length,
}) {
  assert(frequencies.length == amplitudes.length,
    'Frequencies and amplitudes must have same length');

  final buffer = Float32List(length);
  for (int i = 0; i < length; i++) {
    final time = i / sampleRate;
    double sample = 0.0;
    for (int j = 0; j < frequencies.length; j++) {
      sample += amplitudes[j] * (2.0 * 3.14159 * frequencies[j] * time).sin();
    }
    buffer[i] = sample;
  }
  return buffer;
}

/// Generate white noise for testing
Float32List generateWhiteNoise({
  required int length,
  double amplitude = 1.0,
  int? seed,
}) {
  final random = seed != null ? Random(seed) : Random();
  final buffer = Float32List(length);
  for (int i = 0; i < length; i++) {
    buffer[i] = amplitude * (random.nextDouble() * 2.0 - 1.0);
  }
  return buffer;
}

/// Verify buffer is not silent (has non-zero samples)
bool bufferHasAudio(Float32List buffer, {double threshold = 0.001}) {
  for (final sample in buffer) {
    if (sample.abs() > threshold) {
      return true;
    }
  }
  return false;
}

/// Calculate RMS (root mean square) of buffer
double calculateRMS(Float32List buffer) {
  if (buffer.isEmpty) return 0.0;

  double sum = 0.0;
  for (final sample in buffer) {
    sum += sample * sample;
  }
  return (sum / buffer.length).sqrt();
}

/// Calculate peak amplitude of buffer
double calculatePeak(Float32List buffer) {
  if (buffer.isEmpty) return 0.0;

  double peak = 0.0;
  for (final sample in buffer) {
    final abs = sample.abs();
    if (abs > peak) peak = abs;
  }
  return peak;
}

/// Verify two buffers are approximately equal
bool buffersEqual(Float32List a, Float32List b, {double tolerance = 0.01}) {
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    if ((a[i] - b[i]).abs() > tolerance) {
      return false;
    }
  }
  return true;
}

/// Test all 72 geometry combinations (3 systems × 24 geometries)
class GeometryCombinations {
  static const List<String> systemNames = ['quantum', 'faceted', 'holographic'];
  static const int totalGeometries = 24;

  /// Get all 72 combinations as list of (system, geometryIndex) pairs
  static List<GeometryCombination> getAll() {
    final combinations = <GeometryCombination>[];
    for (final system in systemNames) {
      for (int geometry = 0; geometry < totalGeometries; geometry++) {
        combinations.add(GeometryCombination(
          system: system,
          geometryIndex: geometry,
        ));
      }
    }
    return combinations;
  }

  /// Get combinations for a specific core (Base/Hypersphere/Hypertetrahedron)
  static List<GeometryCombination> getForCore(int coreIndex) {
    assert(coreIndex >= 0 && coreIndex < 3, 'Core index must be 0-2');
    final combinations = <GeometryCombination>[];
    final startGeometry = coreIndex * 8;
    final endGeometry = startGeometry + 8;

    for (final system in systemNames) {
      for (int geometry = startGeometry; geometry < endGeometry; geometry++) {
        combinations.add(GeometryCombination(
          system: system,
          geometryIndex: geometry,
        ));
      }
    }
    return combinations;
  }
}

class GeometryCombination {
  final String system;
  final int geometryIndex;

  GeometryCombination({
    required this.system,
    required this.geometryIndex,
  });

  int get coreIndex => geometryIndex ~/ 8;
  int get baseGeometry => geometryIndex % 8;

  String get coreName {
    switch (coreIndex) {
      case 0: return 'Base';
      case 1: return 'Hypersphere';
      case 2: return 'Hypertetrahedron';
      default: return 'Unknown';
    }
  }

  String get geometryName {
    switch (baseGeometry) {
      case 0: return 'Tetrahedron';
      case 1: return 'Hypercube';
      case 2: return 'Sphere';
      case 3: return 'Torus';
      case 4: return 'Klein Bottle';
      case 5: return 'Fractal';
      case 6: return 'Wave';
      case 7: return 'Crystal';
      default: return 'Unknown';
    }
  }

  @override
  String toString() {
    return '$system / $coreName / $geometryName (geo $geometryIndex)';
  }
}

/// Audio feature matchers for testing
class AudioFeatureMatcher {
  /// Verify bass energy is in expected range
  static Matcher bassEnergyInRange(double min, double max) {
    return inInclusiveRange(min, max);
  }

  /// Verify frequency content matches expectations
  static bool hasFrequencyContent(
    AudioFeatures features,
    double frequency,
    {double tolerance = 50.0}
  ) {
    // Check if spectral centroid is near expected frequency
    return (features.spectralCentroid - frequency).abs() < tolerance;
  }
}

/// Mock AudioProvider for testing without real audio hardware
class MockAudioProvider {
  double sampleRate = 44100.0;
  int bufferSize = 512;
  bool isPlaying = false;
  int currentNote = 60;

  Float32List? lastGeneratedBuffer;

  void playNote(int midiNote) {
    currentNote = midiNote;
    isPlaying = true;
  }

  void stopNote() {
    isPlaying = false;
  }

  Float32List generateTestBuffer() {
    final frequency = 440.0 * (2.0.pow((currentNote - 69) / 12.0));
    lastGeneratedBuffer = generateTestSineWave(
      frequency: frequency,
      sampleRate: sampleRate,
      length: bufferSize,
    );
    return lastGeneratedBuffer!;
  }
}

/// Mock VisualProvider for testing without WebView
class MockVisualProvider extends ChangeNotifier {
  String currentSystem = 'quantum';
  int currentGeometry = 0;

  // Rotation parameters (0-2π)
  double rotationXY = 0.0;
  double rotationXZ = 0.0;
  double rotationYZ = 0.0;
  double rotationXW = 0.0;
  double rotationYW = 0.0;
  double rotationZW = 0.0;

  // Visual parameters (0-1)
  double morphParameter = 0.5;
  double chaosParameter = 0.0;
  double speedParameter = 1.0;
  double glowIntensity = 0.5;

  void switchSystem(String system) {
    currentSystem = system;
    notifyListeners();
  }

  void switchGeometry(int index) {
    currentGeometry = index;
    notifyListeners();
  }

  void setRotationXY(double value) {
    rotationXY = value;
    notifyListeners();
  }

  void setRotationXW(double value) {
    rotationXW = value;
    notifyListeners();
  }

  void setMorph(double value) {
    morphParameter = value;
    notifyListeners();
  }

  void setChaos(double value) {
    chaosParameter = value;
    notifyListeners();
  }
}

/// Extension for easier test assertions
extension AudioBufferTestExtensions on Float32List {
  bool get hasAudio => bufferHasAudio(this);
  double get rms => calculateRMS(this);
  double get peak => calculatePeak(this);

  bool approximatelyEquals(Float32List other, {double tolerance = 0.01}) {
    return buffersEqual(this, other, tolerance: tolerance);
  }
}

/// Test data generators for comprehensive testing
class TestDataGenerators {
  /// Generate test cases for all MIDI notes (60-96 = C3-C7)
  static List<int> getMidiNoteTestCases() {
    return [60, 64, 67, 72, 76, 79, 84, 88, 91, 96]; // Common notes
  }

  /// Generate test cases for rotation angles
  static List<double> getRotationTestCases() {
    return [
      0.0,
      3.14159 / 4, // 45 degrees
      3.14159 / 2, // 90 degrees
      3.14159,     // 180 degrees
      3.14159 * 1.5, // 270 degrees
      3.14159 * 2,   // 360 degrees (full rotation)
    ];
  }

  /// Generate test cases for normalized parameters (0-1)
  static List<double> getNormalizedTestCases() {
    return [0.0, 0.25, 0.5, 0.75, 1.0];
  }
}

/// Performance benchmarking utilities
class PerformanceBenchmark {
  final String name;
  final int iterations;
  final List<Duration> _measurements = [];

  PerformanceBenchmark(this.name, {this.iterations = 100});

  Duration measure(void Function() operation) {
    _measurements.clear();

    for (int i = 0; i < iterations; i++) {
      final start = DateTime.now();
      operation();
      final end = DateTime.now();
      _measurements.add(end.difference(start));
    }

    return averageDuration;
  }

  Duration get averageDuration {
    if (_measurements.isEmpty) return Duration.zero;
    final totalMicroseconds = _measurements
      .map((d) => d.inMicroseconds)
      .reduce((a, b) => a + b);
    return Duration(microseconds: totalMicroseconds ~/ _measurements.length);
  }

  Duration get minDuration => _measurements.isEmpty
    ? Duration.zero
    : _measurements.reduce((a, b) => a.inMicroseconds < b.inMicroseconds ? a : b);

  Duration get maxDuration => _measurements.isEmpty
    ? Duration.zero
    : _measurements.reduce((a, b) => a.inMicroseconds > b.inMicroseconds ? a : b);

  void printResults() {
    print('=== $name ===');
    print('Iterations: $iterations');
    print('Average: ${averageDuration.inMicroseconds / 1000.0} ms');
    print('Min: ${minDuration.inMicroseconds / 1000.0} ms');
    print('Max: ${maxDuration.inMicroseconds / 1000.0} ms');
  }
}

// Import Random from dart:math
import 'dart:math';
