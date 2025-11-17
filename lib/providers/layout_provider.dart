///
/// Layout Provider
///
/// State management for layout system. Manages current layout preset,
/// panel positions, docking, and persistence to SharedPreferences.
///
/// Features:
/// - Current layout state management
/// - Layout preset switching
/// - Panel position/size tracking
/// - Persistence to local storage
/// - Undo/redo support
///
/// Part of the Next-Generation UI Redesign (v3.0) - Phase 2
///
/// A Paul Phillips Manifestation
////

import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/layout_preset.dart';
import '../ui/layout/flexible_layout.dart';
import '../ui/layout/panel_dock_system.dart';

// ============================================================================
// LAYOUT STATE
// ============================================================================

/// Current layout state
class LayoutState {
  final LayoutPreset currentPreset;
  final Map<String, PanelLayoutData> panels;
  final bool isModified; // Has been modified since loading preset
  final LayoutBreakpoint breakpoint;

  const LayoutState({
    required this.currentPreset,
    required this.panels,
    this.isModified = false,
    required this.breakpoint,
  });

  LayoutState copyWith({
    LayoutPreset? currentPreset,
    Map<String, PanelLayoutData>? panels,
    bool? isModified,
    LayoutBreakpoint? breakpoint,
  }) {
    return LayoutState(
      currentPreset: currentPreset ?? this.currentPreset,
      panels: panels ?? this.panels,
      isModified: isModified ?? this.isModified,
      breakpoint: breakpoint ?? this.breakpoint,
    );
  }
}

// ============================================================================
// LAYOUT PROVIDER
// ============================================================================

/// Layout state management provider
class LayoutProvider extends ChangeNotifier {
  LayoutState _state;
  final List<LayoutPreset> _userPresets = [];
  final List<LayoutState> _undoStack = [];
  final List<LayoutState> _redoStack = [];
  static const int maxUndoSteps = 20;

  LayoutProvider({
    LayoutPreset? initialPreset,
    LayoutBreakpoint initialBreakpoint = LayoutBreakpoint.portrait,
  }) : _state = LayoutState(
          currentPreset: initialPreset ?? FactoryPresets.performance,
          panels: _buildPanelMap(initialPreset ?? FactoryPresets.performance),
          breakpoint: initialBreakpoint,
        );

  /// Build panel map from preset
  static Map<String, PanelLayoutData> _buildPanelMap(LayoutPreset preset) {
    return Map.fromEntries(
      preset.panels.map((panel) => MapEntry(panel.id, panel)),
    );
  }

  // ============================================================================
  // STATE ACCESS
  // ============================================================================

  /// Get current state
  LayoutState get state => _state;

  /// Get current preset
  LayoutPreset get currentPreset => _state.currentPreset;

  /// Get all panels
  Map<String, PanelLayoutData> get panels => _state.panels;

  /// Get specific panel
  PanelLayoutData? getPanel(String id) => _state.panels[id];

  /// Check if modified
  bool get isModified => _state.isModified;

  /// Get current breakpoint
  LayoutBreakpoint get breakpoint => _state.breakpoint;

  /// Get all available presets (factory + user)
  List<LayoutPreset> get allPresets {
    return [...FactoryPresets.getAll(), ..._userPresets];
  }

  /// Get user presets only
  List<LayoutPreset> get userPresets => List.unmodifiable(_userPresets);

  /// Check if can undo
  bool get canUndo => _undoStack.isNotEmpty;

  /// Check if can redo
  bool get canRedo => _redoStack.isNotEmpty;

  // ============================================================================
  // LAYOUT PRESET MANAGEMENT
  // ============================================================================

  /// Load layout preset
  void loadPreset(LayoutPreset preset) {
    _saveToUndoStack();

    _state = LayoutState(
      currentPreset: preset,
      panels: _buildPanelMap(preset),
      isModified: false,
      breakpoint: _state.breakpoint,
    );

    _redoStack.clear();
    notifyListeners();
  }

  /// Load preset by ID
  void loadPresetById(String id) {
    final preset = FactoryPresets.getById(id) ??
        _userPresets.firstWhere(
          (p) => p.id == id,
          orElse: () => FactoryPresets.performance,
        );

    loadPreset(preset);
  }

  /// Save current layout as user preset
  void saveAsUserPreset(String name, String description) {
    final now = DateTime.now();
    final preset = LayoutPreset(
      id: 'user_${now.millisecondsSinceEpoch}',
      name: name,
      description: description,
      targetBreakpoint: _state.breakpoint,
      panels: _state.panels.values.toList(),
      gridConfig: _state.currentPreset.gridConfig,
      dockConfig: _state.currentPreset.dockConfig,
      isFactory: false,
      createdAt: now,
      modifiedAt: now,
    );

    _userPresets.add(preset);

    // Update current preset to the saved one
    _state = _state.copyWith(
      currentPreset: preset,
      isModified: false,
    );

    notifyListeners();
  }

  /// Delete user preset
  void deleteUserPreset(String id) {
    _userPresets.removeWhere((preset) => preset.id == id);
    notifyListeners();
  }

  /// Reset to factory preset
  void resetToFactory() {
    final factoryPreset = FactoryPresets.getById(_state.currentPreset.id);
    if (factoryPreset != null) {
      loadPreset(factoryPreset);
    }
  }

  // ============================================================================
  // PANEL MANAGEMENT
  // ============================================================================

  /// Update panel position
  void updatePanelPosition(String id, GridPosition position) {
    final panel = _state.panels[id];
    if (panel == null) return;

    _saveToUndoStack();

    final updatedPanels = Map<String, PanelLayoutData>.from(_state.panels);
    updatedPanels[id] = panel.copyWith(position: position);

    _state = _state.copyWith(
      panels: updatedPanels,
      isModified: true,
    );

    _redoStack.clear();
    notifyListeners();
  }

  /// Update panel size
  void updatePanelSize(String id, GridUnits size) {
    final panel = _state.panels[id];
    if (panel == null) return;

    _saveToUndoStack();

    final updatedPanels = Map<String, PanelLayoutData>.from(_state.panels);
    updatedPanels[id] = panel.copyWith(size: size);

    _state = _state.copyWith(
      panels: updatedPanels,
      isModified: true,
    );

    _redoStack.clear();
    notifyListeners();
  }

  /// Update panel dock zone
  void updatePanelDockZone(String id, DockZone zone) {
    final panel = _state.panels[id];
    if (panel == null) return;

    _saveToUndoStack();

    final updatedPanels = Map<String, PanelLayoutData>.from(_state.panels);
    updatedPanels[id] = panel.copyWith(dockZone: zone);

    _state = _state.copyWith(
      panels: updatedPanels,
      isModified: true,
    );

    _redoStack.clear();
    notifyListeners();
  }

  /// Toggle panel visibility
  void togglePanelVisibility(String id) {
    final panel = _state.panels[id];
    if (panel == null) return;

    _saveToUndoStack();

    final updatedPanels = Map<String, PanelLayoutData>.from(_state.panels);
    updatedPanels[id] = panel.copyWith(visible: !panel.visible);

    _state = _state.copyWith(
      panels: updatedPanels,
      isModified: true,
    );

    _redoStack.clear();
    notifyListeners();
  }

  /// Set panel visibility
  void setPanelVisibility(String id, bool visible) {
    final panel = _state.panels[id];
    if (panel == null) return;

    if (panel.visible == visible) return; // No change

    _saveToUndoStack();

    final updatedPanels = Map<String, PanelLayoutData>.from(_state.panels);
    updatedPanels[id] = panel.copyWith(visible: visible);

    _state = _state.copyWith(
      panels: updatedPanels,
      isModified: true,
    );

    _redoStack.clear();
    notifyListeners();
  }

  /// Update panel order in dock zone
  void updatePanelOrder(String id, int order) {
    final panel = _state.panels[id];
    if (panel == null) return;

    _saveToUndoStack();

    final updatedPanels = Map<String, PanelLayoutData>.from(_state.panels);
    updatedPanels[id] = panel.copyWith(order: order);

    _state = _state.copyWith(
      panels: updatedPanels,
      isModified: true,
    );

    _redoStack.clear();
    notifyListeners();
  }

  // ============================================================================
  // BREAKPOINT MANAGEMENT
  // ============================================================================

  /// Update breakpoint (called when orientation changes)
  void updateBreakpoint(LayoutBreakpoint breakpoint) {
    if (_state.breakpoint == breakpoint) return;

    _state = _state.copyWith(breakpoint: breakpoint);
    notifyListeners();

    // Optionally auto-switch to appropriate preset
    if (_state.currentPreset.targetBreakpoint != breakpoint) {
      _suggestPresetForBreakpoint(breakpoint);
    }
  }

  /// Suggest preset for breakpoint (internal)
  void _suggestPresetForBreakpoint(LayoutBreakpoint breakpoint) {
    // Find best matching factory preset for new breakpoint
    final matchingPresets =
        FactoryPresets.getAll().where((p) => p.targetBreakpoint == breakpoint);

    if (matchingPresets.isNotEmpty) {
      // Could show dialog to user asking if they want to switch
      // For now, just notify that we have suggestions
      debugPrint(
          'Suggested preset for $breakpoint: ${matchingPresets.first.name}');
    }
  }

  // ============================================================================
  // UNDO/REDO
  // ============================================================================

  void _saveToUndoStack() {
    _undoStack.add(_state);

    // Limit undo stack size
    while (_undoStack.length > maxUndoSteps) {
      _undoStack.removeAt(0);
    }
  }

  /// Undo last change
  void undo() {
    if (!canUndo) return;

    _redoStack.add(_state);
    _state = _undoStack.removeLast();

    notifyListeners();
  }

  /// Redo last undone change
  void redo() {
    if (!canRedo) return;

    _undoStack.add(_state);
    _state = _redoStack.removeLast();

    notifyListeners();
  }

  /// Clear undo/redo stacks
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }

  // ============================================================================
  // PERSISTENCE
  // ============================================================================

  /// Export current layout to JSON string
  String exportLayout() {
    final preset = LayoutPreset(
      id: 'export_${DateTime.now().millisecondsSinceEpoch}',
      name: _state.currentPreset.name,
      description: _state.currentPreset.description,
      targetBreakpoint: _state.breakpoint,
      panels: _state.panels.values.toList(),
      gridConfig: _state.currentPreset.gridConfig,
      dockConfig: _state.currentPreset.dockConfig,
      isFactory: false,
      createdAt: _state.currentPreset.createdAt,
      modifiedAt: DateTime.now(),
    );

    return preset.exportToString();
  }

  /// Import layout from JSON string
  void importLayout(String jsonString) {
    try {
      final preset = LayoutPreset.importFromString(jsonString);
      loadPreset(preset);
    } catch (e) {
      debugPrint('Failed to import layout: $e');
      rethrow;
    }
  }

  /// Save to SharedPreferences (would need to inject storage)
  Map<String, dynamic> toJson() {
    return {
      'currentPresetId': _state.currentPreset.id,
      'panels':
          _state.panels.map((key, value) => MapEntry(key, value.toJson())),
      'isModified': _state.isModified,
      'breakpoint': _state.breakpoint.name,
      'userPresets': _userPresets.map((p) => p.toJson()).toList(),
    };
  }

  /// Load from SharedPreferences data
  void fromJson(Map<String, dynamic> json) {
    try {
      // Load user presets
      _userPresets.clear();
      if (json.containsKey('userPresets')) {
        final presetList = json['userPresets'] as List;
        _userPresets.addAll(
          presetList
              .map((p) => LayoutPreset.fromJson(p as Map<String, dynamic>)),
        );
      }

      // Load current preset
      final presetId = json['currentPresetId'] as String;
      final preset = FactoryPresets.getById(presetId) ??
          _userPresets.firstWhere(
            (p) => p.id == presetId,
            orElse: () => FactoryPresets.performance,
          );

      // Load panels
      final panelsJson = json['panels'] as Map<String, dynamic>;
      final panels = panelsJson.map(
        (key, value) => MapEntry(
          key,
          PanelLayoutData.fromJson(value as Map<String, dynamic>),
        ),
      );

      // Load breakpoint
      final breakpoint = LayoutBreakpoint.values.firstWhere(
        (e) => e.name == json['breakpoint'],
        orElse: () => LayoutBreakpoint.portrait,
      );

      _state = LayoutState(
        currentPreset: preset,
        panels: panels,
        isModified: json['isModified'] as bool? ?? false,
        breakpoint: breakpoint,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load layout from JSON: $e');
    }
  }
}
