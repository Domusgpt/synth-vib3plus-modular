/**
 * Quaternion Utilities for VIB34D XR Spatial Computing
 *
 * Advanced quaternion mathematics for 4D rotations and spatial transformations.
 * Integrated from vib34d-vib3plus repository for proper quaternion handling.
 *
 * A Paul Phillips Manifestation
 * © 2025 Clear Seas Solutions LLC
 */

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

/// Utility class for quaternion operations used in XR spatial computing
class QuaternionUtils {
  /// Normalize a quaternion to unit length
  ///
  /// Returns null if the input is null or has zero length
  static Quaternion? normalize(Quaternion? q) {
    if (q == null) return null;

    final length = q.length;
    if (length == 0.0) return null;

    return Quaternion(
      q.x / length,
      q.y / length,
      q.z / length,
      q.w / length,
    );
  }

  /// Convert quaternion to Euler angles (roll, pitch, yaw)
  static EulerAngles toEuler(Quaternion q) {
    // Roll (x-axis rotation)
    final sinr_cosp = 2.0 * (q.w * q.x + q.y * q.z);
    final cosr_cosp = 1.0 - 2.0 * (q.x * q.x + q.y * q.y);
    final roll = math.atan2(sinr_cosp, cosr_cosp);

    // Pitch (y-axis rotation)
    final sinp = 2.0 * (q.w * q.y - q.z * q.x);
    final pitch = sinp.abs() >= 1.0
        ? (sinp >= 0 ? math.pi / 2 : -math.pi / 2) // Use 90 degrees if out of range
        : math.asin(sinp);

    // Yaw (z-axis rotation)
    final siny_cosp = 2.0 * (q.w * q.z + q.x * q.y);
    final cosy_cosp = 1.0 - 2.0 * (q.y * q.y + q.z * q.z);
    final yaw = math.atan2(siny_cosp, cosy_cosp);

    return EulerAngles(roll: roll, pitch: pitch, yaw: yaw);
  }

  /// Multiply two quaternions (combine rotations)
  static Quaternion multiply(Quaternion q1, Quaternion q2) {
    return Quaternion(
      q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
      q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x,
      q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w,
      q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z,
    );
  }

  /// Get the conjugate of a quaternion (inverse rotation)
  static Quaternion conjugate(Quaternion q) {
    return Quaternion(-q.x, -q.y, -q.z, q.w);
  }

  /// Calculate angular velocity between two quaternions
  ///
  /// Returns the rotation speed in radians per second
  static double angularVelocity(Quaternion q1, Quaternion q2, double deltaTime) {
    if (deltaTime == 0.0) return 0.0;

    final diff = multiply(conjugate(q1), q2);
    final angle = 2.0 * math.acos(diff.w.clamp(-1.0, 1.0));

    return angle / deltaTime;
  }

  /// Linear interpolation between two quaternions
  static Quaternion lerp(Quaternion q1, Quaternion q2, double t) {
    final clampedT = t.clamp(0.0, 1.0);

    return Quaternion(
      q1.x + (q2.x - q1.x) * clampedT,
      q1.y + (q2.y - q1.y) * clampedT,
      q1.z + (q2.z - q1.z) * clampedT,
      q1.w + (q2.w - q1.w) * clampedT,
    );
  }

  /// Spherical linear interpolation between two quaternions
  ///
  /// Provides smooth rotational transitions for animation
  static Quaternion slerp(Quaternion q1, Quaternion q2, double t) {
    final clampedT = t.clamp(0.0, 1.0);

    // Calculate dot product
    var dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w;

    // If negative dot, negate one quaternion to take shorter path
    var q2b = q2;
    if (dot < 0.0) {
      dot = -dot;
      q2b = Quaternion(-q2.x, -q2.y, -q2.z, -q2.w);
    }

    // If quaternions are very close, use linear interpolation
    if (dot > 0.9995) {
      return normalize(lerp(q1, q2b, clampedT))!;
    }

    // Calculate interpolation
    final theta = math.acos(dot);
    final sinTheta = math.sin(theta);
    final weight1 = math.sin((1.0 - clampedT) * theta) / sinTheta;
    final weight2 = math.sin(clampedT * theta) / sinTheta;

    return Quaternion(
      q1.x * weight1 + q2b.x * weight2,
      q1.y * weight1 + q2b.y * weight2,
      q1.z * weight1 + q2b.z * weight2,
      q1.w * weight1 + q2b.w * weight2,
    );
  }

  /// Create a quaternion from axis and angle
  static Quaternion fromAxisAngle(Vector3 axis, double angle) {
    final halfAngle = angle / 2.0;
    final s = math.sin(halfAngle);
    final normalizedAxis = axis.normalized();

    return Quaternion(
      normalizedAxis.x * s,
      normalizedAxis.y * s,
      normalizedAxis.z * s,
      math.cos(halfAngle),
    );
  }

  /// Create a quaternion from Euler angles (roll, pitch, yaw)
  static Quaternion fromEuler(double roll, double pitch, double yaw) {
    final cy = math.cos(yaw * 0.5);
    final sy = math.sin(yaw * 0.5);
    final cp = math.cos(pitch * 0.5);
    final sp = math.sin(pitch * 0.5);
    final cr = math.cos(roll * 0.5);
    final sr = math.sin(roll * 0.5);

    return Quaternion(
      sr * cp * cy - cr * sp * sy,
      cr * sp * cy + sr * cp * sy,
      cr * cp * sy - sr * sp * cy,
      cr * cp * cy + sr * sp * sy,
    );
  }
}

/// Euler angles representation (roll, pitch, yaw)
class EulerAngles {
  final double roll;   // Rotation around X axis (radians)
  final double pitch;  // Rotation around Y axis (radians)
  final double yaw;    // Rotation around Z axis (radians)

  const EulerAngles({
    required this.roll,
    required this.pitch,
    required this.yaw,
  });

  /// Convert to degrees
  EulerAngles toDegrees() {
    return EulerAngles(
      roll: roll * 180.0 / math.pi,
      pitch: pitch * 180.0 / math.pi,
      yaw: yaw * 180.0 / math.pi,
    );
  }

  @override
  String toString() {
    return 'EulerAngles(roll: ${roll.toStringAsFixed(3)}, '
           'pitch: ${pitch.toStringAsFixed(3)}, '
           'yaw: ${yaw.toStringAsFixed(3)})';
  }
}
