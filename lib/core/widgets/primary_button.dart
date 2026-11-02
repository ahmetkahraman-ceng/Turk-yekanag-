import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

/// Erişilebilirlik kurallarına uygun (min 48dp dokunma alanı, Semantics destekli) ana buton.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.semanticsLabel,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final String label;
  final String? semanticsLabel;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    final Widget child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : Row(
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

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: semanticsLabel ?? label,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: AppSpacing.minTouchTarget,
          minWidth: isExpanded ? double.infinity : AppSpacing.minTouchTarget,
        ),
        child: ElevatedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      ),
    );
  }
}
