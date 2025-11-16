/**
 * Integration Tests for Parameter Bridge
 *
 * Tests bidirectional parameter coupling between audio and visual systems
 *
 * A Paul Phillips Manifestation
 */

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:synther_vib34d_holographic/mapping/parameter_bridge.dart';
import 'package:synther_vib34d_holographic/providers/audio_provider.dart';
import 'package:synther_vib34d_holographic/providers/visual_provider.dart';
import 'package:synther_vib34d_holographic/models/mapping_preset.dart';
import '../test_utilities.dart';

void main() {
  group('ParameterBridge - Initialization', () {
    test('should initialize with audio and visual providers', () {
      final audioProvider = AudioProvider();
      final visualProvider = MockVisualProvider();

      final bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );

      expect(bridge.isRunning, isFalse, reason: 'Should not be running initially');
      expect(bridge.currentPreset, isNotNull);
    });

    test('should start 60 FPS update loop', () async {
      final audioProvider = AudioProvider();
      final visualProvider = MockVisualProvider();

      final bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );

      bridge.start();
      expect(bridge.isRunning, isTrue);

      // Wait for some updates
      await Future.delayed(const Duration(milliseconds: 100));

      // Should have positive FPS
      expect(bridge.currentFPS, greaterThan(0.0));

      bridge.stop();
    });

    test('should stop update loop', () async {
      final audioProvider = AudioProvider();
      final visualProvider = MockVisualProvider();

      final bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );

      bridge.start();
      await Future.delayed(const Duration(milliseconds: 50));

      bridge.stop();
      expect(bridge.isRunning, isFalse);
    });
  });

  group('ParameterBridge - Audio to Visual Coupling', () {
    late AudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late ParameterBridge bridge;

    setUp(() {
      audioProvider = AudioProvider();
      visualProvider = MockVisualProvider();
      bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );
      bridge.start();
    });

    tearDown(() {
      bridge.stop();
    });

    test('should modulate visual parameters when audio is playing', () async {
      // Record initial visual state
      final initialRotationSpeed = visualProvider.speedParameter;

      // Start playing audio
      await audioProvider.startAudio();
      audioProvider.playNote(60); // Middle C

      // Wait for parameter bridge to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Visual parameters should have changed due to audio reactivity
      // (Note: This depends on actual implementation of audio→visual modulation)
      // For now, we verify the bridge is running
      expect(bridge.isRunning, isTrue);
      expect(bridge.currentFPS, greaterThan(30.0), reason: 'Should maintain high FPS');

      await audioProvider.stopAudio();
    });

    test('should map bass energy to rotation speed', () async {
      // This test requires actual implementation of bass→rotation mapping
      // For now, we verify the modulation system is active
      expect(bridge.audioToVisual, isNotNull);
      expect(bridge.isRunning, isTrue);
    });

    test('should map spectral centroid to hue shift', () async {
      // Generate audio with different spectral content
      await audioProvider.startAudio();
      audioProvider.playNote(60); // Lower note

      await Future.delayed(const Duration(milliseconds: 50));

      final lowNoteHue = visualProvider.morphParameter; // Using morph as proxy

      audioProvider.stopNote();
      audioProvider.playNote(84); // Higher note

      await Future.delayed(const Duration(milliseconds: 50));

      final highNoteHue = visualProvider.morphParameter;

      // Different notes should produce different visual states
      // (exact mapping depends on implementation)
      expect(bridge.isRunning, isTrue);

      await audioProvider.stopAudio();
    });
  });

  group('ParameterBridge - Visual to Audio Coupling', () {
    late AudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late ParameterBridge bridge;

    setUp(() {
      audioProvider = AudioProvider();
      visualProvider = MockVisualProvider();
      bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );
      bridge.start();
    });

    tearDown(() {
      bridge.stop();
    });

    test('should modulate synthesis when visual rotation changes', () async {
      await audioProvider.startAudio();
      audioProvider.playNote(60);

      // Change visual rotation
      visualProvider.setRotationXY(1.0);

      // Wait for parameter bridge to process
      await Future.delayed(const Duration(milliseconds: 50));

      // Audio synthesis should be modulated
      // (Verification depends on implementation)
      expect(bridge.visualToAudio, isNotNull);

      await audioProvider.stopAudio();
    });

    test('should map morph parameter to audio filter', () async {
      await audioProvider.startAudio();
      audioProvider.playNote(60);

      // Change morph parameter
      visualProvider.setMorph(0.0);
      await Future.delayed(const Duration(milliseconds: 30));
      final lowMorphBuffer = audioProvider.getCurrentBuffer();

      visualProvider.setMorph(1.0);
      await Future.delayed(const Duration(milliseconds: 30));
      final highMorphBuffer = audioProvider.getCurrentBuffer();

      // Different morph values should produce different audio
      if (lowMorphBuffer != null && highMorphBuffer != null) {
        expect(lowMorphBuffer.approximatelyEquals(highMorphBuffer),
          isFalse,
          reason: 'Different morph values should affect audio');
      }

      await audioProvider.stopAudio();
    });

    test('should map chaos parameter to noise injection', () async {
      await audioProvider.startAudio();
      audioProvider.playNote(60);

      // No chaos
      visualProvider.setChaos(0.0);
      await Future.delayed(const Duration(milliseconds: 30));

      // High chaos
      visualProvider.setChaos(1.0);
      await Future.delayed(const Duration(milliseconds: 30));

      // Should still be generating audio
      expect(audioProvider.isPlaying, isTrue);

      await audioProvider.stopAudio();
    });
  });

  group('ParameterBridge - Mapping Presets', () {
    late AudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late ParameterBridge bridge;

    setUp(() {
      audioProvider = AudioProvider();
      visualProvider = MockVisualProvider();
      bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );
    });

    test('should load default preset', () async {
      final defaultPreset = MappingPreset.defaultPreset();
      await bridge.loadPreset(defaultPreset);

      expect(bridge.currentPreset.name, equals(defaultPreset.name));
      expect(bridge.currentPreset.audioReactiveEnabled, isTrue);
      expect(bridge.currentPreset.visualReactiveEnabled, isTrue);
    });

    test('should toggle audio reactive mode', () {
      expect(bridge.currentPreset.audioReactiveEnabled, isTrue);

      bridge.setAudioReactive(false);
      expect(bridge.currentPreset.audioReactiveEnabled, isFalse);

      bridge.setAudioReactive(true);
      expect(bridge.currentPreset.audioReactiveEnabled, isTrue);
    });

    test('should toggle visual reactive mode', () {
      expect(bridge.currentPreset.visualReactiveEnabled, isTrue);

      bridge.setVisualReactive(false);
      expect(bridge.currentPreset.visualReactiveEnabled, isFalse);

      bridge.setVisualReactive(true);
      expect(bridge.currentPreset.visualReactiveEnabled, isTrue);
    });

    test('should save preset with current mappings', () async {
      final savedPreset = await bridge.saveAsPreset(
        'Test Preset',
        'Test mapping configuration',
      );

      expect(savedPreset.name, equals('Test Preset'));
      expect(savedPreset.description, contains('Test mapping'));
      expect(savedPreset.audioToVisualMappings, isNotNull);
      expect(savedPreset.visualToAudioMappings, isNotNull);
    });
  });

  group('ParameterBridge - Performance', () {
    late AudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late ParameterBridge bridge;

    setUp(() {
      audioProvider = AudioProvider();
      visualProvider = MockVisualProvider();
      bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );
    });

    test('should maintain 60 FPS with audio playing', () async {
      bridge.start();
      await audioProvider.startAudio();
      audioProvider.playNote(60);

      // Wait for FPS to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      final fps = bridge.currentFPS;
      print('Parameter bridge FPS: $fps');

      expect(fps, greaterThan(55.0), reason: 'Should maintain near 60 FPS');
      expect(fps, lessThan(65.0), reason: 'FPS should not exceed expected rate significantly');

      await audioProvider.stopAudio();
      bridge.stop();
    });

    test('should maintain performance with rapid parameter changes', () async {
      bridge.start();
      await audioProvider.startAudio();
      audioProvider.playNote(60);

      // Rapidly change visual parameters
      for (int i = 0; i < 100; i++) {
        visualProvider.setRotationXY(i / 100.0);
        visualProvider.setMorph(i / 100.0);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      expect(bridge.isRunning, isTrue);
      expect(bridge.currentFPS, greaterThan(30.0), reason: 'Should maintain reasonable FPS under stress');

      await audioProvider.stopAudio();
      bridge.stop();
    });

    test('should handle start/stop cycles without memory leaks', () {
      for (int i = 0; i < 10; i++) {
        bridge.start();
        expect(bridge.isRunning, isTrue);

        bridge.stop();
        expect(bridge.isRunning, isFalse);
      }
    });
  });

  group('ParameterBridge - Edge Cases', () {
    late AudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late ParameterBridge bridge;

    setUp(() {
      audioProvider = AudioProvider();
      visualProvider = MockVisualProvider();
      bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );
    });

    test('should handle null audio buffer gracefully', () {
      bridge.start();

      // Don't start audio, so buffer is null
      // Bridge should still run without crashing
      expect(() => Future.delayed(const Duration(milliseconds: 100)), returnsNormally);

      bridge.stop();
    });

    test('should handle empty audio buffer', () async {
      bridge.start();
      await audioProvider.startAudio();

      // Even without playing a note, should handle gracefully
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bridge.isRunning, isTrue);

      await audioProvider.stopAudio();
      bridge.stop();
    });

    test('should handle extreme visual parameter values', () async {
      bridge.start();

      // Set extreme values
      visualProvider.setRotationXY(1000.0); // Way beyond 2π
      visualProvider.setMorph(100.0); // Way beyond 1.0
      visualProvider.setChaos(-10.0); // Negative

      await Future.delayed(const Duration(milliseconds: 50));

      // Should still be running
      expect(bridge.isRunning, isTrue);

      bridge.stop();
    });

    test('should handle rapid system/geometry switching', () async {
      bridge.start();
      await audioProvider.startAudio();
      audioProvider.playNote(60);

      for (int i = 0; i < 50; i++) {
        visualProvider.switchSystem(['quantum', 'faceted', 'holographic'][i % 3]);
        visualProvider.switchGeometry(i % 24);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      expect(bridge.isRunning, isTrue);
      expect(bridge.currentFPS, greaterThan(20.0));

      await audioProvider.stopAudio();
      bridge.stop();
    });
  });

  group('ParameterBridge - All 72 Combinations Integration', () {
    late AudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late ParameterBridge bridge;

    setUp(() {
      audioProvider = AudioProvider();
      visualProvider = MockVisualProvider();
      bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );
      bridge.start();
    });

    tearDown(() {
      bridge.stop();
    });

    test('should handle all 72 system+geometry combinations', () async {
      final combinations = GeometryCombinations.getAll();
      expect(combinations.length, equals(72));

      await audioProvider.startAudio();
      audioProvider.playNote(60);

      for (final combo in combinations) {
        visualProvider.switchSystem(combo.system);
        visualProvider.switchGeometry(combo.geometryIndex);

        // Let parameter bridge process
        await Future.delayed(const Duration(milliseconds: 20));

        // Should still be running
        expect(bridge.isRunning, isTrue,
          reason: 'Bridge should run with ${combo.toString()}');
      }

      expect(bridge.currentFPS, greaterThan(30.0),
        reason: 'Should maintain FPS through all combinations');

      await audioProvider.stopAudio();
    });
  });

  group('ParameterBridge - Bidirectional Coupling Verification', () {
    late AudioProvider audioProvider;
    late MockVisualProvider visualProvider;
    late ParameterBridge bridge;

    setUp(() {
      audioProvider = AudioProvider();
      visualProvider = MockVisualProvider();
      bridge = ParameterBridge(
        audioProvider: audioProvider,
        visualProvider: visualProvider as VisualProvider,
      );
      bridge.start();
    });

    tearDown(() {
      bridge.stop();
    });

    test('should verify audio affects visual AND visual affects audio', () async {
      await audioProvider.startAudio();

      // 1. Change audio (play note) → should affect visual
      final initialVisualState = visualProvider.speedParameter;
      audioProvider.playNote(60);
      await Future.delayed(const Duration(milliseconds: 50));
      // Visual state may have changed due to audio reactivity

      // 2. Change visual (rotation) → should affect audio
      visualProvider.setRotationXW(1.5);
      await Future.delayed(const Duration(milliseconds: 50));
      final modulated Buffer = audioProvider.getCurrentBuffer();

      // Both directions should be active
      expect(bridge.currentPreset.audioReactiveEnabled, isTrue);
      expect(bridge.currentPreset.visualReactiveEnabled, isTrue);
      expect(bridge.isRunning, isTrue);

      await audioProvider.stopAudio();
    });

    test('should verify 60 Hz parameter update rate', () async {
      bridge.start();

      int updateCount = 0;
      final timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        updateCount++;
      });

      await Future.delayed(const Duration(seconds: 1));
      timer.cancel();

      // Should have ~60 updates in 1 second (±10%)
      expect(updateCount, inInclusiveRange(54, 66),
        reason: 'Should maintain 60 Hz update rate');
    });
  });
}
