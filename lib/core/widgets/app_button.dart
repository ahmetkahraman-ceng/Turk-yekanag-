import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, danger, text }

/// Merkezi buton bileşeni.
/// Varyantlar: primary, secondary, danger, text.
/// Özellikler: loading, disabled, ikonlu, tam genişlik, 0.97 basma ölçeği ve haptic.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.semanticsLabel,
    this.enableHaptic = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final String? semanticsLabel;
  final bool enableHaptic;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  bool get _isInteractive => !widget.isLoading && widget.onPressed != null;

  void _handleTap() {
    if (!_isInteractive) return;
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnim = AppMotion.isAnimationsDisabled(context);
    final scale = (_isPressed && !disableAnim) ? AppMotion.pressedScale : 1.0;

    return Semantics(
      button: true,
      enabled: _isInteractive,
      label: widget.semanticsLabel ?? widget.label,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.variant == AppButtonVariant.text
              ? AppSpacing.minTouchTarget
              : AppSpacing.primaryButtonHeight,
          minWidth: widget.isExpanded
              ? double.infinity
              : AppSpacing.minTouchTarget,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTapDown: _isInteractive
              ? (_) => setState(() => _isPressed = true)
              : null,
          onTapUp: _isInteractive
              ? (_) => setState(() => _isPressed = false)
              : null,
          onTapCancel: _isInteractive
              ? () => setState(() => _isPressed = false)
              : null,
          child: AnimatedScale(
            scale: scale,
            duration: AppMotion.resolveDuration(context, AppMotion.fast),
            curve: AppMotion.outCurve,
            child: _ButtonSurface(
              variant: widget.variant,
              label: widget.label,
              icon: widget.icon,
              isLoading: widget.isLoading,
              onPressed: _isInteractive ? _handleTap : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonSurface extends StatelessWidget {
  const _ButtonSurface({
    required this.variant,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.icon,
  });

  final AppButtonVariant variant;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fgColor = switch (variant) {
      AppButtonVariant.primary => scheme.onPrimary,
      AppButtonVariant.danger => AppColors.onError,
      AppButtonVariant.secondary => scheme.onSurface,
      AppButtonVariant.text => scheme.primary,
    };

    final child = _ButtonInnerContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
      indicatorColor: fgColor,
    );

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: onPressed,
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onError,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.buttonBorder,
            ),
          ),
          onPressed: onPressed,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: onPressed,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: onPressed,
          child: child,
        ),
    };
  }
}

class _ButtonInnerContent extends StatelessWidget {
  const _ButtonInnerContent({
    required this.label,
    required this.isLoading,
    required this.indicatorColor,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: indicatorColor,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
