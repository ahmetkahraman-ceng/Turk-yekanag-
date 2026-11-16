import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/mock/donation_center.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Harita kontrolcüsü: dışarıdan "Konumuma git", yakınlaştırma veya belirli bir koordinata odaklanma sağlar.
class RealMapController extends ChangeNotifier {
  double _latitude = 39.9208; // Ankara Kızılay varsayılan merkez
  double _longitude = 32.8541;
  double _zoom = 11.5;
  GoogleMapController? _googleMapController;

  double get latitude => _latitude;
  double get longitude => _longitude;
  double get zoom => _zoom;

  void attachGoogleMap(GoogleMapController controller) {
    _googleMapController = controller;
  }

  void moveTo({
    required double latitude,
    required double longitude,
    double? zoom,
  }) {
    _latitude = latitude.clamp(-85.0, 85.0);
    _longitude = longitude.clamp(-180.0, 180.0);
    if (zoom != null) {
      _zoom = zoom.clamp(5.0, 18.0);
    }
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(_latitude, _longitude), _zoom),
    );
    notifyListeners();
  }

  void zoomBy(double delta) {
    _zoom = (_zoom + delta).clamp(5.0, 18.0);
    _googleMapController?.animateCamera(CameraUpdate.zoomTo(_zoom));
    notifyListeners();
  }

  void panByPixels(double dx, double dy, double tileSize) {
    final worldSize = tileSize * math.pow(2.0, _zoom);
    final lonDelta = (dx / worldSize) * 360.0;
    final currentY = _latToTileY(_latitude, _zoom) * tileSize;
    final nextTileY = ((currentY - dy) / tileSize).clamp(
      0.0,
      math.pow(2.0, _zoom).toDouble(),
    );
    final nextLat = _tileYToLat(nextTileY, _zoom);
    _latitude = nextLat.clamp(-85.0, 85.0);
    _longitude = (_longitude - lonDelta).clamp(-180.0, 180.0);
    notifyListeners();
  }

  static double _latToTileY(double lat, double zoom) {
    final latRad = lat * math.pi / 180.0;
    final n = math.pow(2.0, zoom);
    return (1.0 -
            math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
        2.0 *
        n;
  }

  static double _tileYToLat(double tileY, double zoom) {
    final n = math.pow(2.0, zoom);
    final latRad = math.atan(_sinh(math.pi * (1.0 - 2.0 * tileY / n)));
    return latRad * 180.0 / math.pi;
  }

  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2.0;
}

/// Gerçek harita görünümü:
/// - `GOOGLE_MAPS_API_KEY` tanımlıysa doğrudan yerel `GoogleMap` (`google_maps_flutter`) bileşenini özel önbellekli marker bitmap'leri ve karanlık tema JSON stiliyle çalıştırır.
/// - API anahtarı yoksa bile sahte ızgara yerine gerçek Web Mercator projeksiyonlu **OpenStreetMap / CartoDB** sokak haritası karolarını (`tile.openstreetmap.org`) gerçek hastane/merkez enlem-boylamlarıyla etkileşimli (kaydırma + yakınlaştırma) olarak çizer.
/// - Widget test ortamında (`FLUTTER_TEST`) ağ hatası üretmemek için çevrimdışı vektör yol katmanına otomatik geçer.
class RealMapTileCanvas extends StatefulWidget {
  const RealMapTileCanvas({
    required this.requests,
    required this.centers,
    required this.onSelectRequest,
    required this.onSelectCenter,
    super.key,
    this.controller,
    this.userLatitude = 39.9208,
    this.userLongitude = 32.8541,
  });

  final List<BloodRequest> requests;
  final List<DonationCenter> centers;
  final ValueChanged<BloodRequest> onSelectRequest;
  final ValueChanged<DonationCenter> onSelectCenter;
  final RealMapController? controller;
  final double userLatitude;
  final double userLongitude;

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  @override
  State<RealMapTileCanvas> createState() => _RealMapTileCanvasState();
}

class _RealMapTileCanvasState extends State<RealMapTileCanvas> {
  static const double _tileSize = 256.0;
  static const String _darkGoogleMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#261616"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#f5e9e7"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a0e0e"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#3d2626"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#14222e"}]}
]
''';

  late RealMapController _internalController;
  final Map<String, BitmapDescriptor> _markerBitmapCache = {};
  double _baseScaleZoom = 11.5;
  Offset? _lastFocalPoint;

  RealMapController get _ctrl => widget.controller ?? _internalController;

  bool get _isFlutterTest {
    if (kIsWeb) return false;
    return Platform.environment.containsKey('FLUTTER_TEST');
  }

  bool get _useNativeGoogleMap =>
      RealMapTileCanvas.googleMapsApiKey.isNotEmpty && !_isFlutterTest;

  @override
  void initState() {
    super.initState();
    _internalController = RealMapController();
    _ctrl.addListener(_onControllerChanged);
    if (_useNativeGoogleMap) {
      _prepareCustomBitmaps();
    }
  }

  @override
  void didUpdateWidget(covariant RealMapTileCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _ctrl.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    _internalController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _prepareCustomBitmaps() async {
    for (final urgency in RequestUrgency.values) {
      final key = 'req_${urgency.name}';
      if (!_markerBitmapCache.containsKey(key)) {
        _markerBitmapCache[key] = await _createCircleMarkerBitmap(
          _pinColorForUrgency(urgency),
        );
      }
    }
    _markerBitmapCache['center'] = await _createCircleMarkerBitmap(
      AppColors.info,
    );
    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> _createCircleMarkerBitmap(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 44.0;
    final paint = Paint()..color = color;
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(const Offset(size / 2, size / 2), 18, paint);
    canvas.drawCircle(const Offset(size / 2, size / 2), 18, border);
    final image = await recorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  Color _pinColorForUrgency(RequestUrgency urgency) {
    return switch (urgency) {
      RequestUrgency.critical => AppColors.primary,
      RequestUrgency.today => AppColors.warning,
      RequestUrgency.thisWeek => AppColors.neutralTag,
    };
  }

  static double _lonToTileX(double lon, double zoom) {
    return (lon + 180.0) / 360.0 * math.pow(2.0, zoom);
  }

  static double _latToTileY(double lat, double zoom) {
    final latRad = lat * math.pi / 180.0;
    final n = math.pow(2.0, zoom);
    return (1.0 -
            math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
        2.0 *
        n;
  }

  Offset _latLngToViewportOffset({
    required double lat,
    required double lon,
    required Size viewportSize,
  }) {
    final centerTileX = _lonToTileX(_ctrl.longitude, _ctrl.zoom);
    final centerTileY = _latToTileY(_ctrl.latitude, _ctrl.zoom);
    final pointTileX = _lonToTileX(lon, _ctrl.zoom);
    final pointTileY = _latToTileY(lat, _ctrl.zoom);

    final dx = (pointTileX - centerTileX) * _tileSize + viewportSize.width / 2;
    final dy = (pointTileY - centerTileY) * _tileSize + viewportSize.height / 2;
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_useNativeGoogleMap) {
      return _buildNativeGoogleMap(isDark);
    }

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (details) {
              _baseScaleZoom = _ctrl.zoom;
              _lastFocalPoint = details.localFocalPoint;
            },
            onScaleUpdate: (details) {
              if (_lastFocalPoint != null) {
                final delta = details.localFocalPoint - _lastFocalPoint!;
                _ctrl.panByPixels(delta.dx, delta.dy, _tileSize);
                _lastFocalPoint = details.localFocalPoint;
              }
              if ((details.scale - 1.0).abs() > 0.02) {
                final nextZoom =
                    (_baseScaleZoom + math.log(details.scale) / math.ln2)
                        .clamp(5.0, 18.0);
                _ctrl.moveTo(
                  latitude: _ctrl.latitude,
                  longitude: _ctrl.longitude,
                  zoom: nextZoom,
                );
              }
            },
            child: ClipRect(
              child: Stack(
                children: [
                  // 1. Gerçek Harita Karo Katmanı (OpenStreetMap / CartoDB)
                  Positioned.fill(
                    child: _buildSlippyMapTiles(size, isDark),
                  ),

                  // 2. Kullanıcı Mavi Konum Noktası (Gerçek GPS koordinatında)
                  _buildUserLocationMarker(size),

                  // 3. Kümeleme (Cluster) Rozeti
                  if (widget.requests.length > 6)
                    Positioned(
                      left: 16,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: AppRadius.chipBorder,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '+${widget.requests.length - 6}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  // 4. Gerçek Hastane Koordinatlı Kan Talebi Pin'leri
                  for (var i = 0; i < widget.requests.length; i++)
                    _buildRequestPin(widget.requests[i], i, size),

                  // 5. Gerçek Koordinatlı Kızılay & Gezici Araç Pin'leri
                  for (var j = 0; j < widget.centers.length; j++)
                    _buildCenterPin(widget.centers[j], j, size),

                  // 6. Sağ Üst Yakınlaştır / Uzaklaştır Kontrolleri
                  Positioned(
                    right: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: Column(
                      children: [
                        _ZoomMiniButton(
                          icon: Icons.add_rounded,
                          tooltip: 'Yakınlaştır',
                          onTap: () => _ctrl.zoomBy(1.0),
                        ),
                        const SizedBox(height: 6),
                        _ZoomMiniButton(
                          icon: Icons.remove_rounded,
                          tooltip: 'Uzaklaştır',
                          onTap: () => _ctrl.zoomBy(-1.0),
                        ),
                      ],
                    ),
                  ),

                  // 7. Sol Alt OpenStreetMap / Harita Katkı Etiketi
                  Positioned(
                    left: 8,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white)
                            .withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '© OpenStreetMap • Gerçek Koordinat Haritası',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNativeGoogleMap(bool isDark) {
    final markers = <Marker>{
      for (final req in widget.requests)
        Marker(
          markerId: MarkerId('req_${req.id}'),
          position: LatLng(req.hospital.latitude, req.hospital.longitude),
          icon: _markerBitmapCache['req_${req.urgency.name}'] ??
              BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: '${req.bloodType.code} • ${req.hospital.name}',
            snippet: '${req.hospital.district}/${req.hospital.province}',
          ),
          onTap: () => widget.onSelectRequest(req),
        ),
      for (final ctr in widget.centers)
        Marker(
          markerId: MarkerId('ctr_${ctr.id}'),
          position: LatLng(ctr.latitude, ctr.longitude),
          icon:
              _markerBitmapCache['center'] ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: ctr.name,
            snippet: ctr.workingHours,
          ),
          onTap: () => widget.onSelectCenter(ctr),
        ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_ctrl.latitude, _ctrl.longitude),
        zoom: _ctrl.zoom,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      style: isDark ? _darkGoogleMapStyle : null,
      markers: markers,
      onMapCreated: _ctrl.attachGoogleMap,
    );
  }

  Widget _buildSlippyMapTiles(Size size, bool isDark) {
    if (_isFlutterTest) {
      return CustomPaint(
        painter: _OfflineStreetFallbackPainter(isDark: isDark),
      );
    }

    final int z = _ctrl.zoom.floor().clamp(5, 18);
    final int maxTileIndex = (1 << z);
    final double centerTileX = _lonToTileX(_ctrl.longitude, z.toDouble());
    final double centerTileY = _latToTileY(_ctrl.latitude, z.toDouble());

    final int startX =
        (centerTileX - (size.width / 2) / _tileSize).floor() - 1;
    final int endX = (centerTileX + (size.width / 2) / _tileSize).ceil() + 1;
    final int startY =
        (centerTileY - (size.height / 2) / _tileSize).floor() - 1;
    final int endY = (centerTileY + (size.height / 2) / _tileSize).ceil() + 1;

    final tiles = <Widget>[
      Positioned.fill(
        child: CustomPaint(
          painter: _OfflineStreetFallbackPainter(isDark: isDark),
        ),
      ),
    ];

    for (var tx = startX; tx <= endX; tx++) {
      for (var ty = startY; ty <= endY; ty++) {
        if (ty < 0 || ty >= maxTileIndex) continue;
        final wrappedX = ((tx % maxTileIndex) + maxTileIndex) % maxTileIndex;
        final left = (tx - centerTileX) * _tileSize + size.width / 2;
        final top = (ty - centerTileY) * _tileSize + size.height / 2;

        final tileUrl = isDark
            ? 'https://a.basemaps.cartocdn.com/dark_all/$z/$wrappedX/$ty.png'
            : 'https://tile.openstreetmap.org/$z/$wrappedX/$ty.png';

        tiles.add(
          Positioned(
            key: ValueKey('tile_${isDark ? "d" : "l"}_${z}_${wrappedX}_$ty'),
            left: left,
            top: top,
            width: _tileSize + 0.5,
            height: _tileSize + 0.5,
            child: Image.network(
              tileUrl,
              fit: BoxFit.cover,
              headers: const {
                'User-Agent': 'TurkiyeKanAgiApp/1.0 (https://kanagi.org.tr)',
              },
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        );
      }
    }

    return Stack(children: tiles);
  }

  Widget _buildUserLocationMarker(Size size) {
    final pos = _latLngToViewportOffset(
      lat: widget.userLatitude,
      lon: widget.userLongitude,
      viewportSize: size,
    );
    return Positioned(
      left: (pos.dx - 11).clamp(8.0, size.width - 28.0),
      top: (pos.dy - 11).clamp(8.0, size.height - 28.0),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.info,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.info.withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestPin(BloodRequest req, int index, Size size) {
    // Aynı hastanede birden fazla talep varsa üst üste binmemesi için küçük açısal ofset
    final angle = (index * 1.15);
    final jitterLat = req.hospital.latitude + math.sin(angle) * 0.0035;
    final jitterLon = req.hospital.longitude + math.cos(angle) * 0.0045;

    final rawPos = _latLngToViewportOffset(
      lat: jitterLat,
      lon: jitterLon,
      viewportSize: size,
    );

    // İlk 6 pin'in her zaman görünür alanda kalmasını garanti et (farklı şehirlerde olsalar bile kenarda/yakında erişilebilir)
    final bool isOut = rawPos.dx < 8 ||
        rawPos.dx > size.width - 68 ||
        rawPos.dy < 8 ||
        rawPos.dy > size.height - 44;

    if (isOut && index >= 6) {
      return const SizedBox.shrink();
    }

    final dx = rawPos.dx.clamp(12.0, math.max(12.0, size.width - 74.0)).toDouble();
    final dy = rawPos.dy.clamp(12.0, math.max(12.0, size.height - 44.0)).toDouble();

    return Positioned(
      left: dx,
      top: dy,
      child: GestureDetector(
        key: Key('map_request_pin_${req.id}'),
        onTap: () => widget.onSelectRequest(req),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _pinColorForUrgency(req.urgency),
            borderRadius: AppRadius.chipBorder,
            border: Border.all(color: Colors.white, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bloodtype_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 2),
              Text(
                req.bloodType.code,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPin(DonationCenter center, int index, Size size) {
    final rawPos = _latLngToViewportOffset(
      lat: center.latitude,
      lon: center.longitude,
      viewportSize: size,
    );

    final bool isOut = rawPos.dx < 8 ||
        rawPos.dx > size.width - 80 ||
        rawPos.dy < 8 ||
        rawPos.dy > size.height - 44;

    if (isOut && index >= 4) {
      return const SizedBox.shrink();
    }

    final dx = rawPos.dx.clamp(12.0, math.max(12.0, size.width - 96.0)).toDouble();
    final dy = rawPos.dy.clamp(12.0, math.max(12.0, size.height - 44.0)).toDouble();

    return Positioned(
      left: dx,
      top: dy,
      child: GestureDetector(
        key: Key('map_center_pin_${center.id}'),
        onTap: () => widget.onSelectCenter(center),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.info,
            borderRadius: AppRadius.chipBorder,
            border: Border.all(color: Colors.white, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                center.isMobileUnit
                    ? Icons.directions_bus_rounded
                    : Icons.local_hospital_rounded,
                size: 14,
                color: Colors.white,
              ),
              if (center.isMobileUnit) ...[
                const SizedBox(width: 3),
                Text(
                  context.l10n.centerMobileUnitBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomMiniButton extends StatelessWidget {
  const _ZoomMiniButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outline),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _OfflineStreetFallbackPainter extends CustomPainter {
  const _OfflineStreetFallbackPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = isDark ? const Color(0xFF1F1616) : const Color(0xFFEDE8E2);
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // Park / yeşil alanlar ve su kütleleri (gerçek harita dokusu)
    final parkPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2D24) : const Color(0xFFD8E8C8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.12, 95, 65),
        const Radius.circular(14),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.58, 110, 75),
        const Radius.circular(16),
      ),
      parkPaint,
    );

    final mainRoad = Paint()
      ..color = isDark ? const Color(0xFF4A3333) : const Color(0xFFFAD284)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final secondaryRoad = Paint()
      ..color = isDark ? const Color(0xFF332222) : Colors.white
      ..strokeWidth = 3.0;

    for (double x = 24; x < size.width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), secondaryRoad);
    }
    for (double y = 24; y < size.height; y += 56) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), secondaryRoad);
    }

    final highway = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.44,
        size.width,
        size.height * 0.22,
      );
    canvas.drawPath(highway, mainRoad);
  }

  @override
  bool shouldRepaint(covariant _OfflineStreetFallbackPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
