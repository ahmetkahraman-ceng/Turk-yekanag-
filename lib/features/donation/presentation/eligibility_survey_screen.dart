import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/loading_skeleton.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/donation/data/eligibility_questionnaire_source.dart';
import 'package:turkiye_kan_agi/features/donation/data/firestore_donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/domain/eligibility_question.dart';
import 'package:turkiye_kan_agi/features/donation/domain/eligibility_survey.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

/// Bağışa uygunluk ön kontrol anketi ekranı.
/// Sorular Remote Config (`eligibility_survey_json`) veya yerel JSON'dan yönetilir.
/// Kesin tıbbi karar vermez; "Karar kan merkezindeki sağlık personelindedir" uyarısını gösterir.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class EligibilitySurveyScreen extends ConsumerStatefulWidget {
  const EligibilitySurveyScreen({super.key});

  @override
  ConsumerState<EligibilitySurveyScreen> createState() =>
      _EligibilitySurveyScreenState();
}

class _EligibilitySurveyScreenState
    extends ConsumerState<EligibilitySurveyScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  EligibilityQuestionnaire? _questionnaire;
  UserGender _gender = UserGender.unspecified;
  final Map<String, SurveyAnswer> _answers = <String, SurveyAnswer>{};
  SurveyOutcome? _evaluatedOutcome;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final sensitiveRes =
        await ref.read(profileRepositoryProvider).getSensitiveProfile(uid);
    final gender = sensitiveRes.when(
      success: (p) => p?.gender ?? UserGender.unspecified,
      failure: (_) => UserGender.unspecified,
    );

    final res = await ref
        .read(eligibilityQuestionnaireSourceProvider)
        .loadQuestionnaire();
    if (!mounted) return;
    res.when(
      success: (q) {
        setState(() {
          _gender = gender;
          _questionnaire = q;
          _isLoading = false;
        });
      },
      failure: (f) {
        setState(() {
          _errorMessage = f.toLocalizedMessage(context.l10n);
          _isLoading = false;
        });
      },
    );
  }

  String _answerLabel(BuildContext context, SurveyAnswer answer) {
    final l10n = context.l10n;
    return switch (answer) {
      SurveyAnswer.yes => l10n.donationSurveyAnswerYes,
      SurveyAnswer.no => l10n.donationSurveyAnswerNo,
      SurveyAnswer.unsure => l10n.donationSurveyAnswerUnsure,
    };
  }

  Future<void> _evaluate(List<EligibilityQuestion> questions) async {
    final l10n = context.l10n;
    final outcome = EligibilitySurveyEvaluator.evaluate(
      questions: questions,
      answers: _answers,
    );
    if (outcome == null) {
      setState(() => _validationError = l10n.donationSurveyIncompleteError);
      return;
    }

    setState(() {
      _validationError = null;
      _evaluatedOutcome = outcome;
    });

    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final nowUtc = DateTime.now().toUtc();
    final result = EligibilitySurveyResult(
      id: 'survey-${nowUtc.millisecondsSinceEpoch}',
      completedAt: nowUtc,
      outcome: outcome,
      answers: _answers.map((k, v) => MapEntry(k, v.code)),
      questionnaireVersion: _questionnaire?.version ?? '1.0.0',
    );
    await ref.read(donationRepositoryProvider).saveSurveyResult(
          uid: uid,
          result: result,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final questions =
        _questionnaire?.questionsFor(_gender) ?? const <EligibilityQuestion>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.donationSurveyTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: _isLoading
                ? const LoadingSkeleton(itemCount: 4)
                : _errorMessage != null
                    ? ErrorState(
                        message: _errorMessage!,
                        onRetry: _loadSurvey,
                      )
                    : questions.isEmpty
                        ? EmptyState(
                            title: l10n.donationEmptyTitle,
                            subtitle: l10n.donationEmptySubtitle,
                          )
                        : ListView(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            children: [
                              Card(
                                key: const Key('survey_medical_disclaimer_card'),
                                color: theme.colorScheme.secondaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.medical_information_rounded,
                                        color: theme
                                            .colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          l10n.donationSurveyDisclaimer,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.colorScheme
                                                .onSecondaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              for (final q in questions)
                                Card(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.md),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          q.textFor(lang),
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Wrap(
                                          spacing: AppSpacing.xs,
                                          children: [
                                            for (final ans
                                                in SurveyAnswer.values)
                                              ChoiceChip(
                                                key: Key(
                                                  'survey_q_${q.id}_${ans.code}',
                                                ),
                                                label: Text(
                                                  _answerLabel(context, ans),
                                                ),
                                                selected: _answers[q.id] == ans,
                                                onSelected: (_) {
                                                  setState(() {
                                                    _answers[q.id] = ans;
                                                    _validationError = null;
                                                  });
                                                },
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (_validationError != null) ...[
                                Text(
                                  _validationError!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              PrimaryButton(
                                key: const Key('evaluate_survey_button'),
                                icon: Icons.fact_check_rounded,
                                label: l10n.donationSurveyEvaluateButton,
                                onPressed: () => _evaluate(questions),
                              ),
                              if (_evaluatedOutcome != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                _OutcomeCard(outcome: _evaluatedOutcome!),
                              ],
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.outcome});

  final SurveyOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (title, body, icon) = switch (outcome) {
      SurveyOutcome.looksEligible => (
          l10n.donationSurveyOutcomeEligibleTitle,
          l10n.donationSurveyOutcomeEligibleBody,
          Icons.check_circle_outline_rounded,
        ),
      SurveyOutcome.unsure => (
          l10n.donationSurveyOutcomeUnsureTitle,
          l10n.donationSurveyOutcomeUnsureBody,
          Icons.help_outline_rounded,
        ),
      SurveyOutcome.looksIneligible => (
          l10n.donationSurveyOutcomeIneligibleTitle,
          l10n.donationSurveyOutcomeIneligibleBody,
          Icons.warning_amber_rounded,
        ),
    };

    return Semantics(
      liveRegion: true,
      child: Card(
        key: Key('survey_outcome_card_${outcome.code}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(body, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.donationSurveyDisclaimer,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
