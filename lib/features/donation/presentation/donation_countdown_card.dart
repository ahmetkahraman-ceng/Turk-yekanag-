import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_availability_state.dart';
import 'package:turkiye_kan_agi/features/donation/domain/next_donation_calculator.dart';

/// Sonraki bağış uygunluk durumu, geri sayım, otomatik uygunluk bilgisi,
/// hatırlatıcı anahtarı ve takvime ekleme kartı.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class DonationCountdownCard extends StatelessWidget {
  const DonationCountdownCard({
    required this.nextInfo,
    required this.availabilityState,
    required this.maleIntervalDays,
    required this.femaleIntervalDays,
    required this.onReminderToggled,
    required this.onAddToCalendar,
    super.key,
  });

  final NextDonationInfo nextInfo;
  final DonationAvailabilityState availabilityState;
  final int maleIntervalDays;
  final int femaleIntervalDays;
  final ValueChanged<bool> onReminderToggled;
  final VoidCallback onAddToCalendar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEligible = nextInfo.isEligibleNow;
    final nextDate = nextInfo.nextEligibleAt;
    final localeName = Localizations.localeOf(context).languageCode;
    final formattedNextDate = nextDate != null
        ? DateFormat.yMMMd(localeName).format(nextDate.toLocal())
        : null;

    return Card(
      key: const Key('donation_countdown_card'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEligible
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_bottom_rounded,
                  color: isEligible
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    isEligible
                        ? l10n.donationStatusEligibleNowTitle
                        : l10n.donationStatusWaitingTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (!isEligible && nextDate != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.donationCountdownDaysHours(
                    nextInfo.remainingDays,
                    nextInfo.remaining.inHours,
                  ),
                  key: const Key('donation_countdown_text'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (formattedNextDate != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.donationNextEligibleDateLabel(formattedNextDate),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              availabilityState.autoPaused
                  ? l10n.donationAutoPausedNotice
                  : l10n.donationAutoResumedNotice,
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: AppSpacing.lg),
            SwitchListTile(
              key: const Key('donation_reminder_switch'),
              contentPadding: EdgeInsets.zero,
              value: availabilityState.reminderEnabled,
              onChanged: onReminderToggled,
              title: Text(l10n.donationReminderToggleTitle),
              subtitle: Text(l10n.donationReminderToggleSubtitle),
            ),
            if (nextDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.minTouchTarget,
                child: OutlinedButton.icon(
                  key: const Key('add_to_calendar_button'),
                  onPressed: onAddToCalendar,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(l10n.donationAddToCalendarButton),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.donationIntervalInfo(maleIntervalDays, femaleIntervalDays),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
