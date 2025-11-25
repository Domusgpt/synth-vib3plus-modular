/**
 * Context-Sensitive Help Overlay
 *
 * Interactive help system that provides contextual guidance based on user
 * location and actions. Includes tooltips, walkthroughs, feature highlights,
 * and interactive tutorials.
 *
 * Features:
 * - Context-aware help based on current screen/component
 * - Interactive walkthroughs (first-time user experience)
 * - Feature highlights with animated pointers
 * - Tooltip system with rich content
 * - Gesture instruction overlays
 * - Quick reference sheets
 * - Search help topics
 * - Video tutorial integration
 * - Help history tracking
 *
 * Part of the Integration Layer (Phase 3.5)
 *
 * A Paul Phillips Manifestation
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../effects/glassmorphic_container.dart';

// ============================================================================
// HELP CONTEXT
// ============================================================================

/// Help context types
enum HelpContext {
  mainScreen,
  xyPad,
  orbController,
  modulationMatrix,
  presetBrowser,
  performanceMonitor,
  layoutEditor,
  audioSettings,
  visualSettings,
  gestures,
}

extension HelpContextExtension on HelpContext {
  String get displayName {
    switch (this) {
      case HelpContext.mainScreen:
        return 'Main Screen';
      case HelpContext.xyPad:
        return 'XY Performance Pad';
      case HelpContext.orbController:
        return 'Orb Controller';
      case HelpContext.modulationMatrix:
        return 'Modulation Matrix';
      case HelpContext.presetBrowser:
        return 'Preset Browser';
      case HelpContext.performanceMonitor:
        return 'Performance Monitor';
      case HelpContext.layoutEditor:
        return 'Layout Editor';
      case HelpContext.audioSettings:
        return 'Audio Settings';
      case HelpContext.visualSettings:
        return 'Visual Settings';
      case HelpContext.gestures:
        return 'Gestures';
    }
  }

  String get description {
    switch (this) {
      case HelpContext.mainScreen:
        return 'The main synthesizer interface combining audio and visual controls';
      case HelpContext.xyPad:
        return 'Multi-touch performance controller for frequency and filter modulation';
      case HelpContext.orbController:
        return 'Holographic pitch bend and vibrato controller';
      case HelpContext.modulationMatrix:
        return 'Visual modulation routing interface';
      case HelpContext.presetBrowser:
        return 'Browse, search, and manage presets';
      case HelpContext.performanceMonitor:
        return 'Real-time performance metrics and system health';
      case HelpContext.layoutEditor:
        return 'Customize panel layout and arrangement';
      case HelpContext.audioSettings:
        return 'Configure audio engine parameters';
      case HelpContext.visualSettings:
        return 'Adjust VIB3+ visualization settings';
      case HelpContext.gestures:
        return 'Multi-touch gesture controls';
    }
  }

  List<HelpTopic> get topics {
    switch (this) {
      case HelpContext.xyPad:
        return [
          const HelpTopic(
            title: 'Multi-Touch Control',
            content: 'Use multiple fingers simultaneously for polyphonic control. Each touch point controls independent frequency and filter parameters.',
            icon: Icons.touch_app,
          ),
          const HelpTopic(
            title: 'Trails',
            content: 'Touch trails visualize your movement and provide visual feedback for parameter changes.',
            icon: Icons.gesture,
          ),
          const HelpTopic(
            title: 'Grid Snapping',
            content: 'Enable grid snapping for quantized note values. Useful for melodic performance.',
            icon: Icons.grid_on,
          ),
        ];
      case HelpContext.orbController:
        return [
          const HelpTopic(
            title: 'Pitch Bend',
            content: 'Drag horizontally to bend pitch. Range is configurable from ±1 to ±12 semitones.',
            icon: Icons.tune,
          ),
          const HelpTopic(
            title: 'Vibrato',
            content: 'Drag vertically for vibrato depth. Higher movement = more intense vibrato.',
            icon: Icons.graphic_eq,
          ),
          const HelpTopic(
            title: 'Auto-Return',
            content: 'Release to automatically return to center. Disable in settings for manual control.',
            icon: Icons.settings_backup_restore,
          ),
        ];
      case HelpContext.modulationMatrix:
        return [
          const HelpTopic(
            title: 'Creating Connections',
            content: 'Drag from a source (left) to a target (right) to create a modulation connection.',
            icon: Icons.cable,
          ),
          const HelpTopic(
            title: 'Adjusting Strength',
            content: 'Click a connection to select it, then adjust the strength slider at the bottom.',
            icon: Icons.tune,
          ),
          const HelpTopic(
            title: 'Bipolar Mode',
            content: 'Toggle bipolar mode to modulate in both positive and negative directions.',
            icon: Icons.swap_vert,
          ),
        ];
      case HelpContext.gestures:
        return [
          const HelpTopic(
            title: 'Pinch to Zoom',
            content: 'Use two fingers to pinch in/out for zooming the UI.',
            icon: Icons.zoom_in,
          ),
          const HelpTopic(
            title: 'Two-Finger Rotate',
            content: 'Rotate two fingers to adjust visual parameters.',
            icon: Icons.rotate_right,
          ),
          const HelpTopic(
            title: 'Three-Finger Swipe',
            content: 'Swipe with three fingers to navigate between presets.',
            icon: Icons.swipe,
          ),
        ];
      default:
        return [];
    }
  }
}

// ============================================================================
// HELP TOPIC
// ============================================================================

/// Individual help topic
class HelpTopic {
  final String title;
  final String content;
  final IconData icon;
  final String? videoUrl;
  final List<String>? keyboardShortcuts;

  const HelpTopic({
    required this.title,
    required this.content,
    required this.icon,
    this.videoUrl,
    this.keyboardShortcuts,
  });
}

// ============================================================================
// WALKTHROUGH STEP
// ============================================================================

/// Step in an interactive walkthrough
class WalkthroughStep {
  final String title;
  final String description;
  final Offset? targetPosition;  // Position to highlight
  final Size? targetSize;
  final IconData? icon;
  final VoidCallback? action;

  const WalkthroughStep({
    required this.title,
    required this.description,
    this.targetPosition,
    this.targetSize,
    this.icon,
    this.action,
  });
}

// ============================================================================
// HELP OVERLAY WIDGET
// ============================================================================

/// Context-sensitive help overlay
class HelpOverlay extends StatefulWidget {
  final HelpContext context;
  final VoidCallback? onClose;
  final bool showWalkthrough;

  const HelpOverlay({
    Key? key,
    required this.context,
    this.onClose,
    this.showWalkthrough = false,
  }) : super(key: key);

  @override
  State<HelpOverlay> createState() => _HelpOverlayState();
}

class _HelpOverlayState extends State<HelpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _walkthroughStep = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<HelpTopic> get _filteredTopics {
    final topics = widget.context.topics;
    if (_searchQuery.isEmpty) return topics;

    return topics.where((topic) {
      final query = _searchQuery.toLowerCase();
      return topic.title.toLowerCase().contains(query) ||
             topic.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping content
              child: widget.showWalkthrough
                  ? _buildWalkthrough()
                  : _buildHelpContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpContent() {
    return GlassmorphicContainer(
      width: 600,
      height: 700,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Search bar
          _buildSearchBar(),

          // Context info
          _buildContextInfo(),

          // Topics list
          Expanded(
            child: _buildTopicsList(),
          ),

          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, size: 24),
          const SizedBox(width: DesignTokens.spacing2),
          Text(
            'Help & Tutorials',
            style: DesignTokens.headingMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
            color: Colors.white.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: DesignTokens.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search help topics...',
          hintStyle: DesignTokens.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.4),
          ),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          ),
        ),
      ),
    );
  }

  Widget _buildContextInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing3),
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: DesignTokens.quantum.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: DesignTokens.quantum.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.context.displayName,
            style: DesignTokens.headingSmall.copyWith(
              color: DesignTokens.quantum,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing1),
          Text(
            widget.context.description,
            style: DesignTokens.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsList() {
    final topics = _filteredTopics;

    if (topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: DesignTokens.spacing3),
            Text(
              'No help topics found',
              style: DesignTokens.headingSmall.copyWith(
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return _buildTopicCard(topics[index]);
      },
    );
  }

  Widget _buildTopicCard(HelpTopic topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: GlassmorphicContainer(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacing3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spacing2),
                    decoration: BoxDecoration(
                      color: DesignTokens.quantum.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    ),
                    child: Icon(
                      topic.icon,
                      color: DesignTokens.quantum,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacing2),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: DesignTokens.headingSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacing2),
              Text(
                topic.content,
                style: DesignTokens.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              if (topic.keyboardShortcuts != null) ...[
                const SizedBox(height: DesignTokens.spacing2),
                Wrap(
                  spacing: DesignTokens.spacing1,
                  children: topic.keyboardShortcuts!.map((shortcut) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing2,
                        vertical: DesignTokens.spacing1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        shortcut,
                        style: DesignTokens.labelSmall.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (topic.videoUrl != null) ...[
                const SizedBox(height: DesignTokens.spacing2),
                TextButton.icon(
                  onPressed: () {
                    // Open video URL
                  },
                  icon: const Icon(Icons.play_circle_outline, size: 16),
                  label: const Text('Watch Tutorial'),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignTokens.quantum,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Show all gestures help
                setState(() {
                  // Switch to gestures context
                });
              },
              icon: const Icon(Icons.touch_app, size: 16),
              label: const Text('Gestures'),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Start walkthrough
              },
              icon: const Icon(Icons.ondemand_video, size: 16),
              label: const Text('Tutorial'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkthrough() {
    // TODO: Implement interactive walkthrough
    return Container();
  }
}

// ============================================================================
// TOOLTIP WIDGET
// ============================================================================

/// Rich tooltip with custom styling
class RichTooltip extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Widget child;
  final Color? color;

  const RichTooltip({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    required this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: WidgetSpan(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(DesignTokens.spacing2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: color ?? DesignTokens.quantum,
                    ),
                    const SizedBox(width: DesignTokens.spacing1),
                    Text(
                      title,
                      style: DesignTokens.labelMedium.copyWith(
                        color: color ?? DesignTokens.quantum,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  title,
                  style: DesignTokens.labelMedium.copyWith(
                    color: color ?? DesignTokens.quantum,
                  ),
                ),
              const SizedBox(height: DesignTokens.spacing1),
              Text(
                message,
                style: DesignTokens.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(
          color: (color ?? DesignTokens.quantum).withOpacity(0.5),
        ),
      ),
      child: child,
    );
  }
}

// ============================================================================
// FEATURE HIGHLIGHT
// ============================================================================

/// Animated feature highlight overlay
class FeatureHighlight extends StatefulWidget {
  final Offset position;
  final Size size;
  final String title;
  final String description;
  final VoidCallback onDismiss;

  const FeatureHighlight({
    Key? key,
    required this.position,
    required this.size,
    required this.title,
    required this.description,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<FeatureHighlight> createState() => _FeatureHighlightState();
}

class _FeatureHighlightState extends State<FeatureHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dimmed background
        GestureDetector(
          onTap: widget.onDismiss,
          child: Container(
            color: Colors.black.withOpacity(0.7),
          ),
        ),

        // Highlighted area
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: widget.size.width,
                  height: widget.size.height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: DesignTokens.stateActive.withOpacity(
                        0.5 + (_controller.value * 0.5),
                      ),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.stateActive.withOpacity(_controller.value * 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Description card
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy + widget.size.height + 20,
          child: GlassmorphicContainer(
            width: 300,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: DesignTokens.headingSmall.copyWith(
                      color: DesignTokens.stateActive,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing2),
                  Text(
                    widget.description,
                    style: DesignTokens.bodyMedium,
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: widget.onDismiss,
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
