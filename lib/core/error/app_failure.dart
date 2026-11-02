import 'package:turkiye_kan_agi/l10n/generated/app_localizations.dart';

/// Uygulama genelinde kullanılan hata türleri.
enum AppFailureType {
  network,
  unauthorized,
  unexpected,
}

/// Repository ve servis katmanlarından dönen standart hata modeli.
class AppFailure {
  const AppFailure({
    required this.type,
    this.technicalDetails,
    this.stackTrace,
  });

  const AppFailure.network({String? technicalDetails, StackTrace? stackTrace})
      : this(
          type: AppFailureType.network,
          technicalDetails: technicalDetails,
          stackTrace: stackTrace,
        );

  const AppFailure.unauthorized({
    String? technicalDetails,
    StackTrace? stackTrace,
  }) : this(
          type: AppFailureType.unauthorized,
          technicalDetails: technicalDetails,
          stackTrace: stackTrace,
        );

  const AppFailure.unexpected({
    String? technicalDetails,
    StackTrace? stackTrace,
  }) : this(
          type: AppFailureType.unexpected,
          technicalDetails: technicalDetails,
          stackTrace: stackTrace,
        );

  final AppFailureType type;
  final String? technicalDetails;
  final StackTrace? stackTrace;

  /// Kullanıcıya gösterilecek anlaşılır ve yerelleştirilmiş hata mesajı (ARB üzerinden).
  String toLocalizedMessage(AppLocalizations l10n) {
    switch (type) {
      case AppFailureType.network:
        return l10n.networkErrorMessage;
      case AppFailureType.unauthorized:
        return l10n.unauthorizedErrorMessage;
      case AppFailureType.unexpected:
        return l10n.commonErrorMessage;
    }
  }
}
