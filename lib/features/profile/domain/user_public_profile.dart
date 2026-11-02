/// Firestore `users/{uid}` dokümanında tutulan genel (public) profil verisi.
/// KVKK kuralları gereği burada kan grubu, telefon numarası, tam konum,
/// doğum tarihi veya kilo bilgisi KESİNLİKLE yer almaz.
class UserPublicProfile {
  const UserPublicProfile({
    required this.uid,
    required this.displayName,
    required this.useNickname,
    required this.province,
    required this.district,
    required this.isAvailableToDonate,
    required this.updatedAt,
    this.photoUrl,
  });

  factory UserPublicProfile.fromJson(Map<String, dynamic> json) {
    return UserPublicProfile(
      uid: json['uid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      useNickname: json['useNickname'] as bool? ?? false,
      province: json['province'] as String? ?? '',
      district: json['district'] as String? ?? '',
      isAvailableToDonate: json['isAvailableToDonate'] as bool? ?? true,
      photoUrl: json['photoUrl'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String uid;
  final String displayName;
  final bool useNickname;
  final String province;
  final String district;
  final bool isAvailableToDonate;
  final String? photoUrl;
  final DateTime updatedAt;

  UserPublicProfile copyWith({
    String? displayName,
    bool? useNickname,
    String? province,
    String? district,
    bool? isAvailableToDonate,
    String? photoUrl,
    DateTime? updatedAt,
  }) {
    return UserPublicProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      useNickname: useNickname ?? this.useNickname,
      province: province ?? this.province,
      district: district ?? this.district,
      isAvailableToDonate: isAvailableToDonate ?? this.isAvailableToDonate,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'useNickname': useNickname,
      'province': province,
      'district': district,
      'isAvailableToDonate': isAvailableToDonate,
      'photoUrl': photoUrl,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
