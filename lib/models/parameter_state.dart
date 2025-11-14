/**
 * Parameter State - Base + Modulation Architecture
 *
 * Manages parameter values with separation between:
 * - Base value (user-controlled via sliders)
 * - Modulation amount (from audio/visual coupling)
 * - Final value (base + modulation, clamped to range)
 *
 * This prevents audio reactivity from "fighting" user input.
 * User sets the base, audio/visual adds ±modulation over it.
 *
 * A Paul Phillips Manifestation
 */

import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Parameter state with base + modulation architecture
class ParameterState extends ChangeNotifier {
  final String name;
  final double minValue;
  final double maxValue;

  // User-controlled base value (from sliders/controls)
  double _baseValue;

  // Current modulation amount (from audio/visual coupling)
  double _currentModulation = 0.0;

  // Maximum modulation range (±modulation depth)
  double _modulationDepth;

  // Enable/disable modulation for this parameter
  bool _modulationEnabled = true;

  ParameterState({
    required this.name,
    required double initialValue,
    required this.minValue,
    required this.maxValue,
    double modulationDepth = 0.0,
  })  : _baseValue = initialValue.clamp(minValue, maxValue),
        _modulationDepth = modulationDepth;

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Base value (user-controlled)
  double get baseValue => _baseValue;

  /// Current modulation amount
  double get currentModulation => _currentModulation;

  /// Modulation depth (maximum ±range)
  double get modulationDepth => _modulationDepth;

  /// Modulation enabled
  bool get modulationEnabled => _modulationEnabled;

  /// Final value (base + modulation, clamped to valid range)
  double get finalValue {
    if (!_modulationEnabled) return _baseValue;

    final modulated = _baseValue + _currentModulation;
    return modulated.clamp(minValue, maxValue);
  }

  /// Negative modulation limit (base - depth)
  double get negativeLimit {
    return (_baseValue - _modulationDepth).clamp(minValue, maxValue);
  }

  /// Positive modulation limit (base + depth)
  double get positiveLimit {
    return (_baseValue + _modulationDepth).clamp(minValue, maxValue);
  }

  /// Normalized base value (0-1)
  double get normalizedBase {
    if (maxValue == minValue) return 0.5;
    return (_baseValue - minValue) / (maxValue - minValue);
  }

  /// Normalized final value (0-1)
  double get normalizedFinal {
    if (maxValue == minValue) return 0.5;
    return (finalValue - minValue) / (maxValue - minValue);
  }

  // ============================================================================
  // SETTERS
  // ============================================================================

  /// Set base value (from user input)
  void setBaseValue(double value) {
    final clamped = value.clamp(minValue, maxValue);
    if (_baseValue != clamped) {
      _baseValue = clamped;
      notifyListeners();
    }
  }

  /// Set current modulation (from audio/visual coupling)
  void setModulation(double value) {
    final clamped = value.clamp(-_modulationDepth, _modulationDepth);
    if (_currentModulation != clamped) {
      _currentModulation = clamped;
      notifyListeners();
    }
  }

  /// Set modulation depth (maximum ±range)
  void setModulationDepth(double depth) {
    if (_modulationDepth != depth) {
      _modulationDepth = depth.abs();
      // Re-clamp current modulation to new depth
      _currentModulation = _currentModulation.clamp(-_modulationDepth, _modulationDepth);
      notifyListeners();
    }
  }

  /// Enable/disable modulation
  void setModulationEnabled(bool enabled) {
    if (_modulationEnabled != enabled) {
      _modulationEnabled = enabled;
      notifyListeners();
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Reset to initial state
  void reset(double initialValue) {
    _baseValue = initialValue.clamp(minValue, maxValue);
    _currentModulation = 0.0;
    notifyListeners();
  }

  /// Get state as map (for debugging/UI)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'baseValue': _baseValue,
      'currentModulation': _currentModulation,
      'finalValue': finalValue,
      'modulationDepth': _modulationDepth,
      'modulationEnabled': _modulationEnabled,
      'minValue': minValue,
      'maxValue': maxValue,
      'negativeLimit': negativeLimit,
      'positiveLimit': positiveLimit,
    };
  }

  @override
  String toString() {
    return 'ParameterState($name: base=$_baseValue, mod=${_currentModulation.toStringAsFixed(3)}, final=${finalValue.toStringAsFixed(3)})';
  }
}

/// Integer parameter state (for discrete values like tessellation density)
class IntParameterState extends ParameterState {
  IntParameterState({
    required String name,
    required int initialValue,
    required int minValue,
    required int maxValue,
    int modulationDepth = 0,
  }) : super(
          name: name,
          initialValue: initialValue.toDouble(),
          minValue: minValue.toDouble(),
          maxValue: maxValue.toDouble(),
          modulationDepth: modulationDepth.toDouble(),
        );

  /// Final value as integer
  int get finalValueInt => finalValue.round();

  /// Base value as integer
  int get baseValueInt => baseValue.round();

  /// Set base value as integer
  void setBaseValueInt(int value) {
    setBaseValue(value.toDouble());
  }

  /// Set modulation as integer
  void setModulationInt(int value) {
    setModulation(value.toDouble());
  }
}

/// Manager for all parameter states
class ParameterStateManager extends ChangeNotifier {
  final Map<String, ParameterState> _parameters = {};

  /// Register a new parameter
  void register(ParameterState param) {
    _parameters[param.name] = param;
    param.addListener(notifyListeners);
  }

  /// Get parameter by name
  ParameterState? get(String name) => _parameters[name];

  /// Get parameter (throws if not found)
  ParameterState getRequired(String name) {
    final param = _parameters[name];
    if (param == null) {
      throw StateError('Parameter "$name" not found. Available: ${_parameters.keys.join(", ")}');
    }
    return param;
  }

  /// Get all parameters
  Map<String, ParameterState> get all => Map.unmodifiable(_parameters);

  /// Reset all parameters
  void resetAll() {
    for (final param in _parameters.values) {
      param.reset(param.baseValue);
    }
  }

  /// Enable/disable all modulation
  void setAllModulationEnabled(bool enabled) {
    for (final param in _parameters.values) {
      param.setModulationEnabled(enabled);
    }
  }

  /// Get state of all parameters
  Map<String, Map<String, dynamic>> getAllStates() {
    return _parameters.map((name, param) => MapEntry(name, param.toMap()));
  }

  @override
  void dispose() {
    for (final param in _parameters.values) {
      param.dispose();
    }
    _parameters.clear();
    super.dispose();
  }
}
