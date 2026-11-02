import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/error/app_failure.dart';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/donation/domain/eligibility_question.dart';

/// Ön kontrol anketi sorularını önce Remote Config (`eligibility_survey_json`),
/// boş veya geçersizse yerel JSON asset (`assets/data/eligibility_survey.json`)
/// üzerinden yükleyen kaynak.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class EligibilityQuestionnaireSource {
  EligibilityQuestionnaireSource({
    required RemoteConfigService remoteConfig,
    AssetBundle? assetBundle,
  })  : _remoteConfig = remoteConfig,
        _assetBundle = assetBundle ?? rootBundle;

  final RemoteConfigService _remoteConfig;
  final AssetBundle _assetBundle;

  static const String assetPath = 'assets/data/eligibility_survey.json';

  Future<Result<EligibilityQuestionnaire>> loadQuestionnaire() async {
    final remoteRaw = _remoteConfig.eligibilitySurveyJson.trim();
    if (remoteRaw.isNotEmpty) {
      final parsed = _tryParse(remoteRaw);
      if (parsed != null && parsed.questions.isNotEmpty) {
        return Result.success(parsed);
      }
    }

    try {
      final assetRaw = await _assetBundle.loadString(assetPath);
      final parsed = _tryParse(assetRaw);
      if (parsed != null && parsed.questions.isNotEmpty) {
        return Result.success(parsed);
      }
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'EMPTY_SURVEY_JSON'),
      );
    } catch (error, stackTrace) {
      return Result.failure(
        AppFailure.unexpected(
          technicalDetails: error.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  EligibilityQuestionnaire? _tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return EligibilityQuestionnaire.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }
}

final eligibilityQuestionnaireSourceProvider =
    Provider<EligibilityQuestionnaireSource>((ref) {
  final rc = ref.watch(remoteConfigServiceProvider);
  return EligibilityQuestionnaireSource(remoteConfig: rc);
});
