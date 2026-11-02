import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/features/auth/domain/turkish_phone_validator.dart';

void main() {
  group('TurkishPhoneValidator', () {
    test('geçerli Türkiye cep telefonu formatlarını +905XXXXXXXXX olarak normalize eder', () {
      expect(
        TurkishPhoneValidator.normalize('532 123 45 67'),
        '+905321234567',
      );
      expect(
        TurkishPhoneValidator.normalize('05441112233'),
        '+905441112233',
      );
      expect(
        TurkishPhoneValidator.normalize('+90 (505) 999-88-77'),
        '+905059998877',
      );
      expect(TurkishPhoneValidator.isValid('0530 444 55 66'), isTrue);
    });

    test('5 ile başlamayan veya eksik haneli numaraları reddeder', () {
      expect(TurkishPhoneValidator.normalize('212 123 45 67'), isNull);
      expect(TurkishPhoneValidator.normalize('532 123 45'), isNull);
      expect(TurkishPhoneValidator.isValid('123456'), isFalse);
    });
  });
}
