import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

/// Firestore `users/{uid}/private_data/sensitive_profile` dokümanında tutulan
/// KVKK kapsamındaki özel nitelikli kişisel veriler ve iletişim bilgileri.
/// Yalnızca hesabın sahibi (`request.auth.uid == uid`) tarafından okunabilir.
class UserSensitiveProfile {
  const UserSensitiveProfile({
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.weightKg,
    required this.bloodType,
    required this.updatedAt,
    this.nickname,
    this.phoneNumber,
  });

  factory UserSensitiveProfile.fromJson(Map<String, dynamic> json) {
    return UserSensitiveProfile(
      fullName: json['fullName'] as String? ?? '',
      nickname: json['nickname'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      birthDate: DateTime.tryParse(json['birthDate'] as String? ?? '') ??
          DateTime(1995),
      gender: UserGender.fromCode(json['gender'] as String?),
      weightKg: (json['weightKg'] as num?)?.toInt() ?? 60,
      bloodType: BloodType.fromCode(json['bloodType'] as String?),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String fullName;
  final String? nickname;
  final String? phoneNumber;
  final DateTime birthDate;
  final UserGender gender;
  final int weightKg;
  final BloodType bloodType;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName,
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate.toUtc().toIso8601String(),
      'gender': gender.code,
      'weightKg': weightKg,
      'bloodType': bloodType.code,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
