///
/// Flexible Layout System
///
/// Grid-based layout system for responsive, resizable UI components.
/// Provides 12-column grid with breakpoints, snap-to-grid, and
/// automatic layout calculations.
///
/// Features:
/// - 12-column responsive grid
/// - Portrait/landscape breakpoints
/// - Snap-to-grid positioning
/// - Grid unit calculations
/// - Constraint validation
///
/// Part of the Next-Generation UI Redesign (v3.0) - Phase 2
///
/// A Paul Phillips Manifestation
////

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ============================================================================
// GRID CONFIGURATION
// ============================================================================

/// Grid configuration
class GridConfig {
  final int columns;
  final double gutterSize;
  final EdgeInsets padding;
  final bool snapToGrid;

  const GridConfig({
    this.columns = 12,
    this.gutterSize = 8.0,
    this.padding = const EdgeInsets.all(8.0),
    this.snapToGrid = true,
  });

  /// Default grid config
  static const standard = GridConfig(
    columns: 12,
    gutterSize: 8.0,
    padding: EdgeInsets.all(8.0),
    snapToGrid: true,
  );

  /// Dense grid (smaller gutters)
  static const dense = GridConfig(
    columns: 12,
    gutterSize: 4.0,
    padding: EdgeInsets.all(4.0),
    snapToGrid: true,
  );

  /// Loose grid (larger gutters)
  static const loose = GridConfig(
    columns: 12,
    gutterSize: 16.0,
    padding: EdgeInsets.all(16.0),
    snapToGrid: true,
  );
}

// ============================================================================
// BREAKPOINTS
// ============================================================================

/// Screen orientation breakpoint
enum LayoutBreakpoint {
  portrait, // Height > width
  landscape, // Width > height
  square, // Width ≈ height
}

/// Breakpoint utilities
class Breakpoints {
  /// Get breakpoint for given size
  static LayoutBreakpoint getBreakpoint(Size size) {
    final aspectRatio = size.width / size.height;

    if (aspectRatio < 0.9) {
      return LayoutBreakpoint.portrait;
    } else if (aspectRatio > 1.1) {
      return LayoutBreakpoint.landscape;
    } else {
      return LayoutBreakpoint.square;
    }
  }

  /// Check if portrait
  static bool isPortrait(Size size) =>
      getBreakpoint(size) == LayoutBreakpoint.portrait;

  /// Check if landscape
  static bool isLandscape(Size size) =>
      getBreakpoint(size) == LayoutBreakpoint.landscape;

  /// Check if square
  static bool isSquare(Size size) =>
      getBreakpoint(size) == LayoutBreakpoint.square;
}

// ============================================================================
// GRID UNITS
// ============================================================================

/// Grid unit representation (columns × rows)
class GridUnits {
  final int columns; // Width in grid columns
  final int rows; // Height in grid rows

  const GridUnits(this.columns, this.rows);

  /// 1×1 unit
  static const unit1x1 = GridUnits(1, 1);

  /// 2×2 units
  static const unit2x2 = GridUnits(2, 2);

  /// 3×3 units
  static const unit3x3 = GridUnits(3, 3);

  /// 4×4 units
  static const unit4x4 = GridUnits(4, 4);

  /// 6×6 units
  static const unit6x6 = GridUnits(6, 6);

  /// Full width (12 columns)
  static const fullWidth = GridUnits(12, 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridUnits &&
          runtimeType == other.runtimeType &&
          columns == other.columns &&
          rows == other.rows;

  @override
  int get hashCode => columns.hashCode ^ rows.hashCode;

  @override
  String toString() => 'GridUnits($columns×$rows)';
}

// ============================================================================
// GRID POSITION
// ============================================================================

/// Position in grid coordinates
class GridPosition {
  final int column; // Column index (0-based)
  final int row; // Row index (0-based)

  const GridPosition(this.column, this.row);

  /// Top-left corner
  static const topLeft = GridPosition(0, 0);

  /// Center (approximate)
  static GridPosition center(GridConfig config) =>
      GridPosition(config.columns ~/ 2, 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          column == other.column &&
          row == other.row;

  @override
  int get hashCode => column.hashCode ^ row.hashCode;

  @override
  String toString() => 'GridPosition(col: $column, row: $row)';
}

// ============================================================================
// GRID CALCULATOR
// ============================================================================

/// Grid calculation utilities
class GridCalculator {
  final GridConfig config;
  final Size containerSize;

  GridCalculator({
    required this.config,
    required this.containerSize,
  });

  /// Calculate column width
  double get columnWidth {
    final availableWidth = containerSize.width -
        config.padding.horizontal -
        (config.gutterSize * (config.columns - 1));
    return availableWidth / config.columns;
  }

  /// Calculate size in pixels from grid units
  Size calculateSize(GridUnits units) {
    final width = (columnWidth * units.columns) +
        (config.gutterSize * (units.columns - 1));

    // Assume square cells for row height
    final rowHeight = columnWidth;
    final height =
        (rowHeight * units.rows) + (config.gutterSize * (units.rows - 1));

    return Size(width, height);
  }

  /// Calculate position in pixels from grid position
  Offset calculatePosition(GridPosition position) {
    final x = config.padding.left +
        (columnWidth * position.column) +
        (config.gutterSize * position.column);

    final rowHeight = columnWidth;
    final y = config.padding.top +
        (rowHeight * position.row) +
        (config.gutterSize * position.row);

    return Offset(x, y);
  }

  /// Snap pixel position to grid
  GridPosition snapToGrid(Offset pixelPosition) {
    if (!config.snapToGrid) {
      return pixelToGrid(pixelPosition);
    }

    // Remove padding
    final adjustedX = pixelPosition.dx - config.padding.left;
    final adjustedY = pixelPosition.dy - config.padding.top;

    // Calculate column
    final columnWithGutter = columnWidth + config.gutterSize;
    final column =
        (adjustedX / columnWithGutter).round().clamp(0, config.columns - 1);

    // Calculate row
    final rowHeight = columnWidth;
    final rowWithGutter = rowHeight + config.gutterSize;
    final row =
        (adjustedY / rowWithGutter).round().clamp(0, 100); // Max 100 rows

    return GridPosition(column, row);
  }

  /// Convert pixel position to grid position (exact, no snapping)
  GridPosition pixelToGrid(Offset pixelPosition) {
    final adjustedX = pixelPosition.dx - config.padding.left;
    final adjustedY = pixelPosition.dy - config.padding.top;

    final columnWithGutter = columnWidth + config.gutterSize;
    final column =
        (adjustedX / columnWithGutter).floor().clamp(0, config.columns - 1);

    final rowHeight = columnWidth;
    final rowWithGutter = rowHeight + config.gutterSize;
    final row = (adjustedY / rowWithGutter).floor().clamp(0, 100);

    return GridPosition(column, row);
  }

  /// Convert pixel size to grid units
  GridUnits pixelToGridUnits(Size pixelSize) {
    final columnWithGutter = columnWidth + config.gutterSize;
    final columns = ((pixelSize.width + config.gutterSize) / columnWithGutter)
        .round()
        .clamp(1, config.columns);

    final rowHeight = columnWidth;
    final rowWithGutter = rowHeight + config.gutterSize;
    final rows = ((pixelSize.height + config.gutterSize) / rowWithGutter)
        .round()
        .clamp(1, 100);

    return GridUnits(columns, rows);
  }

  /// Check if grid units fit at position
  bool canFit(GridPosition position, GridUnits units) {
    return position.column + units.columns <= config.columns;
  }

  /// Find next available position for given units
  GridPosition? findNextAvailablePosition(
    GridUnits units,
    Set<Rect> occupiedRects,
  ) {
    for (int row = 0; row < 100; row++) {
      for (int col = 0; col <= config.columns - units.columns; col++) {
        final position = GridPosition(col, row);
        final rect = getRectForGridArea(position, units);

        // Check if this rect overlaps with any occupied rects
        bool overlaps = false;
        for (final occupied in occupiedRects) {
          if (rect.overlaps(occupied)) {
            overlaps = true;
            break;
          }
        }

        if (!overlaps) {
          return position;
        }
      }
    }

    return null; // No available position found
  }

  /// Get bounding rect for grid area
  Rect getRectForGridArea(GridPosition position, GridUnits units) {
    final topLeft = calculatePosition(position);
    final size = calculateSize(units);
    return Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
  }

  /// Constrain grid units to valid range
  GridUnits constrainUnits(GridUnits units) {
    return GridUnits(
      units.columns.clamp(1, config.columns),
      units.rows.clamp(1, 100),
    );
  }

  /// Constrain grid position to valid range
  GridPosition constrainPosition(GridPosition position, GridUnits units) {
    return GridPosition(
      position.column.clamp(0, config.columns - units.columns),
      position.row.clamp(0, 99),
    );
  }
}

// ============================================================================
// GRID OVERLAY (debug visualization)
// ============================================================================

/// Visual grid overlay for debugging
class GridOverlay extends StatelessWidget {
  final GridConfig config;
  final bool showLabels;
  final Color gridColor;
  final double opacity;

  const GridOverlay({
    Key? key,
    this.config = GridConfig.standard,
    this.showLabels = true,
    this.gridColor = DesignTokens.stateActive,
    this.opacity = 0.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final calculator = GridCalculator(
          config: config,
          containerSize: constraints.biggest,
        );

        return CustomPaint(
          painter: _GridPainter(
            calculator: calculator,
            config: config,
            showLabels: showLabels,
            gridColor: gridColor.withOpacity(opacity),
          ),
          size: constraints.biggest,
        );
      },
    );
  }
}

/// Custom painter for grid
class _GridPainter extends CustomPainter {
  final GridCalculator calculator;
  final GridConfig config;
  final bool showLabels;
  final Color gridColor;

  _GridPainter({
    required this.calculator,
    required this.config,
    required this.showLabels,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw vertical lines (columns)
    for (int col = 0; col <= config.columns; col++) {
      final position = calculator.calculatePosition(GridPosition(col, 0));
      canvas.drawLine(
        Offset(position.dx, 0),
        Offset(position.dx, size.height),
        paint,
      );

      // Draw column labels
      if (showLabels && col < config.columns) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$col',
            style: DesignTokens.labelSmall.copyWith(color: gridColor),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(position.dx + 4, 4),
        );
      }
    }

    // Draw horizontal lines (rows) - show first 10
    final rowHeight = calculator.columnWidth;
    for (int row = 0; row <= 10; row++) {
      final y =
          config.padding.top + (rowHeight * row) + (config.gutterSize * row);

      if (y > size.height) break;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

// ============================================================================
// GRID CONTAINER WIDGET
// ============================================================================

/// Container that enforces grid layout
class GridContainer extends StatelessWidget {
  final GridConfig config;
  final List<Widget> children;
  final bool showGrid;

  const GridContainer({
    Key? key,
    this.config = GridConfig.standard,
    required this.children,
    this.showGrid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Children
        ...children,

        // Debug grid overlay
        if (showGrid)
          IgnorePointer(
            child: GridOverlay(config: config),
          ),
      ],
    );
  }
}

// ============================================================================
// HELPER EXTENSIONS
// ============================================================================

extension GridUnitsExtension on GridUnits {
  /// Get total grid cells
  int get totalCells => columns * rows;

  /// Check if valid for given config
  bool isValidFor(GridConfig config) {
    return columns > 0 && columns <= config.columns && rows > 0;
  }

  /// Scale by factor
  GridUnits scale(double factor) {
    return GridUnits(
      (columns * factor).round().clamp(1, 12),
      (rows * factor).round().clamp(1, 100),
    );
  }
}

extension GridPositionExtension on GridPosition {
  /// Check if valid for given config
  bool isValidFor(GridConfig config) {
    return column >= 0 && column < config.columns && row >= 0;
  }

  /// Translate by delta
  GridPosition translate(int deltaColumn, int deltaRow) {
    return GridPosition(column + deltaColumn, row + deltaRow);
  }

  /// Distance to another position
  double distanceTo(GridPosition other) {
    final dx = (column - other.column).toDouble();
    final dy = (row - other.row).toDouble();
    return math.sqrt(dx * dx + dy * dy);
  }
}
