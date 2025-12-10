/**
 * Professional Logging Service
 *
 * Provides leveled logging with compile-time optimization and
 * runtime configuration for production builds.
 *
 * Log Levels (in order of severity):
 * - TRACE: Detailed diagnostic information for debugging
 * - DEBUG: General debugging messages
 * - INFO: Informational messages about application state
 * - WARN: Warning messages for potentially problematic situations
 * - ERROR: Error messages for failures that don't crash the app
 * - FATAL: Critical errors that may crash the app
 *
 * Usage:
 * ```dart
 * Log.info('System', 'Audio engine initialized');
 * Log.error('AudioProvider', 'Failed to start playback', error: e);
 * Log.debug('ParameterBridge', 'Updated rotation: $value');
 * ```
 *
 * Configuration (in main.dart):
 * ```dart
 * void main() {
 *   // Development: Show all logs
 *   Log.configure(minLevel: LogLevel.trace);
 *
 *   // Production: Only show warnings and errors
 *   Log.configure(minLevel: LogLevel.warn, enableTimestamps: false);
 * }
 * ```
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/foundation.dart';

/// Log severity levels
enum LogLevel {
  trace(0, 'TRACE', '🔍'),
  debug(1, 'DEBUG', '🐛'),
  info(2, 'INFO ', '💡'),
  warn(3, 'WARN ', '⚠️'),
  error(4, 'ERROR', '❌'),
  fatal(5, 'FATAL', '💥');

  final int severity;
  final String label;
  final String emoji;

  const LogLevel(this.severity, this.label, this.emoji);

  bool operator >=(LogLevel other) => severity >= other.severity;
  bool operator >(LogLevel other) => severity > other.severity;
  bool operator <=(LogLevel other) => severity <= other.severity;
  bool operator <(LogLevel other) => severity < other.severity;
}

/// Central logging service
class Log {
  // Configuration
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.warn;
  static bool _enableTimestamps = kDebugMode;
  static bool _enableEmojis = true;
  static bool _enableColors = kDebugMode;
  static int _maxTagLength = 20;

  // Statistics (for diagnostics)
  static int _traceCount = 0;
  static int _debugCount = 0;
  static int _infoCount = 0;
  static int _warnCount = 0;
  static int _errorCount = 0;
  static int _fatalCount = 0;

  /// Configure the logging system
  static void configure({
    LogLevel? minLevel,
    bool? enableTimestamps,
    bool? enableEmojis,
    bool? enableColors,
    int? maxTagLength,
  }) {
    if (minLevel != null) _minLevel = minLevel;
    if (enableTimestamps != null) _enableTimestamps = enableTimestamps;
    if (enableEmojis != null) _enableEmojis = enableEmojis;
    if (enableColors != null) _enableColors = enableColors;
    if (maxTagLength != null) _maxTagLength = maxTagLength;
  }

  /// Reset all counters (useful for testing)
  static void resetCounters() {
    _traceCount = 0;
    _debugCount = 0;
    _infoCount = 0;
    _warnCount = 0;
    _errorCount = 0;
    _fatalCount = 0;
  }

  /// Get logging statistics
  static Map<String, int> getStatistics() {
    return {
      'trace': _traceCount,
      'debug': _debugCount,
      'info': _infoCount,
      'warn': _warnCount,
      'error': _errorCount,
      'fatal': _fatalCount,
      'total': _traceCount + _debugCount + _infoCount + _warnCount + _errorCount + _fatalCount,
    };
  }

  // ============================================================================
  // PUBLIC LOGGING METHODS
  // ============================================================================

  /// Log at TRACE level (most verbose)
  static void trace(String tag, String message, {Object? data}) {
    _log(LogLevel.trace, tag, message, data: data);
    _traceCount++;
  }

  /// Log at DEBUG level
  static void debug(String tag, String message, {Object? data}) {
    _log(LogLevel.debug, tag, message, data: data);
    _debugCount++;
  }

  /// Log at INFO level
  static void info(String tag, String message, {Object? data}) {
    _log(LogLevel.info, tag, message, data: data);
    _infoCount++;
  }

  /// Log at WARN level
  static void warn(String tag, String message, {Object? data}) {
    _log(LogLevel.warn, tag, message, data: data);
    _warnCount++;
  }

  /// Log at ERROR level
  static void error(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, tag, message, data: error);
    if (stackTrace != null && _minLevel <= LogLevel.debug) {
      debugPrint('Stack trace:\n$stackTrace');
    }
    _errorCount++;
  }

  /// Log at FATAL level (most severe)
  static void fatal(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, tag, message, data: error);
    if (stackTrace != null) {
      debugPrint('Stack trace:\n$stackTrace');
    }
    _fatalCount++;
  }

  // ============================================================================
  // SPECIALIZED LOGGING METHODS
  // ============================================================================

  /// Log performance metrics
  static void performance(String tag, String operation, int durationMs) {
    if (_minLevel <= LogLevel.debug) {
      final emoji = durationMs < 16 ? '⚡' : durationMs < 100 ? '⏱️' : '🐌';
      debug(tag, '$emoji $operation completed in ${durationMs}ms');
    }
  }

  /// Log audio events
  static void audio(String event, {int? noteNumber, double? value}) {
    if (_minLevel <= LogLevel.info) {
      String message = event;
      if (noteNumber != null) message += ' (Note: $noteNumber)';
      if (value != null) message += ' (Value: ${value.toStringAsFixed(2)})';
      info('Audio', message);
    }
  }

  /// Log visual events
  static void visual(String event, {String? system, int? geometry}) {
    if (_minLevel <= LogLevel.info) {
      String message = event;
      if (system != null) message += ' (System: $system)';
      if (geometry != null) message += ' (Geometry: $geometry)';
      info('Visual', message);
    }
  }

  /// Log parameter changes
  static void parameter(String name, dynamic value) {
    if (_minLevel <= LogLevel.debug) {
      String valueStr = value is double
          ? value.toStringAsFixed(3)
          : value.toString();
      debug('Parameter', '$name = $valueStr');
    }
  }

  // ============================================================================
  // INTERNAL IMPLEMENTATION
  // ============================================================================

  static void _log(LogLevel level, String tag, String message, {Object? data}) {
    // Check if this level should be logged
    if (level < _minLevel) return;

    // Build log message components
    final timestamp = _enableTimestamps ? _getTimestamp() : '';
    final emoji = _enableEmojis ? '${level.emoji} ' : '';
    final levelLabel = level.label;
    final formattedTag = _formatTag(tag);
    final dataStr = data != null ? '\n  Data: $data' : '';

    // Assemble final message
    final logMessage = '$timestamp$emoji[$levelLabel] $formattedTag $message$dataStr';

    // Output based on severity
    if (level >= LogLevel.error) {
      // Errors always go to debug output (may be redirected to crash reporting in production)
      debugPrint(logMessage);
    } else {
      debugPrint(logMessage);
    }
  }

  /// Format tag to consistent width for alignment
  static String _formatTag(String tag) {
    if (tag.length > _maxTagLength) {
      return '${tag.substring(0, _maxTagLength - 3)}...';
    }
    return tag.padRight(_maxTagLength);
  }

  /// Get current timestamp string
  static String _getTimestamp() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = now.millisecond.toString().padLeft(3, '0');
    return '[$h:$m:$s.$ms] ';
  }
}

/// Convenience extension for object logging
extension LoggableObject on Object {
  void logTrace(String tag, String message) => Log.trace(tag, message, data: this);
  void logDebug(String tag, String message) => Log.debug(tag, message, data: this);
  void logInfo(String tag, String message) => Log.info(tag, message, data: this);
  void logWarn(String tag, String message) => Log.warn(tag, message, data: this);
  void logError(String tag, String message, {StackTrace? stackTrace}) {
    Log.error(tag, message, error: this, stackTrace: stackTrace);
  }
}
