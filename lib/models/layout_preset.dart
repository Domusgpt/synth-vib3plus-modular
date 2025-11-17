/**
 * Layout Preset Model
 *
 * Data model for saving and loading layout configurations.
 * Includes preset layouts (Performance, Production, Minimal, Desktop)
 * with JSON serialization for persistence.
 *
 * Features:
 * - Panel configuration serialization
 * - Preset layouts
 * - User custom layouts
 * - JSON import/export
 * - Device-specific configurations
 *
 * Part of the Next-Generation UI Redesign (v3.0) - Phase 2
 *
 * A Paul Phillips Manifestation
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import '../ui/layout/flexible_layout.dart';
import '../ui/layout/panel_dock_system.dart';

// ============================================================================
// PANEL LAYOUT DATA
// ============================================================================

/// Configuration for a single panel in a layout
class PanelLayoutData {
  final String id;
  final GridPosition position;
  final GridUnits size;
  final DockZone dockZone;
  final int order;
  final bool visible;
  final Map<String, dynamic>? customData; // Panel-specific data

  const PanelLayoutData({
    required this.id,
    required this.position,
    required this.size,
    this.dockZone = DockZone.floating,
    this.order = 0,
    this.visible = true,
    this.customData,
  });

  // ============================================================================
  // SERIALIZATION
  // ============================================================================

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': {
          'column': position.column,
          'row': position.row,
        },
        'size': {
          'columns': size.columns,
          'rows': size.rows,
        },
        'dockZone': dockZone.name,
        'order': order,
        'visible': visible,
        if (customData != null) 'customData': customData,
      };

  factory PanelLayoutData.fromJson(Map<String, dynamic> json) {
    return PanelLayoutData(
      id: json['id'] as String,
      position: GridPosition(
        json['position']['column'] as int,
        json['position']['row'] as int,
      ),
      size: GridUnits(
        json['size']['columns'] as int,
        json['size']['rows'] as int,
      ),
      dockZone: DockZone.values.firstWhere(
        (e) => e.name == json['dockZone'],
        orElse: () => DockZone.floating,
      ),
      order: json['order'] as int? ?? 0,
      visible: json['visible'] as bool? ?? true,
      customData: json['customData'] as Map<String, dynamic>?,
    );
  }

  PanelLayoutData copyWith({
    String? id,
    GridPosition? position,
    GridUnits? size,
    DockZone? dockZone,
    int? order,
    bool? visible,
    Map<String, dynamic>? customData,
  }) {
    return PanelLayoutData(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      dockZone: dockZone ?? this.dockZone,
      order: order ?? this.order,
      visible: visible ?? this.visible,
      customData: customData ?? this.customData,
    );
  }
}

// ============================================================================
// LAYOUT PRESET
// ============================================================================

/// Complete layout preset configuration
class LayoutPreset {
  final String id;
  final String name;
  final String description;
  final LayoutBreakpoint targetBreakpoint;
  final List<PanelLayoutData> panels;
  final GridConfig gridConfig;
  final DockConfig dockConfig;
  final bool isFactory; // Factory preset vs user preset
  final DateTime createdAt;
  final DateTime modifiedAt;

  const LayoutPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.targetBreakpoint,
    required this.panels,
    this.gridConfig = GridConfig.standard,
    this.dockConfig = DockConfig.standard,
    this.isFactory = false,
    required this.createdAt,
    required this.modifiedAt,
  });

  // ============================================================================
  // SERIALIZATION
  // ============================================================================

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'targetBreakpoint': targetBreakpoint.name,
        'panels': panels.map((p) => p.toJson()).toList(),
        'gridConfig': {
          'columns': gridConfig.columns,
          'gutterSize': gridConfig.gutterSize,
          'snapToGrid': gridConfig.snapToGrid,
        },
        'dockConfig': {
          'snapDistance': dockConfig.snapDistance,
          'magneticStrength': dockConfig.magneticStrength,
          'enableCollisionDetection': dockConfig.enableCollisionDetection,
          'enableAutoLayout': dockConfig.enableAutoLayout,
          'dockedPanelSize': dockConfig.dockedPanelSize,
        },
        'isFactory': isFactory,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  factory LayoutPreset.fromJson(Map<String, dynamic> json) {
    return LayoutPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      targetBreakpoint: LayoutBreakpoint.values.firstWhere(
        (e) => e.name == json['targetBreakpoint'],
        orElse: () => LayoutBreakpoint.portrait,
      ),
      panels: (json['panels'] as List)
          .map((p) => PanelLayoutData.fromJson(p as Map<String, dynamic>))
          .toList(),
      gridConfig: GridConfig(
        columns: json['gridConfig']['columns'] as int,
        gutterSize: json['gridConfig']['gutterSize'] as double,
        snapToGrid: json['gridConfig']['snapToGrid'] as bool,
      ),
      dockConfig: DockConfig(
        snapDistance: json['dockConfig']['snapDistance'] as double,
        magneticStrength: json['dockConfig']['magneticStrength'] as double,
        enableCollisionDetection: json['dockConfig']['enableCollisionDetection'] as bool,
        enableAutoLayout: json['dockConfig']['enableAutoLayout'] as bool,
        dockedPanelSize: json['dockConfig']['dockedPanelSize'] as double,
      ),
      isFactory: json['isFactory'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
  }

  /// Export as JSON string
  String exportToString() => jsonEncode(toJson());

  /// Import from JSON string
  static LayoutPreset importFromString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return LayoutPreset.fromJson(json);
  }

  LayoutPreset copyWith({
    String? id,
    String? name,
    String? description,
    LayoutBreakpoint? targetBreakpoint,
    List<PanelLayoutData>? panels,
    GridConfig? gridConfig,
    DockConfig? dockConfig,
    bool? isFactory,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return LayoutPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetBreakpoint: targetBreakpoint ?? this.targetBreakpoint,
      panels: panels ?? this.panels,
      gridConfig: gridConfig ?? this.gridConfig,
      dockConfig: dockConfig ?? this.dockConfig,
      isFactory: isFactory ?? this.isFactory,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}

// ============================================================================
// FACTORY PRESETS
// ============================================================================

/// Factory preset layouts
class FactoryPresets {
  /// Performance Mode - Maximum visualization, minimal controls
  static LayoutPreset get performance {
    final now = DateTime.now();
    return LayoutPreset(
      id: 'factory_performance',
      name: 'Performance Mode',
      description: 'Maximum visualization (95% screen), minimal controls. '
          'Ideal for live performances and presentations.',
      targetBreakpoint: LayoutBreakpoint.portrait,
      panels: [
        // XY Pad (center, 2x2)
        PanelLayoutData(
          id: 'xy_pad',
          position: GridPosition(5, 10), // Centered
          size: GridUnits.unit2x2,
          visible: true,
        ),
        // Orb (small, bottom-left corner)
        PanelLayoutData(
          id: 'orb',
          position: GridPosition(1, 20),
          size: GridUnits.unit1x1,
          visible: true,
        ),
        // Quick controls (collapsed at bottom)
        PanelLayoutData(
          id: 'controls',
          position: GridPosition.topLeft,
          size: GridUnits.fullWidth,
          dockZone: DockZone.bottom,
          visible: true,
        ),
      ],
      isFactory: true,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Production Mode - Balanced visuals + controls
  static LayoutPreset get production {
    final now = DateTime.now();
    return LayoutPreset(
      id: 'factory_production',
      name: 'Production Mode',
      description: 'Balanced layout with visuals + controls. '
          'Ideal for sound design and preset creation.',
      targetBreakpoint: LayoutBreakpoint.landscape,
      panels: [
        // Parameters panel (left sidebar)
        PanelLayoutData(
          id: 'parameters',
          position: GridPosition.topLeft,
          size: GridUnits(2, 6),
          dockZone: DockZone.left,
          visible: true,
        ),
        // XY Pad (center, 3x3)
        PanelLayoutData(
          id: 'xy_pad',
          position: GridPosition(4, 5),
          size: GridUnits.unit3x3,
          visible: true,
        ),
        // Modulation visualizer (right sidebar top)
        PanelLayoutData(
          id: 'modulation',
          position: GridPosition(10, 0),
          size: GridUnits(2, 3),
          dockZone: DockZone.right,
          order: 0,
          visible: true,
        ),
        // Orb (right sidebar bottom)
        PanelLayoutData(
          id: 'orb',
          position: GridPosition(10, 4),
          size: GridUnits(2, 2),
          dockZone: DockZone.right,
          order: 1,
          visible: true,
        ),
        // Parameters panel (bottom)
        PanelLayoutData(
          id: 'controls',
          position: GridPosition.topLeft,
          size: GridUnits.fullWidth,
          dockZone: DockZone.bottom,
          visible: true,
        ),
      ],
      isFactory: true,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Minimal Mode - 100% visualization, hidden controls
  static LayoutPreset get minimal {
    final now = DateTime.now();
    return LayoutPreset(
      id: 'factory_minimal',
      name: 'Minimal Mode',
      description: '100% visualization focus. Tap to show floating controls. '
          'Ideal for visual performances and VJing.',
      targetBreakpoint: LayoutBreakpoint.portrait,
      panels: [
        // All panels hidden initially
        PanelLayoutData(
          id: 'xy_pad',
          position: GridPosition(5, 10),
          size: GridUnits.unit2x2,
          visible: false,
        ),
        PanelLayoutData(
          id: 'orb',
          position: GridPosition(1, 20),
          size: GridUnits.unit1x1,
          visible: false,
        ),
        PanelLayoutData(
          id: 'controls',
          position: GridPosition.topLeft,
          size: GridUnits.fullWidth,
          dockZone: DockZone.bottom,
          visible: false,
        ),
      ],
      isFactory: true,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Desktop Mode - Quad-split for tablets/large screens
  static LayoutPreset get desktop {
    final now = DateTime.now();
    return LayoutPreset(
      id: 'factory_desktop',
      name: 'Desktop Mode',
      description: 'Maximum control + visualization for tablets and large screens. '
          'Quad-split layout with all controls visible.',
      targetBreakpoint: LayoutBreakpoint.landscape,
      panels: [
        // Presets (left sidebar top)
        PanelLayoutData(
          id: 'presets',
          position: GridPosition.topLeft,
          size: GridUnits(2, 3),
          dockZone: DockZone.left,
          order: 0,
          visible: true,
        ),
        // XY Pad (center)
        PanelLayoutData(
          id: 'xy_pad',
          position: GridPosition(4, 5),
          size: GridUnits.unit2x2,
          visible: true,
        ),
        // Oscilloscope (right sidebar top)
        PanelLayoutData(
          id: 'visualizer',
          position: GridPosition(10, 0),
          size: GridUnits(2, 3),
          dockZone: DockZone.right,
          order: 0,
          visible: true,
        ),
        // Spectrum (right sidebar bottom)
        PanelLayoutData(
          id: 'spectrum',
          position: GridPosition(10, 4),
          size: GridUnits(2, 3),
          dockZone: DockZone.right,
          order: 1,
          visible: true,
        ),
        // Settings (right sidebar bottom)
        PanelLayoutData(
          id: 'settings',
          position: GridPosition(10, 8),
          size: GridUnits(2, 3),
          dockZone: DockZone.right,
          order: 2,
          visible: true,
        ),
        // Parameters (bottom panel)
        PanelLayoutData(
          id: 'parameters',
          position: GridPosition.topLeft,
          size: GridUnits.fullWidth,
          dockZone: DockZone.bottom,
          visible: true,
        ),
      ],
      isFactory: true,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Get all factory presets
  static List<LayoutPreset> getAll() {
    return [
      performance,
      production,
      minimal,
      desktop,
    ];
  }

  /// Get preset by ID
  static LayoutPreset? getById(String id) {
    try {
      return getAll().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
