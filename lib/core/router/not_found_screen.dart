import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';

/// Geçersiz bir adrese (deep link vb.) gidildiğinde gösterilen 404 ekranı.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notFoundTitle),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: EmptyState(
              title: l10n.notFoundTitle,
              subtitle: l10n.notFoundMessage,
              icon: Icons.explore_off_outlined,
              actionLabel: l10n.notFoundBackHome,
              onAction: () => context.go(AppRoutes.requests),
            ),
          ),
        ],
      ),
    );
  }
}
