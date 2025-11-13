/**
 * Synth-VIB3+ Main Application (INTEGRATED VERSION)
 *
 * This is the fully integrated version with all enhancement systems:
 * - Component Integration Manager
 * - Gesture Recognition (2-5 finger gestures)
 * - Performance Monitoring
 * - Preset Browser
 * - Modulation Matrix
 * - Haptic Feedback
 * - Context-Sensitive Help
 *
 * To use this version, rename this file to main.dart:
 * mv lib/main.dart lib/main_standard.dart
 * mv lib/main_integrated.dart lib/main.dart
 *
 * Or update lib/main.dart to import from ui/screens/integrated_main_screen.dart
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/material.dart';
import 'core/synth_app_initializer.dart';
import 'ui/screens/integrated_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize modular architecture
  final modules = await initializeSynthModules();

  // Run integrated version with all enhancements
  runApp(IntegratedSynthApp(modules: modules));
}
