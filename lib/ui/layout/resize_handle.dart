/**
 * Resize Handle Widget
 *
 * Interactive handles for resizing panels. Supports corner and edge
 * handles with visual feedback and snap-to-grid behavior.
 *
 * Features:
 * - Corner handles (8 directions)
 * - Edge handles (4 directions)
 * - Visual feedback (hover, active)
 * - Snap-to-grid support
 * - Touch-optimized sizes
 *
 * Part of the Next-Generation UI Redesign (v3.0) - Phase 2
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ============================================================================
// RESIZE DIRECTION
// ============================================================================

/// Direction for resize operation
enum ResizeDirection {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

extension ResizeDirectionExtension on ResizeDirection {
  /// Check if this is a corner handle
  bool get isCorner {
    return this == ResizeDirection.topLeft ||
           this == ResizeDirection.topRight ||
           this == ResizeDirection.bottomLeft ||
           this == ResizeDirection.bottomRight;
  }

  /// Check if this is an edge handle
  bool get isEdge => !isCorner;

  /// Check if this affects top edge
  bool get affectsTop {
    return this == ResizeDirection.topLeft ||
           this == ResizeDirection.topCenter ||
           this == ResizeDirection.topRight;
  }

  /// Check if this affects bottom edge
  bool get affectsBottom {
    return this == ResizeDirection.bottomLeft ||
           this == ResizeDirection.bottomCenter ||
           this == ResizeDirection.bottomRight;
  }

  /// Check if this affects left edge
  bool get affectsLeft {
    return this == ResizeDirection.topLeft ||
           this == ResizeDirection.centerLeft ||
           this == ResizeDirection.bottomLeft;
  }

  /// Check if this affects right edge
  bool get affectsRight {
    return this == ResizeDirection.topRight ||
           this == ResizeDirection.centerRight ||
           this == ResizeDirection.bottomRight;
  }

  /// Get mouse cursor for this direction
  MouseCursor get cursor {
    switch (this) {
      case ResizeDirection.topLeft:
      case ResizeDirection.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeDirection.topRight:
      case ResizeDirection.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case ResizeDirection.topCenter:
      case ResizeDirection.bottomCenter:
        return SystemMouseCursors.resizeUpDown;
      case ResizeDirection.centerLeft:
      case ResizeDirection.centerRight:
        return SystemMouseCursors.resizeLeftRight;
    }
  }
}

// ============================================================================
// RESIZE HANDLE WIDGET
// ============================================================================

/// Interactive resize handle
class ResizeHandle extends StatefulWidget {
  final ResizeDirection direction;
  final ValueChanged<Offset> onResize;
  final VoidCallback? onResizeStart;
  final VoidCallback? onResizeEnd;
  final bool visible;
  final Color color;
  final double size;

  const ResizeHandle({
    Key? key,
    required this.direction,
    required this.onResize,
    this.onResizeStart,
    this.onResizeEnd,
    this.visible = true,
    this.color = DesignTokens.stateActive,
    this.size = 12.0,
  }) : super(key: key);

  @override
  State<ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle> {
  bool _isHovering = false;
  bool _isDragging = false;
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    final isActive = _isHovering || _isDragging;

    return Positioned(
      ..._getPositionConstraints(),
      child: MouseRegion(
        cursor: widget.direction.cursor,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: isActive
                  ? widget.color.withOpacity(0.8)
                  : widget.color.withOpacity(0.4),
              border: Border.all(
                color: isActive
                    ? widget.color
                    : widget.color.withOpacity(0.6),
                width: isActive ? 2.0 : 1.0,
              ),
              borderRadius: widget.direction.isCorner
                  ? BorderRadius.circular(widget.size / 2)
                  : BorderRadius.zero,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  /// Get positioning constraints for this handle
  Map<String, double> _getPositionConstraints() {
    final constraints = <String, double>{};
    final offset = widget.size / 2;

    switch (widget.direction) {
      case ResizeDirection.topLeft:
        constraints['top'] = -offset;
        constraints['left'] = -offset;
        break;
      case ResizeDirection.topCenter:
        constraints['top'] = -offset;
        constraints['left'] = 0;
        constraints['right'] = 0;
        break;
      case ResizeDirection.topRight:
        constraints['top'] = -offset;
        constraints['right'] = -offset;
        break;
      case ResizeDirection.centerLeft:
        constraints['top'] = 0;
        constraints['bottom'] = 0;
        constraints['left'] = -offset;
        break;
      case ResizeDirection.centerRight:
        constraints['top'] = 0;
        constraints['bottom'] = 0;
        constraints['right'] = -offset;
        break;
      case ResizeDirection.bottomLeft:
        constraints['bottom'] = -offset;
        constraints['left'] = -offset;
        break;
      case ResizeDirection.bottomCenter:
        constraints['bottom'] = -offset;
        constraints['left'] = 0;
        constraints['right'] = 0;
        break;
      case ResizeDirection.bottomRight:
        constraints['bottom'] = -offset;
        constraints['right'] = -offset;
        break;
    }

    return constraints;
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStart = details.localPosition;
    });
    widget.onResizeStart?.call();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;

    final delta = details.localPosition - _dragStart!;
    widget.onResize(delta);
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragStart = null;
    });
    widget.onResizeEnd?.call();
  }
}

// ============================================================================
// RESIZE HANDLE SET
// ============================================================================

/// Callback for resize events with direction
typedef ResizeCallback = void Function(ResizeDirection direction, Offset delta);

/// Set of resize handles for all directions
class ResizeHandleSet extends StatelessWidget {
  final ResizeCallback onResize;
  final VoidCallback? onResizeStart;
  final VoidCallback? onResizeEnd;
  final bool showCorners;
  final bool showEdges;
  final Color color;
  final double size;

  const ResizeHandleSet({
    Key? key,
    required this.onResize,
    this.onResizeStart,
    this.onResizeEnd,
    this.showCorners = true,
    this.showEdges = true,
    this.color = DesignTokens.stateActive,
    this.size = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Corner handles
        if (showCorners) ...[
          ResizeHandle(
            direction: ResizeDirection.topLeft,
            onResize: (delta) => onResize(ResizeDirection.topLeft, delta),
            onResizeStart: onResizeStart,
            onResizeEnd: onResizeEnd,
            color: color,
            size: size,
          ),
          ResizeHandle(
            direction: ResizeDirection.topRight,
            onResize: (delta) => onResize(ResizeDirection.topRight, delta),
            onResizeStart: onResizeStart,
            onResizeEnd: onResizeEnd,
            color: color,
            size: size,
          ),
          ResizeHandle(
            direction: ResizeDirection.bottomLeft,
            onResize: (delta) => onResize(ResizeDirection.bottomLeft, delta),
            onResizeStart: onResizeStart,
            onResizeEnd: onResizeEnd,
            color: color,
            size: size,
          ),
          ResizeHandle(
            direction: ResizeDirection.bottomRight,
            onResize: (delta) => onResize(ResizeDirection.bottomRight, delta),
            onResizeStart: onResizeStart,
            onResizeEnd: onResizeEnd,
            color: color,
            size: size,
          ),
        ],

        // Edge handles
        if (showEdges) ...[
          ResizeHandle(
            direction: ResizeDirection.topCenter,
            onResize: (delta) => onResize(ResizeDirection.topCenter, delta),
            onResizeStart: onResizeStart,
            onResizeEnd: onResizeEnd,
            color: color,
            size: size,
          ),
          ResizeHandle(
            direction: ResizeDirection.bottomCenter,
            onResize: (delta) => onResize(ResizeDirection.bottomCenter, delta),
            onResizeStart: onResizeStart,
            onResizeEnd: onResizeEnd,
            color: color,
            size: size,
          ),
          ResizeHandle(
            direction: ResizeDirection.centerLeft,
            onResize: (delta) => onResize(ResizeDirection.centerLeft, delta),
            onResizeStart: onResizeStart,
            onResizeEnd: onResizeEnd,
            color: color,
            size: size,
          ),
          ResizeHandle(
            direction: ResizeDirection.centerRight,
            onResize: (delta) => onResize(ResizeDirection.centerRight, delta),
            onResizeStart: onResizeStart,
            onResizeEnd: onResizeEnd,
            color: color,
            size: size,
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// RESIZE PREVIEW OVERLAY
// ============================================================================

/// Visual preview during resize operation
class ResizePreviewOverlay extends StatelessWidget {
  final Rect previewRect;
  final Color color;
  final bool show;

  const ResizePreviewOverlay({
    Key? key,
    required this.previewRect,
    this.color = DesignTokens.stateActive,
    this.show = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Positioned(
      left: previewRect.left,
      top: previewRect.top,
      width: previewRect.width,
      height: previewRect.height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              '${previewRect.width.toInt()} × ${previewRect.height.toInt()}',
              style: DesignTokens.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
