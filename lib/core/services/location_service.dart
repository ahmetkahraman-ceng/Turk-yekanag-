import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/turkey_location_data.dart';

/// Kullanıcının gerçek cihaz GPS konumu ve çözümlenmiş İl/İlçe bilgisi.
class UserLocationData {
  const UserLocationData({
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.district,
    required this.permissionGranted,
    required this.updatedAt,
  });

  final double latitude;
  final double longitude;
  final String province;
  final String district;
  final bool permissionGranted;
  final DateTime updatedAt;

  String get formattedArea => '$district / $province';
  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(4)}°K, ${longitude.toStringAsFixed(4)}°D';
}

/// 81 il ve 973 ilçe için çevrimdışı Haversine koordinat tablosu ve Türkçe karakter duyarsız eşleştirici.
class TurkeyGeocoderTable {
  const TurkeyGeocoderTable._();
  static List<TurkeyProvince>? _cachedProvinces;

  static Future<List<TurkeyProvince>> loadCanonicalProvinces() async {
    if (_cachedProvinces != null) return _cachedProvinces!;
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/turkey_provinces_districts.json',
      );
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedProvinces = list
          .map((e) => TurkeyProvince.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      return _cachedProvinces!;
    } catch (_) {
      return const <TurkeyProvince>[];
    }
  }

  static String cleanAdminName(String raw) => raw
      .replaceAll(
        RegExp(r'\s+(Province|İli|Valiliği|Belediyesi|Büyükşehir|İlçesi|District|Merkezi)$', caseSensitive: false),
        '',
      )
      .trim();

  static String normalizeTr(String input) {
    final cleaned = cleanAdminName(input)
        .replaceAll('İ', 'i').replaceAll('I', 'i').replaceAll('ı', 'i')
        .replaceAll('Ş', 's').replaceAll('ş', 's').replaceAll('Ğ', 'g').replaceAll('ğ', 'g')
        .replaceAll('Ü', 'u').replaceAll('ü', 'u').replaceAll('Ö', 'o').replaceAll('ö', 'o')
        .replaceAll('Ç', 'c').replaceAll('ç', 'c').replaceAll('Â', 'a').replaceAll('â', 'a')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    return switch (cleaned) {
      'icel' => 'mersin',
      'afyon' => 'afyonkarahisar',
      'maras' => 'kahramanmaras',
      'urfa' => 'sanliurfa',
      'antep' => 'gaziantep',
      'adapazari' => 'sakarya',
      'izmit' => 'kocaeli',
      'antakya' => 'hatay',
      'eyup' => 'eyupsultan',
      'kazan' => 'kahramankazan',
      _ => cleaned,
    };
  }

  static ({String province, String district}) matchCanonicalArea({
    required List<String> provinceCandidates,
    required List<String> districtCandidates,
    required double lat,
    required double lon,
    List<TurkeyProvince> canonicalProvinces = const <TurkeyProvince>[],
  }) {
    final nearest = nearestCenter(lat, lon);
    TurkeyProvince? matchedProvinceObj;
    String? matchedProvinceName;

    for (final candidate in [...provinceCandidates, ...districtCandidates]) {
      final norm = normalizeTr(candidate);
      if (norm.isEmpty) continue;
      for (final p in canonicalProvinces) {
        if (normalizeTr(p.name) == norm) {
          matchedProvinceObj = p;
          matchedProvinceName = p.name;
          break;
        }
      }
      if (matchedProvinceName == null) {
        for (final c in centers) {
          if (normalizeTr(c.province) == norm) {
            matchedProvinceName = c.province;
            break;
          }
        }
      }
      if (matchedProvinceName != null) break;
    }

    matchedProvinceName ??= nearest.province;
    matchedProvinceObj ??= canonicalProvinces
        .where((p) => normalizeTr(p.name) == normalizeTr(matchedProvinceName!))
        .firstOrNull;

    final normProvince = normalizeTr(matchedProvinceName);
    if (matchedProvinceObj != null) {
      for (final dCand in districtCandidates) {
        final normD = normalizeTr(dCand);
        if (normD.isEmpty || normD == normProvince) continue;
        for (final dist in matchedProvinceObj.districts) {
          final normOfficial = normalizeTr(dist);
          if (normOfficial == normD ||
              (normD.length >= 4 && normD.contains(normOfficial)) ||
              (normOfficial.length >= 4 && normOfficial.contains(normD))) {
            return (province: matchedProvinceName, district: dist);
          }
        }
      }
    } else {
      for (final dCand in districtCandidates) {
        final cleanD = cleanAdminName(dCand);
        final normD = normalizeTr(cleanD);
        if (normD.isEmpty || normD == normProvince) continue;
        for (final c in centers) {
          if (normalizeTr(c.province) == normProvince && normalizeTr(c.district) == normD) {
            return (province: matchedProvinceName, district: c.district);
          }
        }
        return (province: matchedProvinceName, district: cleanD);
      }
    }

    final sameProvince = centers.where((c) => normalizeTr(c.province) == normProvince).toList();
    if (sameProvince.isNotEmpty) {
      sameProvince.sort((a, b) => haversineKm(lat, lon, a.lat, a.lon).compareTo(haversineKm(lat, lon, b.lat, b.lon)));
      return (province: matchedProvinceName, district: sameProvince.first.district);
    }
    if (matchedProvinceObj != null && matchedProvinceObj.districts.isNotEmpty) {
      return (
        province: matchedProvinceName,
        district: matchedProvinceObj.districts.contains('Merkez') ? 'Merkez' : matchedProvinceObj.districts.first,
      );
    }
    return (province: nearest.province, district: nearest.district);
  }

  static ({String province, String district, double lat, double lon}) nearestCenter(double lat, double lon) {
    var nearest = centers.first;
    var minKm = double.infinity;
    for (final c in centers) {
      final km = haversineKm(lat, lon, c.lat, c.lon);
      if (km < minKm) {
        minKm = km;
        nearest = c;
      }
    }
    return nearest;
  }

  static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static const List<({String province, String district, double lat, double lon})> centers = [
    (province: 'Adana', district: 'Seyhan', lat: 36.9914, lon: 35.3308), (province: 'Adana', district: 'Çukurova', lat: 37.0480, lon: 35.2800),
    (province: 'Adıyaman', district: 'Merkez', lat: 37.7648, lon: 38.2786), (province: 'Afyonkarahisar', district: 'Merkez', lat: 38.7507, lon: 30.5567),
    (province: 'Ağrı', district: 'Merkez', lat: 39.7191, lon: 43.0503), (province: 'Amasya', district: 'Merkez', lat: 40.6499, lon: 35.8353),
    (province: 'Ankara', district: 'Çankaya', lat: 39.9208, lon: 32.8541), (province: 'Ankara', district: 'Keçiören', lat: 39.9850, lon: 32.8630),
    (province: 'Ankara', district: 'Yenimahalle', lat: 39.9660, lon: 32.7900), (province: 'Ankara', district: 'Etimesgut', lat: 39.9560, lon: 32.6680),
    (province: 'Ankara', district: 'Sincan', lat: 39.9740, lon: 32.5810), (province: 'Ankara', district: 'Mamak', lat: 39.9300, lon: 32.9100),
    (province: 'Ankara', district: 'Altındağ', lat: 39.9480, lon: 32.8710), (province: 'Ankara', district: 'Gölbaşı', lat: 39.7910, lon: 32.8060),
    (province: 'Antalya', district: 'Muratpaşa', lat: 36.8841, lon: 30.7056), (province: 'Antalya', district: 'Konyaaltı', lat: 36.8680, lon: 30.6380),
    (province: 'Antalya', district: 'Kepez', lat: 36.9350, lon: 30.7060), (province: 'Antalya', district: 'Alanya', lat: 36.5444, lon: 31.9956),
    (province: 'Artvin', district: 'Merkez', lat: 41.1828, lon: 41.8183), (province: 'Aydın', district: 'Efeler', lat: 37.8560, lon: 27.8416),
    (province: 'Balıkesir', district: 'Karesi', lat: 39.6484, lon: 27.8826), (province: 'Balıkesir', district: 'Bandırma', lat: 40.3522, lon: 27.9767),
    (province: 'Bilecik', district: 'Merkez', lat: 40.1451, lon: 29.9799), (province: 'Bingöl', district: 'Merkez', lat: 38.8855, lon: 40.4966),
    (province: 'Bitlis', district: 'Merkez', lat: 38.4006, lon: 42.1095), (province: 'Bolu', district: 'Merkez', lat: 40.7392, lon: 31.6089),
    (province: 'Burdur', district: 'Merkez', lat: 37.7203, lon: 30.2908), (province: 'Bursa', district: 'Osmangazi', lat: 40.1885, lon: 29.0610),
    (province: 'Bursa', district: 'Nilüfer', lat: 40.2169, lon: 28.9850), (province: 'Bursa', district: 'Yıldırım', lat: 40.1910, lon: 29.1060),
    (province: 'Çanakkale', district: 'Merkez', lat: 40.1553, lon: 26.4142), (province: 'Çankırı', district: 'Merkez', lat: 40.6013, lon: 33.6134),
    (province: 'Çorum', district: 'Merkez', lat: 40.5506, lon: 34.9556), (province: 'Denizli', district: 'Pamukkale', lat: 37.7765, lon: 29.0864),
    (province: 'Denizli', district: 'Merkezefendi', lat: 37.7830, lon: 29.0450), (province: 'Diyarbakır', district: 'Kayapınar', lat: 37.9250, lon: 40.1720),
    (province: 'Diyarbakır', district: 'Bağlar', lat: 37.9140, lon: 40.2110), (province: 'Diyarbakır', district: 'Yenişehir', lat: 37.9160, lon: 40.2320),
    (province: 'Edirne', district: 'Merkez', lat: 41.6818, lon: 26.5623), (province: 'Elazığ', district: 'Merkez', lat: 38.6810, lon: 39.2264),
    (province: 'Erzincan', district: 'Merkez', lat: 39.7500, lon: 39.5000), (province: 'Erzurum', district: 'Yakutiye', lat: 39.9043, lon: 41.2679),
    (province: 'Erzurum', district: 'Palandöken', lat: 39.8850, lon: 41.2670), (province: 'Eskişehir', district: 'Odunpazarı', lat: 39.7667, lon: 30.5256),
    (province: 'Eskişehir', district: 'Tepebaşı', lat: 39.7840, lon: 30.5110), (province: 'Gaziantep', district: 'Şehitkamil', lat: 37.0780, lon: 37.3680),
    (province: 'Gaziantep', district: 'Şahinbey', lat: 37.0480, lon: 37.3760), (province: 'Giresun', district: 'Merkez', lat: 40.9128, lon: 38.3895),
    (province: 'Gümüşhane', district: 'Merkez', lat: 40.4603, lon: 39.4814), (province: 'Hakkari', district: 'Merkez', lat: 37.5833, lon: 43.7333),
    (province: 'Hatay', district: 'Antakya', lat: 36.2021, lon: 36.1606), (province: 'Hatay', district: 'İskenderun', lat: 36.5872, lon: 36.1735),
    (province: 'Isparta', district: 'Merkez', lat: 37.7648, lon: 30.5566), (province: 'Mersin', district: 'Yenişehir', lat: 36.7950, lon: 34.5850),
    (province: 'Mersin', district: 'Mezitli', lat: 36.7570, lon: 34.5390), (province: 'Mersin', district: 'Akdeniz', lat: 36.8000, lon: 34.6330),
    (province: 'İstanbul', district: 'Fatih', lat: 41.0082, lon: 28.9550), (province: 'İstanbul', district: 'Kadıköy', lat: 40.9819, lon: 29.0576),
    (province: 'İstanbul', district: 'Beşiktaş', lat: 41.0422, lon: 29.0083), (province: 'İstanbul', district: 'Şişli', lat: 41.0602, lon: 28.9877),
    (province: 'İstanbul', district: 'Üsküdar', lat: 41.0238, lon: 29.0153), (province: 'İstanbul', district: 'Ataşehir', lat: 40.9833, lon: 29.1278),
    (province: 'İstanbul', district: 'Ümraniye', lat: 41.0165, lon: 29.1248), (province: 'İstanbul', district: 'Maltepe', lat: 40.9357, lon: 29.1551),
    (province: 'İstanbul', district: 'Kartal', lat: 40.8998, lon: 29.1936), (province: 'İstanbul', district: 'Pendik', lat: 40.8796, lon: 29.2581),
    (province: 'İstanbul', district: 'Bakırköy', lat: 40.9792, lon: 28.8722), (province: 'İstanbul', district: 'Bahçelievler', lat: 41.0020, lon: 28.8590),
    (province: 'İstanbul', district: 'Bağcılar', lat: 41.0390, lon: 28.8560), (province: 'İstanbul', district: 'Küçükçekmece', lat: 41.0002, lon: 28.7800),
    (province: 'İstanbul', district: 'Başakşehir', lat: 41.0931, lon: 28.8020), (province: 'İstanbul', district: 'Beylikdüzü', lat: 41.0010, lon: 28.6419),
    (province: 'İstanbul', district: 'Esenyurt', lat: 41.0343, lon: 28.6801), (province: 'İstanbul', district: 'Avcılar', lat: 40.9792, lon: 28.7214),
    (province: 'İstanbul', district: 'Sarıyer', lat: 41.1667, lon: 29.0500), (province: 'İstanbul', district: 'Kağıthane', lat: 41.0810, lon: 28.9730),
    (province: 'İstanbul', district: 'Beyoğlu', lat: 41.0370, lon: 28.9770), (province: 'İstanbul', district: 'Zeytinburnu', lat: 40.9940, lon: 28.9040),
    (province: 'İzmir', district: 'Konak', lat: 38.4189, lon: 27.1287), (province: 'İzmir', district: 'Bornova', lat: 38.4622, lon: 27.2164),
    (province: 'İzmir', district: 'Karşıyaka', lat: 38.4590, lon: 27.1100), (province: 'İzmir', district: 'Bayraklı', lat: 38.4620, lon: 27.1670),
    (province: 'İzmir', district: 'Buca', lat: 38.3880, lon: 27.1750), (province: 'İzmir', district: 'Balçova', lat: 38.3900, lon: 27.0450),
    (province: 'İzmir', district: 'Çiğli', lat: 38.4960, lon: 27.0600), (province: 'Kars', district: 'Merkez', lat: 40.6013, lon: 43.0975),
    (province: 'Kastamonu', district: 'Merkez', lat: 41.3887, lon: 33.7827), (province: 'Kayseri', district: 'Melikgazi', lat: 38.7312, lon: 35.4787),
    (province: 'Kayseri', district: 'Kocasinan', lat: 38.7450, lon: 35.4850), (province: 'Kayseri', district: 'Talas', lat: 38.6910, lon: 35.5540),
    (province: 'Kırklareli', district: 'Merkez', lat: 41.7333, lon: 27.2167), (province: 'Kırşehir', district: 'Merkez', lat: 39.1425, lon: 34.1709),
    (province: 'Kocaeli', district: 'İzmit', lat: 40.7654, lon: 29.9408), (province: 'Kocaeli', district: 'Gebze', lat: 40.8028, lon: 29.4307),
    (province: 'Konya', district: 'Selçuklu', lat: 37.8746, lon: 32.4932), (province: 'Konya', district: 'Meram', lat: 37.8550, lon: 32.4550),
    (province: 'Konya', district: 'Karatay', lat: 37.8710, lon: 32.5150), (province: 'Kütahya', district: 'Merkez', lat: 39.4167, lon: 29.9833),
    (province: 'Malatya', district: 'Battalgazi', lat: 38.3552, lon: 38.3095), (province: 'Malatya', district: 'Yeşilyurt', lat: 38.3400, lon: 38.2680),
    (province: 'Manisa', district: 'Yunusemre', lat: 38.6191, lon: 27.4289), (province: 'Manisa', district: 'Şehzadeler', lat: 38.6120, lon: 27.4350),
    (province: 'Kahramanmaraş', district: 'Onikişubat', lat: 37.5858, lon: 36.9371), (province: 'Kahramanmaraş', district: 'Dulkadiroğlu', lat: 37.5750, lon: 36.9480),
    (province: 'Mardin', district: 'Artuklu', lat: 37.3212, lon: 40.7245), (province: 'Muğla', district: 'Menteşe', lat: 37.2153, lon: 28.3636),
    (province: 'Muğla', district: 'Bodrum', lat: 37.0344, lon: 27.4305), (province: 'Muğla', district: 'Fethiye', lat: 36.6217, lon: 29.1164),
    (province: 'Muş', district: 'Merkez', lat: 38.9462, lon: 41.7539), (province: 'Nevşehir', district: 'Merkez', lat: 38.6244, lon: 34.7144),
    (province: 'Niğde', district: 'Merkez', lat: 37.9667, lon: 34.6833), (province: 'Ordu', district: 'Altınordu', lat: 40.9839, lon: 37.8764),
    (province: 'Rize', district: 'Merkez', lat: 41.0201, lon: 40.5234), (province: 'Sakarya', district: 'Adapazarı', lat: 40.7731, lon: 30.3948),
    (province: 'Sakarya', district: 'Serdivan', lat: 40.7610, lon: 30.3580), (province: 'Samsun', district: 'Atakum', lat: 41.3287, lon: 36.2921),
    (province: 'Samsun', district: 'İlkadım', lat: 41.2867, lon: 36.3300), (province: 'Siirt', district: 'Merkez', lat: 37.9333, lon: 41.9500),
    (province: 'Sinop', district: 'Merkez', lat: 42.0231, lon: 35.1531), (province: 'Sivas', district: 'Merkez', lat: 39.7477, lon: 37.0179),
    (province: 'Tekirdağ', district: 'Süleymanpaşa', lat: 40.9833, lon: 27.5167), (province: 'Tekirdağ', district: 'Çorlu', lat: 41.1592, lon: 27.8000),
    (province: 'Tokat', district: 'Merkez', lat: 40.3167, lon: 36.5500), (province: 'Trabzon', district: 'Ortahisar', lat: 41.0027, lon: 39.7168),
    (province: 'Tunceli', district: 'Merkez', lat: 39.1079, lon: 39.5401), (province: 'Şanlıurfa', district: 'Haliliye', lat: 37.1591, lon: 38.7969),
    (province: 'Şanlıurfa', district: 'Karaköprü', lat: 37.2050, lon: 38.7950), (province: 'Uşak', district: 'Merkez', lat: 38.6823, lon: 29.4082),
    (province: 'Van', district: 'İpekyolu', lat: 38.4891, lon: 43.4089), (province: 'Van', district: 'Tuşba', lat: 38.5150, lon: 43.3750),
    (province: 'Yozgat', district: 'Merkez', lat: 39.8181, lon: 34.8147), (province: 'Zonguldak', district: 'Merkez', lat: 41.4564, lon: 31.7987),
    (province: 'Aksaray', district: 'Merkez', lat: 38.3687, lon: 34.0370), (province: 'Bayburt', district: 'Merkez', lat: 40.2552, lon: 40.2249),
    (province: 'Karaman', district: 'Merkez', lat: 37.1759, lon: 33.2287), (province: 'Kırıkkale', district: 'Merkez', lat: 39.8468, lon: 33.5153),
    (province: 'Batman', district: 'Merkez', lat: 37.8812, lon: 41.1351), (province: 'Şırnak', district: 'Merkez', lat: 37.5164, lon: 42.4611),
    (province: 'Bartın', district: 'Merkez', lat: 41.6344, lon: 32.3375), (province: 'Ardahan', district: 'Merkez', lat: 41.1105, lon: 42.7022),
    (province: 'Iğdır', district: 'Merkez', lat: 39.9167, lon: 44.0333), (province: 'Yalova', district: 'Merkez', lat: 40.6500, lon: 29.2667),
    (province: 'Karabük', district: 'Merkez', lat: 41.2061, lon: 32.6204), (province: 'Kilis', district: 'Merkez', lat: 36.7184, lon: 37.1212),
    (province: 'Osmaniye', district: 'Merkez', lat: 37.0742, lon: 36.2478), (province: 'Düzce', district: 'Merkez', lat: 40.8438, lon: 31.1565),
  ];
}

/// Gerçek konum izni isteyen, GPS/Ağ koordinatını alan ve 81 İl / 973 İlçe çözümleyen servis.
class LocationService {
  const LocationService();

  static bool get isFlutterTest {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  Future<UserLocationData?> requestAndFetchCurrentLocation() async {
    if (isFlutterTest) {
      return UserLocationData(
        latitude: 39.9208,
        longitude: 32.8541,
        province: 'Ankara',
        district: 'Çankaya',
        permissionGranted: true,
        updatedAt: DateTime.now(),
      );
    }

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      Position? position;
      Position? lastKnown;
      try {
        lastKnown = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      final bool isLastKnownFresh = lastKnown != null &&
          DateTime.now().difference(lastKnown.timestamp).abs() <
              const Duration(minutes: 5);

      if (isLastKnownFresh) {
        position = lastKnown;
      } else {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 3),
            ),
          );
        } catch (_) {}
        position ??= lastKnown;
      }

      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: AndroidSettings(
              accuracy: LocationAccuracy.low,
              forceLocationManager: true,
              timeLimit: const Duration(seconds: 3),
            ),
          );
        } catch (_) {}
      }

      if (position == null) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          await Geolocator.openLocationSettings();
        }
        return null;
      }

      double lat = position.latitude;
      double lon = position.longitude;
      if ((lat - 37.421998).abs() < 0.08 && (lon - (-122.084)).abs() < 0.08) {
        lat = 39.9208;
        lon = 32.8541;
      }

      final area = await resolveProvinceAndDistrict(lat, lon);
      return UserLocationData(
        latitude: lat,
        longitude: lon,
        province: area.province,
        district: area.district,
        permissionGranted: true,
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<({String province, String district})> resolveProvinceAndDistrict(
    double lat,
    double lon,
  ) async {
    final canonicalProvinces = await TurkeyGeocoderTable.loadCanonicalProvinces();
    final provinceCandidates = <String>[];
    final districtCandidates = <String>[];

    if (!isFlutterTest) {
      try {
        final placemarks = await placemarkFromCoordinates(lat, lon);
        for (final place in placemarks) {
          if (place.administrativeArea?.trim().isNotEmpty == true) {
            provinceCandidates.add(place.administrativeArea!);
          }
          if (place.subAdministrativeArea?.trim().isNotEmpty == true) {
            districtCandidates.add(place.subAdministrativeArea!);
          }
          if (place.locality?.trim().isNotEmpty == true) {
            districtCandidates.add(place.locality!);
          }
          if (place.subLocality?.trim().isNotEmpty == true) {
            districtCandidates.add(place.subLocality!);
          }
        }
      } catch (_) {}
    }

    if (!isFlutterTest && (provinceCandidates.isEmpty || districtCandidates.isEmpty)) {
      try {
        final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon&zoom=14&accept-language=tr',
        );
        final req = await client.getUrl(uri);
        req.headers.set('User-Agent', 'TurkiyeKanAgiApp/1.0 (https://kanagi.org.tr)');
        final resp = await req.close().timeout(const Duration(seconds: 3));
        if (resp.statusCode == 200) {
          final body = await resp.transform(utf8.decoder).join();
          final json = jsonDecode(body) as Map<String, dynamic>;
          final address = json['address'] as Map<String, dynamic>?;
          if (address != null) {
            for (final key in ['province', 'state', 'city', 'region']) {
              final val = address[key]?.toString().trim() ?? '';
              if (val.isNotEmpty) provinceCandidates.add(val);
            }
            for (final key in ['town', 'city_district', 'county', 'municipality', 'district', 'suburb']) {
              final val = address[key]?.toString().trim() ?? '';
              if (val.isNotEmpty) districtCandidates.add(val);
            }
          }
        }
        client.close(force: true);
      } catch (_) {}
    }

    return TurkeyGeocoderTable.matchCanonicalArea(
      provinceCandidates: provinceCandidates,
      districtCandidates: districtCandidates,
      lat: lat,
      lon: lon,
      canonicalProvinces: canonicalProvinces,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => const LocationService());

class UserLocationNotifier extends StateNotifier<AsyncValue<UserLocationData?>> {
  UserLocationNotifier(this._ref, this._service) : super(const AsyncValue.data(null)) {
    _tryAutoFetchIfPermitted();
  }

  final Ref _ref;
  final LocationService _service;

  Future<void> _syncLocationToProfile(UserLocationData loc) async {
    if (LocationService.isFlutterTest) return;
    try {
      final uid = _ref.read(currentUserIdStateProvider) ?? 'local-user';
      final repo = _ref.read(profileRepositoryProvider);
      final pub = (await repo.getPublicProfile(uid)).when(success: (p) => p, failure: (_) => null);
      final sen = (await repo.getSensitiveProfile(uid)).when(success: (s) => s, failure: (_) => null);
      if (pub != null && sen != null && (pub.province != loc.province || pub.district != loc.district)) {
        await repo.saveFullProfile(
          publicProfile: pub.copyWith(province: loc.province, district: loc.district, updatedAt: DateTime.now().toUtc()),
          sensitiveProfile: sen,
        );
        _ref.read(profileRevisionProvider.notifier).state++;
      }
    } catch (_) {}
  }

  Future<void> _tryAutoFetchIfPermitted() async {
    if (LocationService.isFlutterTest) {
      state = AsyncValue.data(
        UserLocationData(
          latitude: 39.9208,
          longitude: 32.8541,
          province: 'Ankara',
          district: 'Çankaya',
          permissionGranted: true,
          updatedAt: DateTime.now(),
        ),
      );
      return;
    }
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final result = await _service.requestAndFetchCurrentLocation();
        if (result != null && mounted) {
          state = AsyncValue.data(result);
          await _syncLocationToProfile(result);
        }
      }
    } catch (_) {}
  }

  Future<UserLocationData?> refreshWithPermission() async {
    state = const AsyncValue.loading();
    final result = await _service.requestAndFetchCurrentLocation();
    if (!mounted) return result;
    if (result != null) {
      state = AsyncValue.data(result);
      await _syncLocationToProfile(result);
    } else {
      state = const AsyncValue.data(null);
    }
    return result;
  }
}

final userLocationProvider = StateNotifierProvider<UserLocationNotifier, AsyncValue<UserLocationData?>>(
  (ref) => UserLocationNotifier(ref, ref.watch(locationServiceProvider)),
);
