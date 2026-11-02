// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Türkiye Blood Network';

  @override
  String get appTagline =>
      'Solidarity network connecting voluntary blood donors with people in need';

  @override
  String get nonCommercialNotice =>
      'Buying or selling blood for money is strictly prohibited in this app. This is a voluntary solidarity network complementing the Red Crescent (Kızılay).';

  @override
  String get splashLoading => 'Preparing application...';

  @override
  String get navRequests => 'Requests';

  @override
  String get navRequestsSemantics => 'Blood requests tab';

  @override
  String get navMap => 'Map';

  @override
  String get navMapSemantics => 'Nearby blood requests map tab';

  @override
  String get navDonation => 'Donation';

  @override
  String get navDonationSemantics =>
      'Blood donation eligibility and history tab';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navNotificationsSemantics => 'Notifications tab';

  @override
  String get navProfile => 'Profile';

  @override
  String get navProfileSemantics => 'User profile and settings tab';

  @override
  String get requestsTitle => 'Blood Requests';

  @override
  String get requestsEmptyTitle => 'No active blood requests yet';

  @override
  String get requestsEmptySubtitle =>
      'Urgent requests matching your blood type in your area will be listed here.';

  @override
  String get mapTitle => 'Request Map';

  @override
  String get mapEmptyTitle => 'Map view is being prepared';

  @override
  String get mapEmptySubtitle =>
      'For donor privacy, exact locations are never shared; only province, district, and hospital points are displayed.';

  @override
  String get donationTitle => 'Donation Guide';

  @override
  String get donationEmptyTitle => 'No donation records found';

  @override
  String get donationEmptySubtitle =>
      'You can track your donation intervals here according to Kızılay and Ministry of Health guidelines.';

  @override
  String donationIntervalInfo(int maleDays, int femaleDays) {
    return 'Whole blood donation interval: Male $maleDays days, Female $femaleDays days (Must be verified with current Kızılay and Ministry of Health guidelines).';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'No new notifications';

  @override
  String get notificationsEmptySubtitle =>
      'Urgent calls matching your blood type and match confirmations appear here.';

  @override
  String get profileTitle => 'Profile & Privacy Settings';

  @override
  String get profileEmptyTitle => 'Your profile is not complete yet';

  @override
  String get profileEmptySubtitle =>
      'Your blood type and health data are protected with your explicit consent; you can manage account deletion and data export here.';

  @override
  String get commonRetry => 'Try Again';

  @override
  String get commonRetrySemantics => 'Retry operation button';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonErrorTitle => 'Something went wrong';

  @override
  String get commonErrorMessage =>
      'An unexpected error occurred during the operation. Please try again.';

  @override
  String get networkErrorMessage =>
      'Could not connect to the internet. Please check your connection.';

  @override
  String get unauthorizedErrorMessage =>
      'You must be signed in to perform this action.';

  @override
  String get notFoundTitle => 'Page Not Found (404)';

  @override
  String get notFoundMessage =>
      'The page you are looking for does not exist or may have been moved.';

  @override
  String get notFoundBackHome => 'Back to Home';

  @override
  String get offlineBannerMessage =>
      'You are offline. Data will be updated when your internet connection is restored.';

  @override
  String get offlineBannerSemantics => 'Warning: No internet connection';

  @override
  String get forceUpdateTitle => 'Update Required';

  @override
  String forceUpdateMessage(String minVersion, String currentVersion) {
    return 'For your safety and uninterrupted service, you must install the latest version ($minVersion) of the application. Your current version: $currentVersion.';
  }

  @override
  String get forceUpdateAction => 'Update from Store';

  @override
  String get statePreviewNormal => 'Normal';

  @override
  String get statePreviewLoading => 'Loading';

  @override
  String get statePreviewEmpty => 'Empty';

  @override
  String get statePreviewError => 'Error';

  @override
  String get themeToggleSemantics => 'Toggle theme mode';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get onboardingSlide1Title => 'Voluntary Blood Solidarity';

  @override
  String get onboardingSlide1Description =>
      'Türkiye Blood Network quickly connects patients in urgent need of blood with nearby compatible voluntary donors. It complements Kızılay and strictly prohibits buying or selling blood.';

  @override
  String get onboardingSlide2Title => 'How It Works?';

  @override
  String get onboardingSlide2Description =>
      'When a blood need arises at a hospital, a request is created. The system only notifies compatible and available donors in nearby districts.';

  @override
  String get onboardingSlide3Title => 'Your Personal Data is Safe';

  @override
  String get onboardingSlide3Description =>
      'Your blood type and health info are strictly private under KVKK. Your phone number is never shared until you tap \'I can help\' and both parties confirm.';

  @override
  String get onboardingSlide4Title => 'Why is Location Permission Needed?';

  @override
  String get onboardingSlide4Description =>
      'Your exact location is never shown to others; only province/district level is stored and used to filter urgent calls at the nearest hospital.';

  @override
  String get onboardingStartAction => 'Continue';

  @override
  String get kvkkScreenTitle => 'KVKK Disclosure & Explicit Consent';

  @override
  String get kvkkLightingTitle => 'Summary of KVKK Law No. 6698 Disclosure';

  @override
  String get kvkkLightingBody =>
      'As Türkiye Blood Network, we process your special-category personal data such as blood type, weight, and eligibility solely for matching blood requests based on your explicit consent. Your data is never sold and can be permanently deleted anytime.';

  @override
  String get kvkkConsentHealthTitle =>
      'Health Data Explicit Consent (Required)';

  @override
  String get kvkkConsentHealthSubtitle =>
      'I explicitly consent to the processing of my blood type, weight, birth date, and eligibility data for blood request matching.';

  @override
  String get kvkkConsentLocationTitle =>
      'Province/District & Proximity Consent (Required)';

  @override
  String get kvkkConsentLocationSubtitle =>
      'Without sharing my exact location, I approve the processing of my province/district and distance info to list nearby hospital requests.';

  @override
  String get kvkkConsentNotificationTitle =>
      'Urgent Blood Call Notification Consent (Required)';

  @override
  String get kvkkConsentNotificationSubtitle =>
      'I agree to receive push notifications regarding urgent blood requests matching my blood type and match statuses.';

  @override
  String get kvkkReadPrivacyPolicy => 'Read Privacy Policy';

  @override
  String get kvkkReadTermsOfUse => 'Read Terms of Use';

  @override
  String get kvkkApproveAndContinue => 'Give Explicit Consent & Continue';

  @override
  String get kvkkAllConsentsRequiredWarning =>
      'Please check all explicit consent boxes to continue.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy & KVKK Text';

  @override
  String get privacyPolicyPlaceholderBody =>
      '1. Data Controller & Purpose:\nTürkiye Blood Network operates to connect voluntary blood donors with people in need.\n\n2. Special Category Personal Data:\nYour blood type, weight, and donation history are processed only with your explicit consent under KVKK Article 6 and are readable only by your account via Firestore security rules.\n\n3. Location & Contact Privacy:\nExact donor location is never stored or shared; only province and district are kept. Phone numbers are shared only after mutual \'I can help\' confirmation.\n\n4. Data Subject Rights (Article 11):\nYou can export all your data as JSON or permanently delete your account from the Profile screen.';

  @override
  String get termsOfUseTitle => 'Terms of Use';

  @override
  String get termsOfUsePlaceholderBody =>
      '1. Voluntary Basis & Non-Commercial Rule:\nRequesting or offering blood for money or any material benefit is strictly prohibited.\n\n2. Kızılay & Official Institutions:\nThis app does not replace the Turkish Red Crescent (Kızılay) or Ministry of Health; it facilitates hospital-based voluntary donor routing.\n\n3. Medical Responsibility:\nFinal eligibility decisions belong to the authorized physician at the blood donation center.';

  @override
  String get authLoginTitle => 'Sign In';

  @override
  String get authLoginSubtitle =>
      'Sign in securely with your phone number. Your number is never shared without your approval.';

  @override
  String get authPhoneLabel => 'Phone Number';

  @override
  String get authPhoneHint => '5XX XXX XX XX';

  @override
  String get authPhoneInvalidError =>
      'Please enter a valid Türkiye mobile phone number (5XX XXX XX XX).';

  @override
  String get authSendOtpButton => 'Send Verification Code';

  @override
  String get authOrDivider => 'or sign in with';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authOtpTitle => 'SMS Verification';

  @override
  String authOtpSubtitle(String phoneNumber) {
    return 'Enter the 6-digit verification code sent to $phoneNumber.';
  }

  @override
  String get authOtpCodeLabel => '6-Digit Verification Code';

  @override
  String get authOtpInvalidError =>
      'Please enter the complete 6-digit verification code.';

  @override
  String get authVerifyOtpButton => 'Verify & Sign In';

  @override
  String authResendCountdown(int seconds) {
    return 'Resend code (${seconds}s)';
  }

  @override
  String get authResendNow => 'Resend Code';

  @override
  String get wizardTitle => 'Profile Setup Wizard';

  @override
  String get wizardStepIdentity => '1. Identity & Visibility';

  @override
  String get wizardStepMedical => '2. Blood Type & Physical Info';

  @override
  String get wizardStepLocation => '3. Province & District';

  @override
  String get wizardFullNameLabel => 'Full Name';

  @override
  String get wizardFullNameRequiredError => 'Please enter your full name.';

  @override
  String get wizardNicknameLabel => 'Nickname (Optional)';

  @override
  String get wizardUseNicknameSwitch =>
      'Show my nickname instead of my real name in lists';

  @override
  String get wizardBirthDateLabel => 'Date of Birth';

  @override
  String get wizardBirthDateSelectButton => 'Select Birth Date';

  @override
  String wizardAgeValidationError(int minAge, int maxAge) {
    return 'Donor age must be between $minAge and $maxAge (Kızılay & Ministry of Health guidelines).';
  }

  @override
  String get wizardGenderLabel => 'Gender';

  @override
  String get wizardGenderMale => 'Male';

  @override
  String get wizardGenderFemale => 'Female';

  @override
  String get wizardGenderUnspecified => 'Prefer Not to Say';

  @override
  String get wizardWeightLabel => 'Weight (kg)';

  @override
  String wizardWeightValidationError(int minWeight) {
    return 'Minimum weight for voluntary blood donation is $minWeight kg.';
  }

  @override
  String get wizardBloodTypeLabel => 'Your Blood Type';

  @override
  String get wizardBloodTypeUnknownOption => 'I don\'t know my blood type';

  @override
  String get wizardBloodTypeHowToLearnLink => 'How can I learn my blood type?';

  @override
  String get wizardProvinceLabel => 'Select Province (81 Provinces)';

  @override
  String get wizardDistrictLabel => 'Select District';

  @override
  String get wizardLocationRequiredError =>
      'Please select both province and district.';

  @override
  String get wizardSearchHint => 'Search province or district...';

  @override
  String get wizardCompleteButton => 'Save Profile & Start';

  @override
  String get unknownBloodGuideTitle => 'How Can I Learn My Blood Type?';

  @override
  String get unknownBloodGuideIntro =>
      'If you don\'t know your blood type yet, you can still continue and update your profile once you learn it.';

  @override
  String get unknownBloodGuideStep1Title =>
      '1. Turkish Red Crescent (Kızılay) Donation Points';

  @override
  String get unknownBloodGuideStep1Body =>
      'Visit the nearest Kızılay blood donation center or mobile unit to learn your blood type free of charge during pre-donation screening.';

  @override
  String get unknownBloodGuideStep2Title =>
      '2. Family Health Centers (Family Physician)';

  @override
  String get unknownBloodGuideStep2Body =>
      'Apply to your registered Family Physician for a quick ABO and Rh blood group test.';

  @override
  String get unknownBloodGuideStep3Title =>
      '3. e-Nabız & Driver\'s License Records';

  @override
  String get unknownBloodGuideStep3Body =>
      'Check the \'My Lab Results\' section in your e-Nabız account or your driver\'s license medical report.';

  @override
  String get profileAvailableSwitchTitle => 'Available to Donate';

  @override
  String get profileAvailableSwitchSubtitle =>
      'When enabled, you receive notifications for nearby compatible blood requests.';

  @override
  String get profilePhotoChangeButton => 'Select Profile Photo (Optional)';

  @override
  String get profileEditButton => 'Edit Profile Information';

  @override
  String get profileNotificationPrefsButton => 'Notification Preferences';

  @override
  String get profileThemeTitle => 'Theme Mode';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileLanguageTitle => 'App Language';

  @override
  String get profileLanguageTr => 'Türkçe';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileExportDataButton => 'Download My Data (JSON)';

  @override
  String get profileExportDataSuccessTitle => 'Your Data Export (JSON)';

  @override
  String get profileDeleteAccountButton =>
      'Permanently Delete My Account & Data';

  @override
  String get profileDeleteConfirmTitle =>
      'Are You Sure You Want to Delete Your Account?';

  @override
  String get profileDeleteConfirmBody =>
      'This action cannot be undone. Your KVKK consent records, special-category health data, and profile will be permanently deleted via Cloud Function.';

  @override
  String get profileDeleteConfirmAction => 'Yes, Delete My Account';

  @override
  String get profileSignOutButton => 'Sign Out';

  @override
  String get notifPrefsTitle => 'Notification Preferences';

  @override
  String get notifUrgencyTitle => 'Minimum Urgency Level';

  @override
  String get notifUrgencyAll => 'All Requests';

  @override
  String get notifUrgencyUrgentOnly => 'Urgent & Critical Only';

  @override
  String get notifUrgencyCriticalOnly => 'Critical (Life-Threatening) Only';

  @override
  String get notifRadiusTitle => 'Notification Distance Radius';

  @override
  String notifRadiusKm(int km) {
    return '$km km';
  }

  @override
  String get notifQuietHoursTitle => 'Quiet Hours';

  @override
  String get notifQuietHoursEnable => 'Enable quiet hours (23:00 - 07:00)';

  @override
  String get notifQuietHoursAllowCritical =>
      'Receive critical alerts even during quiet hours';

  @override
  String get notifPrefsSavedMessage =>
      'Your notification preferences have been saved.';

  @override
  String get requestCreateTitle => 'Create Blood Request';

  @override
  String get requestEditTitle => 'Edit Blood Request';

  @override
  String get requestStepPatientProduct => '1. Patient & Blood Component';

  @override
  String get requestStepHospitalUrgency => '2. Hospital & Urgency';

  @override
  String get requestStepContactReport => '3. Contact & Document';

  @override
  String get requestPatientInitialsLabel =>
      'Patient Initials Only (e.g., A.Y.)';

  @override
  String get requestPatientInitialsHint => 'A.Y.';

  @override
  String get requestPatientInitialsError =>
      'For privacy, please enter initials only (e.g., A.Y.).';

  @override
  String get requestProductTypeLabel => 'Blood Product Type';

  @override
  String get productWholeBlood => 'Whole Blood';

  @override
  String get productErythrocyte => 'Red Blood Cells (Erythrocyte)';

  @override
  String get productPlatelet => 'Platelets (Apheresis)';

  @override
  String get productPlasma => 'Fresh Frozen Plasma';

  @override
  String get requestUnitsLabel => 'Units Needed';

  @override
  String requestUnitsValue(int count) {
    return '$count Units';
  }

  @override
  String get requestHospitalSelectLabel => 'Select Hospital';

  @override
  String get requestHospitalSearchHint =>
      'Search hospital, province, or district...';

  @override
  String get requestHospitalRequiredError => 'Please select a hospital.';

  @override
  String get requestDepartmentLabel =>
      'Department / Ward (e.g., ICU, Hematology)';

  @override
  String get requestDepartmentRequiredError =>
      'Please enter the department or ward.';

  @override
  String get requestUrgencyLabel => 'Urgency Level';

  @override
  String get urgencyCritical => 'Critical (Immediate)';

  @override
  String get urgencyToday => 'Today';

  @override
  String get urgencyThisWeek => 'This Week';

  @override
  String get requestContactNameLabel => 'Relative Name / Initials';

  @override
  String get requestContactPhoneLabel => 'Relative Phone (Hidden Publicly)';

  @override
  String get requestNotesLabel =>
      'Additional Notes (Monetary Requests Prohibited)';

  @override
  String get requestMedicalReportButton =>
      'Attach Medical Report / Document (Optional)';

  @override
  String get requestMedicalReportAttached =>
      'Medical report attached (Visible only to moderators and you)';

  @override
  String get requestProhibitedTextError =>
      'Prohibited monetary or payment terms detected. Blood donation must be strictly voluntary.';

  @override
  String requestLimitActiveError(int maxActive) {
    return 'You can have at most $maxActive active requests at a time.';
  }

  @override
  String requestLimitDailyError(int maxDaily) {
    return 'You have reached the daily request limit ($maxDaily).';
  }

  @override
  String get requestSubmitButton => 'Publish Request';

  @override
  String get requestSaveChangesButton => 'Save Changes';

  @override
  String get requestStatusOpen => 'Open';

  @override
  String get requestStatusFulfilled => 'Fulfilled';

  @override
  String get requestStatusCancelled => 'Cancelled';

  @override
  String get requestStatusExpired => 'Expired';

  @override
  String get requestFilterAll => 'All';

  @override
  String get requestFilterBloodGroup => 'Blood Group';

  @override
  String get requestFilterProduct => 'Product';

  @override
  String get requestFilterUrgency => 'Urgency';

  @override
  String get requestFilterProvince => 'Province';

  @override
  String get requestFilterClear => 'Clear Filters';

  @override
  String get requestLoadMore => 'Load More';

  @override
  String get requestDetailTitle => 'Request Details';

  @override
  String requestOfferCountBadge(int count) {
    return '$count volunteers offered help';
  }

  @override
  String get requestShareButton => 'Share';

  @override
  String get requestReportButton => 'Report';

  @override
  String get requestReportDialogTitle => 'Report Request';

  @override
  String get requestReportReasonHint =>
      'Report monetary demand or misleading info...';

  @override
  String get requestReportSubmittedMessage =>
      'Your report has been sent to moderators.';

  @override
  String get requestOwnerActionsTitle => 'Request Management';

  @override
  String get requestMarkFulfilledButton => 'Mark as Fulfilled';

  @override
  String get requestExtendExpiryButton => 'Extend Expiry (+24h)';

  @override
  String get requestCancelButton => 'Cancel Request';

  @override
  String get requestStopNewOffersSwitch =>
      'Enough donors arrived (Close new offers)';

  @override
  String get requestShareCardTitle => 'Emergency Blood Request Share Card';

  @override
  String get requestShareCopyTextButton => 'Copy Share Text & Link';

  @override
  String get requestShareCopiedMessage =>
      'Share text and deep link copied to clipboard.';

  @override
  String get matchingCanHelpButton => 'I Can Help';

  @override
  String matchingCompatibilityIncompatible(
      String donorBlood, String recipientBlood, String product) {
    return 'Your blood type ($donorBlood) is not medically compatible with this request ($recipientBlood $product).';
  }

  @override
  String get matchingCompatibilityCompatible =>
      'Your blood type is compatible with this request.';

  @override
  String get matchingSelectTimeSlotTitle =>
      'Select Estimated Arrival Slot (Coordination)';

  @override
  String get matchingTimeSlotNow => 'Immediate (Within 1 Hour)';

  @override
  String get matchingTimeSlotMorning => 'Morning (09:00 - 12:00)';

  @override
  String get matchingTimeSlotAfternoon => 'Afternoon (12:00 - 17:00)';

  @override
  String get matchingTimeSlotEvening => 'Evening (17:00 - 21:00)';

  @override
  String get matchingOfferPending =>
      'Awaiting Approval (Phones unlock once requester approves)';

  @override
  String get matchingOfferApproved => 'Approved — Mutual Contact Unlocked';

  @override
  String get matchingStepOnTheWay => 'On the Way';

  @override
  String get matchingStepArrived => 'Arrived at Hospital';

  @override
  String get matchingStepDonated => 'Donated';

  @override
  String get matchingStepConfirmed => 'Donation Confirmed (Saved to History)';

  @override
  String get matchingQuickMsg1 => 'I am on my way to the hospital.';

  @override
  String get matchingQuickMsg2 =>
      'I have arrived at the blood center and am registering.';

  @override
  String get matchingQuickMsg3 =>
      'I completed the donation, wishing a speedy recovery.';

  @override
  String get matchingCallButton => 'Call';

  @override
  String get matchingWhatsAppButton => 'WhatsApp';

  @override
  String get matchingOwnerApproveDonorButton =>
      'Approve Donor (Unlock Contact)';

  @override
  String get matchingOwnerConfirmDonationButton =>
      'Confirm Donation (Completed)';

  @override
  String get matchingOffersClosedNotice =>
      'The requester indicated enough donors have arrived; new offers are closed.';

  @override
  String get notificationsMarkAllRead => 'Mark All as Read';

  @override
  String get notificationsFilterUnreadOnly => 'Unread Only';
}
