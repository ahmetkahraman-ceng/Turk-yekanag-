import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/notifications/data/firestore_notification_repository.dart';

/// Uygulama içi bildirim merkezi ekranı (Okundu/Okunmadı filtresi ve ilgili talebe yönlendirme).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final allNotifications = ref.watch(notificationCenterProvider);
    final filtered = _unreadOnly
        ? allNotifications.where((n) => !n.isRead).toList(growable: false)
        : allNotifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          TextButton.icon(
            key: const Key('mark_all_read_button'),
            onPressed: () {
              ref.read(notificationCenterProvider.notifier).markAllAsRead();
            },
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: Text(l10n.notificationsMarkAllRead),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Padding(
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
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: l10n.notificationsEmptyTitle,
                    subtitle: l10n.notificationsEmptySubtitle,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        color: item.isRead
                            ? null
                            : theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.35,
                              ),
                        child: ListTile(
                          key: Key('notification_tile_${item.id}'),
                          leading: Icon(
                            item.isCritical
                                ? Icons.warning_amber_rounded
                                : Icons.notifications_active_outlined,
                            color: item.isCritical
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                          title: Text(
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: item.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(item.body),
                          trailing: item.isRead
                              ? const Icon(Icons.check_rounded, size: 18)
                              : const Badge(smallSize: 10),
                          onTap: () {
                            ref
                                .read(notificationCenterProvider.notifier)
                                .markAsRead(item.id);
                            if (item.requestId != null) {
                              context.push(
                                '${AppRoutes.requests}/${item.requestId}',
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
