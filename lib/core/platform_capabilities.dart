/**
 * Platform Detection & Utilities
 *
 * Detects platform capabilities and provides conditional features.
 * This allows the same codebase to work on mobile AND web with
 * graceful degradation.
 *
 * Philosophy: Make it work everywhere, adapt to platform constraints.
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/foundation.dart';

/// Platform capabilities detection
class PlatformCapabilities {
  /// Is running on web platform
  static bool get isWeb => kIsWeb;

  /// Is running on mobile (Android/iOS)
  static bool get isMobile => !kIsWeb;

  /// Supports real-time audio synthesis
  static bool get supportsAudioSynthesis => isMobile;

  /// Supports WebView for VIB3+ visualization
  static bool get supportsWebViewVisualization => isMobile;

  /// Supports accelerometer/gyroscope sensors
  static bool get supportsSensors => isMobile;

  /// Supports haptic feedback
  static bool get supportsHaptics => isMobile;

  /// Supports multi-touch gestures
  static bool get supportsMultiTouch => true; // Works everywhere

  /// Supports performance monitoring
  static bool get supportsPerformanceMonitoring => true; // Works everywhere

  /// Supports preset browser
  static bool get supportsPresetBrowser => true; // Works everywhere

  /// Supports modulation matrix
  static bool get supportsModulationMatrix => true; // Works everywhere

  /// Supports help system
  static bool get supportsHelpSystem => true; // Works everywhere

  /// Get platform name
  static String get platformName {
    if (kIsWeb) return 'Web';
    return defaultTargetPlatform.toString().split('.').last;
  }

  /// Get feature availability summary
  static Map<String, bool> get featureAvailability => {
        'Audio Synthesis': supportsAudioSynthesis,
        'VIB3+ Visualization': supportsWebViewVisualization,
        'Sensor Input': supportsSensors,
        'Haptic Feedback': supportsHaptics,
        'Multi-Touch Gestures': supportsMultiTouch,
        'Performance Monitor': supportsPerformanceMonitoring,
        'Preset Browser': supportsPresetBrowser,
        'Modulation Matrix': supportsModulationMatrix,
        'Help System': supportsHelpSystem,
      };

  /// Get available features count
  static int get availableFeaturesCount =>
      featureAvailability.values.where((v) => v).length;

  /// Get total features count
  static int get totalFeaturesCount => featureAvailability.length;

  /// Get availability percentage
  static double get availabilityPercentage =>
      (availableFeaturesCount / totalFeaturesCount) * 100;
}

/// Platform-specific feature flags
class FeatureFlags {
  /// Enable audio synthesis (platform-dependent)
  static bool enableAudio = PlatformCapabilities.supportsAudioSynthesis;

  /// Enable VIB3+ visualization (platform-dependent)
  static bool enableVisualization = PlatformCapabilities.supportsWebViewVisualization;

  /// Enable sensor input (platform-dependent)
  static bool enableSensors = PlatformCapabilities.supportsSensors;

  /// Enable haptic feedback (platform-dependent)
  static bool enableHaptics = PlatformCapabilities.supportsHaptics;

  /// Enable multi-touch gestures (always on)
  static bool enableGestures = PlatformCapabilities.supportsMultiTouch;

  /// Enable performance monitoring (always on)
  static bool enablePerformanceMonitoring = PlatformCapabilities.supportsPerformanceMonitoring;

  /// Enable preset browser (always on)
  static bool enablePresetBrowser = PlatformCapabilities.supportsPresetBrowser;

  /// Enable modulation matrix (always on)
  static bool enableModulationMatrix = PlatformCapabilities.supportsModulationMatrix;

  /// Enable help system (always on)
  static bool enableHelp = PlatformCapabilities.supportsHelpSystem;

  /// Show platform limitations notice
  static bool showLimitationsNotice = PlatformCapabilities.isWeb;

  /// Enable feature placeholders (show what's available on mobile)
  static bool enablePlaceholders = PlatformCapabilities.isWeb;
}

/// Platform-aware configuration
class PlatformConfig {
  /// Get recommended buffer size for audio (if supported)
  static int get audioBufferSize {
    if (PlatformCapabilities.isMobile) return 512;
    return 2048; // Larger for web (if we add web audio later)
  }

  /// Get recommended sample rate for audio (if supported)
  static double get audioSampleRate {
    if (PlatformCapabilities.isMobile) return 44100.0;
    return 48000.0; // Web Audio API standard
  }

  /// Get target frame rate
  static int get targetFPS => 60;

  /// Get target audio latency (ms)
  static double get targetAudioLatency {
    if (PlatformCapabilities.isMobile) return 10.0;
    return 50.0; // Web is higher latency
  }

  /// Get target parameter update rate (Hz)
  static double get targetParameterUpdateRate => 60.0;

  /// Get maximum particle count
  static int get maxParticleCount {
    if (PlatformCapabilities.isMobile) return 500;
    return 300; // Fewer for web performance
  }

  /// Get maximum active voices
  static int get maxActiveVoices {
    if (PlatformCapabilities.isMobile) return 8;
    return 4; // Fewer for web
  }

  /// Should show performance overlay
  static bool get showPerformanceOverlay => true;

  /// Should show platform badge
  static bool get showPlatformBadge => PlatformCapabilities.isWeb;
}

/// Platform-specific messaging
class PlatformMessages {
  /// Get platform-specific welcome message
  static String get welcomeMessage {
    if (PlatformCapabilities.isWeb) {
      return 'Welcome to Synth-VIB3+ Web Demo!\n\n'
          'You\'re viewing the UI showcase version.\n'
          'Download the mobile app for the complete experience with:\n'
          '• Real-time audio synthesis\n'
          '• 4D holographic visualization\n'
          '• Sensor-based tilt control\n'
          '• Haptic feedback\n\n'
          'Available here: UI, gestures, presets, modulation routing, help.';
    }

    return 'Welcome to Synth-VIB3+!\n\n'
        'The revolutionary holographic synthesizer with:\n'
        '• Real-time audio synthesis (<10ms latency)\n'
        '• 4D VIB3+ visualization\n'
        '• Multi-touch performance (2-5 fingers)\n'
        '• Musical haptic feedback\n'
        '• Full sensor integration\n\n'
        'Explore the integrated experience!';
  }

  /// Get feature unavailable message
  static String getFeatureUnavailableMessage(String featureName) {
    if (PlatformCapabilities.isWeb) {
      return '$featureName is available in the mobile app.\n\n'
          'Download Synth-VIB3+ for Android/iOS to experience this feature.';
    }

    return '$featureName is currently unavailable.';
  }

  /// Get platform badge text
  static String get platformBadge {
    if (PlatformCapabilities.isWeb) {
      return 'WEB DEMO - ${PlatformCapabilities.availabilityPercentage.toStringAsFixed(0)}% Features';
    }

    return PlatformCapabilities.platformName.toUpperCase();
  }
}
