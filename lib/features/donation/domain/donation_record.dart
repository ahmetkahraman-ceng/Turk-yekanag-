import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Bağış kaydının nereden geldiği.
enum DonationRecordSource {
  /// Kullanıcının kendi eklediği kayıt (ör. Kızılay merkezinde yapılan bağış).
  manual('manual'),

  /// Talep akışında talep sahibinin onayıyla (Cloud Function) yazılan kayıt.
  request('request');

  const DonationRecordSource(this.code);
  final String code;

  static DonationRecordSource fromCode(String? raw) {
    for (final item in values) {
      if (item.code == raw) return item;
    }
    return DonationRecordSource.manual;
  }
}

/// Bağış geçmişi kaydı.
/// Firestore: `users/{uid}/donation_history/{id}` — KVKK özel nitelikli sağlık verisidir,
/// yalnızca hesap sahibi okuyabilir ve açık rıza (healthDataConsent) olmadan yazılamaz.
class DonationRecord {
  const DonationRecord({
    required this.id,
    required this.donatedAt,
    required this.place,
    required this.productType,
    required this.source,
    required this.createdAt,
    this.requestId,
  });

  factory DonationRecord.fromJson(String id, Map<String, dynamic> json) {
    final donatedRaw =
        json['donatedAt'] as String? ?? json['confirmedAt'] as String? ?? '';
    return DonationRecord(
      id: id,
      donatedAt: DateTime.tryParse(donatedRaw)?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      place: json['place'] as String? ?? json['hospitalName'] as String? ?? '',
      productType: BloodProductType.fromCode(json['productType'] as String?),
      source: DonationRecordSource.fromCode(json['source'] as String?),
      requestId: json['requestId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final DateTime donatedAt;
  final String place;
  final BloodProductType productType;
  final DonationRecordSource source;
  final String? requestId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'donatedAt': donatedAt.toUtc().toIso8601String(),
      'place': place,
      'productType': productType.code,
      'source': source.code,
      if (requestId != null) 'requestId': requestId,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
