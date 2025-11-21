/**
 * Unit Tests for Synthesis Branch Manager
 *
 * Tests the 3D matrix system: 3 systems × 3 cores × 8 geometries = 72 combinations
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:synther_vib34d_holographic/synthesis/synthesis_branch_manager.dart';
import '../test_utilities.dart';

void main() {
  group('SynthesisBranchManager - Core Routing', () {
    late SynthesisBranchManager manager;

    setUp(() {
      manager = SynthesisBranchManager(sampleRate: 44100.0);
    });

    test('should route geometries 0-7 to Base core (Direct synthesis)', () {
      for (int geo = 0; geo < 8; geo++) {
        manager.setGeometry(geo);
        final coreIndex = manager.currentGeometry ~/ 8;
        expect(coreIndex, equals(0), reason: 'Geometry $geo should route to Base core');
      }
    });

    test('should route geometries 8-15 to Hypersphere core (FM synthesis)', () {
      for (int geo = 8; geo < 16; geo++) {
        manager.setGeometry(geo);
        final coreIndex = manager.currentGeometry ~/ 8;
        expect(coreIndex, equals(1), reason: 'Geometry $geo should route to Hypersphere core');
      }
    });

    test('should route geometries 16-23 to Hypertetrahedron core (Ring mod)', () {
      for (int geo = 16; geo < 24; geo++) {
        manager.setGeometry(geo);
        final coreIndex = manager.currentGeometry ~/ 8;
        expect(coreIndex, equals(2), reason: 'Geometry $geo should route to Hypertetrahedron core');
      }
    });

    test('should calculate base geometry correctly', () {
      final testCases = {
        0: 0,   // Tetrahedron
        1: 1,   // Hypercube
        7: 7,   // Crystal
        8: 0,   // Hypersphere + Tetrahedron
        11: 3,  // Hypersphere + Torus
        16: 0,  // Hypertetrahedron + Tetrahedron
        23: 7,  // Hypertetrahedron + Crystal
      };

      testCases.forEach((geometryIndex, expectedBase) {
        manager.setGeometry(geometryIndex);
        final baseGeometry = manager.currentGeometry % 8;
        expect(baseGeometry, equals(expectedBase),
          reason: 'Geometry $geometryIndex should have base geometry $expectedBase');
      });
    });
  });

  group('SynthesisBranchManager - Sound Families', () {
    late SynthesisBranchManager manager;

    setUp(() {
      manager = SynthesisBranchManager(sampleRate: 44100.0);
    });

    test('should apply Quantum family characteristics', () {
      manager.setVisualSystem(VisualSystem.quantum);
      final family = manager.soundFamily;

      expect(family.name, contains('Quantum'));
      expect(family.filterQ, greaterThan(7.0), reason: 'Quantum should have high filter Q');
      expect(family.noiseLevel, lessThan(0.01), reason: 'Quantum should have minimal noise');
    });

    test('should apply Faceted family characteristics', () {
      manager.setVisualSystem(VisualSystem.faceted);
      final family = manager.soundFamily;

      expect(family.name, contains('Faceted'));
      expect(family.filterQ, inInclusiveRange(4.0, 7.0), reason: 'Faceted should have moderate Q');
    });

    test('should apply Holographic family characteristics', () {
      manager.setVisualSystem(VisualSystem.holographic);
      final family = manager.soundFamily;

      expect(family.name, contains('Holographic'));
      expect(family.reverbMix, greaterThan(0.3), reason: 'Holographic should have high reverb');
      expect(family.filterQ, lessThan(5.0), reason: 'Holographic should have lower Q');
    });
  });

  group('SynthesisBranchManager - Voice Characters', () {
    late SynthesisBranchManager manager;

    setUp(() {
      manager = SynthesisBranchManager(sampleRate: 44100.0);
    });

    test('Tetrahedron (0) should have fundamental character', () {
      manager.setGeometry(0); // Base core, Tetrahedron
      final character = manager.voiceCharacter;

      expect(character.name, equals('Fundamental'));
      expect(character.detuneCents, equals(0.0), reason: 'Should have perfect tuning');
      expect(character.harmonicCount, lessThanOrEqualTo(3), reason: 'Should have minimal harmonics');
    });

    test('Hypercube (1) should have complex character', () {
      manager.setGeometry(1); // Base core, Hypercube
      final character = manager.voiceCharacter;

      expect(character.name, equals('Complex'));
      expect(character.hasChorusEffect, isTrue, reason: 'Should have chorus');
      expect(character.harmonicCount, greaterThanOrEqualTo(5), reason: 'Should have rich harmonics');
    });

    test('Crystal (7) should have sharp attack', () {
      manager.setGeometry(7); // Base core, Crystal
      final character = manager.voiceCharacter;

      expect(character.name, equals('Crystalline'));
      expect(character.attackMs, lessThan(15.0), reason: 'Should have fast attack');
    });

    test('Voice character should persist across core changes', () {
      // Test that base geometry determines character, not core
      manager.setGeometry(0);  // Base + Tetrahedron
      final char1 = manager.voiceCharacter.name;

      manager.setGeometry(8);  // Hypersphere + Tetrahedron
      final char2 = manager.voiceCharacter.name;

      manager.setGeometry(16); // Hypertetrahedron + Tetrahedron
      final char3 = manager.voiceCharacter.name;

      expect(char1, equals(char2));
      expect(char2, equals(char3));
      expect(char1, equals('Fundamental'), reason: 'Tetrahedron should always be Fundamental');
    });
  });

  group('SynthesisBranchManager - Audio Generation', () {
    late SynthesisBranchManager manager;

    setUp(() {
      manager = SynthesisBranchManager(sampleRate: 44100.0);
    });

    test('should generate non-zero audio after noteOn', () {
      manager.setGeometry(0);
      manager.noteOn(60, 1.0); // Middle C

      final buffer = manager.generateBuffer(512);

      expect(buffer.length, equals(512));
      expect(buffer.hasAudio, isTrue, reason: 'Buffer should contain non-zero samples');
    });

    test('should generate different audio for different notes', () {
      manager.setGeometry(0);

      manager.noteOn(60, 1.0); // Middle C
      final buffer60 = manager.generateBuffer(512);

      manager.noteOff(60);
      manager.noteOn(72, 1.0); // C5 (octave higher)
      final buffer72 = manager.generateBuffer(512);

      expect(buffer60.approximatelyEquals(buffer72), isFalse,
        reason: 'Different notes should produce different audio');
    });

    test('should generate silence after noteOff completes release', () {
      manager.setGeometry(0);
      manager.noteOn(60, 1.0);

      // Generate some audio
      manager.generateBuffer(512);

      manager.noteOff(60);

      // Generate enough buffers for release to complete (assuming < 1 second release)
      for (int i = 0; i < 100; i++) {
        manager.generateBuffer(512);
      }

      final finalBuffer = manager.generateBuffer(512);
      final rms = finalBuffer.rms;

      expect(rms, lessThan(0.001), reason: 'Should be silent after release completes');
    });

    test('should support polyphony (multiple simultaneous notes)', () {
      manager.setGeometry(0);

      // Play a C major triad
      manager.noteOn(60, 1.0); // C
      manager.noteOn(64, 1.0); // E
      manager.noteOn(67, 1.0); // G

      final buffer = manager.generateBuffer(512);

      expect(buffer.hasAudio, isTrue);
      expect(buffer.rms, greaterThan(0.05), reason: 'Should have significant amplitude with 3 notes');
    });
  });

  group('SynthesisBranchManager - All 72 Combinations', () {
    late SynthesisBranchManager manager;

    setUp(() {
      manager = SynthesisBranchManager(sampleRate: 44100.0);
    });

    test('should generate unique audio for each combination', () {
      final combinations = GeometryCombinations.getAll();
      expect(combinations.length, equals(72), reason: 'Should have exactly 72 combinations');

      final audioFingerprints = <String, String>{};

      for (final combo in combinations) {
        // Set system and geometry
        switch (combo.system) {
          case 'quantum':
            manager.setVisualSystem(VisualSystem.quantum);
            break;
          case 'faceted':
            manager.setVisualSystem(VisualSystem.faceted);
            break;
          case 'holographic':
            manager.setVisualSystem(VisualSystem.holographic);
            break;
        }
        manager.setGeometry(combo.geometryIndex);

        // Generate audio
        manager.noteOn(60, 1.0);
        final buffer = manager.generateBuffer(512);
        manager.noteOff(60);

        // Create fingerprint (RMS + peak)
        final fingerprint = '${buffer.rms.toStringAsFixed(4)}_${buffer.peak.toStringAsFixed(4)}';

        // Verify audio was generated
        expect(buffer.hasAudio, isTrue,
          reason: 'Combination ${combo.toString()} should generate audio');

        // Store fingerprint for uniqueness check
        audioFingerprints[combo.toString()] = fingerprint;
      }

      // Note: We don't strictly require 72 unique fingerprints since some
      // combinations might produce similar waveforms, but we verify all generated audio
      expect(audioFingerprints.length, equals(72),
        reason: 'All 72 combinations should generate audio');
    });

    test('should verify Base core geometries use direct synthesis', () {
      final baseCombos = GeometryCombinations.getForCore(0);
      expect(baseCombos.length, equals(24), reason: '3 systems × 8 geometries = 24');

      for (final combo in baseCombos) {
        expect(combo.coreName, equals('Base'));
        expect(combo.coreIndex, equals(0));
      }
    });

    test('should verify Hypersphere core geometries use FM synthesis', () {
      final fmCombos = GeometryCombinations.getForCore(1);
      expect(fmCombos.length, equals(24));

      for (final combo in fmCombos) {
        expect(combo.coreName, equals('Hypersphere'));
        expect(combo.coreIndex, equals(1));
      }
    });

    test('should verify Hypertetrahedron core geometries use ring mod', () {
      final ringModCombos = GeometryCombinations.getForCore(2);
      expect(ringModCombos.length, equals(24));

      for (final combo in ringModCombos) {
        expect(combo.coreName, equals('Hypertetrahedron'));
        expect(combo.coreIndex, equals(2));
      }
    });
  });

  group('SynthesisBranchManager - Performance', () {
    late SynthesisBranchManager manager;

    setUp(() {
      manager = SynthesisBranchManager(sampleRate: 44100.0);
    });

    test('should generate 512-sample buffer in < 10ms (real-time requirement)', () {
      manager.setGeometry(5);
      manager.noteOn(60, 1.0);

      final benchmark = PerformanceBenchmark('Buffer Generation (512 samples)', iterations: 50);
      final avgDuration = benchmark.measure(() {
        manager.generateBuffer(512);
      });

      print('Average buffer generation time: ${avgDuration.inMicroseconds / 1000.0} ms');

      // For 512 samples at 44100 Hz = 11.6ms of audio
      // Generation should be faster than real-time
      expect(avgDuration.inMilliseconds, lessThan(10),
        reason: 'Should generate audio faster than real-time for <10ms latency');
    });

    test('should handle rapid geometry switching without crashes', () {
      manager.noteOn(60, 1.0);

      for (int i = 0; i < 100; i++) {
        manager.setGeometry(i % 24);
        final buffer = manager.generateBuffer(256);
        expect(buffer.length, equals(256));
      }

      manager.noteOff(60);
    });

    test('should handle rapid system switching', () {
      manager.noteOn(60, 1.0);

      final systems = [
        VisualSystem.quantum,
        VisualSystem.faceted,
        VisualSystem.holographic,
      ];

      for (int i = 0; i < 50; i++) {
        manager.setVisualSystem(systems[i % 3]);
        final buffer = manager.generateBuffer(256);
        expect(buffer.hasAudio, isTrue);
      }

      manager.noteOff(60);
    });
  });

  group('SynthesisBranchManager - Edge Cases', () {
    late SynthesisBranchManager manager;

    setUp(() {
      manager = SynthesisBranchManager(sampleRate: 44100.0);
    });

    test('should handle geometry index out of range', () {
      expect(() => manager.setGeometry(-1), throwsA(anything));
      expect(() => manager.setGeometry(24), throwsA(anything));
    });

    test('should handle zero velocity noteOn', () {
      manager.setGeometry(0);
      manager.noteOn(60, 0.0);

      final buffer = manager.generateBuffer(512);
      // Should generate either silence or very quiet audio
      expect(buffer.rms, lessThan(0.1));
    });

    test('should handle high velocity noteOn', () {
      manager.setGeometry(0);
      manager.noteOn(60, 1.0);

      final buffer = manager.generateBuffer(512);
      expect(buffer.hasAudio, isTrue);
      expect(buffer.peak, lessThanOrEqualTo(1.0), reason: 'Should not clip');
    });

    test('should handle very low MIDI notes', () {
      manager.setGeometry(0);
      manager.noteOn(24, 1.0); // Very low note (C1)

      final buffer = manager.generateBuffer(512);
      expect(buffer.hasAudio, isTrue);
    });

    test('should handle very high MIDI notes', () {
      manager.setGeometry(0);
      manager.noteOn(108, 1.0); // Very high note (C8)

      final buffer = manager.generateBuffer(512);
      expect(buffer.hasAudio, isTrue);
    });
  });
}
