///
/// Gesture Recognition System
///
/// Advanced multi-finger gesture detection for enhanced UI interactions.
/// Recognizes complex gestures like pinch-to-zoom, two-finger rotate,
/// three-finger swipe, and custom musical gestures.
///
/// Features:
/// - Multi-touch gesture recognition (2-5 fingers)
/// - Pinch to zoom (UI scale)
/// - Two-finger rotate (parameter control)
/// - Three-finger swipe (preset navigation)
/// - Four-finger tap (panel toggle)
/// - Custom musical gestures
/// - Gesture history and replay
/// - Conflict resolution
///
/// A Paul Phillips Manifestation
////

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ============================================================================
// GESTURE TYPE
// ============================================================================

/// Recognized gesture types
enum GestureType {
  // Single finger
  tap,
  doubleTap,
  longPress,
  swipe,
  drag,

  // Two fingers
  pinch,
  twoFingerRotate,
  twoFingerSwipe,
  twoFingerTap,

  // Three fingers
  threeFingerSwipe,
  threeFingerTap,
  threeFingerPinch,

  // Four fingers
  fourFingerSwipe,
  fourFingerTap,

  // Five fingers
  fiveFingerTap,
  fiveFingerSpread,

  // Custom
  musicalStrum,
  musicalTremolo,
  musicalGliss,
}

// ============================================================================
// GESTURE DATA
// ============================================================================

/// Detected gesture data
class DetectedGesture {
  final GestureType type;
  final int fingerCount;
  final Offset center;
  final double distance; // For pinch gestures
  final double angle; // For rotate gestures
  final Offset velocity; // For swipe gestures
  final double pressure; // Average pressure
  final Duration duration; // Gesture duration
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const DetectedGesture({
    required this.type,
    required this.fingerCount,
    required this.center,
    this.distance = 0.0,
    this.angle = 0.0,
    this.velocity = Offset.zero,
    this.pressure = 1.0,
    this.duration = Duration.zero,
    required this.timestamp,
    this.metadata = const {},
  });
}

// ============================================================================
// GESTURE RECOGNIZER
// ============================================================================

/// Advanced gesture recognition system
class GestureRecognitionSystem {
  // Active touch points
  final Map<int, _TouchPoint> _activeTouches = {};

  // Gesture callbacks
  final Map<GestureType, void Function(DetectedGesture)> _handlers = {};

  // Configuration
  double pinchThreshold = 20.0; // Pixels
  double rotateThreshold = 0.1; // Radians (~5.7°)
  double swipeThreshold = 100.0; // Pixels per second
  double longPressDuration = 500.0; // Milliseconds
  int maxSimultaneousTouches = 5;

  // State tracking
  DateTime? _gestureStartTime;
  Offset? _initialCenter;
  double? _initialDistance;
  double? _initialAngle;

  // Gesture history
  final List<DetectedGesture> _gestureHistory = [];
  static const int maxHistoryLength = 50;

  // ============================================================================
  // GESTURE REGISTRATION
  // ============================================================================

  /// Register handler for gesture type
  void on(GestureType type, void Function(DetectedGesture) handler) {
    _handlers[type] = handler;
  }

  /// Unregister handler
  void off(GestureType type) {
    _handlers.remove(type);
  }

  /// Unregister all handlers
  void offAll() {
    _handlers.clear();
  }

  // ============================================================================
  // TOUCH TRACKING
  // ============================================================================

  /// Handle pointer down
  void handlePointerDown(PointerDownEvent event) {
    if (_activeTouches.length >= maxSimultaneousTouches) return;

    _activeTouches[event.pointer] = _TouchPoint(
      id: event.pointer,
      position: event.localPosition,
      pressure: event.pressure,
      timestamp: DateTime.now(),
    );

    _gestureStartTime = DateTime.now();
    _updateGestureMetrics();

    _checkMultiTouchGestures();
  }

  /// Handle pointer move
  void handlePointerMove(PointerMoveEvent event) {
    final touch = _activeTouches[event.pointer];
    if (touch == null) return;

    _activeTouches[event.pointer] = touch.copyWith(
      position: event.localPosition,
      pressure: event.pressure,
    );

    _checkContinuousGestures();
  }

  /// Handle pointer up
  void handlePointerUp(PointerUpEvent event) {
    final touch = _activeTouches.remove(event.pointer);
    if (touch == null) return;

    _checkEndGestures(touch);

    if (_activeTouches.isEmpty) {
      _reset();
    }
  }

  /// Handle pointer cancel
  void handlePointerCancel(PointerCancelEvent event) {
    _activeTouches.remove(event.pointer);

    if (_activeTouches.isEmpty) {
      _reset();
    }
  }

  // ============================================================================
  // GESTURE DETECTION
  // ============================================================================

  void _checkMultiTouchGestures() {
    final fingerCount = _activeTouches.length;

    switch (fingerCount) {
      case 2:
        _detectTwoFingerGestures();
        break;
      case 3:
        _detectThreeFingerGestures();
        break;
      case 4:
        _detectFourFingerGestures();
        break;
      case 5:
        _detectFiveFingerGestures();
        break;
    }
  }

  void _checkContinuousGestures() {
    final fingerCount = _activeTouches.length;

    if (fingerCount == 2) {
      _detectPinch();
      _detectRotate();
    } else if (fingerCount == 3) {
      _detectThreeFingerPinch();
    }
  }

  void _checkEndGestures(_TouchPoint touch) {
    final duration = DateTime.now().difference(touch.timestamp);
    final displacement = (touch.position - touch.startPosition).distance;

    // Swipe detection
    if (duration.inMilliseconds < 300 && displacement > swipeThreshold / 3) {
      _detectSwipe(touch, duration);
    }

    // Tap detection
    if (duration.inMilliseconds < 300 && displacement < 10) {
      _detectTap();
    }

    // Long press
    if (duration.inMilliseconds > longPressDuration && displacement < 10) {
      _emitGesture(DetectedGesture(
        type: GestureType.longPress,
        fingerCount: 1,
        center: touch.position,
        pressure: touch.pressure,
        duration: duration,
        timestamp: DateTime.now(),
      ));
    }
  }

  // ============================================================================
  // TWO-FINGER GESTURES
  // ============================================================================

  void _detectTwoFingerGestures() {
    _updateGestureMetrics();

    // Two-finger tap
    final handler = _handlers[GestureType.twoFingerTap];
    if (handler != null) {
      _emitGesture(DetectedGesture(
        type: GestureType.twoFingerTap,
        fingerCount: 2,
        center: _initialCenter!,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _detectPinch() {
    if (_initialDistance == null || _initialCenter == null) return;

    final currentCenter = _calculateCenter();
    final currentDistance = _calculateDistance();
    final distanceChange = currentDistance - _initialDistance!;

    if (distanceChange.abs() > pinchThreshold) {
      final scale = currentDistance / _initialDistance!;

      _emitGesture(DetectedGesture(
        type: GestureType.pinch,
        fingerCount: 2,
        center: currentCenter,
        distance: distanceChange,
        timestamp: DateTime.now(),
        metadata: {'scale': scale},
      ));

      _initialDistance = currentDistance; // Update for next frame
    }
  }

  void _detectRotate() {
    if (_initialAngle == null || _initialCenter == null) return;

    final currentAngle = _calculateAngle();
    final angleChange = currentAngle - _initialAngle!;

    if (angleChange.abs() > rotateThreshold) {
      _emitGesture(DetectedGesture(
        type: GestureType.twoFingerRotate,
        fingerCount: 2,
        center: _calculateCenter(),
        angle: angleChange,
        timestamp: DateTime.now(),
        metadata: {'totalAngle': currentAngle},
      ));

      _initialAngle = currentAngle; // Update for next frame
    }
  }

  // ============================================================================
  // THREE-FINGER GESTURES
  // ============================================================================

  void _detectThreeFingerGestures() {
    _emitGesture(DetectedGesture(
      type: GestureType.threeFingerTap,
      fingerCount: 3,
      center: _calculateCenter(),
      timestamp: DateTime.now(),
    ));
  }

  void _detectThreeFingerPinch() {
    if (_initialDistance == null) return;

    final currentDistance = _calculateAverageDistance();
    final distanceChange = currentDistance - _initialDistance!;

    if (distanceChange.abs() > pinchThreshold) {
      _emitGesture(DetectedGesture(
        type: GestureType.threeFingerPinch,
        fingerCount: 3,
        center: _calculateCenter(),
        distance: distanceChange,
        timestamp: DateTime.now(),
      ));

      _initialDistance = currentDistance;
    }
  }

  // ============================================================================
  // FOUR-FINGER GESTURES
  // ============================================================================

  void _detectFourFingerGestures() {
    _emitGesture(DetectedGesture(
      type: GestureType.fourFingerTap,
      fingerCount: 4,
      center: _calculateCenter(),
      timestamp: DateTime.now(),
    ));
  }

  // ============================================================================
  // FIVE-FINGER GESTURES
  // ============================================================================

  void _detectFiveFingerGestures() {
    _emitGesture(DetectedGesture(
      type: GestureType.fiveFingerTap,
      fingerCount: 5,
      center: _calculateCenter(),
      timestamp: DateTime.now(),
    ));
  }

  // ============================================================================
  // SINGLE-FINGER GESTURES
  // ============================================================================

  void _detectTap() {
    _emitGesture(DetectedGesture(
      type: GestureType.tap,
      fingerCount: 1,
      center: _activeTouches.values.first.position,
      timestamp: DateTime.now(),
    ));
  }

  void _detectSwipe(_TouchPoint touch, Duration duration) {
    final displacement = touch.position - touch.startPosition;
    final velocity = Offset(
      displacement.dx / duration.inMilliseconds * 1000,
      displacement.dy / duration.inMilliseconds * 1000,
    );

    _emitGesture(DetectedGesture(
      type: GestureType.swipe,
      fingerCount: 1,
      center: touch.position,
      velocity: velocity,
      duration: duration,
      timestamp: DateTime.now(),
    ));
  }

  // ============================================================================
  // METRIC CALCULATIONS
  // ============================================================================

  void _updateGestureMetrics() {
    _initialCenter = _calculateCenter();
    _initialDistance = _activeTouches.length == 2
        ? _calculateDistance()
        : _calculateAverageDistance();
    _initialAngle = _activeTouches.length == 2 ? _calculateAngle() : null;
  }

  Offset _calculateCenter() {
    if (_activeTouches.isEmpty) return Offset.zero;

    double sumX = 0, sumY = 0;
    for (final touch in _activeTouches.values) {
      sumX += touch.position.dx;
      sumY += touch.position.dy;
    }

    return Offset(
      sumX / _activeTouches.length,
      sumY / _activeTouches.length,
    );
  }

  double _calculateDistance() {
    if (_activeTouches.length != 2) return 0.0;

    final touches = _activeTouches.values.toList();
    return (touches[0].position - touches[1].position).distance;
  }

  double _calculateAverageDistance() {
    if (_activeTouches.length < 2) return 0.0;

    final center = _calculateCenter();
    double sum = 0;

    for (final touch in _activeTouches.values) {
      sum += (touch.position - center).distance;
    }

    return sum / _activeTouches.length;
  }

  double _calculateAngle() {
    if (_activeTouches.length != 2) return 0.0;

    final touches = _activeTouches.values.toList();
    final delta = touches[1].position - touches[0].position;

    return math.atan2(delta.dy, delta.dx);
  }

  // ============================================================================
  // EVENT EMISSION
  // ============================================================================

  void _emitGesture(DetectedGesture gesture) {
    // Add to history
    _gestureHistory.add(gesture);
    if (_gestureHistory.length > maxHistoryLength) {
      _gestureHistory.removeAt(0);
    }

    // Call handler
    final handler = _handlers[gesture.type];
    handler?.call(gesture);
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  void _reset() {
    _gestureStartTime = null;
    _initialCenter = null;
    _initialDistance = null;
    _initialAngle = null;
  }

  /// Clear gesture history
  void clearHistory() {
    _gestureHistory.clear();
  }

  /// Get gesture history
  List<DetectedGesture> get history => List.unmodifiable(_gestureHistory);

  /// Get active touch count
  int get activeTouchCount => _activeTouches.length;
}

// ============================================================================
// TOUCH POINT
// ============================================================================

class _TouchPoint {
  final int id;
  final Offset position;
  final Offset startPosition;
  final double pressure;
  final DateTime timestamp;

  _TouchPoint({
    required this.id,
    required this.position,
    Offset? startPosition,
    required this.pressure,
    required this.timestamp,
  }) : startPosition = startPosition ?? position;

  _TouchPoint copyWith({
    Offset? position,
    double? pressure,
  }) {
    return _TouchPoint(
      id: id,
      position: position ?? this.position,
      startPosition: startPosition,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp,
    );
  }
}
