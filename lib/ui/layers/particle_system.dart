///
/// Particle System
///
/// Audio-reactive particle effects for touch interactions and
/// musical events. Particles spawn on note triggers, respond to
/// audio features, and create dynamic visual feedback.
///
/// Features:
/// - Object pooling (efficient memory management)
/// - Audio-reactive size/color/movement
/// - Multiple particle types (note, burst, ambient)
/// - Batch rendering for performance
///
/// Part of the Next-Generation UI Redesign (v3.0)
///
/// A Paul Phillips Manifestation
////

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../effects/glassmorphic_container.dart';

// ============================================================================
// PARTICLE MODEL
// ============================================================================

/// Single particle instance
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifetime; // Remaining lifetime in seconds
  double maxLifetime; // Initial lifetime
  double opacity;
  double rotation;
  double rotationSpeed;
  ParticleType type;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifetime,
    required this.type,
  })  : maxLifetime = lifetime,
        opacity = 1.0,
        rotation = 0.0,
        rotationSpeed = 0.0;

  /// Create particle from note trigger
  factory Particle.fromNote({
    required Offset position,
    required double frequency,
    required double velocity,
  }) {
    // Map frequency to hue (0-8000 Hz → 0-360°)
    final hue = (frequency / 8000.0).clamp(0.0, 1.0) * 360.0;
    final color = HSLColor.fromAHSL(1.0, hue, 0.8, 0.5).toColor();

    // Map velocity to size and speed
    final size = 2.0 + (velocity * 8.0); // 2-10px
    final speed = 50.0 + (velocity * 150.0); // 50-200 px/s

    // Random direction
    final angle = math.Random().nextDouble() * math.pi * 2;
    final velocityVector = Offset(
      math.cos(angle) * speed,
      math.sin(angle) * speed,
    );

    return Particle(
      position: position,
      velocity: velocityVector,
      color: color,
      size: size,
      lifetime: 1.0 + (velocity * 1.0), // 1-2 seconds
      type: ParticleType.note,
    )..rotationSpeed = (math.Random().nextDouble() - 0.5) * 4.0;
  }

  /// Create burst particle (multiple particles at once)
  factory Particle.fromBurst({
    required Offset position,
    required Color color,
    required double intensity,
  }) {
    final random = math.Random();
    final angle = random.nextDouble() * math.pi * 2;
    final speed = 100.0 + (intensity * 200.0);

    return Particle(
      position: position,
      velocity: Offset(
        math.cos(angle) * speed,
        math.sin(angle) * speed,
      ),
      color: color,
      size: 3.0 + (intensity * 7.0),
      lifetime: 0.5 + (intensity * 0.5),
      type: ParticleType.burst,
    );
  }

  /// Create ambient particle (background atmosphere)
  factory Particle.ambient({
    required Offset position,
    required Color color,
  }) {
    final random = math.Random();
    return Particle(
      position: position,
      velocity: Offset(
        (random.nextDouble() - 0.5) * 20.0,
        -20.0 - (random.nextDouble() * 30.0), // Float upward
      ),
      color: color,
      size: 1.0 + (random.nextDouble() * 3.0),
      lifetime: 3.0 + (random.nextDouble() * 2.0),
      type: ParticleType.ambient,
    );
  }

  /// Update particle physics
  void update(double dt, {AudioFeatures? audioFeatures}) {
    // Update position
    position += velocity * dt;

    // Apply drag
    velocity *= math.pow(0.95, dt * 60).toDouble(); // Frame-independent

    // Update rotation
    rotation += rotationSpeed * dt;

    // Update lifetime
    lifetime -= dt;

    // Update opacity (fade out)
    opacity = (lifetime / maxLifetime).clamp(0.0, 1.0);

    // Shrink over time
    size *= math.pow(0.98, dt * 60);

    // Audio reactivity
    if (audioFeatures != null && type == ParticleType.note) {
      // Pulse with RMS
      final pulse = 1.0 + (audioFeatures.rms * 0.5);
      size *= pulse;

      // Hue shift with dominant frequency
      final hueShift =
          DesignTokens.dominantFreqToHueShift(audioFeatures.dominantFreq);
      color = DesignTokens.adjustHue(color, hueShift * dt * 60);
    }
  }

  /// Check if particle is dead
  bool get isDead => lifetime <= 0 || size < 0.5;

  /// Reset particle for reuse (object pooling)
  void reset() {
    position = Offset.zero;
    velocity = Offset.zero;
    color = Colors.white;
    size = 0.0;
    lifetime = 0.0;
    maxLifetime = 0.0;
    opacity = 1.0;
    rotation = 0.0;
    rotationSpeed = 0.0;
  }
}

/// Particle type
enum ParticleType {
  note, // Musical note trigger
  burst, // Explosion/impact
  ambient, // Background atmosphere
}

// ============================================================================
// PARTICLE SYSTEM
// ============================================================================

/// Manages particle lifecycle and rendering
class ParticleSystem {
  // Object pool for efficient memory management
  final List<Particle> _pool = [];
  final List<Particle> _active = [];

  // Configuration
  int maxParticles;
  bool enabled;

  ParticleSystem({
    this.maxParticles = 500,
    this.enabled = true,
  }) {
    // Pre-allocate particle pool
    for (int i = 0; i < maxParticles; i++) {
      _pool.add(Particle(
        position: Offset.zero,
        velocity: Offset.zero,
        color: Colors.white,
        size: 0,
        lifetime: 0,
        type: ParticleType.ambient,
      ));
    }
  }

  // ============================================================================
  // PARTICLE SPAWNING
  // ============================================================================

  /// Spawn particle from note trigger
  void spawnNote({
    required Offset position,
    required double frequency,
    required double velocity,
  }) {
    if (!enabled) return;

    final particle = _getParticle();
    if (particle == null) return;

    final newParticle = Particle.fromNote(
      position: position,
      frequency: frequency,
      velocity: velocity,
    );

    // Copy properties
    particle.position = newParticle.position;
    particle.velocity = newParticle.velocity;
    particle.color = newParticle.color;
    particle.size = newParticle.size;
    particle.lifetime = newParticle.lifetime;
    particle.maxLifetime = newParticle.maxLifetime;
    particle.type = newParticle.type;
    particle.rotationSpeed = newParticle.rotationSpeed;
  }

  /// Spawn burst of particles
  void spawnBurst({
    required Offset position,
    required Color color,
    required double intensity,
    int count = 10,
  }) {
    if (!enabled) return;

    for (int i = 0; i < count; i++) {
      final particle = _getParticle();
      if (particle == null) break;

      final newParticle = Particle.fromBurst(
        position: position,
        color: color,
        intensity: intensity,
      );

      particle.position = newParticle.position;
      particle.velocity = newParticle.velocity;
      particle.color = newParticle.color;
      particle.size = newParticle.size;
      particle.lifetime = newParticle.lifetime;
      particle.maxLifetime = newParticle.maxLifetime;
      particle.type = newParticle.type;
    }
  }

  /// Spawn ambient particle
  void spawnAmbient({
    required Offset position,
    required Color color,
  }) {
    if (!enabled) return;

    final particle = _getParticle();
    if (particle == null) return;

    final newParticle = Particle.ambient(
      position: position,
      color: color,
    );

    particle.position = newParticle.position;
    particle.velocity = newParticle.velocity;
    particle.color = newParticle.color;
    particle.size = newParticle.size;
    particle.lifetime = newParticle.lifetime;
    particle.maxLifetime = newParticle.maxLifetime;
    particle.type = newParticle.type;
  }

  // ============================================================================
  // UPDATE & RENDERING
  // ============================================================================

  /// Update all active particles
  void update(double dt, {AudioFeatures? audioFeatures}) {
    if (!enabled) return;

    // Update all active particles
    for (int i = _active.length - 1; i >= 0; i--) {
      final particle = _active[i];
      particle.update(dt, audioFeatures: audioFeatures);

      // Recycle dead particles
      if (particle.isDead) {
        _recycleParticle(particle);
        _active.removeAt(i);
      }
    }
  }

  /// Render all particles
  void paint(Canvas canvas, Size size) {
    if (!enabled || _active.isEmpty) return;

    // Group particles by type for batch rendering
    final Map<ParticleType, List<Particle>> batches = {};
    for (final particle in _active) {
      batches.putIfAbsent(particle.type, () => []).add(particle);
    }

    // Render each batch
    for (final entry in batches.entries) {
      _paintBatch(canvas, entry.value);
    }
  }

  /// Paint a batch of similar particles
  void _paintBatch(Canvas canvas, List<Particle> particles) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size / 2);

      // Rotate canvas for this particle
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      // Draw particle
      canvas.drawCircle(Offset.zero, particle.size, paint);

      canvas.restore();
    }
  }

  // ============================================================================
  // OBJECT POOLING
  // ============================================================================

  /// Get particle from pool
  Particle? _getParticle() {
    if (_active.length >= maxParticles) {
      // Pool exhausted, remove oldest particle
      final oldest = _active.removeAt(0);
      _recycleParticle(oldest);
    }

    if (_pool.isEmpty) return null;

    final particle = _pool.removeLast();
    _active.add(particle);
    return particle;
  }

  /// Recycle particle back to pool
  void _recycleParticle(Particle particle) {
    particle.reset();
    if (!_pool.contains(particle)) {
      _pool.add(particle);
    }
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Get active particle count
  int get activeCount => _active.length;

  /// Get pool size
  int get poolSize => _pool.length;

  /// Clear all particles
  void clear() {
    for (final particle in _active) {
      _recycleParticle(particle);
    }
    _active.clear();
  }

  /// Set enabled state
  void setEnabled(bool value) {
    enabled = value;
    if (!enabled) {
      clear();
    }
  }

  /// Dispose of particle system
  void dispose() {
    clear();
    _pool.clear();
  }
}
