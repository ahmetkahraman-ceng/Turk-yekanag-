import 'package:flutter/foundation.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

/// Bağışçı teklif ve adım durumları.
enum DonationOfferStatus {
  pending('pending'),
  approved('approved'),
  onTheWay('on_the_way'),
  arrivedAtHospital('arrived_at_hospital'),
  donatedPendingConfirmation('donated_pending_confirmation'),
  confirmed('confirmed'),
  rejected('rejected');

  const DonationOfferStatus(this.code);
  final String code;

  /// Talep sahibi bağışçıyı onayladıktan sonraki tüm aktif/tamamlanmış adımlarda
  /// karşılıklı telefon numaraları görünür olur.
  bool get isMutualContactUnlocked =>
      this == DonationOfferStatus.approved ||
      this == DonationOfferStatus.onTheWay ||
      this == DonationOfferStatus.arrivedAtHospital ||
      this == DonationOfferStatus.donatedPendingConfirmation ||
      this == DonationOfferStatus.confirmed;

  static DonationOfferStatus fromCode(String? raw) {
    for (final item in DonationOfferStatus.values) {
      if (item.code == raw) return item;
    }
    return DonationOfferStatus.pending;
  }
}

/// Birden fazla bağışçı için basit saat koordinasyonu dilimleri.
enum DonationTimeSlot {
  immediate('immediate'),
  morning('morning'),
  afternoon('afternoon'),
  evening('evening');

  const DonationTimeSlot(this.code);
  final String code;

  static DonationTimeSlot fromCode(String? raw) {
    for (final item in DonationTimeSlot.values) {
      if (item.code == raw) return item;
    }
    return DonationTimeSlot.immediate;
  }
}

/// Bağışçının bir kan talebine yaptığı "Yardım edebilirim" teklifi.
/// Güvenlik kuralı: `requesterPhone` ve `donorPhone` yalnızca talep sahibi
/// teklifi onayladıktan (`isMutualContactUnlocked == true`) sonra doldurulur/gösterilir.
@immutable
class DonationOffer {
  const DonationOffer({
    required this.id,
    required this.requestId,
    required this.donorUid,
    required this.donorDisplayName,
    required this.donorBloodType,
    required this.status,
    required this.timeSlot,
    required this.createdAt,
    this.quickMessage = '',
    this.donorPhone,
    this.requesterPhone,
  });

  final String id;
  final String requestId;
  final String donorUid;
  final String donorDisplayName;
  final BloodType donorBloodType;
  final DonationOfferStatus status;
  final DonationTimeSlot timeSlot;
  final DateTime createdAt;
  final String quickMessage;
  final String? donorPhone;
  final String? requesterPhone;

  bool get isContactVisible => status.isMutualContactUnlocked;

  DonationOffer copyWith({
    DonationOfferStatus? status,
    DonationTimeSlot? timeSlot,
    String? quickMessage,
    String? donorPhone,
    String? requesterPhone,
  }) {
    return DonationOffer(
      id: id,
      requestId: requestId,
      donorUid: donorUid,
      donorDisplayName: donorDisplayName,
      donorBloodType: donorBloodType,
      status: status ?? this.status,
      timeSlot: timeSlot ?? this.timeSlot,
      createdAt: createdAt,
      quickMessage: quickMessage ?? this.quickMessage,
      donorPhone: donorPhone ?? this.donorPhone,
      requesterPhone: requesterPhone ?? this.requesterPhone,
    );
  }
}
