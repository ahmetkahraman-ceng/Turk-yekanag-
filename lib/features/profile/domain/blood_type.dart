/// Kan grubu seçenekleri (A/B/AB/0, Rh+/- ve Bilmiyorum).
enum BloodType {
  aPos('A+'),
  aNeg('A-'),
  bPos('B+'),
  bNeg('B-'),
  abPos('AB+'),
  abNeg('AB-'),
  oPos('0+'),
  oNeg('0-'),
  unknown('unknown');

  const BloodType(this.code);
  final String code;

  bool get isKnown => this != BloodType.unknown;

  static const List<BloodType> knownValues = [
    aPos,
    aNeg,
    bPos,
    bNeg,
    abPos,
    abNeg,
    oPos,
    oNeg,
  ];

  static List<BloodType> get knownTypes => knownValues;

  static BloodType fromCode(String? code) {
    for (final value in values) {
      if (value.code == code) {
        return value;
      }
    }
    return BloodType.unknown;
  }
}

/// Kullanıcı cinsiyet seçenekleri.
enum UserGender {
  male('male'),
  female('female'),
  unspecified('unspecified');

  const UserGender(this.code);
  final String code;

  static UserGender fromCode(String? code) {
    for (final value in values) {
      if (value.code == code) {
        return value;
      }
    }
    return UserGender.unspecified;
  }
}
