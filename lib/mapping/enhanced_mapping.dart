/**
 * Enhanced Parameter Mapping System
 *
 * Professional parameter mapping with:
 * - Musical scaling curves (exponential, logarithmic, S-curve)
 * - Velocity sensitivity
 * - Aftertouch/pressure support
 * - Smart parameter ranges optimized for human perception
 * - Preset-based mapping configurations
 *
 * A Paul Phillips Manifestation
 */

import 'dart:math' as math;

/// Hyperbolic tangent function (not in dart:math)
double _tanh(double x) {
  final e2x = math.exp(2 * x);
  return (e2x - 1) / (e2x + 1);
}

/// Enhanced mapping curve types
enum MappingCurve {
  linear,
  exponential, // Good for frequency, filter cutoff
  logarithmic, // Good for amplitude, mix
  scurve, // Smooth acceleration/deceleration
  quadratic, // Subtle curve
  inverse, // Inverted response
  stepped, // Quantized steps
}

/// Enhanced parameter mapping with musical curves
class EnhancedMapping {
  final String sourceParam;
  final String targetParam;
  final double minValue;
  final double maxValue;
  final MappingCurve curve;
  final double sensitivity; // 0-1, how responsive
  final double deadZone; // 0-1, center dead zone
  final bool bipolar; // If true, 0.5 is center, not 0
  final int? steps; // For stepped curves

  const EnhancedMapping({
    required this.sourceParam,
    required this.targetParam,
    required this.minValue,
    required this.maxValue,
    this.curve = MappingCurve.linear,
    this.sensitivity = 1.0,
    this.deadZone = 0.0,
    this.bipolar = false,
    this.steps,
  });

  /// Map input value (0-1) to output value
  double map(double input) {
    // Apply dead zone
    double normalized = input;
    if (bipolar) {
      // Bipolar: 0.5 is center
      final deviation = (normalized - 0.5).abs();
      if (deviation < deadZone / 2) {
        return minValue + (maxValue - minValue) / 2; // Return center value
      }
      // Scale to account for dead zone
      if (normalized > 0.5) {
        normalized = 0.5 + (normalized - 0.5 - deadZone / 2) / (0.5 - deadZone / 2);
      } else {
        normalized = 0.5 - (0.5 - normalized - deadZone / 2) / (0.5 - deadZone / 2);
      }
    } else {
      // Unipolar: 0 is start
      if (normalized < deadZone) {
        return minValue;
      }
      normalized = (normalized - deadZone) / (1.0 - deadZone);
    }

    // Apply sensitivity
    normalized = math.pow(normalized, 1.0 / sensitivity).toDouble();

    // Apply curve
    double curved = _applyCurve(normalized);

    // Apply steps if specified
    if (steps != null && steps! > 1) {
      curved = (curved * steps!).round() / steps!;
    }

    // Scale to range
    return minValue + curved * (maxValue - minValue);
  }

  double _applyCurve(double input) {
    switch (curve) {
      case MappingCurve.linear:
        return input;

      case MappingCurve.exponential:
        // Musical exponential (good for frequency)
        return (math.pow(2.0, input * 10) - 1) / 1023.0;

      case MappingCurve.logarithmic:
        // Musical logarithmic (good for amplitude)
        return math.log(input * 99 + 1) / math.log(100);

      case MappingCurve.scurve:
        // Smooth S-curve using tanh
        final scaled = (input - 0.5) * 6.0; // Scale to ±3
        return (_tanh(scaled) + 1.0) / 2.0;

      case MappingCurve.quadratic:
        return input * input;

      case MappingCurve.inverse:
        return 1.0 - input;

      case MappingCurve.stepped:
        // Handled separately above
        return input;
    }
  }

  /// Create a copy with modified parameters
  EnhancedMapping copyWith({
    String? sourceParam,
    String? targetParam,
    double? minValue,
    double? maxValue,
    MappingCurve? curve,
    double? sensitivity,
    double? deadZone,
    bool? bipolar,
    int? steps,
  }) {
    return EnhancedMapping(
      sourceParam: sourceParam ?? this.sourceParam,
      targetParam: targetParam ?? this.targetParam,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      curve: curve ?? this.curve,
      sensitivity: sensitivity ?? this.sensitivity,
      deadZone: deadZone ?? this.deadZone,
      bipolar: bipolar ?? this.bipolar,
      steps: steps ?? this.steps,
    );
  }
}

/// Predefined musical mappings with optimal curves
class MusicalMappings {
  /// Filter cutoff mapping (20Hz - 20kHz, exponential)
  static const filterCutoff = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'filterCutoff',
    minValue: 20.0,
    maxValue: 20000.0,
    curve: MappingCurve.exponential,
    sensitivity: 0.8, // Slightly less sensitive for fine control
  );

  /// Resonance mapping (0-1, quadratic for smooth control)
  static const filterResonance = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'filterResonance',
    minValue: 0.0,
    maxValue: 1.0,
    curve: MappingCurve.quadratic,
    sensitivity: 0.9,
  );

  /// Envelope time mapping (1ms - 5s, exponential)
  static const envelopeTime = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'envelopeTime',
    minValue: 0.001,
    maxValue: 5.0,
    curve: MappingCurve.exponential,
    sensitivity: 0.7, // Less sensitive for precise timing
  );

  /// Volume/amplitude mapping (0-1, logarithmic for perceived loudness)
  static const amplitude = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'amplitude',
    minValue: 0.0,
    maxValue: 1.0,
    curve: MappingCurve.logarithmic,
    sensitivity: 1.0,
  );

  /// Pan mapping (-1 to 1, linear with center dead zone)
  static const pan = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'pan',
    minValue: -1.0,
    maxValue: 1.0,
    curve: MappingCurve.linear,
    bipolar: true,
    deadZone: 0.1, // 10% dead zone for easy centering
  );

  /// Detune mapping (±50 cents, bipolar with dead zone)
  static const detune = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'detune',
    minValue: -50.0,
    maxValue: 50.0,
    curve: MappingCurve.linear,
    bipolar: true,
    deadZone: 0.05,
  );

  /// LFO rate mapping (0.1Hz - 20Hz, exponential)
  static const lfoRate = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'lfoRate',
    minValue: 0.1,
    maxValue: 20.0,
    curve: MappingCurve.exponential,
    sensitivity: 0.8,
  );

  /// Reverb/delay time mapping (10ms - 2000ms, exponential)
  static const effectTime = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'effectTime',
    minValue: 10.0,
    maxValue: 2000.0,
    curve: MappingCurve.exponential,
    sensitivity: 0.75,
  );

  /// Mix/blend mapping (0-1, S-curve for smooth crossfade)
  static const mix = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'mix',
    minValue: 0.0,
    maxValue: 1.0,
    curve: MappingCurve.scurve,
  );

  /// Quantized octave selector (-2 to +2 octaves)
  static const octaveSelect = EnhancedMapping(
    sourceParam: 'slider',
    targetParam: 'octave',
    minValue: -24.0,
    maxValue: 24.0,
    curve: MappingCurve.linear,
    steps: 5, // 5 steps = -2, -1, 0, 1, 2 octaves
  );
}

/// Velocity curve processor
class VelocityCurve {
  final double sensitivity; // 0-2, 1=linear
  final double minimum; // 0-1, minimum velocity output
  final double maximum; // 0-1, maximum velocity output
  final MappingCurve curve;

  const VelocityCurve({
    this.sensitivity = 1.0,
    this.minimum = 0.0,
    this.maximum = 1.0,
    this.curve = MappingCurve.linear,
  });

  /// Process velocity (0-1 input) through curve
  double process(double velocity) {
    // Apply sensitivity as power curve
    double curved = math.pow(velocity, 1.0 / sensitivity).toDouble();

    // Apply curve type
    switch (curve) {
      case MappingCurve.exponential:
        curved = curved * curved; // Exponential response
        break;
      case MappingCurve.logarithmic:
        curved = math.sqrt(curved); // Logarithmic response
        break;
      case MappingCurve.scurve:
        // Soft at extremes, responsive in middle
        curved = (_tanh((curved - 0.5) * 4) + 1) / 2;
        break;
      default:
        break;
    }

    // Scale to min/max range
    return minimum + curved * (maximum - minimum);
  }

  /// Preset curves
  static const linear = VelocityCurve(sensitivity: 1.0);
  static const soft = VelocityCurve(sensitivity: 0.6); // More sensitive
  static const hard = VelocityCurve(sensitivity: 1.4); // Less sensitive
  static const compressed = VelocityCurve(
    sensitivity: 0.8,
    minimum: 0.3,
    maximum: 1.0,
  ); // Reduce dynamic range
}

/// Aftertouch/pressure curve processor
class PressureCurve {
  final double threshold; // 0-1, pressure needed to start responding
  final double sensitivity; // 0-2, response curve
  final MappingCurve curve;

  const PressureCurve({
    this.threshold = 0.1,
    this.sensitivity = 1.0,
    this.curve = MappingCurve.quadratic,
  });

  /// Process pressure (0-1 input)
  double process(double pressure) {
    if (pressure < threshold) return 0.0;

    // Normalize above threshold
    final normalized = (pressure - threshold) / (1.0 - threshold);

    // Apply sensitivity
    final curved = math.pow(normalized, 1.0 / sensitivity).toDouble();

    // Apply curve
    switch (curve) {
      case MappingCurve.exponential:
        return curved * curved;
      case MappingCurve.logarithmic:
        return math.sqrt(curved);
      case MappingCurve.scurve:
        return (_tanh((curved - 0.5) * 4) + 1) / 2;
      default:
        return curved;
    }
  }
}

/// Scale quantizer for musical pitch
class ScaleQuantizer {
  final List<int> scale; // Semitone offsets from root (0-11)

  const ScaleQuantizer(this.scale);

  /// Quantize continuous pitch to nearest scale note
  /// pitch: MIDI note number (can be fractional)
  /// Returns: Quantized MIDI note number
  double quantize(double pitch) {
    final octave = (pitch / 12).floor();
    final noteInOctave = pitch % 12;

    // Find nearest scale note
    double nearestNote = scale[0].toDouble();
    double minDistance = (noteInOctave - nearestNote).abs();

    for (final scaleNote in scale) {
      final distance = (noteInOctave - scaleNote).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearestNote = scaleNote.toDouble();
      }
    }

    return octave * 12 + nearestNote;
  }

  /// Predefined scales
  static const chromatic = ScaleQuantizer([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
  static const major = ScaleQuantizer([0, 2, 4, 5, 7, 9, 11]);
  static const minor = ScaleQuantizer([0, 2, 3, 5, 7, 8, 10]);
  static const pentatonicMajor = ScaleQuantizer([0, 2, 4, 7, 9]);
  static const pentatonicMinor = ScaleQuantizer([0, 3, 5, 7, 10]);
  static const blues = ScaleQuantizer([0, 3, 5, 6, 7, 10]);
  static const dorian = ScaleQuantizer([0, 2, 3, 5, 7, 9, 10]);
  static const phrygian = ScaleQuantizer([0, 1, 3, 5, 7, 8, 10]);
  static const lydian = ScaleQuantizer([0, 2, 4, 6, 7, 9, 11]);
  static const mixolydian = ScaleQuantizer([0, 2, 4, 5, 7, 9, 10]);
  static const wholeTone = ScaleQuantizer([0, 2, 4, 6, 8, 10]);
  static const diminished = ScaleQuantizer([0, 2, 3, 5, 6, 8, 9, 11]);
}

/// Smooth parameter interpolator with different curves
class ParameterSmoother {
  double _current;
  double _target;
  final double _sampleRate;
  double _smoothTime; // Seconds
  MappingCurve _curve;

  ParameterSmoother({
    required double sampleRate,
    double initial = 0.0,
    double smoothTime = 0.05, // 50ms default
    MappingCurve curve = MappingCurve.linear,
  })  : _current = initial,
        _target = initial,
        _sampleRate = sampleRate,
        _smoothTime = smoothTime,
        _curve = curve;

  /// Set new target value
  void setTarget(double value) {
    _target = value;
  }

  /// Get next smoothed value
  double process() {
    if ((_target - _current).abs() < 0.0001) {
      _current = _target;
      return _current;
    }

    // Calculate coefficient based on smooth time
    final samplesNeeded = _smoothTime * _sampleRate;
    final coefficient = 1.0 - math.exp(-1.0 / samplesNeeded);

    // Interpolate
    _current += (_target - _current) * coefficient;

    return _current;
  }

  /// Jump to value immediately
  void jump(double value) {
    _current = value;
    _target = value;
  }

  /// Get current value
  double get value => _current;

  /// Set smooth time
  void setSmoothTime(double seconds) {
    _smoothTime = seconds;
  }

  /// Set curve type
  void setCurve(MappingCurve curve) {
    _curve = curve;
  }
}
