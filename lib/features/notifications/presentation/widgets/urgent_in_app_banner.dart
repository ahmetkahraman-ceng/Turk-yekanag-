import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';

/// Uygulama açıkken yeni ACİL ve uyumlu talepte üstten kayan heads-up kart.
class UrgentInAppBanner extends StatelessWidget {
  const UrgentInAppBanner({
    required this.request,
    required this.onDismiss,
    super.key,
  });

  final BloodRequest request;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.priority_high_rounded,
                color: AppColors.onPrimary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.urgentHeadsUpTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    Text(
                      '${request.bloodType.code} • ${request.hospital.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  onDismiss();
                  context.push('${AppRoutes.requests}/${request.id}');
                },
                child: Text(
                  l10n.urgentHeadsUpAction,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.onPrimary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
