import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';

/// Merkezi Bottom Sheet yardımcı sınıfı (üst köşe: 28dp).
abstract final class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetBorder,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: builder(ctx),
      ),
    );
  }
}

/// Onay Bottom Sheet'i.
class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    super.key,
    this.cancelLabel,
    this.isDanger = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final bool isDanger;
  final IconData? icon;

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    bool isDanger = false,
    IconData? icon,
  }) async {
    final result = await AppBottomSheet.show<bool>(
      context: context,
      builder: (_) => ConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            title,
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: confirmLabel,
            variant:
                isDanger ? AppButtonVariant.danger : AppButtonVariant.primary,
            enableHaptic: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: cancelLabel ?? l10n.commonCancel,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

/// Merkezi Dialog yardımcı sınıfı.
abstract final class AppDialog {
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    bool isDanger = false,
  }) async {
    final l10n = context.l10n;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel ?? l10n.commonCancel),
          ),
          AppButton(
            label: confirmLabel,
            isExpanded: false,
            variant:
                isDanger ? AppButtonVariant.danger : AppButtonVariant.primary,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}

/// Merkezi Snackbar yardımcı sınıfı.
abstract final class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info_outline_rounded,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.surface,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
