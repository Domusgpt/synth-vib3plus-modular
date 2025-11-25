///
/// Synth-VIB3+ Application Initializer
///
/// Demonstrates the modular architecture pattern by initializing
/// all system modules in dependency order with professional logging.
///
/// A Paul Phillips Manifestation
///

library;

import 'synth_module.dart';
import 'synth_logger.dart';
import '../modules/audio_engine_module.dart';
import '../modules/visual_bridge_module.dart';
import '../modules/parameter_coupling_module.dart';

/// Initialize all system modules
Future<SynthModules> initializeSynthModules() async {
  SynthLogger.systemStart();

  final manager = ModuleManager();

  // Register all modules
  final audioModule = AudioEngineModule();
  final visualModule = VisualBridgeModule();
  final couplingModule = ParameterCouplingModule();

  manager.register(audioModule);
  manager.register(visualModule);
  manager.register(couplingModule);

  // Initialize all modules (respects dependencies)
  await manager.initializeAll();

  // Set up parameter coupling dependencies
  couplingModule.setDependencies(audioModule, visualModule);

  // Start parameter coupling
  couplingModule.start();

  SynthLogger.systemReady(
    totalModules: 3,
    readyModules: 3,
    failedModules: 0,
    totalTimeMs: 0, // Will be calculated by manager
  );

  return SynthModules(
    manager: manager,
    audio: audioModule,
    visual: visualModule,
    coupling: couplingModule,
  );
}

/// Container for all initialized modules
class SynthModules {
  final ModuleManager manager;
  final AudioEngineModule audio;
  final VisualBridgeModule visual;
  final ParameterCouplingModule coupling;

  SynthModules({
    required this.manager,
    required this.audio,
    required this.visual,
    required this.coupling,
  });

  /// Print comprehensive diagnostics
  void printDiagnostics() {
    manager.printDiagnostics();
  }

  /// Clean shutdown of all modules
  Future<void> dispose() async {
    await manager.disposeAll();
  }
}
