import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/feature_placeholder_view.dart';
import 'package:turkiye_kan_agi/core/widgets/loading_skeleton.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/donation/data/donation_availability_sync.dart';
import 'package:turkiye_kan_agi/features/donation/data/firestore_donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/data/local_notification_reminder_service.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_availability_state.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/donation/domain/next_donation_calculator.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/add_donation_sheet.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/donation_countdown_card.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/donation_history_list.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/widgets/badge_showcase.dart';
import 'package:turkiye_kan_agi/features/onboarding/domain/kvkk_consent_record.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';

/// Bağış sekmesi ana ekranı:
/// - Sonraki bağış tarihi hesaplama (Remote Config), geri sayım ve otomatik uygunluk güncellemesi
/// - Bağış geçmişi (manuel ekleme ve talep akışından otomatik ekleme)
/// - Ön kontrol anketi ve bağış öncesi/sonrası öneriler erişimi
/// - Hatırlatıcı bildirimi ve takvime ekleme
/// - KVKK özel nitelikli sağlık verisi açık rıza kontrolü
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({
    super.key,
    this.initialState,
  });

  final ScreenViewState? initialState;

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasHealthConsent = true;
  List<DonationRecord> _history = const <DonationRecord>[];
  DonationAvailabilityState _availabilityState =
      const DonationAvailabilityState();
  NextDonationInfo _nextInfo = const NextDonationInfo(
    isEligibleNow: true,
    remaining: Duration.zero,
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialState == ScreenViewState.loading) {
      _isLoading = true;
    } else if (widget.initialState == ScreenViewState.error) {
      _isLoading = false;
      _errorMessage = 'FORCED_ERROR';
    } else {
      _refreshAll();
    }
  }

  Future<void> _refreshAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final profileRepo = ref.read(profileRepositoryProvider);
    final donationRepo = ref.read(donationRepositoryProvider);

    final consentRes = await profileRepo.getKvkkConsent(uid);
    final hasConsent = consentRes.when(
      success: (c) => c?.healthDataConsent ?? true,
      failure: (_) => true,
    );

    final historyRes = await donationRepo.getHistory(uid);
    if (!mounted) return;

    await historyRes.when(
      success: (list) async {
        final l10n = context.l10n;
        final nextInfo =
            await ref.read(donationAvailabilitySyncProvider).syncForUser(
                  uid: uid,
                  reminderTitle: l10n.donationReminderNotifTitle,
                  reminderBody: l10n.donationReminderNotifBody,
                );
        final stateRes = await donationRepo.getAvailabilityState(uid);
        if (!mounted) return;
        setState(() {
          _hasHealthConsent = hasConsent;
          _history = list;
          _nextInfo = nextInfo;
          _availabilityState = stateRes.when(
            success: (s) => s,
            failure: (_) => const DonationAvailabilityState(),
          );
          _isLoading = false;
        });
      },
      failure: (f) async {
        setState(() {
          _errorMessage = f.toLocalizedMessage(context.l10n);
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _grantHealthConsent() async {
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final record = KvkkConsentRecord(
      healthDataConsent: true,
      locationConsent: true,
      notificationConsent: true,
      consentedAt: DateTime.now().toUtc(),
      policyVersion: KvkkConsentRecord.currentPolicyVersion,
    );
    await ref.read(profileRepositoryProvider).saveKvkkConsent(
          uid: uid,
          consent: record,
        );
    await _refreshAll();
  }

  Future<void> _openAddManualSheet() async {
    final input = await showModalBottomSheet<ManualDonationInput>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddDonationSheet(),
    );
    if (input == null || !mounted) return;
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    await ref.read(donationRepositoryProvider).addManualDonation(
          uid: uid,
          donatedAt: input.donatedAt,
          place: input.place,
          productType: input.productType,
        );
    await _refreshAll();
  }

  Future<void> _deleteManual(String recordId) async {
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    await ref.read(donationRepositoryProvider).deleteManualDonation(
          uid: uid,
          recordId: recordId,
        );
    await _refreshAll();
  }

  Future<void> _toggleReminder(bool enabled) async {
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final updated = _availabilityState.copyWith(reminderEnabled: enabled);
    await ref.read(donationRepositoryProvider).saveAvailabilityState(
          uid: uid,
          state: updated,
        );
    await _refreshAll();
  }

  Future<void> _addToCalendar() async {
    final nextDate = _nextInfo.nextEligibleAt;
    if (nextDate == null) return;
    final l10n = context.l10n;
    await ref.read(calendarExportServiceProvider).addNextDonationToCalendar(
          eligibleAtUtc: nextDate,
          title: l10n.donationCalendarEventTitle,
          description: l10n.donationCalendarEventDesc,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.donationCalendarAddedSnack)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
    final remoteConfig = ref.watch(remoteConfigServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.donationTitle)),
      body: _isLoading
          ? const LoadingSkeleton(itemCount: 4)
          : _errorMessage != null
              ? ErrorState(
                  message: _errorMessage == 'FORCED_ERROR'
                      ? l10n.commonErrorMessage
                      : _errorMessage!,
                  onRetry: _refreshAll,
                )
              : RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      if (!_hasHealthConsent)
                        Card(
                          key: const Key('kvkk_health_consent_gate_card'),
                          color: theme.colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.donationKvkkConsentRequiredTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  l10n.donationKvkkConsentRequiredBody,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                PrimaryButton(
                                  key: const Key('grant_health_consent_button'),
                                  label: l10n.donationKvkkGrantConsentButton,
                                  onPressed: _grantHealthConsent,
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        DonationCountdownCard(
                          nextInfo: _nextInfo,
                          availabilityState: _availabilityState,
                          maleIntervalDays:
                              remoteConfig.wholeBloodIntervalDaysMale,
                          femaleIntervalDays:
                              remoteConfig.wholeBloodIntervalDaysFemale,
                          onReminderToggled: _toggleReminder,
                          onAddToCalendar: _addToCalendar,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PrimaryButton(
                          key: const Key('open_add_manual_donation_button'),
                          icon: Icons.add_circle_outline_rounded,
                          label: l10n.donationAddManualButton,
                          onPressed: _openAddManualSheet,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        OutlinedButton.icon(
                          key: const Key('open_eligibility_survey_button'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(
                              double.infinity,
                              AppSpacing.minTouchTarget,
                            ),
                          ),
                          onPressed: () =>
                              context.push(AppRoutes.donationSurvey),
                          icon: const Icon(Icons.quiz_outlined),
                          label: Text(l10n.donationQuickSurveyButton),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      OutlinedButton.icon(
                        key: const Key('open_donation_tips_button'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            AppSpacing.minTouchTarget,
                          ),
                        ),
                        onPressed: () => context.push(AppRoutes.donationTips),
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text(l10n.donationQuickTipsButton),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.favorite_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(l10n.donationLivesSavedTitle),
                          subtitle: Text(l10n.donationLivesSavedSubtitle),
                          trailing: const Icon(Icons.info_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BadgeShowcaseSection(donationCount: _history.length),
                      const SizedBox(height: AppSpacing.md),
                      DonationHistoryList(
                        records: _history,
                        onDeleteManual: _deleteManual,
                      ),
                    ],
                  ),
                ),
    );
  }
}
