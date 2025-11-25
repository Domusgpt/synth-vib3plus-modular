///
/// Component Integration Manager
///
/// Central hub that connects all UI components with audio/visual systems,
/// manages parameter routing, animation layer integration, haptic feedback,
/// and coordinates state across the entire application.
///
/// Features:
/// - Component registration and lifecycle management
/// - Audio → Visual parameter routing
/// - Visual → Audio parameter routing
/// - Animation layer coordination
/// - Haptic feedback integration
/// - Performance monitoring
/// - Event broadcasting
/// - State synchronization
///
/// This is the "nervous system" of the application.
///
/// A Paul Phillips Manifestation
///

library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../audio/audio_analyzer.dart';
import '../providers/audio_provider.dart';
import '../providers/visual_provider.dart';
import '../providers/layout_provider.dart';
import '../mapping/parameter_bridge.dart';
import '../ui/layers/animation_layer.dart';
import '../ui/theme/design_tokens.dart';
import '../ui/layers/modulation_visualizer.dart';
import '../ui/utils/haptic_feedback.dart';

// ============================================================================
// COMPONENT TYPE
// ============================================================================

/// Type of registered component
enum ComponentType {
  xyPad,
  orb,
  slider,
  knob,
  ladder,
  panel,
  visualizer,
  custom,
}

// ============================================================================
// COMPONENT REGISTRATION
// ============================================================================

/// Registered component metadata
class RegisteredComponent {
  final String id;
  final ComponentType type;
  final GlobalKey key;
  final Map<String, dynamic> config;
  final DateTime registeredAt;

  RegisteredComponent({
    required this.id,
    required this.type,
    required this.key,
    this.config = const {},
  }) : registeredAt = DateTime.now();
}

// ============================================================================
// PARAMETER BINDING
// ============================================================================

/// Binding between UI component and parameter
class ParameterBinding {
  final String componentId;
  final String parameterId;
  final bool bidirectional; // Two-way binding
  final double sensitivity; // 0.1-2.0
  final Function(double)? transform; // Value transformation

  const ParameterBinding({
    required this.componentId,
    required this.parameterId,
    this.bidirectional = true,
    this.sensitivity = 1.0,
    this.transform,
  });
}

// ============================================================================
// COMPONENT INTEGRATION MANAGER
// ============================================================================

/// Central integration manager
class ComponentIntegrationManager extends ChangeNotifier {
  // Providers
  final AudioProvider? audioProvider;
  final VisualProvider? visualProvider;
  final LayoutProvider? layoutProvider;
  final ParameterBridge? parameterBridge;

  // Animation layer
  AnimationLayerState? animationLayer;

  // Component registry
  final Map<String, RegisteredComponent> _components = {};
  final Map<String, ParameterBinding> _bindings = {};

  // Audio stream
  Stream<AudioFeatures>? audioStream;
  StreamSubscription? _audioSubscription;

  // Performance monitoring
  final Map<String, int> _interactionCounts = {};
  DateTime _sessionStart = DateTime.now();

  // Event broadcasting
  final StreamController<ComponentEvent> _eventController =
      StreamController.broadcast();
  Stream<ComponentEvent> get events => _eventController.stream;

  // Configuration
  bool enableHaptics;
  bool enableParticles;
  bool enableModulationViz;
  double globalSensitivity;

  ComponentIntegrationManager({
    this.audioProvider,
    this.visualProvider,
    this.layoutProvider,
    this.parameterBridge,
    this.enableHaptics = true,
    this.enableParticles = true,
    this.enableModulationViz = true,
    this.globalSensitivity = 1.0,
  }) {
    _initialize();
  }

  void _initialize() {
    _sessionStart = DateTime.now();

    // Subscribe to audio provider updates
    if (audioProvider != null) {
      audioProvider!.addListener(_onAudioProviderUpdate);
    }
  }

  /// Handle audio provider updates
  void _onAudioProviderUpdate() {
    final features = audioProvider?.currentFeatures;
    if (features != null) {
      _handleAudioFeatures(features);
    }
  }

  @override
  void dispose() {
    audioProvider?.removeListener(_onAudioProviderUpdate);
    _audioSubscription?.cancel();
    _eventController.close();
    super.dispose();
  }

  // ============================================================================
  // COMPONENT REGISTRATION
  // ============================================================================

  /// Register a UI component
  void registerComponent({
    required String id,
    required ComponentType type,
    required GlobalKey key,
    Map<String, dynamic>? config,
  }) {
    _components[id] = RegisteredComponent(
      id: id,
      type: type,
      key: key,
      config: config ?? {},
    );

    _broadcastEvent(ComponentEvent(
      type: ComponentEventType.registered,
      componentId: id,
      timestamp: DateTime.now(),
    ));

    notifyListeners();
  }

  /// Unregister a component
  void unregisterComponent(String id) {
    _components.remove(id);
    _bindings.removeWhere((_, binding) => binding.componentId == id);

    _broadcastEvent(ComponentEvent(
      type: ComponentEventType.unregistered,
      componentId: id,
      timestamp: DateTime.now(),
    ));

    notifyListeners();
  }

  /// Get registered component
  RegisteredComponent? getComponent(String id) => _components[id];

  /// Get all components of type
  List<RegisteredComponent> getComponentsByType(ComponentType type) {
    return _components.values.where((c) => c.type == type).toList();
  }

  // ============================================================================
  // PARAMETER BINDING
  // ============================================================================

  /// Bind component to parameter
  void bindParameter(ParameterBinding binding) {
    _bindings[binding.componentId] = binding;

    // Setup modulation visualization if enabled
    if (enableModulationViz && animationLayer != null) {
      _setupModulationVisualization(binding);
    }

    notifyListeners();
  }

  /// Unbind component from parameter
  void unbindParameter(String componentId) {
    _bindings.remove(componentId);

    // Remove modulation visualization
    if (animationLayer != null) {
      animationLayer!.removeModulation(componentId, 'any');
    }

    notifyListeners();
  }

  /// Update parameter value from component
  void updateParameterFromComponent(String componentId, double value) {
    final binding = _bindings[componentId];
    if (binding == null) return;

    // Apply sensitivity and transformation
    final effectiveValue = binding.transform != null
        ? binding.transform!(value)
        : value * binding.sensitivity * globalSensitivity;

    // Route to parameter bridge
    if (parameterBridge != null) {
      // parameterBridge!.setParameter(binding.parameterId, effectiveValue);
    }

    // Route to audio provider
    if (audioProvider != null) {
      _routeToAudioProvider(binding.parameterId, effectiveValue);
    }

    // Route to visual provider
    if (visualProvider != null) {
      _routeToVisualProvider(binding.parameterId, effectiveValue);
    }

    _broadcastEvent(ComponentEvent(
      type: ComponentEventType.valueChanged,
      componentId: componentId,
      value: effectiveValue,
      timestamp: DateTime.now(),
    ));
  }

  // ============================================================================
  // AUDIO INTEGRATION
  // ============================================================================

  void _routeToAudioProvider(String parameterId, double value) {
    // Route based on parameter ID
    switch (parameterId) {
      case 'frequency':
      case 'pitch':
        // Update note frequency
        break;
      case 'filter_cutoff':
        // audioProvider!.setFilterCutoff(value);
        break;
      case 'filter_resonance':
        // audioProvider!.setFilterResonance(value);
        break;
      case 'osc_mix':
        // audioProvider!.setOscillatorMix(value);
        break;
      case 'fm_depth':
        // audioProvider!.setFMDepth(value);
        break;
      case 'ring_mod':
        // audioProvider!.setRingModDepth(value);
        break;
      case 'reverb_mix':
        // audioProvider!.setReverbMix(value);
        break;
      case 'pitch_bend':
        // audioProvider!.setPitchBend(value);
        break;
      case 'vibrato':
        // audioProvider!.setVibratoDepth(value);
        break;
    }
  }

  void _routeToVisualProvider(String parameterId, double value) {
    // Route based on parameter ID
    switch (parameterId) {
      case 'rotation_xy':
        // visualProvider!.setRotationXY(value);
        break;
      case 'rotation_xz':
        // visualProvider!.setRotationXZ(value);
        break;
      case 'morph':
        // visualProvider!.setMorph(value);
        break;
      case 'chaos':
        // visualProvider!.setChaos(value);
        break;
      case 'tessellation':
        // visualProvider!.setTessellation(value.toInt());
        break;
    }
  }

  void _handleAudioFeatures(AudioFeatures features) {
    // Broadcast audio features to all registered components
    _broadcastEvent(ComponentEvent(
      type: ComponentEventType.audioUpdate,
      audioFeatures: features,
      timestamp: DateTime.now(),
    ));

    notifyListeners();
  }

  // ============================================================================
  // ANIMATION LAYER INTEGRATION
  // ============================================================================

  /// Set animation layer reference
  void setAnimationLayer(AnimationLayerState layer) {
    animationLayer = layer;
  }

  /// Spawn particles on interaction
  void spawnInteractionParticles(
    String componentId,
    Offset position, {
    double intensity = 1.0,
    Color? color,
  }) {
    if (!enableParticles || animationLayer == null) return;

    final component = _components[componentId];
    if (component == null) return;

    // Spawn particles based on component type
    switch (component.type) {
      case ComponentType.xyPad:
        animationLayer!.spawnBurst(
          position: position,
          color: color ?? DesignTokens.stateActive,
          intensity: intensity,
          count: 5,
        );
        break;

      case ComponentType.orb:
        animationLayer!.spawnBurst(
          position: position,
          color: color ?? DesignTokens.stateActive,
          intensity: intensity * 0.7,
          count: 3,
        );
        break;

      case ComponentType.slider:
      case ComponentType.knob:
      case ComponentType.ladder:
        animationLayer!.spawnBurst(
          position: position,
          color: color ?? DesignTokens.stateActive,
          intensity: intensity * 0.5,
          count: 2,
        );
        break;

      default:
        break;
    }
  }

  /// Add trail for component
  void addComponentTrail(
    String componentId,
    int pointerId,
    Offset position, {
    double pressure = 1.0,
  }) {
    if (animationLayer == null) return;

    animationLayer!.addTrailPoint(pointerId, position, pressure: pressure);
  }

  /// Remove trail for component
  void removeComponentTrail(String componentId, int pointerId) {
    if (animationLayer == null) return;

    animationLayer!.removeTrail(pointerId);
  }

  void _setupModulationVisualization(ParameterBinding binding) {
    final component = _components[binding.componentId];
    if (component == null || animationLayer == null) return;

    // Get component position (would need to query the actual widget)
    final sourcePosition = Offset(100, 100); // Placeholder

    animationLayer!.addModulation(
      source: ModulationSource(
        id: binding.componentId,
        label: binding.componentId,
        type: ModulationSourceType.manual,
        position: sourcePosition,
      ),
      target: ModulationTarget(
        id: binding.parameterId,
        label: binding.parameterId,
        position: const Offset(200, 200), // Placeholder
      ),
      strength: binding.sensitivity,
    );
  }

  // ============================================================================
  // HAPTIC FEEDBACK
  // ============================================================================

  /// Trigger haptic feedback for component interaction
  void triggerHaptic(String componentId, HapticType type) {
    if (!enableHaptics) return;

    final component = _components[componentId];
    if (component == null) return;

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
    }

    _broadcastEvent(ComponentEvent(
      type: ComponentEventType.hapticTriggered,
      componentId: componentId,
      timestamp: DateTime.now(),
    ));
  }

  /// Trigger musical haptic feedback
  void triggerMusicalHaptic(String componentId, double noteFrequency) {
    if (!enableHaptics) return;

    HapticManager.musicalNote(noteFrequency);

    _broadcastEvent(ComponentEvent(
      type: ComponentEventType.hapticTriggered,
      componentId: componentId,
      value: noteFrequency,
      timestamp: DateTime.now(),
    ));
  }

  // ============================================================================
  // INTERACTION TRACKING
  // ============================================================================

  /// Track component interaction
  void trackInteraction(String componentId, InteractionType type) {
    final key = '$componentId:${type.name}';
    _interactionCounts[key] = (_interactionCounts[key] ?? 0) + 1;

    _broadcastEvent(ComponentEvent(
      type: ComponentEventType.interactionTracked,
      componentId: componentId,
      interactionType: type,
      timestamp: DateTime.now(),
    ));
  }

  /// Get interaction stats
  Map<String, dynamic> getInteractionStats() {
    final sessionDuration = DateTime.now().difference(_sessionStart);

    return {
      'sessionDuration': sessionDuration.inSeconds,
      'totalInteractions':
          _interactionCounts.values.fold(0, (sum, count) => sum + count),
      'componentCount': _components.length,
      'bindingCount': _bindings.length,
      'interactionBreakdown': Map.from(_interactionCounts),
    };
  }

  // ============================================================================
  // EVENT BROADCASTING
  // ============================================================================

  void _broadcastEvent(ComponentEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get current audio features
  AudioFeatures? getCurrentAudioFeatures() {
    // Would return the latest audio features
    return null; // Placeholder
  }

  /// Reset all components
  void resetAllComponents() {
    for (final component in _components.values) {
      _broadcastEvent(ComponentEvent(
        type: ComponentEventType.reset,
        componentId: component.id,
        timestamp: DateTime.now(),
      ));
    }
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'fps': animationLayer?.fps ?? 0.0,
      'activeParticles': animationLayer?.stats['particles'] ?? 0,
      'activeTrails': animationLayer?.stats['trails'] ?? 0,
      'activeModulations': animationLayer?.stats['modulations'] ?? 0,
      ..._interactionCounts,
    };
  }
}

// ============================================================================
// COMPONENT EVENT
// ============================================================================

/// Event broadcast by integration manager
class ComponentEvent {
  final ComponentEventType type;
  final String? componentId;
  final double? value;
  final AudioFeatures? audioFeatures;
  final InteractionType? interactionType;
  final DateTime timestamp;

  const ComponentEvent({
    required this.type,
    this.componentId,
    this.value,
    this.audioFeatures,
    this.interactionType,
    required this.timestamp,
  });
}

enum ComponentEventType {
  registered,
  unregistered,
  valueChanged,
  audioUpdate,
  hapticTriggered,
  interactionTracked,
  reset,
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
}

enum InteractionType {
  tap,
  longPress,
  drag,
  pinch,
  rotate,
  swipe,
}
