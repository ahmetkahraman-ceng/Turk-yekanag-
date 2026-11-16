import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

/// Seçilebilir çip bileşeni (köşe: 999, min 48dp dokunma alanı).
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    super.key,
    this.selected = false,
    this.onSelected,
    this.icon,
    this.semanticsLabel,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel ?? label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.minTouchTarget,
        ),
        child: FilterChip(
          selected: selected,
          onSelected: onSelected,
          showCheckmark: icon == null,
          avatar: icon != null
              ? Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                )
              : null,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.chipBorder,
          ),
          label: Text(label),
        ),
      ),
    );
  }
}
