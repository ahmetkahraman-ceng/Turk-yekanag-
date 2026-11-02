import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

/// İnternet bağlantısı kesildiğinde ekranın üst kısmında beliren erişilebilir uyarı bandı.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({
    super.key,
    this.forceShow,
  });

  /// Test veya önizleme amacıyla çevrimdışı durumunu zorlamak için kullanılır.
  final bool? forceShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOfflineAsync = ref.watch(isOfflineStreamProvider);
    final isOffline = forceShow ?? isOfflineAsync.valueOrNull ?? false;

    if (!isOffline) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.offlineBannerSemantics,
      child: Material(
        color: AppColors.warning,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.onWarning,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.offlineBannerMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onWarning,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
