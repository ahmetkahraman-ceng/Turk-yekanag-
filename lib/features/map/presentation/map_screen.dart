import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/mock/center_repository.dart';
import 'package:turkiye_kan_agi/core/mock/donation_center.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
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
import 'package:turkiye_kan_agi/features/map/presentation/widgets/map_canvas_and_sheets.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/widgets/request_card.dart';

/// Harita ve Bağış Merkezleri ekranı (Aşama 5):
/// - Üstte arama ve filtre çipleri (Talepler, Bağış merkezleri, Kan grubum), "Konumuma git"
/// - Pin'e dokununca DraggableScrollableSheet özet kart
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
  Timer? _debounceTimer;
  List<BloodRequest> _requests = const <BloodRequest>[];
  List<DonationCenter> _centers = const <DonationCenter>[];
  bool _showRequests = true;
  bool _showCenters = true;
  bool _onlyMyBlood = false;
  bool _isListView = false;
  bool _hasLocationPermission = true;
  String _searchQuery = '';
  BloodRequest? _selectedRequest;
  DonationCenter? _selectedCenter;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    final reqRes =
        await ref.read(bloodRequestRepositoryProvider).fetchRequests(limit: 20);
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
      setState(() => _searchQuery = value.trim().toLowerCase());
    });
  }

  List<BloodRequest> get _filteredRequests {
    if (!_showRequests) return const <BloodRequest>[];
    return _requests.where((r) {
      if (_onlyMyBlood && r.bloodType != BloodType.aPos) return false;
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
    final reqs = _filteredRequests;
    final ctrs = _filteredCenters;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapTitle),
        actions: [
          IconButton(
            key: const Key('toggle_location_permission_button'),
            tooltip: l10n.mapOpenLocationButton,
            onPressed: () => setState(
              () => _hasLocationPermission = !_hasLocationPermission,
            ),
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
                    label: l10n.mapFilterMyBlood,
                    selected: _onlyMyBlood,
                    onSelected: (v) => setState(() => _onlyMyBlood = v),
                  ),
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
                            onAction: () => setState(
                              () => _hasLocationPermission = true,
                            ),
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
                      ? _NearbyListView(requests: reqs, centers: ctrs)
                      : Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Stack(
                                    children: [
                                      InteractiveMapCanvas(
                                        requests: reqs,
                                        centers: ctrs,
                                        onSelectRequest: (r) => setState(() {
                                          _selectedRequest = r;
                                          _selectedCenter = null;
                                        }),
                                        onSelectCenter: (c) => setState(() {
                                          _selectedCenter = c;
                                          _selectedRequest = null;
                                        }),
                                      ),
                                      Positioned(
                                        right: AppSpacing.md,
                                        bottom: AppSpacing.md,
                                        child: FloatingActionButton.small(
                                          key: const Key(
                                            'map_my_location_button',
                                          ),
                                          tooltip: l10n.mapMyLocationTooltip,
                                          onPressed: () {
                                            AppSnackbar.show(
                                              context,
                                              message:
                                                  l10n.mapMyLocationTooltip,
                                            );
                                          },
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
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedRequest != null ||
                                _selectedCenter != null)
                              MapPinSummarySheet(
                                request: _selectedRequest,
                                center: _selectedCenter,
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
  });

  final List<BloodRequest> requests;
  final List<DonationCenter> centers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (centers.isNotEmpty) ...[
          SectionHeader(title: l10n.mapFilterCenters),
          for (final center in centers.take(4))
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
          for (final req in requests.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: RequestCard(
                request: req,
                enableHero: false,
                onTap: () => context.push('${AppRoutes.requests}/${req.id}'),
              ),
            ),
        ],
      ],
    );
  }
}
