import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/features/notifications/data/firestore_notification_repository.dart';
import 'package:turkiye_kan_agi/features/notifications/domain/app_notification.dart';

/// Bildirimler sekmesi:
/// - Gruplu (Bugün / Daha önce)
/// - Tür ikonlu satırlar, okunmamış nokta
/// - Kaydırarak sil/okundu (Dismissible)
/// - "Hepsini okundu yap", empty durumu, dokununca ilgili ekrana gitme
/// - Bildirim izni açıklayıcı sheet ve reddedilirse ayarlar banner'ı.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;
  bool _permissionDeniedBanner = false;

  Future<void> _promptNotificationPermission() async {
    final l10n = context.l10n;
    final allowed = await ConfirmSheet.show(
      context: context,
      icon: Icons.notifications_active_rounded,
      title: l10n.notificationPermissionSheetTitle,
      message: l10n.notificationPermissionSheetBody,
      confirmLabel: l10n.notificationPermissionAllow,
    );
    if (!mounted) return;
    setState(() => _permissionDeniedBanner = !allowed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allNotifications = ref.watch(notificationCenterProvider);
    final filtered = _unreadOnly
        ? allNotifications.where((n) => !n.isRead).toList(growable: false)
        : allNotifications;

    final now = DateTime.now().toUtc();
    final todayList = filtered
        .where((n) => now.difference(n.createdAt).inHours < 24)
        .toList();
    final earlierList = filtered
        .where((n) => now.difference(n.createdAt).inHours >= 24)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          IconButton(
            tooltip: l10n.notificationPermissionSheetTitle,
            onPressed: _promptNotificationPermission,
            icon: const Icon(Icons.notifications_paused_outlined),
          ),
          TextButton.icon(
            key: const Key('mark_all_read_button'),
            onPressed: () {
              ref.read(notificationCenterProvider.notifier).markAllAsRead();
            },
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: Text(l10n.notificationsMarkAllReadShort),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          if (_permissionDeniedBanner)
            Container(
              width: double.infinity,
              color: AppColors.warningLight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.notificationPermissionDeniedBanner,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _permissionDeniedBanner = false),
                    child: Text(l10n.notificationOpenSettings),
                  ),
                ],
              ),
            ),
          ResponsiveConstrainedBox(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                FilterChip(
                  key: const Key('filter_unread_only_chip'),
                  label: Text(l10n.notificationsFilterUnreadOnly),
                  selected: _unreadOnly,
                  onSelected: (val) => setState(() => _unreadOnly = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: l10n.notificationsEmptyTitle,
                      subtitle: l10n.notificationsEmptySubtitle,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _buildSectionItems(
                        todayList,
                        earlierList,
                        l10n.notificationsGroupToday,
                        l10n.notificationsGroupEarlier,
                      ).length,
                      itemBuilder: (context, index) {
                        final entries = _buildSectionItems(
                          todayList,
                          earlierList,
                          l10n.notificationsGroupToday,
                          l10n.notificationsGroupEarlier,
                        );
                        return entries[index];
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionItems(
    List<AppNotification> todayList,
    List<AppNotification> earlierList,
    String todayTitle,
    String earlierTitle,
  ) {
    final items = <Widget>[];
    if (todayList.isNotEmpty) {
      items.add(SectionHeader(title: todayTitle));
      for (final item in todayList) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _NotificationRowTile(item: item),
          ),
        );
      }
    }
    if (earlierList.isNotEmpty) {
      items.add(SectionHeader(title: earlierTitle));
      for (final item in earlierList) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _NotificationRowTile(item: item),
          ),
        );
      }
    }
    return items;
  }
}

class _NotificationRowTile extends ConsumerWidget {
  const _NotificationRowTile({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(notificationCenterProvider.notifier);

    return Dismissible(
      key: ValueKey('dismiss_${item.id}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        color: AppColors.info,
        child: const Icon(Icons.mark_email_read_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          notifier.toggleRead(item.id);
          return false;
        }
        notifier.removeNotification(item.id);
        return true;
      },
      child: AppCard(
        padding: EdgeInsets.zero,
        backgroundColor: item.isRead
            ? null
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
        child: ListTile(
          key: Key('notification_tile_${item.id}'),
          leading: CircleAvatar(
            backgroundColor: item.isCritical
                ? theme.colorScheme.error.withValues(alpha: 0.14)
                : theme.colorScheme.primaryContainer,
            child: Icon(
              item.isCritical
                  ? Icons.priority_high_rounded
                  : Icons.notifications_active_outlined,
              color: item.isCritical
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          title: Text(
            item.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
            ),
          ),
          subtitle: Text(item.body),
          trailing: item.isRead
              ? const Icon(Icons.check_rounded, size: 18)
              : const Badge(smallSize: 10),
          onTap: () {
            notifier.markAsRead(item.id);
            if (item.requestId != null) {
              context.push('${AppRoutes.requests}/${item.requestId}');
            }
          },
        ),
      ),
    );
  }
}
