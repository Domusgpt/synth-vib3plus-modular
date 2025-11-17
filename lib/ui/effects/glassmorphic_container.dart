///
/// Glassmorphic Container
///
/// Provides frosted glass effect with backdrop blur, transparency,
/// and audio-reactive modulation. Core visual component for the
/// holographic interface design system.
///
/// Features:
/// - Backdrop blur (configurable intensity)
/// - Semi-transparent background
/// - Border with glow effects
/// - Audio-reactive blur/opacity/glow
/// - Holographic gradient option
///
/// Part of the Next-Generation UI Redesign (v3.0)
///
/// A Paul Phillips Manifestation
///

library;

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../audio/audio_analyzer.dart';
import '../theme/design_tokens.dart';

/// Glassmorphic container with audio-reactive capabilities
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final GlassmorphicConfig config;
  final AudioFeatures? audioFeatures;
  final bool enableAudioReactivity;
  final bool enableHolographicGradient;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? customShadows;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.config = GlassmorphicConfig.interactive,
    this.audioFeatures,
    this.enableAudioReactivity = false,
    this.enableHolographicGradient = false,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.customShadows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Apply audio reactivity if enabled and features available
    final effectiveConfig = enableAudioReactivity && audioFeatures != null
        ? config.withAudioReactivity(
            rms: audioFeatures!.rms,
            spectralCentroid: audioFeatures!.spectralCentroid,
          )
        : config;

    // Calculate audio-reactive border glow
    final glowIntensity = enableAudioReactivity && audioFeatures != null
        ? DesignTokens.transientToGlow(audioFeatures!.transient)
        : 0.0;

    // Calculate audio-reactive border width
    final borderWidth = enableAudioReactivity && audioFeatures != null
        ? DesignTokens.bassEnergyToBorderWidth(audioFeatures!.bassEnergy)
        : effectiveConfig.borderWidth;

    // Generate holographic gradient if enabled
    final backgroundDecoration =
        enableHolographicGradient && audioFeatures != null
            ? BoxDecoration(
                gradient: DesignTokens.holographicGradient(
                  audioIntensity: audioFeatures!.rms,
                ),
                borderRadius: borderRadius ??
                    BorderRadius.circular(DesignTokens.radiusMedium),
              )
            : null;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius:
            borderRadius ?? BorderRadius.circular(DesignTokens.radiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveConfig.blurRadius,
            sigmaY: effectiveConfig.blurRadius,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveConfig.backgroundColor
                  .withValues(alpha: effectiveConfig.opacity),
              borderRadius: borderRadius ??
                  BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: effectiveConfig.borderColor,
                width: borderWidth,
              ),
              boxShadow: customShadows ?? _buildShadows(glowIntensity),
              gradient: backgroundDecoration?.gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Build shadow list with optional glow
  List<BoxShadow> _buildShadows(double glowIntensity) {
    final shadows = <BoxShadow>[];

    // Standard elevation shadow
    shadows.add(DesignTokens.shadowSmall(Colors.black));

    // Audio-reactive glow
    if (glowIntensity > 0.0 && audioFeatures != null) {
      // Color based on dominant frequency
      final glowColor = _getFrequencyColor(audioFeatures!.dominantFreq);
      shadows.add(BoxShadow(
        color: glowColor.withValues(alpha: glowIntensity / 10.0),
        blurRadius: glowIntensity,
        spreadRadius: glowIntensity / 2,
      ));
    }

    return shadows;
  }

  /// Map frequency to color (bass=red, mid=green, high=blue)
  Color _getFrequencyColor(double frequency) {
    if (frequency < 250) return DesignTokens.audioLow;
    if (frequency < 2000) return DesignTokens.audioMid;
    return DesignTokens.audioHigh;
  }
}

/// Glassmorphic card with preset styling
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final AudioFeatures? audioFeatures;
  final bool enableAudioReactivity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.audioFeatures,
    this.enableAudioReactivity = false,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final container = GlassmorphicContainer(
      config: GlassmorphicConfig.interactive,
      audioFeatures: audioFeatures,
      enableAudioReactivity: enableAudioReactivity,
      padding: padding ?? const EdgeInsets.all(DesignTokens.spacing3),
      margin: margin,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Glassmorphic panel for larger content areas
class GlassmorphicPanel extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final AudioFeatures? audioFeatures;
  final bool enableAudioReactivity;
  final bool enableHolographicGradient;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassmorphicPanel({
    Key? key,
    required this.child,
    this.title,
    this.trailing,
    this.audioFeatures,
    this.enableAudioReactivity = false,
    this.enableHolographicGradient = false,
    this.height,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      config: GlassmorphicConfig.interactive,
      audioFeatures: audioFeatures,
      enableAudioReactivity: enableAudioReactivity,
      enableHolographicGradient: enableHolographicGradient,
      height: height,
      margin: margin,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || trailing != null) _buildHeader(),
          Flexible(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(DesignTokens.spacing3),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing3,
        vertical: DesignTokens.spacing2,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != null)
            Text(
              title!,
              style: DesignTokens.headlineMedium.copyWith(
                color: DesignTokens.stateActive,
              ),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Glassmorphic button with state-based styling
class GlassmorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? activeColor;
  final bool isActive;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassmorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.activeColor,
    this.isActive = false,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.activeColor ?? DesignTokens.stateActive;
    final isDisabled = widget.onPressed == null;

    // Determine background color based on state
    Color backgroundColor;
    if (isDisabled) {
      backgroundColor = DesignTokens.stateDisabled;
    } else if (_isPressed) {
      backgroundColor = DesignTokens.pressed.withValues(alpha: 0.3);
    } else if (widget.isActive) {
      backgroundColor = effectiveColor.withValues(alpha: 0.2);
    } else {
      backgroundColor = Colors.white.withValues(alpha: 0.1);
    }

    // Border color
    final borderColor = isDisabled
        ? DesignTokens.stateDisabled
        : widget.isActive
            ? effectiveColor
            : Colors.white.withValues(alpha: 0.2);

    // Glow effect when active
    final shadows = widget.isActive && !isDisabled
        ? [DesignTokens.glowMedium(effectiveColor)]
        : <BoxShadow>[];

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: DesignTokens.micro,
        curve: DesignTokens.easeOut,
        width: widget.width,
        height: widget.height ?? DesignTokens.touchTargetMinimum,
        padding: widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing3,
              vertical: DesignTokens.spacing2,
            ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          border: Border.all(
            color: borderColor,
            width: widget.isActive ? 2.0 : 1.0,
          ),
          boxShadow: shadows,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

/// Glassmorphic modal overlay
class GlassmorphicModal extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDismiss;
  final bool barrierDismissible;
  final double? width;
  final double? height;

  const GlassmorphicModal({
    Key? key,
    required this.child,
    this.onDismiss,
    this.barrierDismissible = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Barrier
        GestureDetector(
          onTap: barrierDismissible ? onDismiss : null,
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        // Modal content
        Center(
          child: GlassmorphicContainer(
            config: GlassmorphicConfig.elevated,
            width: width,
            height: height,
            padding: const EdgeInsets.all(DesignTokens.spacing4),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            customShadows: [
              DesignTokens.shadowLarge(Colors.black),
            ],
            child: child,
          ),
        ),
      ],
    );
  }

  /// Show modal as overlay
  static void show(
    BuildContext context, {
    required Widget child,
    double? width,
    double? height,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (context) => GlassmorphicModal(
        onDismiss: () => Navigator.of(context).pop(),
        barrierDismissible: barrierDismissible,
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}
