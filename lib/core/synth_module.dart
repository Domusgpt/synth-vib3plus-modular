///
/// Core Module System for Synth-VIB3+
///
/// Provides clean lifecycle management and dependency resolution
/// for all system modules. Inspired by VIB3+ JavaScript architecture.
///
/// A Paul Phillips Manifestation
////

import 'package:flutter/foundation.dart';

/// Abstract base class for all synth modules
abstract class SynthModule {
  /// Human-readable module name for logging
  String get name;

  /// Initialize module (async operations allowed)
  Future<void> initialize();

  /// Clean shutdown and resource cleanup
  Future<void> dispose();

  /// Module health check
  bool get isHealthy => true;

  /// Get comprehensive diagnostic info
  Map<String, dynamic> getDiagnostics();

  /// Module dependencies (for initialization ordering)
  List<Type> get dependencies => [];

  /// Optional: Called when another module completes initialization
  Future<void> onModuleReady(Type moduleType) async {}
}

/// Module lifecycle state
enum ModuleState {
  uninitialized,
  initializing,
  ready,
  failed,
  disposed,
}

/// Module wrapper with state tracking
class ModuleInfo {
  final SynthModule module;
  ModuleState state = ModuleState.uninitialized;
  String? error;
  DateTime? initStartTime;
  DateTime? initEndTime;

  ModuleInfo(this.module);

  Duration? get initializationTime {
    if (initStartTime != null && initEndTime != null) {
      return initEndTime!.difference(initStartTime!);
    }
    return null;
  }
}

/// Central module manager - coordinates all modules
class ModuleManager with ChangeNotifier {
  final List<ModuleInfo> _modules = [];
  final Map<Type, ModuleInfo> _moduleMap = {};

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Register a module
  void register(SynthModule module) {
    final info = ModuleInfo(module);
    _modules.add(info);
    _moduleMap[module.runtimeType] = info;
  }

  /// Initialize all modules in dependency order
  Future<void> initializeAll() async {
    debugPrint('📦 Starting module initialization...\n');

    // Sort modules by dependencies (topological sort)
    final ordered = _topologicalSort();

    for (final info in ordered) {
      info.state = ModuleState.initializing;
      info.initStartTime = DateTime.now();

      debugPrint('🔧 Loading ${info.module.name}...');

      try {
        await info.module.initialize();

        info.state = ModuleState.ready;
        info.initEndTime = DateTime.now();

        final duration = info.initializationTime!.inMilliseconds;
        debugPrint('✅ ${info.module.name}: Loaded (${duration}ms)\n');

        // Notify other modules
        for (final other in _modules) {
          if (other != info && other.state == ModuleState.ready) {
            await other.module.onModuleReady(info.module.runtimeType);
          }
        }
      } catch (e, stackTrace) {
        info.state = ModuleState.failed;
        info.error = e.toString();
        info.initEndTime = DateTime.now();

        debugPrint('❌ ${info.module.name}: FAILED');
        debugPrint('   Error: $e\n');

        // Continue with other modules or rethrow?
        // For now, log and continue
      }
    }

    _initialized = true;
    _printSystemSummary();

    notifyListeners();
  }

  /// Get module by type
  T get<T extends SynthModule>() {
    final info = _moduleMap[T];
    if (info == null) {
      throw StateError('Module $T not registered');
    }
    if (info.state != ModuleState.ready) {
      throw StateError('Module $T not ready (state: ${info.state})');
    }
    return info.module as T;
  }

  /// Try to get module (returns null if not ready)
  T? tryGet<T extends SynthModule>() {
    final info = _moduleMap[T];
    if (info?.state == ModuleState.ready) {
      return info!.module as T;
    }
    return null;
  }

  /// Check if module is ready
  bool isReady<T extends SynthModule>() {
    return _moduleMap[T]?.state == ModuleState.ready;
  }

  /// Get all modules
  List<SynthModule> get modules => _modules.map((i) => i.module).toList();

  /// Get module info
  ModuleInfo? getInfo(Type moduleType) => _moduleMap[moduleType];

  /// Print comprehensive diagnostics
  void printDiagnostics() {
    debugPrint('\n🔬 System Diagnostics\n');
    debugPrint('═' * 60);

    int healthy = 0;
    int unhealthy = 0;

    for (final info in _modules) {
      if (info.state == ModuleState.ready) {
        final isHealthy = info.module.isHealthy;
        final healthIcon = isHealthy ? '✅' : '⚠️';

        debugPrint('\n$healthIcon ${info.module.name}:');
        debugPrint('   State: ${info.state}');
        debugPrint('   Healthy: $isHealthy');

        final diag = info.module.getDiagnostics();
        diag.forEach((key, value) {
          debugPrint('   $key: $value');
        });

        isHealthy ? healthy++ : unhealthy++;
      } else {
        debugPrint('\n❌ ${info.module.name}:');
        debugPrint('   State: ${info.state}');
        if (info.error != null) {
          debugPrint('   Error: ${info.error}');
        }
        unhealthy++;
      }
    }

    debugPrint('\n' + '═' * 60);
    debugPrint('Summary: $healthy healthy, $unhealthy with issues\n');
  }

  /// Clean shutdown of all modules
  Future<void> disposeAll() async {
    debugPrint('\n🛑 Shutting down modules...\n');

    // Dispose in reverse order
    for (final info in _modules.reversed) {
      if (info.state == ModuleState.ready) {
        debugPrint('🔧 Disposing ${info.module.name}...');

        try {
          await info.module.dispose();
          info.state = ModuleState.disposed;
          debugPrint('✅ ${info.module.name}: Disposed\n');
        } catch (e) {
          debugPrint('⚠️ ${info.module.name}: Dispose error - $e\n');
        }
      }
    }

    debugPrint('✅ All modules disposed\n');
  }

  /// Topological sort of modules by dependencies
  List<ModuleInfo> _topologicalSort() {
    final sorted = <ModuleInfo>[];
    final visited = <Type>{};
    final visiting = <Type>{};

    void visit(ModuleInfo info) {
      final type = info.module.runtimeType;

      if (visited.contains(type)) return;

      if (visiting.contains(type)) {
        throw StateError('Circular dependency detected: $type');
      }

      visiting.add(type);

      // Visit dependencies first
      for (final depType in info.module.dependencies) {
        final depInfo = _moduleMap[depType];
        if (depInfo == null) {
          throw StateError(
              'Dependency $depType not registered for ${info.module.name}');
        }
        visit(depInfo);
      }

      visiting.remove(type);
      visited.add(type);
      sorted.add(info);
    }

    for (final info in _modules) {
      visit(info);
    }

    return sorted;
  }

  /// Print system summary
  void _printSystemSummary() {
    final ready = _modules.where((i) => i.state == ModuleState.ready).length;
    final failed = _modules.where((i) => i.state == ModuleState.failed).length;
    final total = _modules.length;

    debugPrint('═' * 60);
    debugPrint('✅ Module Initialization Complete');
    debugPrint('═' * 60);
    debugPrint('   Ready: $ready/$total');
    if (failed > 0) {
      debugPrint('   Failed: $failed');
    }

    final totalTime = _modules
        .where((i) => i.initializationTime != null)
        .map((i) => i.initializationTime!.inMilliseconds)
        .fold(0, (a, b) => a + b);

    debugPrint('   Total init time: ${totalTime}ms');
    debugPrint('═' * 60);
    debugPrint('\n🚀 Synth-VIB3+ System Ready\n');
  }
}
