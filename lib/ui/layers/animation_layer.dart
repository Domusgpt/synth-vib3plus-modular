/**
 * Animation Layer
 *
 * Unified animation and visual effects layer that sits on top of
 * the VIB3+ visualization. Coordinates particles, trails, and
 * modulation visualization with 60 FPS updates.
 *
 * Features:
 * - 60 FPS update loop
 * - Integrated particle, trail, and modulation systems
 * - Audio-reactive effects
 * - Performance optimization
 * - Layered z-index rendering
 *
 * Part of the Next-Generation UI Redesign (v3.0)
 *
 * A Paul Phillips Manifestation
 */

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/design_tokens.dart';
import '../effects/glassmorphic_container.dart';
import 'particle_system.dart';
import 'trail_system.dart';
import 'modulation_visualizer.dart';

// ============================================================================
// ANIMATION LAYER CONFIGURATION
// ============================================================================

/// Configuration for animation layer
class AnimationLayerConfig {
  final bool enableParticles;
  final bool enableTrails;
  final bool enableModulationViz;
  final double intensity; // 0-1, scales all effects
  final bool audioReactive; // Enable audio reactivity
  final int maxParticles;
  final double trailLength;
  final double trailFadeTime;

  const AnimationLayerConfig({
    this.enableParticles = true,
    this.enableTrails = true,
    this.enableModulationViz = true,
    this.intensity = 1.0,
    this.audioReactive = true,
    this.maxParticles = 500,
    this.trailLength = 50,
    this.trailFadeTime = 2.0,
  });

  /// Performance mode (reduced effects)
  static const performance = AnimationLayerConfig(
    enableParticles: true,
    enableTrails: true,
    enableModulationViz: false,
    intensity: 0.7,
    maxParticles: 200,
    trailLength: 30,
    trailFadeTime = 1.5,
  );

  /// Full quality mode
  static const full = AnimationLayerConfig(
    enableParticles: true,
    enableTrails: true,
    enableModulationViz: true,
    intensity: 1.0,
    maxParticles: 500,
    trailLength: 50,
    trailFadeTime: 2.0,
  );

  /// Minimal mode (trails only)
  static const minimal = AnimationLayerConfig(
    enableParticles: false,
    enableTrails: true,
    enableModulationViz: false,
    intensity: 0.5,
    maxParticles: 0,
    trailLength: 30,
    trailFadeTime: 1.0,
  );
}

// ============================================================================
// ANIMATION LAYER WIDGET
// ============================================================================

/// Overlay widget that renders animation effects
class AnimationLayer extends StatefulWidget {
  final AnimationLayerConfig config;
  final Stream<AudioFeatures>? audioStream;
  final Widget? child; // Optional child widget (background)

  const AnimationLayer({
    Key? key,
    this.config = AnimationLayerConfig.full,
    this.audioStream,
    this.child,
  }) : super(key: key);

  @override
  State<AnimationLayer> createState() => AnimationLayerState();
}

class AnimationLayerState extends State<AnimationLayer> with SingleTickerProviderStateMixin {
  // Effect systems
  late ParticleSystem _particleSystem;
  late TrailSystem _trailSystem;
  late ModulationVisualizer _modulationViz;

  // Audio features
  AudioFeatures? _audioFeatures;
  StreamSubscription<AudioFeatures>? _audioSubscription;

  // Ticker for 60 FPS updates
  late Ticker _ticker;
  Duration _lastFrameTime = Duration.zero;

  // Performance tracking
  int _frameCount = 0;
  double _fps = 60.0;
  DateTime _lastFpsUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize systems
    _particleSystem = ParticleSystem(
      maxParticles: widget.config.maxParticles,
      enabled: widget.config.enableParticles,
    );

    _trailSystem = TrailSystem(
      maxLength: widget.config.trailLength,
      fadeTime: widget.config.trailFadeTime,
      enabled: widget.config.enableTrails,
      smoothRendering: true,
    );

    _modulationViz = ModulationVisualizer(
      enabled: widget.config.enableModulationViz,
      showLabels: true,
      showParticles: true,
    );

    // Start 60 FPS ticker
    _ticker = createTicker(_onTick)..start();

    // Subscribe to audio stream
    if (widget.audioStream != null && widget.config.audioReactive) {
      _audioSubscription = widget.audioStream!.listen((features) {
        if (mounted) {
          setState(() {
            _audioFeatures = features;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioSubscription?.cancel();
    _particleSystem.dispose();
    _trailSystem.dispose();
    _modulationViz.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimationLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update system configurations
    _particleSystem.setEnabled(widget.config.enableParticles);
    _trailSystem.setEnabled(widget.config.enableTrails);
    _modulationViz.setEnabled(widget.config.enableModulationViz);

    // Update audio subscription
    if (widget.audioStream != oldWidget.audioStream) {
      _audioSubscription?.cancel();
      if (widget.audioStream != null && widget.config.audioReactive) {
        _audioSubscription = widget.audioStream!.listen((features) {
          if (mounted) {
            setState(() {
              _audioFeatures = features;
            });
          }
        });
      }
    }
  }

  // ============================================================================
  // UPDATE LOOP (60 FPS)
  // ============================================================================

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    // Calculate delta time
    final dt = _lastFrameTime == Duration.zero
        ? 0.016 // ~60 FPS
        : (elapsed - _lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = elapsed;

    // Update systems
    _particleSystem.update(dt, audioFeatures: _audioFeatures);
    _trailSystem.update(dt, audioFeatures: _audioFeatures);
    _modulationViz.update(dt, audioFeatures: _audioFeatures);

    // Track FPS
    _updateFPS();

    // Trigger repaint
    if (mounted) {
      setState(() {});
    }
  }

  void _updateFPS() {
    _frameCount++;

    final now = DateTime.now();
    final elapsed = now.difference(_lastFpsUpdate).inMilliseconds;

    if (elapsed >= 1000) {
      // Update every second
      _fps = _frameCount / (elapsed / 1000.0);
      _frameCount = 0;
      _lastFpsUpdate = now;
    }
  }

  // ============================================================================
  // PUBLIC API (for external systems to trigger effects)
  // ============================================================================

  /// Spawn particle on note trigger
  void spawnNoteParticle({
    required Offset position,
    required double frequency,
    required double velocity,
  }) {
    _particleSystem.spawnNote(
      position: position,
      frequency: frequency,
      velocity: velocity,
    );
  }

  /// Spawn burst of particles
  void spawnBurst({
    required Offset position,
    required Color color,
    double intensity = 1.0,
    int count = 10,
  }) {
    _particleSystem.spawnBurst(
      position: position,
      color: color,
      intensity: intensity * widget.config.intensity,
      count: count,
    );
  }

  /// Add point to trail
  void addTrailPoint(int pointerId, Offset position, {double pressure = 1.0}) {
    _trailSystem.addPoint(pointerId, position, pressure: pressure);
  }

  /// Remove trail
  void removeTrail(int pointerId) {
    _trailSystem.removeTrail(pointerId);
  }

  /// Add modulation connection
  void addModulation({
    required ModulationSource source,
    required ModulationTarget target,
    double strength = 0.5,
  }) {
    _modulationViz.addConnection(ModulationConnection(
      source: source,
      target: target,
      strength: strength,
    ));
  }

  /// Remove modulation connection
  void removeModulation(String sourceId, String targetId) {
    _modulationViz.removeConnection(sourceId, targetId);
  }

  /// Update modulation strength
  void updateModulation(String sourceId, String targetId, double strength) {
    _modulationViz.updateStrength(sourceId, targetId, strength);
  }

  /// Get current FPS
  double get fps => _fps;

  /// Get performance stats
  Map<String, dynamic> get stats => {
        'fps': _fps,
        'particles': _particleSystem.activeCount,
        'trails': _trailSystem.activeCount,
        'trailPoints': _trailSystem.totalPoints,
        'modulations': _modulationViz.activeCount,
      };

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background child (e.g., VIB3+ visualization)
        if (widget.child != null) widget.child!,

        // Animation canvas
        Positioned.fill(
          child: CustomPaint(
            painter: _AnimationPainter(
              particleSystem: _particleSystem,
              trailSystem: _trailSystem,
              modulationViz: _modulationViz,
              audioFeatures: _audioFeatures,
              intensity: widget.config.intensity,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CUSTOM PAINTER
// ============================================================================

/// Custom painter for animation effects
class _AnimationPainter extends CustomPainter {
  final ParticleSystem particleSystem;
  final TrailSystem trailSystem;
  final ModulationVisualizer modulationViz;
  final AudioFeatures? audioFeatures;
  final double intensity;

  _AnimationPainter({
    required this.particleSystem,
    required this.trailSystem,
    required this.modulationViz,
    this.audioFeatures,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Render in layered order (back to front):
    // 1. Modulation lines (background)
    // 2. Trails (middle)
    // 3. Particles (foreground)

    // Layer 1: Modulation visualization
    modulationViz.paint(canvas, size, audioFeatures: audioFeatures);

    // Layer 2: Touch trails
    trailSystem.paint(canvas, audioFeatures: audioFeatures);

    // Layer 3: Particles
    particleSystem.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_AnimationPainter oldDelegate) {
    // Always repaint (60 FPS updates)
    return true;
  }
}

// ============================================================================
// HELPER EXTENSIONS
// ============================================================================

/// Extension to easily access animation layer from context
extension AnimationLayerContext on BuildContext {
  /// Get animation layer state (if available)
  AnimationLayerState? get animationLayer {
    return findAncestorStateOfType<AnimationLayerState>();
  }
}

/// Gesture detector that integrates with animation layer
class AnimatedGestureDetector extends StatelessWidget {
  final Widget child;
  final Function(Offset)? onTapDown;
  final Function(int, Offset, double)? onPanUpdate; // pointerId, position, pressure
  final Function(int)? onPanEnd;
  final Color? trailColor;
  final bool spawnParticlesOnTap;

  const AnimatedGestureDetector({
    Key? key,
    required this.child,
    this.onTapDown,
    this.onPanUpdate,
    this.onPanEnd,
    this.trailColor,
    this.spawnParticlesOnTap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationLayer = context.animationLayer;

    return GestureDetector(
      onTapDown: (details) {
        onTapDown?.call(details.localPosition);

        if (spawnParticlesOnTap && animationLayer != null) {
          animationLayer.spawnBurst(
            position: details.localPosition,
            color: trailColor ?? DesignTokens.stateActive,
            intensity: 0.7,
            count: 5,
          );
        }
      },
      onPanStart: (details) {
        if (animationLayer != null && trailColor != null) {
          animationLayer._trailSystem.setColor(trailColor!);
        }
      },
      onPanUpdate: (details) {
        final pointerId = details.hashCode; // Use hash as pointer ID
        onPanUpdate?.call(pointerId, details.localPosition, 1.0);

        if (animationLayer != null) {
          animationLayer.addTrailPoint(pointerId, details.localPosition, pressure: 1.0);
        }
      },
      onPanEnd: (details) {
        final pointerId = details.hashCode;
        onPanEnd?.call(pointerId);

        if (animationLayer != null) {
          animationLayer.removeTrail(pointerId);
        }
      },
      child: child,
    );
  }
}
