/**
 * Application Constants
 *
 * Centralized configuration values for the Synth-VIB3+ application.
 * Replaces magic numbers throughout the codebase with named constants
 * for improved maintainability and documentation.
 *
 * A Paul Phillips Manifestation
 */

import 'dart:ui';

/// Audio configuration constants
class AudioConstants {
  // Sample rate and buffer configuration
  static const int sampleRate = 44100; // Hz
  static const int bufferSize = 512; // samples
  static const int channels = 1; // mono

  // Performance targets
  static const int targetLatencyMs = 10; // <10ms latency target
  static const double maxLatencyMs = 20.0; // Acceptable maximum

  // Audio analysis (FFT)
  static const int fftSize = 2048; // bins
  static const int fftHopSize = 512; // samples between FFT frames

  // Frequency ranges (Hz)
  static const double bassMin = 20.0;
  static const double bassMa

x = 250.0;
  static const double midMin = 250.0;
  static const double midMax = 2000.0;
  static const double highMin = 2000.0;
  static const double highMax = 8000.0;

  // MIDI note range
  static const int midiNoteMin = 0;
  static const int midiNoteMax = 127;
  static const int midiMiddleC = 60;

  // Volume and amplitude
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double defaultVolume = 0.7;
  static const double headroomFactor = 0.6; // Prevent clipping

  // Voice management
  static const int minVoices = 1;
  static const int maxVoices = 8;
  static const int defaultVoices = 4;
}

/// Visual rendering constants
class VisualConstants {
  // Performance targets
  static const int targetFPS = 60;
  static const int minAcceptableFPS = 30;
  static const double frameTimeMs = 16.67; // 1000ms / 60fps

  // Geometry configuration
  static const int totalGeometries = 24; // 0-23
  static const int geometriesPerCore = 8;
  static const int totalCores = 3; // Base, Hypersphere, Hypertetrahedron
  static const int totalSystems = 3; // Quantum, Faceted, Holographic

  // Total combinations
  static const int totalCombinations = 72; // 3 systems × 3 cores × 8 geometries

  // Rotation speeds (degrees/second)
  static const double minRotationSpeed = 0.0;
  static const double maxRotationSpeed = 360.0;
  static const double defaultRotationSpeed = 90.0;

  // Tessellation density
  static const int minTessellation = 1;
  static const int maxTessellation = 8;
  static const int defaultTessellation = 5;

  // Visual parameters ranges
  static const double minBrightness = 0.0;
  static const double maxBrightness = 1.0;
  static const double defaultBrightness = 0.8;

  static const double minHueShift = 0.0;
  static const double maxHueShift = 360.0;
  static const double defaultHueShift = 180.0;

  static const double minGlowIntensity = 0.0;
  static const double maxGlowIntensity = 3.0;
  static const double defaultGlowIntensity = 1.0;

  static const double minMorphParameter = 0.0;
  static const double maxMorphParameter = 1.0;
  static const double defaultMorphParameter = 0.0;

  // Projection and depth
  static const double minProjectionDistance = 4.0;
  static const double maxProjectionDistance = 16.0;
  static const double defaultProjectionDistance = 8.0;

  static const double minLayerSeparation = 0.5;
  static const double maxLayerSeparation = 4.0;
  static const double defaultLayerSeparation = 2.0;
}

/// Parameter bridge constants (bidirectional coupling)
class BridgeConstants {
  // Update frequency
  static const int updateFrequencyHz = 60; // Match visual frame rate
  static const int updateIntervalMs = 16; // ~60 Hz (1000ms / 60)

  // Modulation depth ranges
  static const double minModulationDepth = 0.0;
  static const double maxModulationDepth = 1.0;
  static const double defaultModulationDepth = 0.5;

  // Audio-to-visual modulation ranges
  static const double rotationSpeedModRange = 180.0; // ±180°/sec
  static const double tessellationModRange = 4.0; // ±4 levels
  static const double brightnessModRange = 0.3; // ±30%
  static const double glowModRange = 1.5; // ±1.5 intensity

  // Visual-to-audio modulation ranges
  static const double detuneModRangeCents = 12.0; // ±12 cents
  static const double fmDepthModRangeSemitones = 2.0; // ±2 semitones
  static const double filterCutoffModRange = 0.4; // ±40%
  static const double reverbMixModRange = 0.3; // ±30%

  // Smoothing and interpolation
  static const double smoothingFactor = 0.1; // 0-1, lower = smoother
  static const int interpolationSteps = 4; // Steps for smooth transitions
}

/// UI/UX constants
class UIConstants {
  // Touch targets (accessibility)
  static const double minTouchTarget = 48.0; // Apple/Google minimum
  static const double comfortableTouchTarget = 56.0;
  static const double largeTouchTarget = 72.0;

  // Spacing (8pt grid)
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Animation durations (milliseconds)
  static const int animationMicro = 100; // Immediate feedback
  static const int animationStandard = 300; // Normal transitions
  static const int animationComplex = 500; // Multi-stage
  static const int animationSlow = 800; // Emphasis

  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusFull = 9999.0;

  // Opacity levels
  static const double opacityDisabled = 0.3;
  static const double opacityInactive = 0.5;
  static const double opacityHover = 0.7;
  static const double opacityActive = 1.0;

  // Glassmorphic blur
  static const double glassBlurLow = 10.0;
  static const double glassBlurMedium = 20.0;
  static const double glassBlurHigh = 30.0;
}

/// Gesture recognition constants
class GestureConstants {
  // Multi-touch finger counts
  static const int minFingers = 1;
  static const int maxFingers = 5;

  // Gesture thresholds
  static const double swipeMinVelocity = 50.0; // pixels/second
  static const double swipeMinDistance = 20.0; // pixels
  static const double pinchMinScale = 0.05; // 5% scale change
  static const double rotateMinAngle = 5.0; // degrees
  static const double tapMaxDuration = 300; // milliseconds
  static const double tapMaxMovement = 10.0; // pixels

  // Long press
  static const int longPressDuration = 500; // milliseconds

  // Double tap
  static const int doubleTapMaxDelay = 300; // milliseconds
}

/// Sensor (tilt control) constants
class SensorConstants {
  // Tilt ranges (degrees)
  static const double maxTilt = 45.0; // Maximum tilt angle
  static const double deadZone = 5.0; // Ignore small movements

  // Sensor update rate
  static const int updateIntervalMs = 16; // ~60 Hz

  // Smoothing
  static const double smoothingAlpha = 0.2; // Exponential moving average
  static const int calibrationSamples = 60; // Samples for calibration (~1 second at 60Hz)

  // Mapping to pitch bend
  static const double pitchBendMinSemitones = -2.0;
  static const double pitchBendMaxSemitones = 2.0;
  static const double pitchBendDefaultRange = 2.0; // ±2 semitones
}

/// Performance monitoring constants
class PerformanceConstants {
  // Monitoring intervals
  static const int fpsUpdateIntervalMs = 1000; // Update FPS counter every second
  static const int metricsUpdateIntervalMs = 100; // Update metrics 10x/second

  // Thresholds
  static const int fpsWarningThreshold = 45; // Warn below 45 FPS
  static const int fpsCriticalThreshold = 30; // Critical below 30 FPS
  static const double memoryWarningMB = 100.0; // Warn above 100 MB
  static const double memoryCriticalMB = 200.0; // Critical above 200 MB

  // History retention
  static const int maxHistorySamples = 300; // 5 minutes at 1 sample/second
}

/// Haptic feedback constants
class HapticConstants {
  // Intensity levels (0.0 - 1.0)
  static const double intensityLight = 0.3;
  static const double intensityMedium = 0.6;
  static const double intensityHeavy = 1.0;

  // Duration limits (milliseconds)
  static const int minDuration = 10;
  static const int maxDuration = 500;
  static const int defaultDuration = 50;

  // Rate limiting
  static const int minIntervalMs = 10; // Don't trigger faster than 100Hz
  static const int batchWindowMs = 50; // Group haptics within 50ms window
}

/// Preset system constants
class PresetConstants {
  // Preset limits
  static const int maxPresetsLocal = 100; // Maximum local presets
  static const int maxPresetsCloud = 1000; // Maximum cloud presets
  static const int maxPresetNameLength = 50;
  static const int maxPresetDescriptionLength = 200;

  // Categories
  static const List<String> defaultCategories = [
    'Bass',
    'Lead',
    'Pad',
    'Pluck',
    'Arp',
    'FX',
    'Ambient',
    'Percussion',
    'Experimental',
  ];

  // Search and filtering
  static const int minSearchLength = 2;
  static const int maxSearchResults = 50;
}

/// Firebase/Cloud constants
class CloudConstants {
  // Timeouts (milliseconds)
  static const int connectionTimeout = 10000; // 10 seconds
  static const int readTimeout = 5000; // 5 seconds
  static const int writeTimeout = 5000; // 5 seconds

  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000; // Start with 1 second
  static const double retryBackoffFactor = 2.0; // Exponential backoff

  // Sync intervals
  static const int autoSyncIntervalMinutes = 15;
  static const int maxOfflineChanges = 50; // Sync when this many changes queued
}

/// File path constants
class PathConstants {
  // Asset paths
  static const String vib3DistPath = 'assets/vib3_dist/index.html';
  static const String vib3PlusViewerPath = 'assets/vib3plus_viewer.html';
  static const String presetsPath = 'assets/presets/';
  static const String wavetablesPath = 'assets/wavetables/';

  // Local storage keys
  static const String keyLastPreset = 'last_preset';
  static const String keyUserSettings = 'user_settings';
  static const String keyHapticEnabled = 'haptic_enabled';
  static const String keyLogLevel = 'log_level';
}

/// Debug/development constants
class DebugConstants {
  // Enable/disable features
  static const bool enablePerformanceOverlay = true; // Show FPS in debug
  static const bool enableDiagnostics = true; // Show diagnostics panel
  static const bool enableVerboseLogging = false; // Extra logging

  // Testing
  static const bool enableTestMode = false; // Bypass certain checks for testing
  static const bool mockFirebase = false; // Use mock Firebase in tests
}
