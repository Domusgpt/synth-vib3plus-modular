/**
 * Resizable Panel
 *
 * Panel component with drag-to-resize handles, size constraints,
 * grid snapping, and visual feedback. Foundation for customizable
 * layout system.
 *
 * Features:
 * - Drag-to-resize handles (corner + edge)
 * - Min/max size constraints
 * - Grid snapping
 * - Visual resize preview
 * - Docking support
 * - Layout persistence
 *
 * Part of the Next-Generation UI Redesign (v3.0) - Phase 2
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../effects/glassmorphic_container.dart';
import '../../layout/flexible_layout.dart';
import '../../layout/resize_handle.dart';
import 'reactive_component.dart';

// ============================================================================
// PANEL CONFIGURATION
// ============================================================================

/// Resizable panel configuration
class PanelConfig {
  final GridUnits defaultSize;
  final GridUnits minSize;
  final GridUnits maxSize;
  final bool allowResize;
  final bool allowMove;
  final bool showHandles;
  final bool snapToGrid;
  final bool showPreview;

  const PanelConfig({
    this.defaultSize = GridUnits.unit2x2,
    this.minSize = GridUnits.unit1x1,
    this.maxSize = GridUnits.unit6x6,
    this.allowResize = true,
    this.allowMove = true,
    this.showHandles = true,
    this.snapToGrid = true,
    this.showPreview = true,
  });

  /// Fixed size panel (no resizing)
  static const fixed = PanelConfig(
    allowResize: false,
    allowMove: false,
    showHandles: false,
  );

  /// Fully customizable panel
  static const customizable = PanelConfig(
    allowResize: true,
    allowMove: true,
    showHandles: true,
    snapToGrid: true,
    showPreview: true,
  );
}

// ============================================================================
// RESIZABLE PANEL WIDGET
// ============================================================================

/// Resizable panel component
class ResizablePanel extends StatefulWidget {
  final Widget child;
  final PanelConfig config;
  final GridConfig gridConfig;
  final GridPosition initialPosition;
  final GridUnits? initialSize;
  final ValueChanged<Size>? onResizeComplete;
  final ValueChanged<Offset>? onMoveComplete;
  final String? title;
  final Widget? trailing;
  final AudioFeatures? audioFeatures;
  final bool enableAudioReactivity;
  final Color? color;

  const ResizablePanel({
    Key? key,
    required this.child,
    this.config = PanelConfig.customizable,
    this.gridConfig = GridConfig.standard,
    this.initialPosition = GridPosition.topLeft,
    this.initialSize,
    this.onResizeComplete,
    this.onMoveComplete,
    this.title,
    this.trailing,
    this.audioFeatures,
    this.enableAudioReactivity = false,
    this.color,
  }) : super(key: key);

  @override
  State<ResizablePanel> createState() => ResizablePanelState();
}

class ResizablePanelState extends State<ResizablePanel> {
  late GridCalculator _calculator;
  late GridPosition _position;
  late GridUnits _size;

  bool _isResizing = false;
  bool _isMoving = false;
  Rect? _previewRect;
  Offset? _moveStartOffset;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _size = widget.initialSize ?? widget.config.defaultSize;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCalculator();
  }

  void _updateCalculator() {
    final size = MediaQuery.of(context).size;
    _calculator = GridCalculator(
      config: widget.gridConfig,
      containerSize: size,
    );
  }

  // ============================================================================
  // RESIZE HANDLING
  // ============================================================================

  void _handleResize(ResizeDirection direction, Offset delta) {
    setState(() {
      _isResizing = true;

      // Get current rect
      final currentRect = _calculator.getRectForGridArea(_position, _size);
      var newRect = Rect.fromLTWH(
        currentRect.left,
        currentRect.top,
        currentRect.width,
        currentRect.height,
      );

      // Apply delta based on direction
      if (direction.affectsLeft) {
        newRect = Rect.fromLTRB(
          currentRect.left + delta.dx,
          newRect.top,
          newRect.right,
          newRect.bottom,
        );
      }

      if (direction.affectsRight) {
        newRect = Rect.fromLTRB(
          newRect.left,
          newRect.top,
          currentRect.right + delta.dx,
          newRect.bottom,
        );
      }

      if (direction.affectsTop) {
        newRect = Rect.fromLTRB(
          newRect.left,
          currentRect.top + delta.dy,
          newRect.right,
          newRect.bottom,
        );
      }

      if (direction.affectsBottom) {
        newRect = Rect.fromLTRB(
          newRect.left,
          newRect.top,
          newRect.right,
          currentRect.bottom + delta.dy,
        );
      }

      // Convert to grid units
      final newSize = _calculator.pixelToGridUnits(newRect.size);

      // Apply constraints
      final constrainedSize = GridUnits(
        newSize.columns.clamp(widget.config.minSize.columns, widget.config.maxSize.columns),
        newSize.rows.clamp(widget.config.minSize.rows, widget.config.maxSize.rows),
      );

      // Update preview
      if (widget.config.showPreview) {
        final previewSize = _calculator.calculateSize(constrainedSize);
        _previewRect = Rect.fromLTWH(
          newRect.left,
          newRect.top,
          previewSize.width,
          previewSize.height,
        );
      }
    });
  }

  void _handleResizeEnd() {
    if (_previewRect != null) {
      // Convert preview rect to grid coordinates
      final newPosition = _calculator.pixelToGrid(_previewRect!.topLeft);
      final newSize = _calculator.pixelToGridUnits(_previewRect!.size);

      setState(() {
        _position = newPosition;
        _size = GridUnits(
          newSize.columns.clamp(widget.config.minSize.columns, widget.config.maxSize.columns),
          newSize.rows.clamp(widget.config.minSize.rows, widget.config.maxSize.rows),
        );
        _isResizing = false;
        _previewRect = null;
      });

      widget.onResizeComplete?.call(_calculator.calculateSize(_size));
    }
  }

  // ============================================================================
  // MOVE HANDLING
  // ============================================================================

  void _handleMoveStart(DragStartDetails details) {
    if (!widget.config.allowMove) return;

    setState(() {
      _isMoving = true;
      _moveStartOffset = details.globalPosition;
    });
  }

  void _handleMoveUpdate(DragUpdateDetails details) {
    if (!widget.config.allowMove || _moveStartOffset == null) return;

    setState(() {
      final delta = details.globalPosition - _moveStartOffset!;
      final currentRect = _calculator.getRectForGridArea(_position, _size);

      final newTopLeft = currentRect.topLeft + delta;

      if (widget.config.showPreview) {
        _previewRect = Rect.fromLTWH(
          newTopLeft.dx,
          newTopLeft.dy,
          currentRect.width,
          currentRect.height,
        );
      }
    });
  }

  void _handleMoveEnd(DragEndDetails details) {
    if (!widget.config.allowMove) return;

    if (_previewRect != null) {
      final newPosition = widget.config.snapToGrid
          ? _calculator.snapToGrid(_previewRect!.topLeft)
          : _calculator.pixelToGrid(_previewRect!.topLeft);

      setState(() {
        _position = newPosition;
        _isMoving = false;
        _previewRect = null;
        _moveStartOffset = null;
      });

      widget.onMoveComplete?.call(_calculator.calculatePosition(_position));
    }
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    _updateCalculator();

    final position = _calculator.calculatePosition(_position);
    final size = _calculator.calculateSize(_size);
    final effectiveColor = widget.color ?? DesignTokens.stateActive;

    return Stack(
      children: [
        // Main panel
        Positioned(
          left: position.dx,
          top: position.dy,
          width: size.width,
          height: size.height,
          child: GestureDetector(
            onPanStart: widget.config.allowMove ? _handleMoveStart : null,
            onPanUpdate: widget.config.allowMove ? _handleMoveUpdate : null,
            onPanEnd: widget.config.allowMove ? _handleMoveEnd : null,
            child: GlassmorphicPanel(
              title: widget.title,
              trailing: widget.trailing,
              audioFeatures: widget.audioFeatures,
              enableAudioReactivity: widget.enableAudioReactivity,
              padding: const EdgeInsets.all(DesignTokens.spacing3),
              child: Stack(
                children: [
                  // Content
                  widget.child,

                  // Resize handles
                  if (widget.config.allowResize && widget.config.showHandles)
                    ResizeHandleSet(
                      onResize: _handleResize,
                      onResizeStart: () => setState(() => _isResizing = true),
                      onResizeEnd: _handleResizeEnd,
                      color: effectiveColor,
                      showCorners: true,
                      showEdges: true,
                    ),

                  // State indicator (resizing/moving)
                  if (_isResizing || _isMoving)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing2,
                          vertical: DesignTokens.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                        child: Text(
                          _isResizing ? 'Resizing...' : 'Moving...',
                          style: DesignTokens.labelSmall.copyWith(
                            color: effectiveColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Resize preview
        if (_previewRect != null && widget.config.showPreview)
          ResizePreviewOverlay(
            previewRect: _previewRect!,
            color: effectiveColor,
            show: true,
          ),
      ],
    );
  }

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Get current position
  GridPosition get position => _position;

  /// Get current size
  GridUnits get size => _size;

  /// Get current rect
  Rect get rect => _calculator.getRectForGridArea(_position, _size);

  /// Set position programmatically
  void setPosition(GridPosition newPosition) {
    setState(() {
      _position = _calculator.constrainPosition(newPosition, _size);
    });
  }

  /// Set size programmatically
  void setSize(GridUnits newSize) {
    setState(() {
      _size = GridUnits(
        newSize.columns.clamp(widget.config.minSize.columns, widget.config.maxSize.columns),
        newSize.rows.clamp(widget.config.minSize.rows, widget.config.maxSize.rows),
      );
    });
  }

  /// Reset to initial state
  void reset() {
    setState(() {
      _position = widget.initialPosition;
      _size = widget.initialSize ?? widget.config.defaultSize;
    });
  }
}
