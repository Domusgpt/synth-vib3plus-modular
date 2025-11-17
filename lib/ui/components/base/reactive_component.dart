///
/// Reactive Component Base
///
/// Abstract base class for all audio-reactive UI components.
/// Provides unified state management, visual feedback, and
/// audio-driven modulation capabilities.
///
/// All components inherit from this to ensure consistent:
/// - Interaction states (idle, hover, pressed, dragging)
/// - Functional states (active, inactive, disabled, loading)
/// - Audio reactivity (real-time visual modulation)
/// - Visual encoding (color, glow, border, animation)
///
/// Part of the Next-Generation UI Redesign (v3.0)
///
/// A Paul Phillips Manifestation
///

library;

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../audio/audio_analyzer.dart';
import '../../theme/design_tokens.dart';

// ============================================================================
// COMPONENT STATE MODEL
// ============================================================================

/// Complete component state
class ComponentState {
  final InteractionState interaction;
  final FunctionalState functional;
  final AudioState audio;

  const ComponentState({
    this.interaction = InteractionState.idle,
    this.functional = FunctionalState.active,
    this.audio = AudioState.silent,
  });

  ComponentState copyWith({
    InteractionState? interaction,
    FunctionalState? functional,
    AudioState? audio,
  }) {
    return ComponentState(
      interaction: interaction ?? this.interaction,
      functional: functional ?? this.functional,
      audio: audio ?? this.audio,
    );
  }

  bool get isInteractive => functional != FunctionalState.disabled;
  bool get isActive => functional == FunctionalState.active;
  bool get hasAudio => audio != AudioState.silent;
}

// ============================================================================
// VISUAL CONFIGURATION
// ============================================================================

/// Visual styling configuration
class VisualStyle {
  final Color baseColor;
  final double borderRadius;
  final bool showGlow;
  final bool showBorder;
  final double glowIntensity;
  final GlassmorphicConfig? glassmorphism;

  const VisualStyle({
    this.baseColor = DesignTokens.stateActive,
    this.borderRadius = DesignTokens.radiusMedium,
    this.showGlow = true,
    this.showBorder = true,
    this.glowIntensity = 1.0,
    this.glassmorphism,
  });

  VisualStyle copyWith({
    Color? baseColor,
    double? borderRadius,
    bool? showGlow,
    bool? showBorder,
    double? glowIntensity,
    GlassmorphicConfig? glassmorphism,
  }) {
    return VisualStyle(
      baseColor: baseColor ?? this.baseColor,
      borderRadius: borderRadius ?? this.borderRadius,
      showGlow: showGlow ?? this.showGlow,
      showBorder: showBorder ?? this.showBorder,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      glassmorphism: glassmorphism ?? this.glassmorphism,
    );
  }
}

// ============================================================================
// AUDIO REACTIVITY CONFIGURATION
// ============================================================================

/// Audio reactivity configuration
class AudioReactivity {
  final bool enabled;
  final bool reactToRMS; // Amplitude
  final bool reactToSpectral; // Frequency content
  final bool reactToTransient; // Attack detection
  final bool reactToBass; // Low frequency
  final double sensitivity; // 0-2, 1=normal

  const AudioReactivity({
    this.enabled = false,
    this.reactToRMS = true,
    this.reactToSpectral = true,
    this.reactToTransient = true,
    this.reactToBass = true,
    this.sensitivity = 1.0,
  });

  /// All reactivity enabled preset
  static const all = AudioReactivity(
    enabled: true,
    reactToRMS: true,
    reactToSpectral: true,
    reactToTransient: true,
    reactToBass: true,
  );

  /// Minimal reactivity preset
  static const minimal = AudioReactivity(
    enabled: true,
    reactToRMS: true,
    reactToSpectral: false,
    reactToTransient: false,
    reactToBass: false,
  );

  /// Disabled
  static const none = AudioReactivity(enabled: false);
}

// ============================================================================
// BASE REACTIVE COMPONENT (Abstract)
// ============================================================================

/// Abstract base for all reactive UI components
abstract class ReactiveComponent extends StatefulWidget {
  final ComponentState initialState;
  final VisualStyle style;
  final AudioReactivity audioReactivity;
  final VoidCallback? onTap;
  final ValueChanged<Offset>? onDrag;
  final VoidCallback? onLongPress;
  final bool enabled;

  const ReactiveComponent({
    Key? key,
    this.initialState = const ComponentState(),
    this.style = const VisualStyle(),
    this.audioReactivity = AudioReactivity.none,
    this.onTap,
    this.onDrag,
    this.onLongPress,
    this.enabled = true,
  }) : super(key: key);
}

/// Base state for reactive components
abstract class ReactiveComponentState<T extends ReactiveComponent>
    extends State<T> with SingleTickerProviderStateMixin {
  // State tracking
  late ComponentState _state;
  AudioFeatures? _audioFeatures;

  // Animation controller for state transitions
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState.copyWith(
      functional:
          widget.enabled ? FunctionalState.active : FunctionalState.disabled,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: DesignTokens.standard,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      setState(() {
        _state = _state.copyWith(
          functional: widget.enabled
              ? FunctionalState.active
              : FunctionalState.disabled,
        );
      });
    }
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  /// Current component state
  ComponentState get state => _state;

  /// Update interaction state
  void setInteractionState(InteractionState interaction) {
    if (!mounted) return;
    setState(() {
      _state = _state.copyWith(interaction: interaction);
    });

    // Trigger animation on state change
    if (interaction == InteractionState.pressed ||
        interaction == InteractionState.hover) {
      _animationController.forward();
    } else if (interaction == InteractionState.idle) {
      _animationController.reverse();
    }
  }

  /// Update functional state
  void setFunctionalState(FunctionalState functional) {
    if (!mounted) return;
    setState(() {
      _state = _state.copyWith(functional: functional);
    });
  }

  /// Update audio state
  void setAudioState(AudioState audio) {
    if (!mounted) return;
    setState(() {
      _state = _state.copyWith(audio: audio);
    });
  }

  /// Update audio features
  void updateAudioFeatures(AudioFeatures features) {
    if (!mounted) return;
    if (!widget.audioReactivity.enabled) return;

    setState(() {
      _audioFeatures = features;

      // Update audio state based on RMS
      if (features.rms > 0.01) {
        _state = _state.copyWith(audio: AudioState.playing);
      } else {
        _state = _state.copyWith(audio: AudioState.silent);
      }
    });
  }

  // ============================================================================
  // VISUAL STATE ENCODING
  // ============================================================================

  /// Get color for current state
  Color getStateColor() {
    Color baseColor = widget.style.baseColor;

    // Apply functional state modulation
    baseColor = DesignTokens.getFunctionalColor(_state.functional, baseColor);

    // Apply interaction state modulation
    baseColor = DesignTokens.getInteractionColor(_state.interaction, baseColor);

    // Apply audio reactivity (hue shift)
    if (widget.audioReactivity.enabled &&
        widget.audioReactivity.reactToSpectral &&
        _audioFeatures != null) {
      final hueShift =
          DesignTokens.dominantFreqToHueShift(_audioFeatures!.dominantFreq);
      baseColor = DesignTokens.adjustHue(
          baseColor, hueShift * widget.audioReactivity.sensitivity);
    }

    return baseColor;
  }

  /// Get glow intensity for current state
  double getGlowIntensity() {
    double intensity = DesignTokens.getGlowIntensity(_state.interaction);

    // Add audio-reactive glow
    if (widget.audioReactivity.enabled &&
        widget.audioReactivity.reactToTransient &&
        _audioFeatures != null) {
      intensity += DesignTokens.transientToGlow(_audioFeatures!.transient) *
          widget.audioReactivity.sensitivity;
    }

    return intensity * widget.style.glowIntensity;
  }

  /// Get border width for current state
  double getBorderWidth({bool isSelected = false}) {
    double width =
        DesignTokens.getBorderWidth(_state.interaction, isSelected: isSelected);

    // Add audio-reactive width modulation
    if (widget.audioReactivity.enabled &&
        widget.audioReactivity.reactToBass &&
        _audioFeatures != null) {
      width = DesignTokens.bassEnergyToBorderWidth(_audioFeatures!.bassEnergy) *
          widget.audioReactivity.sensitivity;
    }

    return width;
  }

  /// Get border style decoration
  BoxDecoration getBorderDecoration({bool isSelected = false}) {
    final color = getStateColor();
    final glowIntensity = getGlowIntensity();
    final borderWidth = getBorderWidth(isSelected: isSelected);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(widget.style.borderRadius),
      border: widget.style.showBorder
          ? Border.all(color: color, width: borderWidth)
          : null,
      boxShadow: widget.style.showGlow && glowIntensity > 0
          ? [
              BoxShadow(
                color: color.withValues(alpha: glowIntensity / 10),
                blurRadius: glowIntensity,
                spreadRadius: glowIntensity / 2,
              ),
            ]
          : null,
    );
  }

  /// Get current animation value
  Animation<double> getAnimation() => _animation;

  // ============================================================================
  // GESTURE HANDLING
  // ============================================================================

  /// Handle tap down
  void handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setInteractionState(InteractionState.pressed);
  }

  /// Handle tap up
  void handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setInteractionState(InteractionState.released);

    // Trigger callback after brief delay
    Future.delayed(DesignTokens.micro, () {
      if (mounted) {
        setInteractionState(InteractionState.idle);
        widget.onTap?.call();
      }
    });
  }

  /// Handle tap cancel
  void handleTapCancel() {
    if (!widget.enabled) return;
    setInteractionState(InteractionState.idle);
  }

  /// Handle long press
  void handleLongPress() {
    if (!widget.enabled) return;
    widget.onLongPress?.call();
  }

  /// Handle pan start
  void handlePanStart(DragStartDetails details) {
    if (!widget.enabled || widget.onDrag == null) return;
    setInteractionState(InteractionState.dragging);
  }

  /// Handle pan update
  void handlePanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || widget.onDrag == null) return;
    widget.onDrag?.call(details.localPosition);
  }

  /// Handle pan end
  void handlePanEnd(DragEndDetails details) {
    if (!widget.enabled || widget.onDrag == null) return;
    setInteractionState(InteractionState.idle);
  }

  // ============================================================================
  // ABSTRACT METHODS (implement in subclasses)
  // ============================================================================

  /// Build the component's content
  Widget buildContent(BuildContext context);

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: handleTapDown,
      onTapUp: handleTapUp,
      onTapCancel: handleTapCancel,
      onLongPress: widget.onLongPress != null ? handleLongPress : null,
      onPanStart: widget.onDrag != null ? handlePanStart : null,
      onPanUpdate: widget.onDrag != null ? handlePanUpdate : null,
      onPanEnd: widget.onDrag != null ? handlePanEnd : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => buildContent(context),
      ),
    );
  }
}

// ============================================================================
// AUDIO-REACTIVE MIXIN
// ============================================================================

/// Mixin for components that need audio stream updates
mixin AudioReactiveMixin<T extends ReactiveComponent>
    on ReactiveComponentState<T> {
  StreamSubscription<AudioFeatures>? _audioSubscription;

  /// Subscribe to audio features stream
  void subscribeToAudio(Stream<AudioFeatures> audioStream) {
    _audioSubscription?.cancel();
    _audioSubscription = audioStream.listen((features) {
      updateAudioFeatures(features);
    });
  }

  /// Unsubscribe from audio stream
  void unsubscribeFromAudio() {
    _audioSubscription?.cancel();
    _audioSubscription = null;
  }

  @override
  void dispose() {
    unsubscribeFromAudio();
    super.dispose();
  }
}

// ============================================================================
// HELPER EXTENSIONS
// ============================================================================

extension ComponentStateExtension on ComponentState {
  /// Check if component should respond to interaction
  bool get shouldRespondToTouch =>
      functional == FunctionalState.active ||
      functional == FunctionalState.inactive;

  /// Check if component is in pressed state
  bool get isPressed => interaction == InteractionState.pressed;

  /// Check if component is being dragged
  bool get isDragging => interaction == InteractionState.dragging;

  /// Check if component has active audio
  bool get hasActiveAudio =>
      audio == AudioState.playing || audio == AudioState.modulating;
}
