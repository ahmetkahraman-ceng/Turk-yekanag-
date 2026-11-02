import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/province_district_picker_dialog.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/data/local_json_hospital_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/hospital.dart';
import 'package:turkiye_kan_agi/features/requests/domain/prohibited_content_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Çok adımlı Kan Talebi Oluşturma / Düzenleme ekranı.
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

  BloodType _bloodType = BloodType.aPos;
  BloodProductType _productType = BloodProductType.erythrocyte;
  int _unitsNeeded = 1;
  Hospital? _selectedHospital;
  RequestUrgency _urgency = RequestUrgency.critical;
  Uint8List? _medicalReportBytes;
  String? _errorMessage;
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

  Future<void> _selectHospital() async {
    final hospitals = await ref.read(hospitalRepositoryProvider).searchHospitals();
    if (!mounted) return;
    final items = hospitals
        .map((h) => '${h.name} (${h.district}/${h.province})')
        .toList();
    final selectedName = await SearchableStringPickerDialog.show(
      context,
      title: context.l10n.requestHospitalSelectLabel,
      items: items,
    );
    if (selectedName != null) {
      final found = hospitals
          .where((h) => '${h.name} (${h.district}/${h.province})' == selectedName)
          .firstOrNull;
      if (found != null) setState(() => _selectedHospital = found);
    }
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(l10n.requestStepPatientProduct, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  key: const Key('request_initials_field'),
                  controller: _initialsController,
                  labelText: l10n.requestPatientInitialsLabel,
                  hintText: l10n.requestPatientInitialsHint,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final bt in BloodType.knownTypes)
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
                  decoration: InputDecoration(labelText: l10n.requestProductTypeLabel),
                  items: [
                    DropdownMenuItem(value: BloodProductType.wholeBlood, child: Text(l10n.productWholeBlood)),
                    DropdownMenuItem(value: BloodProductType.erythrocyte, child: Text(l10n.productErythrocyte)),
                    DropdownMenuItem(value: BloodProductType.platelet, child: Text(l10n.productPlatelet)),
                    DropdownMenuItem(value: BloodProductType.plasma, child: Text(l10n.productPlasma)),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _productType = v);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(l10n.requestUnitsLabel),
                    const Spacer(),
                    for (int u = 1; u <= 4; u++)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: ChoiceChip(
                          label: Text('$u'),
                          selected: _unitsNeeded == u,
                          onSelected: (_) => setState(() => _unitsNeeded = u),
                        ),
                      ),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                Text(l10n.requestStepHospitalUrgency, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                ListTile(
                  key: const Key('select_hospital_tile'),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  title: Text(_selectedHospital?.name ?? l10n.requestHospitalSelectLabel),
                  trailing: const Icon(Icons.local_hospital_outlined),
                  onTap: _selectHospital,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('request_department_field'),
                  controller: _departmentController,
                  labelText: l10n.requestDepartmentLabel,
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
                        onSelected: (_) => setState(() => _urgency = urg.$1),
                      ),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                Text(l10n.requestStepContactReport, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  key: const Key('request_contact_phone_field'),
                  controller: _contactPhoneController,
                  labelText: l10n.requestContactPhoneLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('request_notes_field'),
                  controller: _notesController,
                  labelText: l10n.requestNotesLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  key: const Key('attach_medical_report_button'),
                  onPressed: () => setState(() => _medicalReportBytes = Uint8List.fromList([1, 2, 3])),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(
                    _medicalReportBytes != null
                        ? l10n.requestMedicalReportAttached
                        : l10n.requestMedicalReportButton,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
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
        ],
      ),
    );
  }
}
