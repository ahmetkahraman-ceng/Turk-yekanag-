/// Türkiye cep telefonu numarası (`+90 5XX XXX XX XX`) doğrulama ve biçimlendirme yardımcısı.
abstract final class TurkishPhoneValidator {
  static final RegExp _digitsOnlyRegex = RegExp(r'\D');
  static final RegExp _normalizedMobileRegex = RegExp(r'^\+905\d{9}$');

  /// Girdiyi `+905XXXXXXXXX` formatına dönüştürür; geçersizse `null` döner.
  static String? normalize(String input) {
    final digits = input.replaceAll(_digitsOnlyRegex, '');
    String candidate;

    if (digits.length == 10 && digits.startsWith('5')) {
      candidate = '+90$digits';
    } else if (digits.length == 11 && digits.startsWith('05')) {
      candidate = '+90${digits.substring(1)}';
    } else if (digits.length == 12 && digits.startsWith('905')) {
      candidate = '+$digits';
    } else {
      return null;
    }

    if (_normalizedMobileRegex.hasMatch(candidate)) {
      return candidate;
    }
    return null;
  }

  /// Numaranın geçerli bir Türkiye cep telefonu numarası olup olmadığını kontrol eder.
  static bool isValid(String input) => normalize(input) != null;
}
