import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/services/app_version_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';

/// Remote Config'teki `min_version` mevcut sürümden yüksek olduğunda gösterilen zorunlu güncelleme ekranı.
class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({
    super.key,
    this.onUpdateTap,
  });

  final VoidCallback? onUpdateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final statusAsync = ref.watch(forceUpdateStatusProvider);

    final currentVersion = statusAsync.valueOrNull?.currentVersion ?? '1.0.0';
    final minVersion = statusAsync.valueOrNull?.minVersion ?? '1.0.0';

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.system_update_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.forceUpdateTitle,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.forceUpdateMessage(minVersion, currentVersion),
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: l10n.forceUpdateAction,
                        icon: Icons.open_in_new_rounded,
                        onPressed: onUpdateTap ?? () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
