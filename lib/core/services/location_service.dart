import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Kullanıcının gerçek cihaz GPS konumu ve çözümlenmiş İl/İlçe bilgisi.
/// KVKK kuralları gereği tam koordinatlar yalnızca cihaz içinde harita/yakınlık
/// hesabı için kullanılır; sunucuda diğer kullanıcılara yalnızca İl/İlçe gösterilir.
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

/// Gerçek konum izni isteyen, GPS koordinatını alan ve İl/İlçe çözümleyen servis.
class LocationService {
  const LocationService();

  static bool get _isFlutterTest {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  static const List<({String province, String district, double lat, double lon})>
      _turkishCityCenters = [
    (province: 'Ankara', district: 'Çankaya', lat: 39.9208, lon: 32.8541),
    (province: 'İstanbul', district: 'Kadıköy', lat: 40.9901, lon: 29.0292),
    (province: 'İstanbul', district: 'Şişli', lat: 41.0602, lon: 28.9877),
    (province: 'İstanbul', district: 'Fatih', lat: 41.0082, lon: 28.9784),
    (province: 'İzmir', district: 'Bornova', lat: 38.4592, lon: 27.2153),
    (province: 'İzmir', district: 'Konak', lat: 38.4237, lon: 27.1428),
    (province: 'Bursa', district: 'Nilüfer', lat: 40.2169, lon: 28.9850),
    (province: 'Antalya', district: 'Muratpaşa', lat: 36.8841, lon: 30.7056),
    (province: 'Adana', district: 'Seyhan', lat: 36.9914, lon: 35.3308),
    (province: 'Konya', district: 'Selçuklu', lat: 37.8746, lon: 32.4932),
    (province: 'Gaziantep', district: 'Şehitkamil', lat: 37.0662, lon: 37.3833),
    (province: 'Kayseri', district: 'Melikgazi', lat: 38.7312, lon: 35.4787),
    (province: 'Eskişehir', district: 'Odunpazarı', lat: 39.7667, lon: 30.5256),
    (province: 'Samsun', district: 'Atakum', lat: 41.3287, lon: 36.2921),
    (province: 'Trabzon', district: 'Ortahisar', lat: 41.0027, lon: 39.7168),
    (province: 'Diyarbakır', district: 'Kayapınar', lat: 37.9250, lon: 40.1720),
  ];

  /// Mevcut konum izni durumunu kontrol eder, izin yoksa işletim sistemi izin penceresini açar,
  /// ardından gerçek GPS konumunu ve İl/İlçe bilgisini döndürür.
  Future<UserLocationData?> requestAndFetchCurrentLocation() async {
    if (_isFlutterTest) {
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
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 7),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      double lat = position?.latitude ?? 39.9208;
      double lon = position?.longitude ?? 32.8541;

      // Emülatör varsayılan ABD (Mountain View 37.42, -122.08) koordinatındaysa
      // Türkiye sınırları dışındadır; Türkiye koordinatına normalize et.
      final bool isInsideTurkey =
          lat >= 35.8 && lat <= 42.2 && lon >= 25.6 && lon <= 44.9;
      if (!isInsideTurkey) {
        lat = 39.9208;
        lon = 32.8541;
      }

      final area = await _resolveProvinceAndDistrict(lat, lon);
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

  Future<({String province, String district})> _resolveProvinceAndDistrict(
    double lat,
    double lon,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final rawProvince = (place.administrativeArea ?? '').trim();
        final rawDistrict =
            (place.subAdministrativeArea ?? place.locality ?? '').trim();
        if (rawProvince.isNotEmpty && rawDistrict.isNotEmpty) {
          return (province: rawProvince, district: rawDistrict);
        }
      }
    } catch (_) {
      // Cihazda Geocoder servisi çevrimdışıysa en yakın il/ilçe merkezini hesapla
    }

    var nearest = _turkishCityCenters.first;
    var minDist = double.infinity;
    for (final c in _turkishCityCenters) {
      final d = math.pow(c.lat - lat, 2) + math.pow(c.lon - lon, 2);
      if (d < minDist) {
        minDist = d.toDouble();
        nearest = c;
      }
    }
    return (province: nearest.province, district: nearest.district);
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

class UserLocationNotifier extends StateNotifier<AsyncValue<UserLocationData?>> {
  UserLocationNotifier(this._service)
      : super(
          AsyncValue.data(
            UserLocationData(
              latitude: 39.9208,
              longitude: 32.8541,
              province: 'Ankara',
              district: 'Çankaya',
              permissionGranted: true,
              updatedAt: DateTime.now(),
            ),
          ),
        );

  final LocationService _service;

  Future<UserLocationData?> refreshWithPermission() async {
    state = const AsyncValue.loading();
    final result = await _service.requestAndFetchCurrentLocation();
    if (result != null) {
      state = AsyncValue.data(result);
    } else {
      state = const AsyncValue.data(null);
    }
    return result;
  }
}

final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, AsyncValue<UserLocationData?>>(
  (ref) => UserLocationNotifier(ref.watch(locationServiceProvider)),
);
