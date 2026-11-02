import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/config/app_environment.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/l10n/locale_provider.dart';
import 'package:turkiye_kan_agi/core/router/app_router.dart';
import 'package:turkiye_kan_agi/core/theme/app_theme.dart';
import 'package:turkiye_kan_agi/core/theme/theme_mode_provider.dart';

/// Türkiye Kan Ağı kök widget'ı.
class TurkiyeKanAgiApp extends ConsumerWidget {
  const TurkiyeKanAgiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final env = ref.watch(appEnvironmentProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) =>
          '${context.l10n.appTitle}${env.appNameSuffix}',
      debugShowCheckedModeBanner: env.isDev,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
