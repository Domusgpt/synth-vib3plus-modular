///
/// Modulation Matrix System
///
/// Flexible parameter routing system enabling:
/// - Multiple modulation sources → destinations
/// - User-configurable routing
/// - Preset-stored modulation configurations
/// - Depth aggregation for multiple sources
///
/// Adopted from synther-refactored architecture
/// A Paul Phillips Manifestation
///

library;

import 'dart:collection';

/// Modulation route from source to destination
class ModulationRoute {
  final String source;
  final String destination;
  final double amount; // -1.0 to 1.0 (bipolar)

  ModulationRoute({
    required this.source,
    required this.destination,
    required this.amount,
  });

  /// Route key for map storage
  String get key =>
      '${source.trim().toLowerCase()}->${destination.trim().toLowerCase()}';

  /// Copy with modifications
  ModulationRoute copyWith({
    String? source,
    String? destination,
    double? amount,
  }) {
    return ModulationRoute(
      source: source ?? this.source,
      destination: destination ?? this.destination,
      amount: amount ?? this.amount,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'destination': destination,
      'amount': amount,
    };
  }

  /// Deserialize from JSON
  static ModulationRoute fromJson(Map<String, dynamic> json) {
    return ModulationRoute(
      source: json['source'] as String,
      destination: json['destination'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  @override
  String toString() =>
      '$source → $destination (${(amount * 100).toStringAsFixed(0)}%)';
}

/// Modulation matrix managing all routing
class ModulationMatrix {
  final LinkedHashMap<String, ModulationRoute> _routes = LinkedHashMap();

  static const double epsilon = 1e-6;

  /// Add or update a modulation route
  void add(ModulationRoute route) {
    // Remove near-zero routes automatically
    if (route.amount.abs() < epsilon) {
      remove(route.source, route.destination);
      return;
    }

    _routes[route.key] = route;
  }

  /// Remove a modulation route
  void remove(String source, String destination) {
    final key = ModulationRoute(
      source: source,
      destination: destination,
      amount: 0.0,
    ).key;
    _routes.remove(key);
  }

  /// Get modulation route
  ModulationRoute? getRoute(String source, String destination) {
    final key = ModulationRoute(
      source: source,
      destination: destination,
      amount: 0.0,
    ).key;
    return _routes[key];
  }

  /// Get all routes
  List<ModulationRoute> getAllRoutes() {
    return List.unmodifiable(_routes.values);
  }

  /// Get all routes for a specific source
  List<ModulationRoute> getRoutesForSource(String source) {
    final normalized = source.trim().toLowerCase();
    return _routes.values
        .where((route) => route.source.trim().toLowerCase() == normalized)
        .toList();
  }

  /// Get all routes for a specific destination
  List<ModulationRoute> getRoutesForDestination(String destination) {
    final normalized = destination.trim().toLowerCase();
    return _routes.values
        .where((route) => route.destination.trim().toLowerCase() == normalized)
        .toList();
  }

  /// Get aggregated modulation depth for a destination
  /// Multiple sources to same destination are additive
  double getDepthForDestination(String destination) {
    final routes = getRoutesForDestination(destination);
    double total = 0.0;
    for (final route in routes) {
      total += route.amount;
    }
    return total.clamp(-1.0, 1.0); // Clamp final result
  }

  /// Get aggregated modulation depth by source
  Map<String, double> aggregateDepthBySource() {
    final totals = <String, double>{};
    for (final route in _routes.values) {
      final sourceKey = route.source.trim().toLowerCase();
      totals[sourceKey] = (totals[sourceKey] ?? 0.0) + route.amount.abs();
    }
    return totals;
  }

  /// Get aggregated modulation depth by destination
  Map<String, double> aggregateDepthByDestination() {
    final totals = <String, double>{};
    for (final route in _routes.values) {
      final destKey = route.destination.trim().toLowerCase();
      totals[destKey] = (totals[destKey] ?? 0.0) + route.amount.abs();
    }
    return totals;
  }

  /// Clear all routes
  void clear() {
    _routes.clear();
  }

  /// Get route count
  int get routeCount => _routes.length;

  /// Check if matrix is empty
  bool get isEmpty => _routes.isEmpty;

  /// Check if matrix is not empty
  bool get isNotEmpty => _routes.isNotEmpty;

  /// Serialize to JSON
  List<Map<String, dynamic>> toJson() {
    return _routes.values.map((route) => route.toJson()).toList();
  }

  /// Deserialize from JSON
  static ModulationMatrix fromJson(List<dynamic> json) {
    final matrix = ModulationMatrix();
    for (final item in json) {
      if (item is Map<String, dynamic>) {
        matrix.add(ModulationRoute.fromJson(item));
      }
    }
    return matrix;
  }

  /// Create a deep copy
  ModulationMatrix copy() {
    final matrix = ModulationMatrix();
    for (final route in _routes.values) {
      matrix.add(route);
    }
    return matrix;
  }

  @override
  String toString() {
    if (isEmpty) return 'ModulationMatrix(empty)';
    return 'ModulationMatrix(${routeCount} routes):\n' +
        _routes.values.map((route) => '  $route').join('\n');
  }
}

/// Default modulation matrices for different presets
class DefaultModulationMatrices {
  /// Audio-reactive preset (audio controls visuals)
  static ModulationMatrix audioReactive() {
    final matrix = ModulationMatrix();

    matrix.add(ModulationRoute(
      source: 'bassEnergy',
      destination: 'rotationSpeed',
      amount: 0.8, // Bass drives rotation speed
    ));

    matrix.add(ModulationRoute(
      source: 'midEnergy',
      destination: 'tessellationDensity',
      amount: 0.6, // Mids drive tessellation
    ));

    matrix.add(ModulationRoute(
      source: 'highEnergy',
      destination: 'vertexBrightness',
      amount: 0.7, // Highs drive brightness
    ));

    matrix.add(ModulationRoute(
      source: 'spectralCentroid',
      destination: 'hueShift',
      amount: 0.5, // Spectral content drives hue
    ));

    matrix.add(ModulationRoute(
      source: 'rms',
      destination: 'glowIntensity',
      amount: 0.75, // Overall amplitude drives glow
    ));

    return matrix;
  }

  /// Visual-reactive preset (visuals control audio)
  static ModulationMatrix visualReactive() {
    final matrix = ModulationMatrix();

    matrix.add(ModulationRoute(
      source: 'rotationXW',
      destination: 'filterCutoff',
      amount: 0.4, // XW rotation modulates filter
    ));

    matrix.add(ModulationRoute(
      source: 'rotationYW',
      destination: 'reverbMix',
      amount: 0.3, // YW rotation modulates reverb
    ));

    matrix.add(ModulationRoute(
      source: 'rotationZW',
      destination: 'delayTime',
      amount: 0.5, // ZW rotation modulates delay
    ));

    matrix.add(ModulationRoute(
      source: 'morphParameter',
      destination: 'oscillator1Detune',
      amount: 0.6, // Morph modulates detuning
    ));

    matrix.add(ModulationRoute(
      source: 'tessellationDensity',
      destination: 'voiceCount',
      amount: 0.7, // Tessellation drives voice count
    ));

    return matrix;
  }

  /// Bidirectional preset (both ways)
  static ModulationMatrix bidirectional() {
    final matrix = ModulationMatrix();

    // Audio → Visual
    matrix.add(ModulationRoute(
      source: 'bassEnergy',
      destination: 'rotationSpeed',
      amount: 0.6,
    ));

    matrix.add(ModulationRoute(
      source: 'rms',
      destination: 'glowIntensity',
      amount: 0.5,
    ));

    // Visual → Audio
    matrix.add(ModulationRoute(
      source: 'rotationXW',
      destination: 'filterCutoff',
      amount: 0.3,
    ));

    matrix.add(ModulationRoute(
      source: 'morphParameter',
      destination: 'oscillator1Detune',
      amount: 0.4,
    ));

    return matrix;
  }
}
