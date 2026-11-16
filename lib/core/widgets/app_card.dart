import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_shadows.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

/// Merkezi kart bileşeni (köşe yuvarlaklığı: 20, opsiyonel sol vurgu şeridi ve dokunma desteği).
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.leftStripeColor,
    this.backgroundColor,
    this.borderColor,
    this.semanticsLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? leftStripeColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bgColor = backgroundColor ?? scheme.surface;
    final effectiveBorder =
        borderColor ?? scheme.outline.withValues(alpha: 0.55);

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (leftStripeColor != null) {
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: leftStripeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  bottomLeft: Radius.circular(AppRadius.card),
                ),
              ),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: effectiveBorder),
          boxShadow: AppShadows.cardFor(theme.brightness),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.cardBorder,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.cardBorder,
            child: content,
          ),
        ),
      ),
    );
  }
}
