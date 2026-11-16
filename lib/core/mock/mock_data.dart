import 'package:turkiye_kan_agi/core/mock/donation_center.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/notifications/domain/app_notification.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/hospital.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Tüm ekranlar için gerçekçi Türkçe mock veri havuzu:
/// - 32 kan talebi (İstanbul, Ankara, İzmir; 8 kan grubu; 4 ürün tipi; uç durumlar: çok uzun hastane adı, açık/karşılandı/iptal/süresi doldu)
/// - 10 bağış merkezi (sabit Kızılay merkezleri ve gezici kan bağış araçları)
/// - 15 bildirim (Bugün ve Daha Önce gruplu)
/// - Örnek bağış geçmişi kayıtları
abstract final class MockData {
  static const List<Hospital> hospitals = [
    Hospital(
      id: 'hosp-ank-bilkent',
      name: 'Ankara Bilkent Şehir Hastanesi',
      province: 'Ankara',
      district: 'Çankaya',
      latitude: 39.9008,
      longitude: 32.7556,
    ),
    Hospital(
      id: 'hosp-ist-capa',
      name: 'İstanbul Üniversitesi İstanbul Tıp Fakültesi (Çapa)',
      province: 'İstanbul',
      district: 'Fatih',
      latitude: 41.0156,
      longitude: 28.9329,
    ),
    Hospital(
      id: 'hosp-ist-cam-sakura',
      name:
          'İstanbul Başakşehir Çam ve Sakura Şehir Hastanesi Kalp ve Damar Cerrahisi Kulesi Eğitim ve Araştırma Merkezi',
      province: 'İstanbul',
      district: 'Başakşehir',
      latitude: 41.1065,
      longitude: 28.7745,
    ),
    Hospital(
      id: 'hosp-ist-goztepe',
      name: 'Prof. Dr. Süleyman Yalçın Şehir Hastanesi',
      province: 'İstanbul',
      district: 'Kadıköy',
      latitude: 40.9856,
      longitude: 29.0558,
    ),
    Hospital(
      id: 'hosp-ank-hacettepe',
      name: 'Hacettepe Üniversitesi Erişkin Hastanesi',
      province: 'Ankara',
      district: 'Altındağ',
      latitude: 39.9323,
      longitude: 32.8617,
    ),
    Hospital(
      id: 'hosp-ank-etlik',
      name: 'Ankara Etlik Şehir Hastanesi',
      province: 'Ankara',
      district: 'Keçiören',
      latitude: 39.9665,
      longitude: 32.8260,
    ),
    Hospital(
      id: 'hosp-izm-ege',
      name: 'Ege Üniversitesi Tıp Fakültesi Hastanesi',
      province: 'İzmir',
      district: 'Bornova',
      latitude: 38.4581,
      longitude: 27.2266,
    ),
    Hospital(
      id: 'hosp-izm-dokuz-eylul',
      name: 'Dokuz Eylül Üniversitesi Araştırma ve Uygulama Hastanesi',
      province: 'İzmir',
      district: 'Balçova',
      latitude: 38.3949,
      longitude: 27.0342,
    ),
    Hospital(
      id: 'hosp-izm-bayrakli',
      name: 'İzmir Şehir Hastanesi',
      province: 'İzmir',
      district: 'Bayraklı',
      latitude: 38.4750,
      longitude: 27.1850,
    ),
  ];

  static List<BloodRequest> get requests {
    final now = DateTime.now().toUtc();
    const bloodTypes = BloodType.knownValues;
    const products = BloodProductType.values;
    const urgencies = [
      RequestUrgency.critical,
      RequestUrgency.today,
      RequestUrgency.thisWeek,
    ];
    const departments = [
      'Genel Yoğun Bakım',
      'Erişkin Hematoloji Servisi',
      'Kalp ve Damar Cerrahisi',
      'Onkoloji Servisi',
      'Acil Travma Ünitesi',
      'Ortopedi ve Travmatoloji',
      'Çocuk Hematoloji',
      'Organ Nakli Ünitesi',
    ];
    const initials = [
      'M.K.',
      'S.Y.',
      'A.D.',
      'E.T.',
      'Z.Ö.',
      'H.B.',
      'C.A.',
      'F.Ş.',
    ];

    final list = <BloodRequest>[
      BloodRequest(
        id: 'req-seed-1',
        requesterUid: 'seed-owner-1',
        patientInitials: 'M.K.',
        bloodType: BloodType.aPos,
        productType: BloodProductType.erythrocyte,
        unitsNeeded: 2,
        hospital: hospitals[0],
        department: 'Genel Yoğun Bakım',
        urgency: RequestUrgency.critical,
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(hours: 23)),
        notes: 'Ameliyat hazırlığı için acil eritrosit süspansiyonu ihtiyacı.',
        offerCount: 1,
      ),
      BloodRequest(
        id: 'req-seed-2',
        requesterUid: 'seed-owner-2',
        patientInitials: 'S.Y.',
        bloodType: BloodType.oNeg,
        productType: BloodProductType.platelet,
        unitsNeeded: 1,
        hospital: hospitals[1],
        department: 'Erişkin Hematoloji Servisi',
        urgency: RequestUrgency.today,
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(hours: 3)),
        expiresAt: now.add(const Duration(hours: 45)),
        notes: 'Aferez trombosit ihtiyacı bulunmaktadır.',
        offerCount: 2,
      ),
    ];

    for (var i = 3; i <= 32; i++) {
      final hosp = hospitals[i % hospitals.length];
      final bt = bloodTypes[i % bloodTypes.length];
      final prod = products[i % products.length];
      final urg = urgencies[i % urgencies.length];
      final status = switch (i) {
        29 => RequestStatus.fulfilled,
        30 => RequestStatus.cancelled,
        31 => RequestStatus.expired,
        _ => RequestStatus.open,
      };
      list.add(
        BloodRequest(
          id: 'req-seed-$i',
          requesterUid: i == 5 ? 'local-user' : 'seed-owner-$i',
          patientInitials: initials[i % initials.length],
          bloodType: bt,
          productType: prod,
          unitsNeeded: (i % 4) + 1,
          hospital: hosp,
          department: departments[i % departments.length],
          urgency: urg,
          status: status,
          createdAt: now.subtract(Duration(hours: i)),
          expiresAt: now.add(Duration(hours: 36 - (i % 20))),
          notes:
              'Tedavi sürecindeki hastamız için gönüllü ${prod.name} bağışçısı aranmaktadır.',
          offerCount: i % 5,
          hasMedicalReport: i.isEven,
        ),
      );
    }
    return list;
  }

  static const List<DonationCenter> centers = [
    DonationCenter(
      id: 'ctr-ank-kizilay',
      name: 'Türk Kızılayı Çankaya Kan Bağışı Merkezi',
      province: 'Ankara',
      district: 'Çankaya',
      latitude: 39.9208,
      longitude: 32.8541,
      workingHours: '09:00 - 20:00',
      phone: '0312 430 18 18',
      isOpenNow: true,
      distanceKm: 1.4,
    ),
    DonationCenter(
      id: 'ctr-ank-mobil-1',
      name: 'Kızılay Güvenpark Gezici Kan Bağış Aracı',
      province: 'Ankara',
      district: 'Çankaya',
      latitude: 39.9195,
      longitude: 32.8532,
      workingHours: '10:00 - 19:00',
      phone: '168',
      isOpenNow: true,
      isMobileUnit: true,
      distanceKm: 1.8,
    ),
    DonationCenter(
      id: 'ctr-ank-ulus',
      name: 'Türk Kızılayı Orta Anadolu Bölge Kan Merkezi',
      province: 'Ankara',
      district: 'Altındağ',
      latitude: 39.9412,
      longitude: 32.8597,
      workingHours: '08:30 - 18:30',
      phone: '0312 310 32 30',
      isOpenNow: true,
      distanceKm: 3.6,
    ),
    DonationCenter(
      id: 'ctr-ist-kadikoy',
      name: 'Kızılay Kadıköy Meydan Kan Alma Birimi',
      province: 'İstanbul',
      district: 'Kadıköy',
      latitude: 40.9910,
      longitude: 29.0230,
      workingHours: '10:00 - 21:00',
      phone: '0216 336 05 66',
      isOpenNow: true,
      distanceKm: 2.1,
    ),
    DonationCenter(
      id: 'ctr-ist-mobil-1',
      name: 'Beşiktaş İskele Gezici Kan Bağış Otobüsü',
      province: 'İstanbul',
      district: 'Beşiktaş',
      latitude: 41.0419,
      longitude: 29.0056,
      workingHours: '11:00 - 19:30',
      phone: '168',
      isOpenNow: true,
      isMobileUnit: true,
      distanceKm: 4.2,
    ),
    DonationCenter(
      id: 'ctr-ist-capa',
      name: 'Kızılay Çapa Kan Bağışı Merkezi',
      province: 'İstanbul',
      district: 'Fatih',
      latitude: 41.0145,
      longitude: 28.9340,
      workingHours: '08:30 - 19:00',
      phone: '0212 534 69 73',
      isOpenNow: true,
      distanceKm: 5.0,
    ),
    DonationCenter(
      id: 'ctr-ist-kartal',
      name: 'Kızılay Kuzey Marmara Bölge Kan Merkezi',
      province: 'İstanbul',
      district: 'Kartal',
      latitude: 40.9080,
      longitude: 29.1850,
      workingHours: '08:30 - 17:30',
      phone: '0216 458 65 00',
      isOpenNow: false,
      distanceKm: 9.8,
    ),
    DonationCenter(
      id: 'ctr-izm-konak',
      name: 'Kızılay Konak Meydan Gezici Kan Bağış Aracı',
      province: 'İzmir',
      district: 'Konak',
      latitude: 38.4189,
      longitude: 27.1287,
      workingHours: '10:00 - 19:00',
      phone: '168',
      isOpenNow: true,
      isMobileUnit: true,
      distanceKm: 2.5,
    ),
    DonationCenter(
      id: 'ctr-izm-bayrakli',
      name: 'Türk Kızılayı Ege Bölge Kan Merkezi',
      province: 'İzmir',
      district: 'Bayraklı',
      latitude: 38.4622,
      longitude: 27.1670,
      workingHours: '08:30 - 18:00',
      phone: '0232 347 63 00',
      isOpenNow: true,
      distanceKm: 4.7,
    ),
    DonationCenter(
      id: 'ctr-izm-bornova',
      name: 'Kızılay Bornova Kan Alma Birimi',
      province: 'İzmir',
      district: 'Bornova',
      latitude: 38.4601,
      longitude: 27.2185,
      workingHours: '09:30 - 18:00',
      phone: '0232 388 10 20',
      isOpenNow: false,
      distanceKm: 6.1,
    ),
  ];

  static List<AppNotification> get notifications {
    final now = DateTime.now().toUtc();
    return List.generate(15, (i) {
      final idx = i + 1;
      final isToday = i < 5;
      final offset = isToday
          ? Duration(minutes: (i + 1) * 18)
          : Duration(days: i - 3, hours: 2);
      return AppNotification(
        id: 'notif-$idx',
        title: switch (i) {
          0 => 'Acil A Rh(+) Eritrosit İhtiyacı',
          _ => switch (i % 4) {
              0 => 'Acil Kan Çağrısı (#$idx)',
              1 => 'Eşleşme Onayı Bilgilendirmesi',
              2 => 'Teşekkür Mesajı Aldınız',
              _ => 'Bekleme Süreniz Güncellendi',
            },
        },
        body: switch (i % 4) {
          0 =>
            'Ankara Bilkent Şehir Hastanesi — Yakınınızda uyumlu acil talep açıldı.',
          1 => 'Yardım teklifiniz talep sahibi tarafından onaylandı.',
          2 => 'Hasta yakını M.K.: "İyi ki varsınız, çok teşekkür ederiz."',
          _ => 'Sonraki uygun bağış tarihinize 24 gün kaldı.',
        },
        createdAt: now.subtract(offset),
        isRead: i >= 3,
        requestId: 'req-seed-${(i % 10) + 1}',
        isCritical: i % 4 == 0,
      );
    });
  }

  static List<DonationRecord> get sampleDonations {
    final now = DateTime.now().toUtc();
    return [
      DonationRecord(
        id: 'don-1',
        donatedAt: now.subtract(const Duration(days: 66)),
        createdAt: now.subtract(const Duration(days: 66)),
        place: 'Türk Kızılayı Çankaya Kan Bağışı Merkezi',
        productType: BloodProductType.wholeBlood,
        source: DonationRecordSource.manual,
      ),
      DonationRecord(
        id: 'don-2',
        donatedAt: now.subtract(const Duration(days: 190)),
        createdAt: now.subtract(const Duration(days: 190)),
        place: 'Ankara Bilkent Şehir Hastanesi',
        productType: BloodProductType.erythrocyte,
        source: DonationRecordSource.request,
        requestId: 'req-seed-1',
      ),
      DonationRecord(
        id: 'don-3',
        donatedAt: now.subtract(const Duration(days: 310)),
        createdAt: now.subtract(const Duration(days: 310)),
        place: 'Hacettepe Üniversitesi Kan Merkezi',
        productType: BloodProductType.platelet,
        source: DonationRecordSource.request,
        requestId: 'req-seed-2',
      ),
    ];
  }
}
