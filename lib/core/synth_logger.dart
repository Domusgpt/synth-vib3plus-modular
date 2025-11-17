///
/// Enhanced Logging System for Synth-VIB3+
///
/// Provides comprehensive, emoji-enriched logging that matches
/// the VIB3+ JavaScript codebase's logging style.
///
/// A Paul Phillips Manifestation
////

import 'package:flutter/foundation.dart';

/// Central logging system with categorized methods
class SynthLogger {
  // ============================================================================
  // MODULE LIFECYCLE
  // ============================================================================

  static void moduleLoad(String name) {
    debugPrint('🔧 Loading $name...');
  }

  static void moduleReady(String name, {int? durationMs}) {
    if (durationMs != null) {
      debugPrint('✅ $name: Loaded (${durationMs}ms)');
    } else {
      debugPrint('✅ $name: Loaded');
    }
  }

  static void moduleFailed(String name, Object error) {
    debugPrint('❌ $name: FAILED');
    debugPrint('   Error: $error');
  }

  static void moduleDispose(String name) {
    debugPrint('🔧 Disposing $name...');
  }

  static void moduleDisposed(String name) {
    debugPrint('✅ $name: Disposed');
  }

  // ============================================================================
  // SYSTEM INITIALIZATION
  // ============================================================================

  static void systemStart() {
    debugPrint('📦 Starting module initialization...\n');
  }

  static void systemReady({
    required int totalModules,
    required int readyModules,
    required int failedModules,
    required int totalTimeMs,
  }) {
    debugPrint('═' * 60);
    debugPrint('✅ Module Initialization Complete');
    debugPrint('═' * 60);
    debugPrint('   Ready: $readyModules/$totalModules');
    if (failedModules > 0) {
      debugPrint('   Failed: $failedModules');
    }
    debugPrint('   Total init time: ${totalTimeMs}ms');
    debugPrint('═' * 60);
    debugPrint('\n🚀 Synth-VIB3+ System Ready\n');
  }

  static void systemShutdown() {
    debugPrint('\n🛑 Shutting down modules...\n');
  }

  // ============================================================================
  // AUDIO ENGINE
  // ============================================================================

  static void audioInit({
    required int sampleRate,
    required int bufferSize,
    required int channels,
  }) {
    debugPrint(
        '📊 PCM setup: $sampleRate Hz, $bufferSize samples, ${channels == 1 ? "mono" : "stereo"}');
  }

  static void audioReady() {
    debugPrint('🎵 Ready for synthesis');
  }

  static void noteOn(int noteNumber, double velocity) {
    debugPrint(
        '🎹 Note ON: $noteNumber (velocity: ${velocity.toStringAsFixed(2)})');
  }

  static void noteOff(int noteNumber) {
    debugPrint('🎹 Note OFF: $noteNumber');
  }

  static void audioStart() {
    debugPrint('▶️ Audio started');
  }

  static void audioStop() {
    debugPrint('⏸️ Audio stopped');
  }

  // ============================================================================
  // VISUAL ENGINE / VIB3+
  // ============================================================================

  static void visualLoad(String path) {
    debugPrint('📂 Loading VIB3+ from $path');
  }

  static void visualWaiting() {
    debugPrint('⏳ Waiting for VIB3+ initialization...');
  }

  static void visualEnginesLoaded(int count, List<String> engines) {
    debugPrint('✅ VIB3+ engines loaded: $count/$count');
    debugPrint('   Engines: ${engines.join(", ")}');
  }

  static void visualReady() {
    debugPrint('✅ VIB3+ visualization ready');
  }

  static void webViewAttached() {
    debugPrint('✅ WebView controller attached');
  }

  // ============================================================================
  // PARAMETER COUPLING
  // ============================================================================

  static void couplingStart() {
    debugPrint('🌉 Starting 60 FPS update loop');
  }

  static void couplingEnabled({
    required bool audioToVisual,
    required bool visualToAudio,
  }) {
    debugPrint(
        '✅ Audio→Visual modulation: ${audioToVisual ? "ENABLED" : "disabled"}');
    debugPrint(
        '✅ Visual→Audio modulation: ${visualToAudio ? "ENABLED" : "disabled"}');
  }

  static void parameterUpdate(String param, dynamic value) {
    debugPrint('💾 User parameter: $param = $value');
  }

  static void visualToAudio({
    required double rotXW,
    required double rotYW,
    required double rotZW,
    required double osc1Mod,
    required double osc2Mod,
    required double filterMod,
    required double morph,
  }) {
    debugPrint('🔊 Visual→Audio: '
        'rotXW=${rotXW.toStringAsFixed(2)}→osc1=${osc1Mod.toStringAsFixed(2)}st | '
        'rotYW=${rotYW.toStringAsFixed(2)}→osc2=${osc2Mod.toStringAsFixed(2)}st | '
        'rotZW=${rotZW.toStringAsFixed(2)}→filter=${(filterMod * 100).toStringAsFixed(0)}% | '
        'morph=${morph.toStringAsFixed(2)}');
  }

  static void audioToVisual({
    required double bass,
    required double mid,
    required double high,
    required double rotSpeed,
    required int tessellation,
    required double brightness,
    required double hue,
    required double glow,
  }) {
    debugPrint('🎨 Audio→Visual: '
        'bass=${(bass * 100).toStringAsFixed(0)}%→speed=${rotSpeed.toStringAsFixed(2)}x | '
        'mid=${(mid * 100).toStringAsFixed(0)}%→tess=$tessellation | '
        'high=${(high * 100).toStringAsFixed(0)}%→bright=${brightness.toStringAsFixed(2)} | '
        'hue=${hue.toStringAsFixed(0)}° | '
        'glow=${glow.toStringAsFixed(2)}');
  }

  // ============================================================================
  // SYSTEM / GEOMETRY SWITCHING
  // ============================================================================

  static void systemSwitch(String from, String to) {
    debugPrint('🔄 System Switching: $from → $to');
  }

  static void systemSwitched(String system) {
    debugPrint('✅ VIB3+ system switched to $system');
  }

  static void systemInfo(
    String system, {
    required int vertices,
    required double complexity,
    required String synthesisMode,
  }) {
    debugPrint(
        '   $system: vertices=$vertices, complexity=$complexity ($synthesisMode)');
  }

  static void geometrySwitch(int from, int to) {
    debugPrint('🔷 Geometry Switching: $from → $to');
  }

  static void geometryVertexCount(int from, int to) {
    debugPrint('   Vertex count: $from → $to');
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  static void stateSaved(int index, int total) {
    debugPrint('📚 State saved to history ($index/$total)');
  }

  static void stateUndo(int index) {
    debugPrint('⏮️ Undo: State ${index + 1}');
  }

  static void stateRedo(int index) {
    debugPrint('⏭️ Redo: State ${index + 1}');
  }

  static void presetLoaded(String name) {
    debugPrint('💾 Loaded preset: $name');
  }

  static void presetSaved(String name) {
    debugPrint('💾 Saved preset: $name');
  }

  static void autoSaveEnabled(int delayMs) {
    debugPrint('✅ Auto-save enabled (${delayMs}ms delay)');
  }

  // ============================================================================
  // PERFORMANCE
  // ============================================================================

  static void fpsUpdate(double fps) {
    debugPrint('⚡ FPS: ${fps.toStringAsFixed(1)}');
  }

  static void latency(String type, double ms) {
    debugPrint('⏱️ $type latency: ${ms.toStringAsFixed(2)}ms');
  }

  static void performanceWarning(String message) {
    debugPrint('⚠️ Performance: $message');
  }

  static void frameDrops(int count) {
    debugPrint('📉 Frame drops detected: $count');
  }

  // ============================================================================
  // DIAGNOSTICS
  // ============================================================================

  static void diagnosticsStart() {
    debugPrint('\n🔬 System Diagnostics\n');
    debugPrint('═' * 60);
  }

  static void diagnosticsModule(String name, Map<String, dynamic> data) {
    debugPrint('\n📊 $name:');
    data.forEach((key, value) {
      debugPrint('   $key: $value');
    });
  }

  static void diagnosticsEnd({
    required int healthy,
    required int unhealthy,
  }) {
    debugPrint('\n' + '═' * 60);
    debugPrint('Summary: $healthy healthy, $unhealthy with issues\n');
  }

  // ============================================================================
  // TILT SENSOR
  // ============================================================================

  static void tiltCalibrationStart() {
    debugPrint('🎯 Starting tilt calibration (hold device steady)...');
  }

  static void tiltCalibrationComplete(double x, double y) {
    debugPrint(
        '✅ Calibration complete: X=${x.toStringAsFixed(2)}, Y=${y.toStringAsFixed(2)}');
  }

  static void tiltSensitivity(double sensitivity, double smoothing) {
    debugPrint('🚀 Sensitivity: ${sensitivity}x, Smoothing: $smoothing');
  }

  static void tiltError(String message) {
    debugPrint('⚠️ Tilt sensor: $message');
  }

  // ============================================================================
  // TESTING
  // ============================================================================

  static void testSuiteInit(int totalTests) {
    debugPrint('🧪 Registering $totalTests integration tests');
  }

  static void testRunStart() {
    debugPrint('🧪 Running test suite...');
  }

  static void testPassed(String name) {
    debugPrint('✅ Test passed: $name');
  }

  static void testFailed(String name, String error) {
    debugPrint('❌ Test failed: $name');
    debugPrint('   Error: $error');
  }

  static void testSuiteComplete({
    required int total,
    required int passed,
    required int failed,
    required int skipped,
  }) {
    debugPrint('\n🧪 Test Results:');
    debugPrint('   Total: $total');
    debugPrint('   Passed: $passed');
    debugPrint('   Failed: $failed');
    if (skipped > 0) {
      debugPrint('   Skipped: $skipped');
    }
  }

  // ============================================================================
  // ERRORS & WARNINGS
  // ============================================================================

  static void error(String component, String message) {
    debugPrint('❌ $component: $message');
  }

  static void warning(String component, String message) {
    debugPrint('⚠️ $component: $message');
  }

  static void info(String message) {
    debugPrint('ℹ️ $message');
  }

  static void success(String message) {
    debugPrint('✅ $message');
  }

  // ============================================================================
  // KEYBOARD SHORTCUTS
  // ============================================================================

  static void keyboardShortcuts(List<String> shortcuts) {
    debugPrint('⌨️ Keyboard Shortcuts:');
    for (final shortcut in shortcuts) {
      debugPrint('   - $shortcut');
    }
  }

  // ============================================================================
  // CUSTOM LOGGING
  // ============================================================================

  static void custom(String emoji, String message) {
    debugPrint('$emoji $message');
  }

  static void separator({String char = '═', int length = 60}) {
    debugPrint(char * length);
  }

  static void section(String title) {
    debugPrint('\n$title\n');
  }
}
