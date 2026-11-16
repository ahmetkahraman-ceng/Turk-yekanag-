import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/notifications/data/firestore_notification_repository.dart';

/// 5 sekmeli (Talepler, Harita, Bağış, Bildirimler, Profil) ana navigasyon iskeleti.
/// - Sekme durumu korunur (StatefulShellRoute.indexedStack)
/// - Bildirimler sekmesinde okunmamış sayı rozeti gösterilir
/// - Geri tuşu: aktif sekme Talepler (0) değilse önce Talepler sekmesine döner, sonra çıkar.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({
    required this.navigationShell,
    super.key,
    this.topBanner,
  });

  final StatefulNavigationShell navigationShell;
  final Widget? topBanner;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            if (topBanner != null) topBanner!,
            Expanded(child: navigationShell),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.bloodtype_outlined),
              selectedIcon: const Icon(Icons.bloodtype_rounded),
              label: l10n.navRequests,
              tooltip: l10n.navRequestsSemantics,
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map_rounded),
              label: l10n.navMap,
              tooltip: l10n.navMapSemantics,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: l10n.navDonation,
              tooltip: l10n.navDonationSemantics,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                child: const Icon(Icons.notifications_rounded),
              ),
              label: l10n.navNotifications,
              tooltip: l10n.navNotificationsSemantics,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.navProfile,
              tooltip: l10n.navProfileSemantics,
            ),
          ],
        ),
      ),
    );
  }
}
