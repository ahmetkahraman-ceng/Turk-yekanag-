import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

/// Ön kontrol anketinin sonucu. Kesin tıbbi karar DEĞİLDİR;
/// karar kan merkezindeki sağlık personelindedir.
enum SurveyOutcome {
  looksEligible('looks_eligible', 0),
  unsure('unsure', 1),
  looksIneligible('looks_ineligible', 2);

  const SurveyOutcome(this.code, this.severity);
  final String code;
  final int severity;

  static SurveyOutcome fromCode(String? raw) {
    for (final item in values) {
      if (item.code == raw) return item;
    }
    // Bilinmeyen değerde ihtiyatlı davran.
    return SurveyOutcome.unsure;
  }
}

/// Bir soruya verilebilecek cevaplar.
enum SurveyAnswer {
  yes('yes'),
  no('no'),
  unsure('unsure');

  const SurveyAnswer(this.code);
  final String code;

  static SurveyAnswer? fromCode(String? raw) {
    for (final item in values) {
      if (item.code == raw) return item;
    }
    return null;
  }
}

/// Remote Config / JSON'dan yönetilen tek bir ön kontrol sorusu.
/// Soru metinleri içerik olarak JSON'da (tr/en) tutulur.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class EligibilityQuestion {
  const EligibilityQuestion({
    required this.id,
    required this.category,
    required this.texts,
    required this.yesOutcome,
    this.genders,
  });

  factory EligibilityQuestion.fromJson(Map<String, dynamic> json) {
    final rawTexts = json['text'];
    final rawGenders = json['genders'];
    return EligibilityQuestion(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'general',
      texts: rawTexts is Map
          ? rawTexts.map((k, v) => MapEntry(k.toString(), v.toString()))
          : <String, String>{},
      yesOutcome: SurveyOutcome.fromCode(json['yesOutcome'] as String?),
      genders: rawGenders is List
          ? rawGenders.map((g) => UserGender.fromCode(g as String?)).toSet()
          : null,
    );
  }

  final String id;
  final String category;
  final Map<String, String> texts;

  /// "Evet" cevabının sonucu. "Hayır" her zaman [SurveyOutcome.looksEligible].
  final SurveyOutcome yesOutcome;

  /// `null` ise tüm cinsiyetlere sorulur (ör. hamilelik sorusu sadece kadın/belirtilmemiş).
  final Set<UserGender>? genders;

  bool appliesTo(UserGender gender) => genders?.contains(gender) ?? true;

  String textFor(String languageCode) =>
      texts[languageCode] ?? texts['tr'] ?? texts.values.firstOrNull ?? id;
}

/// Sürümlü soru seti.
class EligibilityQuestionnaire {
  const EligibilityQuestionnaire({
    required this.version,
    required this.questions,
  });

  factory EligibilityQuestionnaire.fromJson(Map<String, dynamic> json) {
    final raw = json['questions'] as List<dynamic>? ?? const <dynamic>[];
    return EligibilityQuestionnaire(
      version: json['version'] as String? ?? 'unknown',
      questions: raw
          .whereType<Map<String, dynamic>>()
          .map(EligibilityQuestion.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final List<EligibilityQuestion> questions;

  List<EligibilityQuestion> questionsFor(UserGender gender) =>
      questions.where((q) => q.appliesTo(gender)).toList(growable: false);
}
