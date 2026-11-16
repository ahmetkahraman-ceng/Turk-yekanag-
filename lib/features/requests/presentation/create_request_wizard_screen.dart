import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/core/widgets/step_and_progress.dart';
import 'package:turkiye_kan_agi/core/widgets/tiles_and_selection_sheet.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/data/local_json_hospital_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/hospital.dart';
import 'package:turkiye_kan_agi/features/requests/domain/prohibited_content_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/widgets/request_card.dart';

/// Talep açma sihirbazı (4 adım, StepIndicator, sabit alt buton,
/// para/ücret satır içi uyarısı, RequestCard birebir önizlemesi ve taslak koruma).
class CreateRequestWizardScreen extends ConsumerStatefulWidget {
  const CreateRequestWizardScreen({this.editingRequest, super.key});

  final BloodRequest? editingRequest;

  @override
  ConsumerState<CreateRequestWizardScreen> createState() =>
      _CreateRequestWizardScreenState();
}

class _CreateRequestWizardScreenState
    extends ConsumerState<CreateRequestWizardScreen> {
  final TextEditingController _initialsController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int _currentStep = 0;
  BloodType _bloodType = BloodType.aPos;
  BloodProductType _productType = BloodProductType.erythrocyte;
  int _unitsNeeded = 1;
  Hospital? _selectedHospital;
  RequestUrgency _urgency = RequestUrgency.critical;
  Uint8List? _medicalReportBytes;
  String? _errorMessage;
  String? _inlineProhibitedWarning;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.editingRequest;
    if (edit != null) {
      _initialsController.text = edit.patientInitials;
      _departmentController.text = edit.department;
      _notesController.text = edit.notes;
      _bloodType = edit.bloodType;
      _productType = edit.productType;
      _unitsNeeded = edit.unitsNeeded;
      _selectedHospital = edit.hospital;
      _urgency = edit.urgency;
    }
  }

  @override
  void dispose() {
    _initialsController.dispose();
    _departmentController.dispose();
    _contactPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _checkProhibitedInline(String value) {
    final hasProhibited =
        ProhibitedContentFilter.containsProhibitedContent(value);
    setState(() {
      _inlineProhibitedWarning =
          hasProhibited ? context.l10n.requestProhibitedTextError : null;
    });
  }

  Future<void> _selectHospital() async {
    final hospitals =
        await ref.read(hospitalRepositoryProvider).searchHospitals();
    if (!mounted) return;
    final l10n = context.l10n;
    final selected = await SelectionSheet.show<Hospital>(
      context: context,
      title: l10n.requestHospitalSelectLabel,
      searchHint: l10n.requestHospitalSearchHint,
      items: hospitals,
      labelBuilder: (h) => h.name,
      subtitleBuilder: (h) => '${h.district} / ${h.province}',
      selectedItem: _selectedHospital,
    );
    if (selected != null) {
      setState(() {
        _selectedHospital = selected;
        _currentStep = 1;
      });
    }
  }

  BloodRequest _buildPreviewRequest() {
    final now = DateTime.now().toUtc();
    return BloodRequest(
      id: 'preview-req',
      requesterUid: 'local-user',
      patientInitials: _initialsController.text.trim().isEmpty
          ? 'A.Y.'
          : _initialsController.text.trim(),
      bloodType: _bloodType,
      productType: _productType,
      unitsNeeded: _unitsNeeded,
      hospital: _selectedHospital ??
          const Hospital(
            id: 'preview-hosp',
            name: 'Ankara Bilkent Şehir Hastanesi',
            province: 'Ankara',
            district: 'Çankaya',
            latitude: 39.9,
            longitude: 32.7,
          ),
      department: _departmentController.text.trim().isEmpty
          ? 'Genel Yoğun Bakım'
          : _departmentController.text.trim(),
      urgency: _urgency,
      status: RequestStatus.open,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
      notes: _notesController.text.trim(),
    );
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final initials = _initialsController.text.trim();
    final department = _departmentController.text.trim();
    final notes = _notesController.text.trim();

    if (!ProhibitedContentFilter.isValidPatientInitials(initials)) {
      setState(() => _errorMessage = l10n.requestPatientInitialsError);
      return;
    }
    if (_selectedHospital == null) {
      setState(() => _errorMessage = l10n.requestHospitalRequiredError);
      return;
    }
    if (department.isEmpty) {
      setState(() => _errorMessage = l10n.requestDepartmentRequiredError);
      return;
    }
    if (ProhibitedContentFilter.containsProhibitedContent(notes) ||
        ProhibitedContentFilter.containsProhibitedContent(department)) {
      setState(() => _errorMessage = l10n.requestProhibitedTextError);
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final remoteConfig = ref.read(remoteConfigServiceProvider);
    final now = DateTime.now().toUtc();

    final req = BloodRequest(
      id: widget.editingRequest?.id ?? 'req-${now.millisecondsSinceEpoch}',
      requesterUid: uid,
      patientInitials: initials,
      bloodType: _bloodType,
      productType: _productType,
      unitsNeeded: _unitsNeeded,
      hospital: _selectedHospital!,
      department: department,
      urgency: _urgency,
      status: RequestStatus.open,
      createdAt: widget.editingRequest?.createdAt ?? now,
      expiresAt: _urgency.calculateExpiryFrom(now, remoteConfig),
      notes: notes,
      hasMedicalReport: _medicalReportBytes != null,
    );

    final repo = ref.read(bloodRequestRepositoryProvider);
    final result = widget.editingRequest != null
        ? await repo.updateRequest(req)
        : await repo.createRequest(
            request: req,
            contactName: initials,
            contactPhone: _contactPhoneController.text.trim(),
            medicalReportBytes: _medicalReportBytes,
          );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (_) => context.pop(),
      failure: (f) {
        final msg = switch (f.technicalDetails) {
          'MAX_ACTIVE_LIMIT' => l10n.requestLimitActiveError(
              remoteConfig.maxActiveRequestsPerUser,
            ),
          'MAX_DAILY_LIMIT' => l10n.requestLimitDailyError(
              remoteConfig.maxDailyRequestsPerUser,
            ),
          _ => l10n.requestProhibitedTextError,
        };
        setState(() => _errorMessage = msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editingRequest != null
              ? l10n.requestEditTitle
              : l10n.requestCreateTitle,
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          ResponsiveConstrainedBox(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: StepIndicator(
              totalSteps: 4,
              currentStep: _currentStep,
            ),
          ),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(
                    l10n.requestStepPatientProduct,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField(
                    key: const Key('request_initials_field'),
                    controller: _initialsController,
                    labelText: l10n.requestPatientInitialsLabel,
                    hintText: l10n.requestPatientInitialsHint,
                    onChanged: (_) => setState(() => _currentStep = 0),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final bt in BloodType.knownValues)
                        ChoiceChip(
                          key: Key('request_blood_${bt.code}'),
                          label: Text(bt.code),
                          selected: _bloodType == bt,
                          onSelected: (_) => setState(() => _bloodType = bt),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<BloodProductType>(
                    initialValue: _productType,
                    decoration: InputDecoration(
                      labelText: l10n.requestProductTypeLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: BloodProductType.wholeBlood,
                        child: Text(l10n.productWholeBlood),
                      ),
                      DropdownMenuItem(
                        value: BloodProductType.erythrocyte,
                        child: Text(l10n.productErythrocyte),
                      ),
                      DropdownMenuItem(
                        value: BloodProductType.platelet,
                        child: Text(l10n.productPlatelet),
                      ),
                      DropdownMenuItem(
                        value: BloodProductType.plasma,
                        child: Text(l10n.productPlasma),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _productType = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: Text(l10n.requestUnitsLabel)),
                      IconButton.outlined(
                        onPressed: _unitsNeeded > 1
                            ? () => setState(() => _unitsNeeded--)
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          l10n.requestUnitsValue(_unitsNeeded),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: _unitsNeeded < 10
                            ? () => setState(() => _unitsNeeded++)
                            : null,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl),
                  Text(
                    l10n.requestStepHospitalUrgency,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      key: const Key('select_hospital_tile'),
                      title: Text(
                        _selectedHospital?.name ??
                            l10n.requestHospitalSelectLabel,
                      ),
                      trailing: const Icon(Icons.local_hospital_outlined),
                      onTap: _selectHospital,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    key: const Key('request_department_field'),
                    controller: _departmentController,
                    labelText: l10n.requestDepartmentLabel,
                    onChanged: (val) {
                      _checkProhibitedInline(val);
                      setState(() => _currentStep = 1);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      for (final urg in [
                        (RequestUrgency.critical, l10n.urgencyCritical),
                        (RequestUrgency.today, l10n.urgencyToday),
                        (RequestUrgency.thisWeek, l10n.urgencyThisWeek),
                      ])
                        ChoiceChip(
                          label: Text(urg.$2),
                          selected: _urgency == urg.$1,
                          onSelected: (_) => setState(() {
                            _urgency = urg.$1;
                            _currentStep = 2;
                          }),
                        ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl),
                  Text(
                    l10n.requestStepContactReport,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField.phone(
                    key: const Key('request_contact_phone_field'),
                    controller: _contactPhoneController,
                    labelText: l10n.requestContactPhoneLabel,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    key: const Key('request_notes_field'),
                    controller: _notesController,
                    labelText: l10n.requestNotesLabel,
                    errorText: _inlineProhibitedWarning,
                    onChanged: (val) {
                      _checkProhibitedInline(val);
                      setState(() => _currentStep = 2);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    key: const Key('attach_medical_report_button'),
                    variant: AppButtonVariant.secondary,
                    icon: Icons.upload_file_rounded,
                    label: _medicalReportBytes != null
                        ? l10n.requestMedicalReportAttached
                        : l10n.requestMedicalReportButton,
                    onPressed: () => setState(
                      () => _medicalReportBytes = Uint8List.fromList([1, 2, 3]),
                    ),
                  ),
                  const Divider(height: AppSpacing.xl),
                  RequestCard(
                    request: _buildPreviewRequest(),
                    enableHero: false,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    key: const Key('submit_request_button'),
                    label: widget.editingRequest != null
                        ? l10n.requestSaveChangesButton
                        : l10n.requestSubmitButton,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
