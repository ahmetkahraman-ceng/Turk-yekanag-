import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/services/app_version_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';

/// Uygulama açılışında sürüm (Force Update) ve başlangıç kontrollerini yürüten Splash ekranı.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final forceUpdateAsync = ref.watch(forceUpdateStatusProvider);

    ref.listen<AsyncValue<ForceUpdateStatus>>(
      forceUpdateStatusProvider,
      (_, next) {
        next.whenData((status) {
          if (!context.mounted) return;
          if (status.isRequired) {
            context.go(AppRoutes.forceUpdate);
          } else {
            context.go(AppRoutes.requests);
          }
        });
      },
    );

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: forceUpdateAsync.when(
                  data: (_) => _buildSplashContent(context, theme, l10n),
                  loading: () => _buildSplashContent(context, theme, l10n),
                  error: (_, __) => ErrorState(
                    message: l10n.commonErrorMessage,
                    onRetry: () => ref.invalidate(forceUpdateStatusProvider),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bloodtype_rounded,
            size: 88,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.appTitle,
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.appTagline,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.nonCommercialNotice,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Semantics(
            label: l10n.splashLoading,
            child: const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
