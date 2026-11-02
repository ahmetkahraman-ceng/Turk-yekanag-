import 'package:flutter/widgets.dart';
import 'package:turkiye_kan_agi/l10n/generated/app_localizations.dart';

export 'package:turkiye_kan_agi/l10n/generated/app_localizations.dart';

/// BuildContext üzerinden yerelleştirilmiş metinlere hızlı erişim.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
