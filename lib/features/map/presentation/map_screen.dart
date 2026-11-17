import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/mock/center_repository.dart';
import 'package:turkiye_kan_agi/core/mock/donation_center.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/services/location_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_chip.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/feature_placeholder_view.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donor_status_snapshot.dart';
import 'package:turkiye_kan_agi/features/map/presentation/widgets/map_canvas_and_sheets.dart';
import 'package:turkiye_kan_agi/features/matching/domain/blood_compatibility_engine.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/widgets/request_card.dart';

/// Harita ve Bağış Merkezleri ekranı (Aşama 5):
/// - Gerçek sokak haritası karoları (OpenStreetMap / CartoDB veya `GOOGLE_MAPS_API_KEY` varsa yerel `GoogleMap`)
/// - Gerçek hastane ve Kızılay bağış merkezi GPS koordinatları, şehir seçici (Ankara / İstanbul / İzmir)
/// - Pin'e dokununca kamerayı o noktaya odaklama ve DraggableScrollableSheet özet kartı
/// - Liste / Harita geçişi ve alt yakın liste
/// - Konum izni yoksa fallback EmptyState ("Konumu aç", "Listeyi gör")
/// - Gezici kan bağış aracı için özel ikon ve "Bugün burada" etiketi.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.initialState = ScreenViewState.empty,
  });

  final ScreenViewState initialState;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RealMapController _mapController = RealMapController();
  Timer? _debounceTimer;
  List<BloodRequest> _requests = const <BloodRequest>[];
  List<DonationCenter> _centers = const <DonationCenter>[];
  bool _showRequests = true;
  bool _showCenters = true;
  bool _onlyMyBlood = false;
  bool _isListView = false;
  bool _hasLocationPermission = true;
  bool _didInitialFocus = false;
  String _searchQuery = '';
  String? _selectedCity;
  BloodRequest? _selectedRequest;
  DonationCenter? _selectedCenter;

  static const Map<String, (double, double)> _cityCoordinates = {
    'Ankara': (39.9208, 32.8541),
    'İstanbul': (41.0082, 28.9784),
    'İzmir': (38.4237, 27.1428),
  };

  @override
  void initState() {
    super.initState();
    _loadMapData();
    if (!LocationService.isFlutterTest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final existing = ref.read(userLocationProvider).valueOrNull;
        if (existing != null) {
          _applyUserLocationToCamera(existing);
        } else {
          _goToMyRealLocation(silent: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    final reqRes =
        await ref.read(bloodRequestRepositoryProvider).fetchRequests(limit: 25);
    final ctrRes = await ref.read(centerRepositoryProvider).fetchCenters();
    if (!mounted) return;
    reqRes.when(
      success: (list) => setState(() => _requests = list),
      failure: (_) {},
    );
    ctrRes.when(
      success: (list) => setState(() => _centers = list),
      failure: (_) {},
    );
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      final q = value.trim().toLowerCase();
      setState(() => _searchQuery = q);
      if (q.contains('istanbul') || q.contains('kadıköy') || q.contains('şişli')) {
        _focusCity('İstanbul');
      } else if (q.contains('izmir') || q.contains('konak') || q.contains('bornova')) {
        _focusCity('İzmir');
      } else if (q.contains('ankara') || q.contains('çankaya') || q.contains('bilkent')) {
        _focusCity('Ankara');
      }
    });
  }

  void _focusCity(String? city) {
    setState(() {
      _selectedCity = city;
      _selectedRequest = null;
      _selectedCenter = null;
    });
    if (city == null) return;
    final coords = _cityCoordinates[city];
    if (coords == null) return;
    _mapController.moveTo(
      latitude: coords.$1,
      longitude: coords.$2,
      zoom: 11.4,
    );
  }

  void _applyUserLocationToCamera(UserLocationData loc) {
    setState(() {
      _hasLocationPermission = true;
      _didInitialFocus = true;
      _selectedCity =
          _cityCoordinates.containsKey(loc.province) ? loc.province : null;
    });
    _mapController.moveTo(
      latitude: loc.latitude,
      longitude: loc.longitude,
      zoom: 13.0,
    );
  }

  Future<void> _goToMyRealLocation({bool silent = false}) async {
    final loc =
        await ref.read(userLocationProvider.notifier).refreshWithPermission();
    if (!mounted) return;
    if (loc == null) {
      if (!silent) {
        setState(() => _hasLocationPermission = false);
        AppSnackbar.show(
          context,
          message: context.l10n.mapNoLocationTitle,
        );
      }
      return;
    }
    _applyUserLocationToCamera(loc);
    if (!silent) {
      AppSnackbar.show(
        context,
        message: '${loc.formattedArea} (${loc.formattedCoordinates})',
      );
    }
  }

  List<BloodRequest> _filteredRequestsFor(BloodType userBloodType) {
    if (!_showRequests) return const <BloodRequest>[];
    final effectiveBlood =
        userBloodType == BloodType.unknown ? BloodType.aPos : userBloodType;
    return _requests.where((r) {
      if (_selectedCity != null &&
          _searchQuery.isEmpty &&
          r.hospital.province != _selectedCity) {
        return false;
      }
      if (_onlyMyBlood) {
        final compatible = BloodCompatibilityEngine.isCompatible(
          donor: effectiveBlood,
          recipient: r.bloodType,
          productType: r.productType,
        );
        if (!compatible && r.bloodType != effectiveBlood) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final hay =
            '${r.hospital.name} ${r.hospital.district} ${r.hospital.province}'
                .toLowerCase();
        if (!hay.contains(_searchQuery)) return false;
      }
      return true;
    }).toList();
  }

  List<DonationCenter> get _filteredCenters {
    if (!_showCenters) return const <DonationCenter>[];
    return _centers.where((c) {
      if (_selectedCity != null &&
          _searchQuery.isEmpty &&
          c.province != _selectedCity) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final hay = '${c.name} ${c.district} ${c.province}'.toLowerCase();
        if (!hay.contains(_searchQuery)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final donorStatus = ref.watch(currentDonorStatusProvider).valueOrNull;
    final userBloodType = donorStatus?.bloodType ?? BloodType.aPos;
    final gpsData = ref.watch(userLocationProvider).valueOrNull;

    ref.listen<AsyncValue<UserLocationData?>>(userLocationProvider, (prev, next) {
      final loc = next.valueOrNull;
      if (loc != null && prev?.valueOrNull?.updatedAt != loc.updatedAt) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _applyUserLocationToCamera(loc);
        });
      }
    });

    if (!_didInitialFocus && gpsData != null) {
      _didInitialFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyUserLocationToCamera(gpsData);
      });
    } else if (!_didInitialFocus && donorStatus != null) {
      _didInitialFocus = true;
      final profCity = donorStatus.province;
      if (_cityCoordinates.containsKey(profCity) && _selectedCity != profCity) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusCity(profCity);
        });
      }
    }

    final reqs = _filteredRequestsFor(userBloodType);
    final ctrs = _filteredCenters;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapTitle),
        actions: [
          IconButton(
            key: const Key('toggle_location_permission_button'),
            tooltip: l10n.mapOpenLocationButton,
            onPressed: () {
              if (_hasLocationPermission) {
                setState(() => _hasLocationPermission = false);
              } else {
                _goToMyRealLocation();
              }
            },
            icon: Icon(
              _hasLocationPermission
                  ? Icons.location_on_rounded
                  : Icons.location_off_outlined,
            ),
          ),
          IconButton(
            key: const Key('toggle_map_list_button'),
            tooltip: _isListView ? l10n.mapToggleMap : l10n.mapToggleList,
            onPressed: () => setState(() => _isListView = !_isListView),
            icon: Icon(
              _isListView ? Icons.map_outlined : Icons.view_list_rounded,
            ),
          ),
        ],
      ),
      body: ResponsiveConstrainedBox(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: AppSearchField(
                hintText: l10n.requestHospitalSearchHint,
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  AppChip(
                    label: l10n.mapFilterRequests,
                    selected: _showRequests,
                    onSelected: (v) => setState(() => _showRequests = v),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppChip(
                    label: l10n.mapFilterCenters,
                    selected: _showCenters,
                    onSelected: (v) => setState(() => _showCenters = v),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppChip(
                    label: '${l10n.mapFilterMyBlood} (${userBloodType.code})',
                    selected: _onlyMyBlood,
                    onSelected: (v) => setState(() => _onlyMyBlood = v),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  for (final city in _cityCoordinates.keys) ...[
                    AppChip(
                      label: city,
                      icon: Icons.place_outlined,
                      selected: _selectedCity == city,
                      onSelected: (_) => _focusCity(
                        _selectedCity == city ? null : city,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: !_hasLocationPermission && !_isListView
                  ? Column(
                      children: [
                        Expanded(
                          child: EmptyState(
                            icon: Icons.location_off_outlined,
                            title: l10n.mapNoLocationTitle,
                            subtitle: l10n.mapNoLocationSubtitle,
                            actionLabel: l10n.mapOpenLocationButton,
                            onAction: _goToMyRealLocation,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: TextButton(
                            onPressed: () =>
                                setState(() => _isListView = true),
                            child: Text(l10n.mapViewListButton),
                          ),
                        ),
                      ],
                    )
                  : _isListView
                      ? _NearbyListView(
                          requests: reqs,
                          centers: ctrs,
                          userBloodType: userBloodType,
                        )
                      : Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Stack(
                                    children: [
                                      InteractiveMapCanvas(
                                        controller: _mapController,
                                        requests: reqs,
                                        centers: ctrs,
                                        userLatitude:
                                            gpsData?.latitude ?? 39.9208,
                                        userLongitude:
                                            gpsData?.longitude ?? 32.8541,
                                        onSelectRequest: (r) {
                                          _mapController.moveTo(
                                            latitude: r.hospital.latitude,
                                            longitude: r.hospital.longitude,
                                            zoom: 13.5,
                                          );
                                          setState(() {
                                            _selectedRequest = r;
                                            _selectedCenter = null;
                                          });
                                        },
                                        onSelectCenter: (c) {
                                          _mapController.moveTo(
                                            latitude: c.latitude,
                                            longitude: c.longitude,
                                            zoom: 13.5,
                                          );
                                          setState(() {
                                            _selectedCenter = c;
                                            _selectedRequest = null;
                                          });
                                        },
                                      ),
                                      Positioned(
                                        right: AppSpacing.md,
                                        bottom: AppSpacing.md,
                                        child: FloatingActionButton.small(
                                          key: const Key(
                                            'map_my_location_button',
                                          ),
                                          heroTag: 'map_my_location_fab_hero',
                                          tooltip: l10n.mapMyLocationTooltip,
                                          onPressed: _goToMyRealLocation,
                                          child: const Icon(
                                            Icons.my_location_rounded,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: _NearbyListView(
                                    requests: reqs,
                                    centers: ctrs,
                                    userBloodType: userBloodType,
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedRequest != null ||
                                _selectedCenter != null)
                              MapPinSummarySheet(
                                request: _selectedRequest,
                                center: _selectedCenter,
                                userBloodType: userBloodType,
                                onClose: () => setState(() {
                                  _selectedRequest = null;
                                  _selectedCenter = null;
                                }),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyListView extends StatelessWidget {
  const _NearbyListView({
    required this.requests,
    required this.centers,
    required this.userBloodType,
  });

  final List<BloodRequest> requests;
  final List<DonationCenter> centers;
  final BloodType userBloodType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (centers.isNotEmpty) ...[
          SectionHeader(title: l10n.mapFilterCenters),
          for (final center in centers.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(
                    center.isMobileUnit
                        ? Icons.directions_bus_rounded
                        : Icons.local_hospital_rounded,
                    color: AppColors.info,
                  ),
                  title: Text(center.name),
                  subtitle: Text(
                    '${center.district}/${center.province} • ${center.workingHours} (${center.isOpenNow ? l10n.centerOpenNow : l10n.centerClosedNow})',
                  ),
                  trailing: IconButton(
                    tooltip: l10n.requestDirectionsButton,
                    onPressed: () =>
                        DirectionsPickerSheet.show(context, center.name),
                    icon: const Icon(Icons.directions_rounded),
                  ),
                ),
              ),
            ),
        ],
        if (requests.isNotEmpty) ...[
          SectionHeader(title: l10n.mapNearbyListTitle),
          for (final req in requests.take(8))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: RequestCard(
                request: req,
                userBloodType: userBloodType,
                enableHero: false,
                onTap: () => context.push('${AppRoutes.requests}/${req.id}'),
              ),
            ),
        ],
      ],
    );
  }
}
