/// Uygulama içinde para/ücret karşılığı kan alım-satımını engelleyen
/// istemci tarafı yasaklı kelime ve desen doğrulayıcısı.
/// Aynı kurallar Cloud Functions tarafında da zorunlu olarak kontrol edilir.
abstract final class ProhibitedContentFilter {
  static const List<String> _bannedKeywords = <String>[
    'para',
    'ücret',
    'ucret',
    'nakit',
    'tl',
    'lira',
    'dolar',
    'euro',
    'iban',
    'ödeme',
    'odeme',
    'satılık',
    'satilik',
    'fiyat',
    'komisyon',
    'bahşiş',
    'bahsis',
    'karşılığında',
    'karsiliginda',
    'maddi',
    'havale',
    'eft',
  ];

  static final RegExp _ibanRegex = RegExp(
    r'\btr\s*\d{2}[\d\s]{10,30}\b',
    caseSensitive: false,
  );

  static final RegExp _currencyRegex = RegExp(
    r'(\d+\s*(tl|₺|\$|€|usd|eur|bin\s*tl))',
    caseSensitive: false,
  );

  /// Metin içinde para/ücret/IBAN ifadesi varsa `true` döner.
  static bool containsProhibitedContent(String text) {
    final normalized = text
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .toLowerCase();
    if (normalized.isEmpty) return false;

    if (_ibanRegex.hasMatch(normalized) ||
        _currencyRegex.hasMatch(normalized)) {
      return true;
    }

    final words = normalized
        .split(RegExp(r'[^a-z0-9çğıöşü]+'))
        .where((w) => w.isNotEmpty);

    for (final word in words) {
      if (_bannedKeywords.contains(word)) {
        return true;
      }
    }
    return false;
  }

  /// Hasta adının yalnızca baş harflerden oluştuğunu doğrular (Örn: "A.Y.", "A Y", "M.K.A.").
  static bool isValidPatientInitials(String input) {
    final trimmed = input.trim();
    if (trimmed.length < 2 || trimmed.length > 10) return false;
    final regex = RegExp(
      r'^[A-ZÇĞİÖŞÜ]\.?(\s*[A-ZÇĞİÖŞÜ]\.?)+$',
      caseSensitive: false,
    );
    return regex.hasMatch(trimmed);
  }
}
