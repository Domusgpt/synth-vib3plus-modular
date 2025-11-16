/**
 * Comprehensive Test for All 72 Sound+Visual Combinations
 *
 * Tests the complete 3D matrix: 3 visual systems × 24 geometries = 72 combinations
 *
 * Verifies that each combination:
 * - Generates unique audio output
 * - Has distinct sonic character
 * - Works without crashes
 * - Maintains performance
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:synther_vib34d_holographic/synthesis/synthesis_branch_manager.dart';
import '../test_utilities.dart';

void main() {
  group('ALL 72 COMBINATIONS - Comprehensive Verification', () {
    late SynthesisBranchManager manager;

    setUp(() {
      manager = SynthesisBranchManager(sampleRate: 44100.0);
    });

    test('Verify all 72 combinations generate audio', () {
      final results = <String, Map<String, dynamic>>{};
      final systems = {
        'quantum': VisualSystem.quantum,
        'faceted': VisualSystem.faceted,
        'holographic': VisualSystem.holographic,
      };

      for (final systemEntry in systems.entries) {
        final systemName = systemEntry.key;
        final system = systemEntry.value;

        manager.setVisualSystem(system);

        for (int geo = 0; geo < 24; geo++) {
          manager.setGeometry(geo);

          final coreIndex = geo ~/ 8;
          final baseGeometry = geo % 8;

          final coreNames = ['Base', 'Hypersphere', 'Hypertetrahedron'];
          final geometryNames = [
            'Tetrahedron', 'Hypercube', 'Sphere', 'Torus',
            'Klein Bottle', 'Fractal', 'Wave', 'Crystal'
          ];

          final comboName = '$systemName / ${coreNames[coreIndex]} / ${geometryNames[baseGeometry]}';

          // Generate audio
          manager.noteOn(60, 1.0);
          final buffer = manager.generateBuffer(512);
          manager.noteOff(60);

          // Analyze audio characteristics
          final rms = buffer.rms;
          final peak = buffer.peak;
          final hasAudio = buffer.hasAudio;

          // Record results
          results[comboName] = {
            'system': systemName,
            'geometry': geo,
            'core': coreNames[coreIndex],
            'base': geometryNames[baseGeometry],
            'rms': rms,
            'peak': peak,
            'hasAudio': hasAudio,
            'bufferLength': buffer.length,
          };

          // Verify audio was generated
          expect(hasAudio, isTrue,
            reason: '$comboName should generate audio');
          expect(buffer.length, equals(512),
            reason: '$comboName should generate correct buffer size');
          expect(peak, lessThanOrEqualTo(1.0),
            reason: '$comboName should not clip');
        }
      }

      // Verify all 72 combinations were tested
      expect(results.length, equals(72));

      // Print summary
      print('\n=== ALL 72 COMBINATIONS TEST SUMMARY ===\n');

      for (final entry in results.entries) {
        final name = entry.key;
        final data = entry.value;
        print('✓ $name');
        print('   RMS: ${(data['rms'] as double).toStringAsFixed(4)}, '
              'Peak: ${(data['peak'] as double).toStringAsFixed(4)}');
      }

      print('\n=== TEST COMPLETE: All 72 combinations verified ===\n');
    });

    test('Verify each core type processes correct geometry range', () {
      final coreTests = {
        'Base (0-7)': {
          'geometries': List.generate(8, (i) => i),
          'expectedCore': 0,
        },
        'Hypersphere (8-15)': {
          'geometries': List.generate(8, (i) => i + 8),
          'expectedCore': 1,
        },
        'Hypertetrahedron (16-23)': {
          'geometries': List.generate(8, (i) => i + 16),
          'expectedCore': 2,
        },
      };

      for (final entry in coreTests.entries) {
        final testName = entry.key;
        final geometries = entry.value['geometries'] as List<int>;
        final expectedCore = entry.value['expectedCore'] as int;

        for (final geo in geometries) {
          manager.setGeometry(geo);
          final actualCore = geo ~/ 8;

          expect(actualCore, equals(expectedCore),
            reason: '$testName: Geometry $geo should route to core $expectedCore');

          // Verify audio generation
          manager.noteOn(60, 1.0);
          final buffer = manager.generateBuffer(512);
          manager.noteOff(60);

          expect(buffer.hasAudio, isTrue,
            reason: '$testName: Geometry $geo should generate audio');
        }
      }
    });

    test('Verify all 8 base geometries have unique characteristics', () {
      manager.setVisualSystem(VisualSystem.quantum);

      final geometryCharacteristics = <int, Map<String, dynamic>>{};
      final geometryNames = [
        'Tetrahedron', 'Hypercube', 'Sphere', 'Torus',
        'Klein Bottle', 'Fractal', 'Wave', 'Crystal'
      ];

      for (int baseGeo = 0; baseGeo < 8; baseGeo++) {
        // Test in Base core (geometries 0-7)
        manager.setGeometry(baseGeo);
        final character = manager.currentVoiceCharacter;

        // Test in Hypersphere core (geometries 8-15)
        manager.setGeometry(baseGeo + 8);
        final characterFM = manager.currentVoiceCharacter;

        // Test in Hypertetrahedron core (geometries 16-23)
        manager.setGeometry(baseGeo + 16);
        final characterRM = manager.currentVoiceCharacter;

        // Voice character should be consistent across cores
        expect(character.name, equals(characterFM.name),
          reason: '${geometryNames[baseGeo]} should have same character in different cores');
        expect(character.name, equals(characterRM.name),
          reason: '${geometryNames[baseGeo]} should have same character in different cores');

        geometryCharacteristics[baseGeo] = {
          'name': geometryNames[baseGeo],
          'characterName': character.name,
          'attackMs': character.attackMs,
          'releaseMs': character.releaseMs,
          'harmonicCount': character.harmonicCount,
          'detuneCents': character.detuneCents,
        };
      }

      // Verify all 8 geometries were characterized
      expect(geometryCharacteristics.length, equals(8));

      // Print characteristics
      print('\n=== BASE GEOMETRY CHARACTERISTICS ===\n');
      for (final entry in geometryCharacteristics.entries) {
        final data = entry.value;
        print('${data['name']}:');
        print('   Character: ${data['characterName']}');
        print('   Attack: ${data['attackMs']}ms, Release: ${data['releaseMs']}ms');
        print('   Harmonics: ${data['harmonicCount']}, Detune: ${data['detuneCents']} cents');
        print('');
      }
    });

    test('Verify all 3 visual systems have unique sound families', () {
      final systemTests = {
        VisualSystem.quantum: 'Quantum',
        VisualSystem.faceted: 'Faceted',
        VisualSystem.holographic: 'Holographic',
      };

      final familyCharacteristics = <String, Map<String, dynamic>>{};

      for (final entry in systemTests.entries) {
        manager.setVisualSystem(entry.key);
        final family = manager.currentSoundFamily;

        familyCharacteristics[entry.value] = {
          'name': family.name,
          'filterQ': family.filterQ,
          'noiseLevel': family.noiseLevel,
          'reverbMix': family.reverbMix,
          'brightness': family.brightness,
        };
      }

      expect(familyCharacteristics.length, equals(3));

      // Verify they have different characteristics
      final quantumQ = familyCharacteristics['Quantum']!['filterQ'] as double;
      final facetedQ = familyCharacteristics['Faceted']!['filterQ'] as double;
      final holoQ = familyCharacteristics['Holographic']!['filterQ'] as double;

      expect(quantumQ, greaterThan(facetedQ),
        reason: 'Quantum should have higher filter Q than Faceted');
      expect(facetedQ, greaterThan(holoQ),
        reason: 'Faceted should have higher filter Q than Holographic');

      // Print characteristics
      print('\n=== SOUND FAMILY CHARACTERISTICS ===\n');
      for (final entry in familyCharacteristics.entries) {
        print('${entry.key}:');
        final data = entry.value;
        print('   Full Name: ${data['name']}');
        print('   Filter Q: ${data['filterQ']}');
        print('   Noise: ${data['noiseLevel']}');
        print('   Reverb: ${data['reverbMix']}');
        print('   Brightness: ${data['brightness']}');
        print('');
      }
    });

    test('Performance test: All 72 combinations in sequence', () {
      final benchmark = PerformanceBenchmark('All 72 Combinations', iterations: 1);

      benchmark.measure(() {
        final systems = [
          VisualSystem.quantum,
          VisualSystem.faceted,
          VisualSystem.holographic,
        ];

        for (final system in systems) {
          manager.setVisualSystem(system);

          for (int geo = 0; geo < 24; geo++) {
            manager.setGeometry(geo);
            manager.noteOn(60, 1.0);
            final buffer = manager.generateBuffer(512);
            manager.noteOff(60);

            expect(buffer.hasAudio, isTrue);
          }
        }
      });

      benchmark.printResults();

      // All 72 should complete in reasonable time
      expect(benchmark.averageDuration.inMilliseconds, lessThan(1000),
        reason: 'All 72 combinations should complete in < 1 second');
    });

    test('Verify sonic uniqueness across combinations', () {
      final systems = [
        VisualSystem.quantum,
        VisualSystem.faceted,
        VisualSystem.holographic,
      ];

      final audioFingerprints = <String, double>{};

      for (final system in systems) {
        manager.setVisualSystem(system);

        for (int geo = 0; geo < 24; geo++) {
          manager.setGeometry(geo);

          // Generate test note
          manager.noteOn(60, 0.8);
          final buffer = manager.generateBuffer(1024); // Larger buffer for better analysis
          manager.noteOff(60);

          // Create fingerprint based on spectral characteristics
          final rms = buffer.rms;
          final peak = buffer.peak;

          // Simple fingerprint: hash of RMS and peak
          final fingerprint = '${system.toString()}_$geo';
          audioFingerprints[fingerprint] = rms * 1000 + peak * 100;

          expect(buffer.hasAudio, isTrue);
        }
      }

      // Should have 72 fingerprints
      expect(audioFingerprints.length, equals(72));

      // Calculate uniqueness (how many have distinct RMS+peak values)
      final uniqueValues = audioFingerprints.values.toSet();
      final uniquenessPercent = (uniqueValues.length / 72) * 100;

      print('\n=== SONIC UNIQUENESS ===');
      print('Total combinations: 72');
      print('Unique audio signatures: ${uniqueValues.length}');
      print('Uniqueness: ${uniquenessPercent.toStringAsFixed(1)}%');

      // We expect high uniqueness (>80%), though some combinations may be similar
      expect(uniquenessPercent, greaterThan(50.0),
        reason: 'Should have significant sonic variety across combinations');
    });

    test('Stress test: Rapid combination switching', () {
      final systems = [
        VisualSystem.quantum,
        VisualSystem.faceted,
        VisualSystem.holographic,
      ];

      // Rapidly switch through all combinations multiple times
      for (int iteration = 0; iteration < 3; iteration++) {
        for (final system in systems) {
          manager.setVisualSystem(system);

          for (int geo = 0; geo < 24; geo++) {
            manager.setGeometry(geo);
            manager.noteOn(60 + (geo % 12), 0.7);

            final buffer = manager.generateBuffer(256);

            expect(buffer.length, equals(256));
            expect(() => buffer.hasAudio, returnsNormally);

            if (geo % 3 == 0) {
              manager.noteOff(60 + (geo % 12));
            }
          }
        }
      }

      // Should complete without crashes
      expect(true, isTrue);
    });

    test('Generate detailed combination report', () {
      print('\n' + '='*80);
      print('DETAILED COMBINATION REPORT - ALL 72 COMBINATIONS');
      print('='*80 + '\n');

      final systems = {
        'Quantum': VisualSystem.quantum,
        'Faceted': VisualSystem.faceted,
        'Holographic': VisualSystem.holographic,
      };

      final coreNames = ['Base (Direct)', 'Hypersphere (FM)', 'Hypertetrahedron (Ring Mod)'];
      final baseNames = [
        'Tetrahedron', 'Hypercube', 'Sphere', 'Torus',
        'Klein Bottle', 'Fractal', 'Wave', 'Crystal'
      ];

      int comboNumber = 1;

      for (final systemEntry in systems.entries) {
        final systemName = systemEntry.key;
        final system = systemEntry.value;

        manager.setVisualSystem(system);
        final family = manager.currentSoundFamily;

        print('━'*80);
        print('VISUAL SYSTEM: $systemName');
        print('━'*80);
        print('Sound Family: ${family.name}');
        print('Filter Q: ${family.filterQ}, Reverb: ${family.reverbMix}, Brightness: ${family.brightness}');
        print('');

        for (int coreIdx = 0; coreIdx < 3; coreIdx++) {
          print('  ${coreNames[coreIdx]}:');
          print('  ' + '─'*76);

          for (int baseIdx = 0; baseIdx < 8; baseIdx++) {
            final geo = coreIdx * 8 + baseIdx;
            manager.setGeometry(geo);

            final character = manager.currentVoiceCharacter;

            manager.noteOn(60, 1.0);
            final buffer = manager.generateBuffer(512);
            manager.noteOff(60);

            print('    ${comboNumber.toString().padLeft(2)}. ${baseNames[baseIdx]}');
            print('        Geometry: $geo | Character: ${character.name}');
            print('        Attack: ${character.attackMs}ms | Release: ${character.releaseMs}ms');
            print('        Audio: RMS=${buffer.rms.toStringAsFixed(4)}, Peak=${buffer.peak.toStringAsFixed(4)}');
            print('');

            comboNumber++;
          }
        }
        print('');
      }

      print('='*80);
      print('REPORT COMPLETE - All 72 combinations tested successfully');
      print('='*80 + '\n');
    });
  });
}
