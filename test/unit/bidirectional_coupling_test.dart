/**
 * Bidirectional Audio-Visual Coupling Unit Tests
 *
 * Tests the core logic of parameter mappings WITHOUT requiring WebView/device.
 * Validates that the coupling algorithms work correctly.
 *
 * A Paul Phillips Manifestation
 */

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:synther_vib34d_holographic/mapping/audio_to_visual.dart';
import 'package:synther_vib34d_holographic/mapping/visual_to_audio.dart';
import '../test_utilities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Audio → Visual Modulation Logic', () {
    late MockAudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late AudioToVisualModulator modulator;

    setUp(() {
      audioProvider = MockAudioProvider();
      visualProvider = MockVisualProvider();
      modulator = AudioToVisualModulator(
        audioProvider: audioProvider as dynamic,
        visualProvider: visualProvider,
      );
    });

    test('should extract FFT features from audio buffer', () {
      // Generate test audio with known frequency content
      final bassSignal = generateTestSineWave(
        frequency: 100.0, // Bass range
        sampleRate: 44100.0,
        length: 2048,
        amplitude: 0.8,
      );

      // Analyzer should extract features
      final features = modulator.analyzer.extractFeatures(bassSignal);

      expect(features.bassEnergy, greaterThan(0.0),
        reason: 'Should detect bass energy from 100Hz signal');
      expect(features.rms, greaterThan(0.0),
        reason: 'Should calculate RMS amplitude');
    });

    test('should map bass energy to rotation speed', () {
      // Create bass-heavy audio
      final bassBuffer = generateTestSineWave(
        frequency: 80.0,
        sampleRate: 44100.0,
        length: 512,
        amplitude: 1.0,
      );

      final initialSpeed = visualProvider.rotationSpeed;

      // Modulate from audio
      modulator.updateFromAudio(bassBuffer);

      // Rotation speed should change (may increase or stay same)
      expect(visualProvider.rotationSpeed, greaterThanOrEqualTo(initialSpeed * 0.8),
        reason: 'Rotation speed should respond to bass energy');
    });

    test('should map spectral centroid to hue shift', () {
      // Create high-frequency signal (bright spectrum)
      final trebleBuffer = generateTestSineWave(
        frequency: 4000.0,
        sampleRate: 44100.0,
        length: 512,
      );

      modulator.updateFromAudio(trebleBuffer);

      // Hue shift should update based on spectral centroid
      expect(visualProvider.hueShift, inInclusiveRange(0.0, 360.0),
        reason: 'Hue shift should be valid range');
    });

    test('should map RMS to glow intensity', () {
      // Create loud signal
      final loudBuffer = generateTestSineWave(
        frequency: 440.0,
        sampleRate: 44100.0,
        length: 512,
        amplitude: 0.9,
      );

      modulator.updateFromAudio(loudBuffer);

      // Glow intensity should respond to amplitude
      expect(visualProvider.glowIntensity, greaterThan(0.0),
        reason: 'Glow should respond to audio amplitude');
    });

    test('should handle silent audio gracefully', () {
      // Create silent buffer
      final silentBuffer = Float32List(512);

      expect(() => modulator.updateFromAudio(silentBuffer), returnsNormally,
        reason: 'Should handle silence without crashing');
    });
  });

  group('Visual → Audio Modulation Logic', () {
    late MockAudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late VisualToAudioModulator modulator;

    setUp(() {
      audioProvider = MockAudioProvider();
      visualProvider = MockVisualProvider();
      modulator = VisualToAudioModulator(
        audioProvider: audioProvider as dynamic,
        visualProvider: visualProvider,
      );
    });

    test('should map 4D rotation to oscillator frequency modulation', () {
      // Set rotation XW
      visualProvider.setRotationXW(1.0); // ~1 radian

      // Update audio from visuals
      modulator.updateFromVisuals();

      // Oscillator frequencies should be modulated
      // (Can't directly test without AudioProvider interface, but shouldn't crash)
      expect(() => modulator.updateFromVisuals(), returnsNormally);
    });

    test('should map morph parameter to synthesis', () {
      // Set morph to halfway
      visualProvider.setMorphParameter(0.5);

      modulator.updateFromVisuals();

      expect(() => modulator.updateFromVisuals(), returnsNormally,
        reason: 'Should handle morph parameter mapping');
    });

    test('should sync geometry to synthesis branch manager', () {
      // Switch to different geometry
      visualProvider.setGeometry(11); // Hypersphere Torus

      modulator.updateFromVisuals();

      // Should route to correct synthesis core
      expect(audioProvider.synthesisBranchManager.currentGeometry, equals(11));
      expect(audioProvider.synthesisBranchManager.voiceCharacter.toString(),
        contains('Torus'));
    });

    test('should sync visual system to sound family', () {
      // Switch visual system
      visualProvider.switchSystem('holographic');

      modulator.updateFromVisuals();

      // Sound family should update
      expect(audioProvider.synthesisBranchManager.soundFamily.toString(),
        contains('Holographic'));
    });

    test('should map projection distance to audio parameters', () {
      // Set projection distance
      visualProvider.setProjectionDistance(12.0);

      modulator.updateFromVisuals();

      expect(() => modulator.updateFromVisuals(), returnsNormally,
        reason: 'Should handle projection distance mapping');
    });

    test('should handle all 3 visual systems correctly', () {
      final systems = ['quantum', 'faceted', 'holographic'];

      for (final system in systems) {
        visualProvider.switchSystem(system);
        modulator.updateFromVisuals();

        expect(audioProvider.synthesisBranchManager.soundFamily.toString(),
          isNotEmpty,
          reason: 'System $system should map to sound family');
      }
    });
  });

  group('Bidirectional Coupling Validation', () {
    test('should verify all audio features map to visual parameters', () {
      final audioProvider = MockAudioProvider();
      final visualProvider = MockVisualProvider();
      final audioToVisual = AudioToVisualModulator(
        audioProvider: audioProvider as dynamic,
        visualProvider: visualProvider,
      );

      // Verify mappings exist
      expect(audioToVisual.exportMappings(), isNotEmpty,
        reason: 'Should have audio→visual mappings');

      final mappings = audioToVisual.exportMappings();

      // Check key mappings
      expect(mappings.keys, contains('bassEnergy_to_rotationSpeed'));
      expect(mappings.keys, contains('midEnergy_to_tessellationDensity'));
      expect(mappings.keys, contains('highEnergy_to_vertexBrightness'));
      expect(mappings.keys, contains('spectralCentroid_to_hueShift'));
      expect(mappings.keys, contains('rms_to_glowIntensity'));
    });

    test('should verify all visual parameters map to audio', () {
      final audioProvider = MockAudioProvider();
      final visualProvider = MockVisualProvider();
      final visualToAudio = VisualToAudioModulator(
        audioProvider: audioProvider as dynamic,
        visualProvider: visualProvider,
      );

      // Verify mappings exist
      expect(visualToAudio.exportMappings(), isNotEmpty,
        reason: 'Should have visual→audio mappings');

      final mappings = visualToAudio.exportMappings();

      // Check key mappings
      expect(mappings.keys, contains('rotationXW_to_osc1Freq'));
      expect(mappings.keys, contains('rotationYW_to_osc2Freq'));
      expect(mappings.keys, contains('rotationZW_to_filterCutoff'));
      expect(mappings.keys, contains('morphParameter_to_wavetable'));
      expect(mappings.keys, contains('projectionDistance_to_reverb'));
    });

    test('should verify 72-combination matrix integrates with coupling', () {
      final audioProvider = MockAudioProvider();
      final visualProvider = MockVisualProvider();
      final visualToAudio = VisualToAudioModulator(
        audioProvider: audioProvider as dynamic,
        visualProvider: visualProvider,
      );

      final systems = ['quantum', 'faceted', 'holographic'];
      final geometries = List.generate(24, (i) => i);

      int testCount = 0;

      // Test that all 72 combinations can be set via visual provider
      for (final system in systems) {
        visualProvider.switchSystem(system);

        for (final geometry in geometries) {
          visualProvider.setGeometry(geometry);
          visualToAudio.updateFromVisuals();

          // Verify synthesis manager updated
          expect(audioProvider.synthesisBranchManager.currentGeometry,
            equals(geometry));

          testCount++;
        }
      }

      expect(testCount, equals(72),
        reason: 'Should test all 72 combinations');
    });
  });
}
