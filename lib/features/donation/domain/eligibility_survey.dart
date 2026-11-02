import 'package:turkiye_kan_agi/features/donation/domain/eligibility_question.dart';

/// Tamamlanmış ön kontrol anketi kaydı.
/// Firestore: `users/{uid}/health_surveys/{id}` — KVKK özel nitelikli sağlık verisi.
class EligibilitySurveyResult {
  const EligibilitySurveyResult({
    required this.id,
    required this.completedAt,
    required this.outcome,
    required this.answers,
    required this.questionnaireVersion,
  });

  factory EligibilitySurveyResult.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    final rawAnswers = json['answers'];
    return EligibilitySurveyResult(
      id: id,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      outcome: SurveyOutcome.fromCode(json['outcome'] as String?),
      answers: rawAnswers is Map
          ? rawAnswers.map((k, v) => MapEntry(k.toString(), v.toString()))
          : <String, String>{},
      questionnaireVersion: json['questionnaireVersion'] as String? ?? '',
    );
  }

  final String id;
  final DateTime completedAt;
  final SurveyOutcome outcome;

  /// soruId -> cevap kodu (yes/no/unsure)
  final Map<String, String> answers;
  final String questionnaireVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'completedAt': completedAt.toUtc().toIso8601String(),
        'outcome': outcome.code,
        'answers': answers,
        'questionnaireVersion': questionnaireVersion,
      };
}

/// Ön kontrol anketi değerlendiricisi (saf fonksiyon).
///
/// - "Hayır" → uygun görünüyor
/// - "Evet" → sorunun `yesOutcome` değeri
/// - "Emin değilim" → en fazla "emin değilim" (yesOutcome daha hafifse o)
/// Genel sonuç en ağır (severity) cevaptır. KESİN TIBBİ KARAR VERMEZ;
/// karar kan merkezindeki sağlık personelindedir.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
abstract final class EligibilitySurveyEvaluator {
  /// Tüm sorular cevaplanmadıysa `null` döner.
  static SurveyOutcome? evaluate({
    required List<EligibilityQuestion> questions,
    required Map<String, SurveyAnswer> answers,
  }) {
    var overall = SurveyOutcome.looksEligible;
    for (final question in questions) {
      final answer = answers[question.id];
      if (answer == null) return null;
      final outcome = _outcomeFor(question, answer);
      if (outcome.severity > overall.severity) overall = outcome;
    }
    return overall;
  }

  static SurveyOutcome _outcomeFor(
    EligibilityQuestion question,
    SurveyAnswer answer,
  ) {
    switch (answer) {
      case SurveyAnswer.no:
        return SurveyOutcome.looksEligible;
      case SurveyAnswer.yes:
        return question.yesOutcome;
      case SurveyAnswer.unsure:
        return question.yesOutcome.severity < SurveyOutcome.unsure.severity
            ? question.yesOutcome
            : SurveyOutcome.unsure;
    }
  }
}
