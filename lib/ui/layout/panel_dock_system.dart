/**
 * Panel Docking System
 *
 * Manages panel docking with snap-to-edge functionality, magnetic
 * snapping, collision detection, and auto-layout when docked.
 *
 * Features:
 * - 5 dock zones (top, bottom, left, right, float)
 * - Magnetic snapping with distance threshold
 * - Collision detection
 * - Auto-layout when docked
 * - Dock zone visualization
 *
 * Part of the Next-Generation UI Redesign (v3.0) - Phase 2
 *
 * A Paul Phillips Manifestation
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'flexible_layout.dart';

// ============================================================================
// DOCK ZONE
// ============================================================================

/// Docking zones
enum DockZone {
  top,      // Docked to top edge
  bottom,   // Docked to bottom edge
  left,     // Docked to left edge
  right,    // Docked to right edge
  floating, // Not docked (free positioning)
}

extension DockZoneExtension on DockZone {
  /// Check if docked (not floating)
  bool get isDocked => this != DockZone.floating;

  /// Get icon for dock zone
  IconData get icon {
    switch (this) {
      case DockZone.top:
        return Icons.vertical_align_top;
      case DockZone.bottom:
        return Icons.vertical_align_bottom;
      case DockZone.left:
        return Icons.border_left;
      case DockZone.right:
        return Icons.border_right;
      case DockZone.floating:
        return Icons.open_with;
    }
  }

  /// Get label for dock zone
  String get label {
    switch (this) {
      case DockZone.top:
        return 'Top';
      case DockZone.bottom:
        return 'Bottom';
      case DockZone.left:
        return 'Left';
      case DockZone.right:
        return 'Right';
      case DockZone.floating:
        return 'Float';
    }
  }
}

// ============================================================================
// DOCKING CONFIGURATION
// ============================================================================

/// Docking system configuration
class DockConfig {
  final double snapDistance;        // Pixels from edge to trigger snap
  final double magneticStrength;    // 0-1, how strong the magnetic pull is
  final bool enableCollisionDetection;
  final bool enableAutoLayout;      // Auto-arrange docked panels
  final double dockedPanelSize;     // Default size for docked panels
  final EdgeInsets dockZoneMargin;  // Margin around dock zones

  const DockConfig({
    this.snapDistance = 50.0,
    this.magneticStrength = 0.8,
    this.enableCollisionDetection = true,
    this.enableAutoLayout = true,
    this.dockedPanelSize = 300.0,
    this.dockZoneMargin = const EdgeInsets.all(8.0),
  });

  /// Standard docking config
  static const standard = DockConfig(
    snapDistance: 50.0,
    magneticStrength: 0.8,
    enableCollisionDetection: true,
    enableAutoLayout: true,
    dockedPanelSize: 300.0,
  );

  /// Loose docking (less magnetic)
  static const loose = DockConfig(
    snapDistance: 30.0,
    magneticStrength: 0.5,
    enableCollisionDetection: true,
    enableAutoLayout: true,
    dockedPanelSize: 300.0,
  );

  /// No docking
  static const none = DockConfig(
    snapDistance: 0.0,
    magneticStrength: 0.0,
    enableCollisionDetection: false,
    enableAutoLayout: false,
    dockedPanelSize: 0.0,
  );
}

// ============================================================================
// DOCKED PANEL INFO
// ============================================================================

/// Information about a docked panel
class DockedPanelInfo {
  final String id;
  final DockZone zone;
  final Rect rect;
  final int order;  // Order within dock zone (for auto-layout)

  const DockedPanelInfo({
    required this.id,
    required this.zone,
    required this.rect,
    this.order = 0,
  });

  DockedPanelInfo copyWith({
    String? id,
    DockZone? zone,
    Rect? rect,
    int? order,
  }) {
    return DockedPanelInfo(
      id: id ?? this.id,
      zone: zone ?? this.zone,
      rect: rect ?? this.rect,
      order: order ?? this.order,
    );
  }
}

// ============================================================================
// PANEL DOCK SYSTEM
// ============================================================================

/// Manages panel docking
class PanelDockSystem extends ChangeNotifier {
  final DockConfig config;
  final Size containerSize;

  // Registered panels
  final Map<String, DockedPanelInfo> _panels = {};

  PanelDockSystem({
    required this.config,
    required this.containerSize,
  });

  // ============================================================================
  // PANEL REGISTRATION
  // ============================================================================

  /// Register panel
  void registerPanel(DockedPanelInfo panel) {
    _panels[panel.id] = panel;
    notifyListeners();
  }

  /// Unregister panel
  void unregisterPanel(String id) {
    _panels.remove(id);
    notifyListeners();
  }

  /// Update panel info
  void updatePanel(DockedPanelInfo panel) {
    _panels[panel.id] = panel;
    notifyListeners();
  }

  /// Get panel info
  DockedPanelInfo? getPanel(String id) => _panels[id];

  /// Get all panels in dock zone
  List<DockedPanelInfo> getPanelsInZone(DockZone zone) {
    return _panels.values
        .where((panel) => panel.zone == zone)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  // ============================================================================
  // DOCKING LOGIC
  // ============================================================================

  /// Determine dock zone for given rect
  DockZone getDockZoneForRect(Rect rect) {
    if (config.snapDistance <= 0) return DockZone.floating;

    // Check distance to each edge
    final distanceToTop = rect.top;
    final distanceToBottom = containerSize.height - rect.bottom;
    final distanceToLeft = rect.left;
    final distanceToRight = containerSize.width - rect.right;

    // Find closest edge
    final minDistance = math.min(
      math.min(distanceToTop, distanceToBottom),
      math.min(distanceToLeft, distanceToRight),
    );

    // If within snap distance, return corresponding zone
    if (minDistance > config.snapDistance) {
      return DockZone.floating;
    }

    if (minDistance == distanceToTop) return DockZone.top;
    if (minDistance == distanceToBottom) return DockZone.bottom;
    if (minDistance == distanceToLeft) return DockZone.left;
    if (minDistance == distanceToRight) return DockZone.right;

    return DockZone.floating;
  }

  /// Calculate docked position for panel
  Rect getDOCKedRect(String panelId, DockZone zone, Size panelSize) {
    if (zone == DockZone.floating) {
      // Return current rect if available
      final current = _panels[panelId];
      if (current != null) return current.rect;

      // Otherwise return centered rect
      return Rect.fromLTWH(
        (containerSize.width - panelSize.width) / 2,
        (containerSize.height - panelSize.height) / 2,
        panelSize.width,
        panelSize.height,
      );
    }

    // Get panels in this zone
    final panelsInZone = getPanelsInZone(zone);
    final order = panelsInZone.length;  // New panel goes at end

    // Calculate position based on zone and order
    switch (zone) {
      case DockZone.top:
        return Rect.fromLTWH(
          config.dockZoneMargin.left,
          config.dockZoneMargin.top + (order * (config.dockedPanelSize + 8)),
          containerSize.width - config.dockZoneMargin.horizontal,
          config.dockedPanelSize,
        );

      case DockZone.bottom:
        return Rect.fromLTWH(
          config.dockZoneMargin.left,
          containerSize.height -
              config.dockZoneMargin.bottom -
              config.dockedPanelSize -
              (order * (config.dockedPanelSize + 8)),
          containerSize.width - config.dockZoneMargin.horizontal,
          config.dockedPanelSize,
        );

      case DockZone.left:
        return Rect.fromLTWH(
          config.dockZoneMargin.left,
          config.dockZoneMargin.top + (order * (config.dockedPanelSize + 8)),
          config.dockedPanelSize,
          containerSize.height - config.dockZoneMargin.vertical,
        );

      case DockZone.right:
        return Rect.fromLTWH(
          containerSize.width -
              config.dockZoneMargin.right -
              config.dockedPanelSize,
          config.dockZoneMargin.top + (order * (config.dockedPanelSize + 8)),
          config.dockedPanelSize,
          containerSize.height - config.dockZoneMargin.vertical,
        );

      case DockZone.floating:
        return Rect.fromLTWH(0, 0, panelSize.width, panelSize.height);
    }
  }

  /// Snap rect to dock zone with magnetic pull
  Rect snapToZone(Rect rect, DockZone zone) {
    final targetRect = getDOCKedRect('temp', zone, rect.size);

    if (zone == DockZone.floating) {
      return rect;
    }

    // Apply magnetic strength
    final dx = (targetRect.left - rect.left) * config.magneticStrength;
    final dy = (targetRect.top - rect.top) * config.magneticStrength;

    return Rect.fromLTWH(
      rect.left + dx,
      rect.top + dy,
      rect.width,
      rect.height,
    );
  }

  // ============================================================================
  // COLLISION DETECTION
  // ============================================================================

  /// Check if rect collides with any existing panel
  bool hasCollision(Rect rect, {String? excludePanelId}) {
    if (!config.enableCollisionDetection) return false;

    for (final entry in _panels.entries) {
      if (entry.key == excludePanelId) continue;

      if (rect.overlaps(entry.value.rect)) {
        return true;
      }
    }

    return false;
  }

  /// Get all colliding panels
  List<DockedPanelInfo> getCollidingPanels(Rect rect, {String? excludePanelId}) {
    final collisions = <DockedPanelInfo>[];

    for (final entry in _panels.entries) {
      if (entry.key == excludePanelId) continue;

      if (rect.overlaps(entry.value.rect)) {
        collisions.add(entry.value);
      }
    }

    return collisions;
  }

  /// Find non-colliding position near target rect
  Rect? findNonCollidingPosition(Rect targetRect, {String? excludePanelId}) {
    if (!hasCollision(targetRect, excludePanelId: excludePanelId)) {
      return targetRect;
    }

    // Try offsets in spiral pattern
    const offsets = [
      Offset(10, 0),
      Offset(0, 10),
      Offset(-10, 0),
      Offset(0, -10),
      Offset(20, 0),
      Offset(0, 20),
      Offset(-20, 0),
      Offset(0, -20),
    ];

    for (final offset in offsets) {
      final testRect = targetRect.shift(offset);
      if (!hasCollision(testRect, excludePanelId: excludePanelId) &&
          _isRectInBounds(testRect)) {
        return testRect;
      }
    }

    return null;  // Couldn't find non-colliding position
  }

  /// Check if rect is within container bounds
  bool _isRectInBounds(Rect rect) {
    return rect.left >= 0 &&
           rect.top >= 0 &&
           rect.right <= containerSize.width &&
           rect.bottom <= containerSize.height;
  }

  // ============================================================================
  // AUTO-LAYOUT
  // ============================================================================

  /// Auto-arrange panels in dock zone
  void autoLayoutZone(DockZone zone) {
    if (!config.enableAutoLayout || zone == DockZone.floating) return;

    final panels = getPanelsInZone(zone);

    for (int i = 0; i < panels.length; i++) {
      final panel = panels[i];
      final newRect = getDOCKedRect(panel.id, zone, panel.rect.size);

      _panels[panel.id] = panel.copyWith(
        rect: newRect,
        order: i,
      );
    }

    notifyListeners();
  }

  /// Auto-arrange all docked panels
  void autoLayoutAll() {
    autoLayoutZone(DockZone.top);
    autoLayoutZone(DockZone.bottom);
    autoLayoutZone(DockZone.left);
    autoLayoutZone(DockZone.right);
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Get total number of panels
  int get panelCount => _panels.length;

  /// Get number of docked panels
  int get dockedPanelCount =>
      _panels.values.where((p) => p.zone.isDocked).length;

  /// Get number of floating panels
  int get floatingPanelCount =>
      _panels.values.where((p) => p.zone == DockZone.floating).length;

  /// Clear all panels
  void clear() {
    _panels.clear();
    notifyListeners();
  }
}

// ============================================================================
// DOCK ZONE INDICATOR
// ============================================================================

/// Visual indicator for dock zones
class DockZoneIndicator extends StatelessWidget {
  final DockZone zone;
  final bool isActive;
  final Color color;
  final double opacity;

  const DockZoneIndicator({
    Key? key,
    required this.zone,
    this.isActive = false,
    this.color = DesignTokens.stateActive,
    this.opacity = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (zone == DockZone.floating) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rect = _getRectForZone(zone, constraints.biggest);

        return Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: DesignTokens.micro,
              decoration: BoxDecoration(
                color: color.withOpacity(isActive ? opacity * 2 : opacity),
                border: Border.all(
                  color: color.withOpacity(isActive ? 0.8 : 0.4),
                  width: isActive ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      zone.icon,
                      color: color.withOpacity(isActive ? 1.0 : 0.6),
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      zone.label,
                      style: DesignTokens.headlineMedium.copyWith(
                        color: color.withOpacity(isActive ? 1.0 : 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Rect _getRectForZone(DockZone zone, Size containerSize) {
    const margin = 20.0;
    const thickness = 100.0;

    switch (zone) {
      case DockZone.top:
        return Rect.fromLTWH(
          margin,
          margin,
          containerSize.width - margin * 2,
          thickness,
        );

      case DockZone.bottom:
        return Rect.fromLTWH(
          margin,
          containerSize.height - margin - thickness,
          containerSize.width - margin * 2,
          thickness,
        );

      case DockZone.left:
        return Rect.fromLTWH(
          margin,
          margin + thickness + 20,
          thickness,
          containerSize.height - margin * 2 - thickness * 2 - 40,
        );

      case DockZone.right:
        return Rect.fromLTWH(
          containerSize.width - margin - thickness,
          margin + thickness + 20,
          thickness,
          containerSize.height - margin * 2 - thickness * 2 - 40,
        );

      case DockZone.floating:
        return Rect.zero;
    }
  }
}
