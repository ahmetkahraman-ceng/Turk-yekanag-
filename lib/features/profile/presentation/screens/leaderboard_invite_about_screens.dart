import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';

final leaderboardOptInProvider = StateProvider<bool>((ref) => false);

/// Aşama 7.7: Liderlik tablosu (opsiyonel, kapalı gelir, açarken uyarı).
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  static const List<(String, String, int)> _leaders = [
    ('Ayşe K.', 'Ankara', 14),
    ('Mehmet T.', 'İstanbul', 11),
    ('Zeynep B.', 'İzmir', 9),
    ('Caner D.', 'Bursa', 8),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final enabled = ref.watch(leaderboardOptInProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leaderboardTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: !enabled
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.volunteer_activism_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.leaderboardOptInWarning,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            key: const Key('enable_leaderboard_button'),
                            label: l10n.leaderboardEnableButton,
                            onPressed: () => ref
                                .read(leaderboardOptInProvider.notifier)
                                .state = true,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _leaders.length,
                      itemBuilder: (context, index) {
                        final entry = _leaders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(entry.$1),
                              subtitle: Text(entry.$2),
                              trailing: Text(
                                '${entry.$3}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aşama 7.7: Davet ekranı (link kopyala/paylaş, sayaç).
class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({super.key});

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  int _invitedCount = 2;
  static const String _inviteUrl = 'https://kanagi.org.tr/davet/gonullu-2026';

  Future<void> _copyInvite() async {
    await Clipboard.setData(const ClipboardData(text: _inviteUrl));
    if (!mounted) return;
    setState(() => _invitedCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.inviteCopyLink)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.inviteTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.group_add_rounded,
                    size: 72,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.inviteSubtitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      children: [
                        SelectableText(
                          _inviteUrl,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.inviteCountLabel(_invitedCount)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    key: const Key('copy_invite_link_button'),
                    label: l10n.inviteCopyLink,
                    icon: Icons.copy_rounded,
                    onPressed: _copyInvite,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aşama 7.8: Hakkında, geri bildirim formu, sürüm bilgisi ve bakım modu ekranı.
class AboutAndFeedbackScreen extends StatefulWidget {
  const AboutAndFeedbackScreen({super.key});

  @override
  State<AboutAndFeedbackScreen> createState() => _AboutAndFeedbackScreenState();
}

class _AboutAndFeedbackScreenState extends State<AboutAndFeedbackScreen> {
  final _feedbackCtrl = TextEditingController();

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.inviteSubtitle),
                        const SizedBox(height: AppSpacing.sm),
                        const Text('v1.0.0+1'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionHeader(title: l10n.feedbackTitle),
                  AppTextField(
                    key: const Key('feedback_input_field'),
                    controller: _feedbackCtrl,
                    labelText: l10n.feedbackTitle,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    key: const Key('send_feedback_button'),
                    label: l10n.commonSave,
                    onPressed: () {
                      _feedbackCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.commonSave)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.build_circle_outlined,
          title: l10n.maintenanceTitle,
          subtitle: l10n.maintenanceMessage,
        ),
      ),
    );
  }
}
