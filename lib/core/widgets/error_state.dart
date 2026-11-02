import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';

/// Hata durumunda kullanıcıya anlaşılır Türkçe/yerelleştirilmiş mesaj ve tekrar deneme
/// aksiyonu sunan ortak bileşen.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    super.key,
    this.title,
    this.onRetry,
  });

  final String? title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final effectiveTitle = title ?? l10n.commonErrorTitle;

    return Semantics(
      container: true,
      liveRegion: true,
      label: '$effectiveTitle. $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                effectiveTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: l10n.commonRetry,
                  semanticsLabel: l10n.commonRetrySemantics,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                  isExpanded: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
