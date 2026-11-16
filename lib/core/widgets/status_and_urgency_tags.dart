import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Aciliyet etiketi: ACİL kırmızı dolu+ikon, Bugün turuncu+ikon, Bu hafta gri+ikon.
/// Renk körlüğü için her renk yazı + ikon taşır.
class UrgencyTag extends StatelessWidget {
  const UrgencyTag({
    required this.urgency,
    super.key,
  });

  final RequestUrgency urgency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (bg, fg, icon, text) = switch (urgency) {
      RequestUrgency.critical => (
          AppColors.primary,
          AppColors.onPrimary,
          Icons.priority_high_rounded,
          l10n.urgencyCriticalShort,
        ),
      RequestUrgency.today => (
          isDark ? AppColors.darkWarningLight : AppColors.warningLight,
          isDark ? AppColors.onWarning : AppColors.warning,
          Icons.schedule_rounded,
          l10n.urgencyTodayShort,
        ),
      RequestUrgency.thisWeek => (
          isDark ? AppColors.darkNeutralTagBg : AppColors.neutralTagBg,
          isDark ? AppColors.darkTextPrimary : AppColors.textSecondary,
          Icons.calendar_today_rounded,
          l10n.urgencyThisWeekShort,
        ),
    };

    return Semantics(
      label: text,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.chipBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Talep durum etiketi: Açık, Karşılandı, İptal, Süresi doldu.
class StatusTag extends StatelessWidget {
  const StatusTag({
    required this.status,
    super.key,
  });

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (bg, fg, icon, text) = switch (status) {
      RequestStatus.open => (
          isDark ? AppColors.darkInfoLight : AppColors.infoLight,
          isDark ? AppColors.darkTextPrimary : AppColors.info,
          Icons.radio_button_checked_rounded,
          l10n.statusOpen,
        ),
      RequestStatus.fulfilled => (
          isDark ? AppColors.darkSuccessLight : AppColors.successLight,
          isDark ? AppColors.darkTextPrimary : AppColors.success,
          Icons.check_circle_rounded,
          l10n.statusFulfilled,
        ),
      RequestStatus.cancelled => (
          isDark ? AppColors.darkNeutralTagBg : AppColors.neutralTagBg,
          isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          Icons.cancel_outlined,
          l10n.statusCancelled,
        ),
      RequestStatus.expired => (
          isDark ? AppColors.darkWarningLight : AppColors.warningLight,
          isDark ? AppColors.onWarning : AppColors.warning,
          Icons.timer_off_outlined,
          l10n.statusExpired,
        ),
    };

    return Semantics(
      label: text,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.chipBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Doğrulanmış hesap / kurum / talep rozeti.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    this.label,
  });

  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = label ?? context.l10n.verifiedBadgeLabel;
    return Semantics(
      label: text,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 16,
            color: AppColors.info,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Kan grubu uyumlu bağışçılar için "Uyumlusun" etiketi.
class CompatibleBadge extends StatelessWidget {
  const CompatibleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSuccessLight : AppColors.successLight;
    final fg = isDark ? AppColors.darkTextPrimary : AppColors.success;

    return Semantics(
      label: l10n.compatibleBadgeLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.chipBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              l10n.compatibleBadgeLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
