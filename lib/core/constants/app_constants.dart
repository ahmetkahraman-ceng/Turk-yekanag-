/// Uygulama genelinde kullanılan sabitler.
/// Tıbbi uygunluk ve bağış aralığı değerleri burada tutulmaz, RemoteConfigService üzerinden okunur.
abstract final class AppConstants {
  static const String packageName = 'tr.org.kanagi.turkiye_kan_agi';
  static const String defaultLocaleCode = 'tr';
  static const List<String> supportedLocaleCodes = ['tr', 'en'];
}
