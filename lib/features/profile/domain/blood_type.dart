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

  static List<BloodType> get knownTypes =>
      values.where((t) => t.isKnown).toList(growable: false);

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
