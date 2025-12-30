/**
 * Haptic Feedback System
 *
 * Professional haptic feedback for UI interactions:
 * - Light haptics for normal interactions
 * - Medium haptics for important actions
 * - Heavy haptics for critical actions
 * - Pattern-based haptics for musical feedback
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Haptic feedback manager with configurable intensity
class HapticManager {
  static bool _isEnabled = true;
  static double _intensity = 1.0; // 0-2, 1=normal

  /// Enable/disable haptics globally
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Set global intensity (0=off, 1=normal, 2=strong)
  static void setIntensity(double intensity) {
    _intensity = intensity.clamp(0.0, 2.0);
  }

  /// Light haptic (for UI interactions, sliders)
  static void light() {
    if (!_isEnabled || _intensity < 0.1) return;
    if (_intensity < 0.8) {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium haptic (for button presses, toggles)
  static void medium() {
    if (!_isEnabled || _intensity < 0.1) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic (for important actions, errors)
  static void heavy() {
    if (!_isEnabled || _intensity < 0.1) return;
    if (_intensity > 1.2) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  /// Selection click (for scrolling, selecting)
  static void selection() {
    if (!_isEnabled || _intensity < 0.1) return;
    HapticFeedback.selectionClick();
  }

  /// Vibrate (for notifications, alerts)
  static void vibrate() {
    if (!_isEnabled) return;
    HapticFeedback.vibrate();
  }

  /// Pattern-based haptic sequence
  static Future<void> pattern(List<HapticPattern> pattern) async {
    if (!_isEnabled || _intensity < 0.1) return;

    for (final item in pattern) {
      switch (item.type) {
        case HapticType.light:
          light();
          break;
        case HapticType.medium:
          medium();
          break;
        case HapticType.heavy:
          heavy();
          break;
        case HapticType.selection:
          selection();
          break;
        case HapticType.pause:
          // Just wait
          break;
      }
      if (item.duration > 0) {
        await Future.delayed(Duration(milliseconds: item.duration));
      }
    }
  }

  /// Success pattern (light → medium)
  static Future<void> success() async {
    await pattern([
      HapticPattern(HapticType.light, 50),
      HapticPattern(HapticType.medium, 0),
    ]);
  }

  /// Error pattern (heavy → pause → heavy)
  static Future<void> error() async {
    await pattern([
      HapticPattern(HapticType.heavy, 100),
      HapticPattern(HapticType.heavy, 0),
    ]);
  }

  /// Warning pattern (medium → pause → light)
  static Future<void> warning() async {
    await pattern([
      HapticPattern(HapticType.medium, 80),
      HapticPattern(HapticType.light, 0),
    ]);
  }

  /// Musical note haptic (scales with pitch)
  static void musicalNote(double noteFrequency) {
    if (!_isEnabled || _intensity < 0.1) return;

    // Higher notes = lighter haptic
    if (noteFrequency > 800) {
      light();
    } else if (noteFrequency > 400) {
      selection();
    } else {
      medium();
    }
  }

  /// Continuous value change (for sliders)
  static void valueChange() {
    if (!_isEnabled || _intensity < 0.5) return;
    selection();
  }

  /// Boundary reached (for min/max values)
  static void boundary() {
    if (!_isEnabled) return;
    medium();
  }

  /// Mode switch (for changing modes, tabs)
  static void modeSwitch() {
    if (!_isEnabled) return;
    light();
  }
}

/// Haptic pattern definition
class HapticPattern {
  final HapticType type;
  final int duration; // milliseconds

  HapticPattern(this.type, this.duration);
}

/// Haptic types
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  pause,
}

/// Convenience extensions for widgets
extension HapticWidget on Widget {
  /// Wrap widget with haptic feedback on tap
  Widget withHaptic({
    HapticType type = HapticType.light,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        switch (type) {
          case HapticType.light:
            HapticManager.light();
            break;
          case HapticType.medium:
            HapticManager.medium();
            break;
          case HapticType.heavy:
            HapticManager.heavy();
            break;
          case HapticType.selection:
            HapticManager.selection();
            break;
          case HapticType.pause:
            break;
        }
        onTap();
      },
      child: this,
    );
  }
}

/// Haptic patterns for common UI interactions
class HapticPatterns {
  /// Note on pattern
  static Future<void> noteOn() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.light, 0),
    ]);
  }

  /// Note off pattern
  static Future<void> noteOff() async {
    // Subtle feedback
    await HapticManager.pattern([
      HapticPattern(HapticType.selection, 0),
    ]);
  }

  /// Panel open pattern
  static Future<void> panelOpen() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.light, 30),
      HapticPattern(HapticType.selection, 0),
    ]);
  }

  /// Panel close pattern
  static Future<void> panelClose() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.selection, 30),
      HapticPattern(HapticType.light, 0),
    ]);
  }

  /// System switch pattern (Quantum/Faceted/Holographic)
  static Future<void> systemSwitch() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.medium, 0),
    ]);
  }

  /// Preset load pattern
  static Future<void> presetLoad() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.light, 40),
      HapticPattern(HapticType.light, 40),
      HapticPattern(HapticType.medium, 0),
    ]);
  }

  /// Preset save pattern
  static Future<void> presetSave() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.medium, 50),
      HapticPattern(HapticType.light, 0),
    ]);
  }

  /// Scale change pattern
  static Future<void> scaleChange() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.selection, 20),
      HapticPattern(HapticType.selection, 20),
      HapticPattern(HapticType.light, 0),
    ]);
  }

  /// Octave change pattern
  static Future<void> octaveChange() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.medium, 0),
    ]);
  }

  /// Parameter reset pattern
  static Future<void> parameterReset() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.medium, 60),
      HapticPattern(HapticType.light, 0),
    ]);
  }

  /// Lock/unlock pattern
  static Future<void> toggleLock() async {
    await HapticManager.pattern([
      HapticPattern(HapticType.heavy, 0),
    ]);
  }
}
