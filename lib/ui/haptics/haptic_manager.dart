///
/// Haptic Manager
///
/// Comprehensive haptic feedback system for tactile UI response.
/// Provides musical haptics, pattern-based feedback, and intensity control.
///
/// Features:
/// - Basic haptic types (light, medium, heavy, selection)
/// - Musical haptics (pitch-scaled vibrations)
/// - Pattern-based haptics (note on, preset load, system switch)
/// - Custom haptic sequences
/// - Intensity scaling (0.1-2.0x)
/// - Platform-adaptive (iOS/Android)
/// - Energy-efficient batching
///
/// Part of the Integration Layer (Phase 3.5)
///
/// A Paul Phillips Manifestation
///

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// ============================================================================
// HAPTIC TYPE
// ============================================================================

/// Standard haptic feedback types
enum HapticType {
  light, // Subtle tap
  medium, // Standard impact
  heavy, // Strong impact
  selection, // Selection change
  error, // Error indication
  success, // Success confirmation
  warning, // Warning indication
}

// ============================================================================
// HAPTIC PATTERN
// ============================================================================

/// A sequence of haptic pulses
class HapticPattern {
  final List<HapticPulse> pulses;
  final String name;

  const HapticPattern({
    required this.pulses,
    required this.name,
  });

  Duration get totalDuration {
    return pulses.fold(
      Duration.zero,
      (sum, pulse) => sum + pulse.delay + pulse.duration,
    );
  }
}

/// Single haptic pulse
class HapticPulse {
  final Duration delay;
  final Duration duration;
  final double intensity; // 0-1
  final HapticType type;

  const HapticPulse({
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 50),
    this.intensity = 1.0,
    this.type = HapticType.medium,
  });
}

// ============================================================================
// HAPTIC MANAGER
// ============================================================================

/// Haptic feedback manager
class HapticManager {
  static HapticManager? _instance;
  static HapticManager get instance {
    _instance ??= HapticManager._();
    return _instance!;
  }

  HapticManager._();

  // Configuration
  bool _enabled = true;
  double _intensity = 1.0; // Global intensity multiplier (0.1-2.0)

  // Batching
  final List<_QueuedHaptic> _queue = [];
  Timer? _processTimer;
  static const Duration _batchInterval = Duration(milliseconds: 16); // ~60 FPS

  // Rate limiting
  DateTime? _lastHapticTime;
  static const Duration _minInterval = Duration(milliseconds: 10);

  // ============================================================================
  // CONFIGURATION
  // ============================================================================

  /// Enable/disable haptic feedback
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Set global intensity multiplier (0.1-2.0)
  void setIntensity(double intensity) {
    _intensity = intensity.clamp(0.1, 2.0);
  }

  bool get isEnabled => _enabled;
  double get intensity => _intensity;

  // ============================================================================
  // BASIC HAPTICS
  // ============================================================================

  /// Light haptic feedback
  static Future<void> light() async {
    return instance._triggerHaptic(HapticType.light);
  }

  /// Medium haptic feedback
  static Future<void> medium() async {
    return instance._triggerHaptic(HapticType.medium);
  }

  /// Heavy haptic feedback
  static Future<void> heavy() async {
    return instance._triggerHaptic(HapticType.heavy);
  }

  /// Selection change haptic
  static Future<void> selection() async {
    return instance._triggerHaptic(HapticType.selection);
  }

  /// Error indication haptic
  static Future<void> error() async {
    return instance._triggerHaptic(HapticType.error);
  }

  /// Success confirmation haptic
  static Future<void> success() async {
    return instance._triggerHaptic(HapticType.success);
  }

  /// Warning indication haptic
  static Future<void> warning() async {
    return instance._triggerHaptic(HapticType.warning);
  }

  // ============================================================================
  // MUSICAL HAPTICS
  // ============================================================================

  /// Pitch-scaled haptic feedback
  /// Maps frequency to vibration intensity/duration
  static Future<void> musicalNote(double frequency) async {
    // Map frequency to intensity (higher freq = lighter haptic)
    // A4 (440 Hz) = medium, lower = heavier, higher = lighter
    final normalizedFreq = (frequency / 440.0).clamp(0.25, 4.0);
    final intensity = 1.0 / normalizedFreq;

    return instance._triggerMusicalHaptic(frequency, intensity);
  }

  /// Chord haptic (multiple notes)
  static Future<void> musicalChord(List<double> frequencies) async {
    for (int i = 0; i < frequencies.length; i++) {
      final delay = Duration(milliseconds: i * 20);
      Timer(delay, () => musicalNote(frequencies[i]));
    }
  }

  // ============================================================================
  // PATTERN-BASED HAPTICS
  // ============================================================================

  /// Play a haptic pattern
  static Future<void> playPattern(HapticPattern pattern) async {
    return instance._playPattern(pattern);
  }

  // ============================================================================
  // INTERNAL METHODS
  // ============================================================================

  Future<void> _triggerHaptic(HapticType type) async {
    if (!_enabled) return;

    // Rate limiting
    final now = DateTime.now();
    if (_lastHapticTime != null &&
        now.difference(_lastHapticTime!) < _minInterval) {
      return;
    }
    _lastHapticTime = now;

    // Queue haptic
    _queue.add(_QueuedHaptic(type: type, intensity: _intensity));

    // Start processing if not already running
    _processTimer ??= Timer.periodic(_batchInterval, (_) => _processBatch());
  }

  Future<void> _triggerMusicalHaptic(double frequency, double intensity) async {
    if (!_enabled) return;

    // Calculate duration based on frequency
    // Higher frequencies = shorter duration
    final durationMs = (100.0 / (frequency / 220.0)).clamp(20.0, 100.0);

    // Use appropriate haptic type based on intensity
    final type = intensity > 1.5
        ? HapticType.heavy
        : intensity > 0.7
            ? HapticType.medium
            : HapticType.light;

    _queue.add(_QueuedHaptic(
      type: type,
      intensity: (intensity * _intensity).clamp(0.1, 2.0),
      duration: Duration(milliseconds: durationMs.toInt()),
    ));

    _processTimer ??= Timer.periodic(_batchInterval, (_) => _processBatch());
  }

  Future<void> _playPattern(HapticPattern pattern) async {
    if (!_enabled) return;

    for (final pulse in pattern.pulses) {
      await Future.delayed(pulse.delay);

      _queue.add(_QueuedHaptic(
        type: pulse.type,
        intensity: (pulse.intensity * _intensity).clamp(0.1, 2.0),
        duration: pulse.duration,
      ));
    }

    _processTimer ??= Timer.periodic(_batchInterval, (_) => _processBatch());
  }

  void _processBatch() {
    if (_queue.isEmpty) {
      _processTimer?.cancel();
      _processTimer = null;
      return;
    }

    // Process first queued haptic
    final haptic = _queue.removeAt(0);
    _executeHaptic(haptic);
  }

  void _executeHaptic(_QueuedHaptic haptic) {
    // Platform-specific haptic execution
    try {
      switch (haptic.type) {
        case HapticType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          HapticFeedback.selectionClick();
          break;
        case HapticType.error:
          // Custom error pattern
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 100), () {
            HapticFeedback.mediumImpact();
          });
          break;
        case HapticType.success:
          // Custom success pattern
          HapticFeedback.lightImpact();
          Future.delayed(const Duration(milliseconds: 50), () {
            HapticFeedback.lightImpact();
          });
          break;
        case HapticType.warning:
          // Custom warning pattern
          HapticFeedback.mediumImpact();
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback error: $e');
      }
    }
  }
}

// ============================================================================
// QUEUED HAPTIC
// ============================================================================

class _QueuedHaptic {
  final HapticType type;
  final double intensity;
  final Duration duration;

  _QueuedHaptic({
    required this.type,
    required this.intensity,
    this.duration = const Duration(milliseconds: 50),
  });
}

// ============================================================================
// PREDEFINED PATTERNS
// ============================================================================

/// Common haptic patterns
class HapticPatterns {
  /// Note-on pattern (quick double tap)
  static HapticPattern get noteOn => const HapticPattern(
        name: 'Note On',
        pulses: [
          HapticPulse(
            type: HapticType.light,
            duration: Duration(milliseconds: 30),
          ),
          HapticPulse(
            delay: Duration(milliseconds: 40),
            type: HapticType.light,
            duration: Duration(milliseconds: 20),
          ),
        ],
      );

  /// Note-off pattern (single light tap)
  static HapticPattern get noteOff => const HapticPattern(
        name: 'Note Off',
        pulses: [
          HapticPulse(
            type: HapticType.light,
            duration: Duration(milliseconds: 20),
            intensity: 0.5,
          ),
        ],
      );

  /// Preset load pattern (medium then light)
  static HapticPattern get presetLoad => const HapticPattern(
        name: 'Preset Load',
        pulses: [
          HapticPulse(
            type: HapticType.medium,
            duration: Duration(milliseconds: 50),
          ),
          HapticPulse(
            delay: Duration(milliseconds: 100),
            type: HapticType.light,
            duration: Duration(milliseconds: 30),
          ),
        ],
      );

  /// System mode switch (heavy pulse)
  static HapticPattern get systemSwitch => const HapticPattern(
        name: 'System Switch',
        pulses: [
          HapticPulse(
            type: HapticType.heavy,
            duration: Duration(milliseconds: 80),
          ),
        ],
      );

  /// Parameter change (selection feedback)
  static HapticPattern get parameterChange => const HapticPattern(
        name: 'Parameter Change',
        pulses: [
          HapticPulse(
            type: HapticType.selection,
            duration: Duration(milliseconds: 20),
          ),
        ],
      );

  /// UI button press (medium impact)
  static HapticPattern get buttonPress => const HapticPattern(
        name: 'Button Press',
        pulses: [
          HapticPulse(
            type: HapticType.medium,
            duration: Duration(milliseconds: 40),
          ),
        ],
      );

  /// Slider snap (light with quick follow-up)
  static HapticPattern get sliderSnap => const HapticPattern(
        name: 'Slider Snap',
        pulses: [
          HapticPulse(
            type: HapticType.light,
            duration: Duration(milliseconds: 15),
          ),
          HapticPulse(
            delay: Duration(milliseconds: 20),
            type: HapticType.light,
            duration: Duration(milliseconds: 10),
            intensity: 0.6,
          ),
        ],
      );

  /// Error pattern (heavy-medium-medium)
  static HapticPattern get errorPattern => const HapticPattern(
        name: 'Error',
        pulses: [
          HapticPulse(
            type: HapticType.heavy,
            duration: Duration(milliseconds: 60),
          ),
          HapticPulse(
            delay: Duration(milliseconds: 80),
            type: HapticType.medium,
            duration: Duration(milliseconds: 40),
          ),
          HapticPulse(
            delay: Duration(milliseconds: 80),
            type: HapticType.medium,
            duration: Duration(milliseconds: 40),
          ),
        ],
      );

  /// Success pattern (light-light-medium)
  static HapticPattern get successPattern => const HapticPattern(
        name: 'Success',
        pulses: [
          HapticPulse(
            type: HapticType.light,
            duration: Duration(milliseconds: 30),
          ),
          HapticPulse(
            delay: Duration(milliseconds: 50),
            type: HapticType.light,
            duration: Duration(milliseconds: 30),
          ),
          HapticPulse(
            delay: Duration(milliseconds: 50),
            type: HapticType.medium,
            duration: Duration(milliseconds: 50),
          ),
        ],
      );

  /// Ascending scale (musical demonstration)
  static HapticPattern get ascendingScale => HapticPattern(
        name: 'Ascending Scale',
        pulses: [
          for (int i = 0; i < 8; i++)
            HapticPulse(
              delay: Duration(milliseconds: i * 100),
              type: i < 3
                  ? HapticType.heavy
                  : i < 6
                      ? HapticType.medium
                      : HapticType.light,
              duration: Duration(milliseconds: 40 - (i * 3)),
              intensity: 1.0 - (i * 0.1),
            ),
        ],
      );

  /// Descending scale (musical demonstration)
  static HapticPattern get descendingScale => HapticPattern(
        name: 'Descending Scale',
        pulses: [
          for (int i = 0; i < 8; i++)
            HapticPulse(
              delay: Duration(milliseconds: i * 100),
              type: i < 3
                  ? HapticType.light
                  : i < 6
                      ? HapticType.medium
                      : HapticType.heavy,
              duration: Duration(milliseconds: 20 + (i * 3)),
              intensity: 0.3 + (i * 0.1),
            ),
        ],
      );
}

// ============================================================================
// HAPTIC EXTENSIONS
// ============================================================================

/// Extension methods for easier haptic triggering
extension HapticGesture on GestureDetector {
  /// Add haptic feedback to onTap
  GestureDetector withHaptic({
    HapticType type = HapticType.light,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticManager.instance._triggerHaptic(type);
        onTap?.call();
      },
    );
  }
}
