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

  @override
  String get donationStatusEligibleNowTitle =>
      'You Appear Eligible to Donate Now';

  @override
  String get donationStatusWaitingTitle => 'Waiting Period Until Next Donation';

  @override
  String donationCountdownDaysHours(int days, int hours) {
    return 'Remaining: $days days ($hours hours)';
  }

  @override
  String donationNextEligibleDateLabel(String dateText) {
    return 'Next eligible date: $dateText';
  }

  @override
  String get donationAutoPausedNotice =>
      'Your \'Available to donate\' status was automatically paused until your waiting period ends.';

  @override
  String get donationAutoResumedNotice =>
      'Your \'Available to donate\' status resumes automatically once the waiting period ends.';

  @override
  String get donationReminderToggleTitle => '\'You can donate again\' reminder';

  @override
  String get donationReminderToggleSubtitle =>
      'Sends a local notification when your waiting period ends';

  @override
  String get donationReminderScheduledSnack =>
      'Reminder notification scheduled.';

  @override
  String get donationAddToCalendarButton => 'Add to Calendar';

  @override
  String get donationCalendarEventTitle =>
      'Blood Donation Eligibility Day (Türkiye Kan Ağı)';

  @override
  String get donationCalendarEventDesc =>
      'Your waiting period has ended. You may donate at Kızılay or a blood center.';

  @override
  String get donationCalendarAddedSnack => 'Calendar event created.';

  @override
  String get donationReminderNotifTitle => 'You Can Donate Again';

  @override
  String get donationReminderNotifBody =>
      'The waiting period since your last donation is complete. You can donate blood if you feel well.';

  @override
  String get donationAddManualButton => 'Add Manual Donation';

  @override
  String get donationAddSheetTitle => 'Add Past Donation Record';

  @override
  String get donationPlaceLabel => 'Donation Place (Blood Center / Hospital)';

  @override
  String get donationPlaceHint => 'e.g. Kızılay Çankaya Blood Center';

  @override
  String get donationDateLabel => 'Donation Date';

  @override
  String get donationSelectDateButton => 'Select Date';

  @override
  String get donationProductTypeLabel => 'Donated Product Type';

  @override
  String get donationSourceManualBadge => 'Manual Entry';

  @override
  String get donationSourceRequestBadge => 'Request Flow (Confirmed)';

  @override
  String get donationDeleteManualTooltip => 'Delete manual donation record';

  @override
  String get donationValidationPlaceRequired =>
      'Please enter the donation place.';

  @override
  String get donationValidationFutureDate =>
      'Future donation dates cannot be added.';

  @override
  String get donationHistorySectionTitle => 'My Donation History';

  @override
  String get donationQuickSurveyButton => 'Eligibility Pre-Check Survey';

  @override
  String get donationQuickTipsButton => 'Pre & Post Donation Tips';

  @override
  String get donationSurveyTitle => 'Donation Eligibility Pre-Check Survey';

  @override
  String get donationSurveyDisclaimer =>
      'IMPORTANT NOTICE: This survey does not make a final medical decision and is for preliminary guidance only. The decision belongs to healthcare staff at the blood center. Must be verified with current Kızılay and Ministry of Health rules.';

  @override
  String get donationSurveyAnswerYes => 'Yes';

  @override
  String get donationSurveyAnswerNo => 'No';

  @override
  String get donationSurveyAnswerUnsure => 'Not Sure';

  @override
  String get donationSurveyEvaluateButton => 'View Pre-Check Result';

  @override
  String get donationSurveyIncompleteError => 'Please answer all questions.';

  @override
  String get donationSurveyOutcomeEligibleTitle => 'Looks Eligible';

  @override
  String get donationSurveyOutcomeEligibleBody =>
      'Based on your answers, there is no obvious barrier. Final decision belongs to the physician and healthcare staff at the blood center.';

  @override
  String get donationSurveyOutcomeUnsureTitle => 'Not Sure (Consult Staff)';

  @override
  String get donationSurveyOutcomeUnsureBody =>
      'Some answers require further evaluation. Please consult the physician at the blood center.';

  @override
  String get donationSurveyOutcomeIneligibleTitle =>
      'Looks Ineligible (Possible Temporary Deferral)';

  @override
  String get donationSurveyOutcomeIneligibleBody =>
      'At least one answer may require temporary or permanent deferral. The decision belongs to healthcare staff at the blood center.';

  @override
  String get donationSurveySavedSnack =>
      'Your pre-check result was saved under your private health data.';

  @override
  String get donationTipsTitle => 'Pre & Post Donation Tips';

  @override
  String get donationTipsMedicalNote =>
      'This information is for general guidance; must be verified with current Kızılay and Ministry of Health rules.';

  @override
  String get donationTipsBeforeTitle => 'Before Donation';

  @override
  String get donationTipsBefore1 =>
      'Drink plenty of water and eat a light, low-fat meal before donating; do not donate on an empty stomach.';

  @override
  String get donationTipsBefore2 =>
      'Be well rested and avoid alcohol for 24 hours prior to donating.';

  @override
  String get donationTipsBefore3 =>
      'Bring an official ID and inform the healthcare staff about any medications you take.';

  @override
  String get donationTipsAfterTitle => 'After Donation';

  @override
  String get donationTipsAfter1 =>
      'Rest for at least 10-15 minutes after donating and enjoy the refreshments provided.';

  @override
  String get donationTipsAfter2 =>
      'Drink extra fluids for the next 24 hours and avoid lifting heavy objects with the donation arm.';

  @override
  String get donationTipsAfter3 =>
      'Avoid smoking for the first few hours; if you feel dizzy, lie down and elevate your legs.';

  @override
  String get donationKvkkConsentRequiredTitle =>
      'Health Data Explicit Consent Required';

  @override
  String get donationKvkkConsentRequiredBody =>
      'Your donation history and health survey answers are sensitive personal data under KVKK. Explicit consent is required to continue.';

  @override
  String get donationKvkkGrantConsentButton =>
      'Grant Explicit Consent & Continue';

  @override
  String get splashSubtitle => 'One drop, one hope.';

  @override
  String get splashSemantics => 'Türkiye Blood Network is loading';

  @override
  String get urgencyCriticalShort => 'URGENT';

  @override
  String get urgencyTodayShort => 'Today';

  @override
  String get urgencyThisWeekShort => 'This week';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusFulfilled => 'Fulfilled';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusExpired => 'Expired';

  @override
  String get verifiedBadgeLabel => 'Verified';

  @override
  String get compatibleBadgeLabel => 'Compatible';

  @override
  String get requestsNoOpenNearYouTitle =>
      'No open requests near you, that is good news.';

  @override
  String get requestsNoOpenNearYouSubtitle =>
      'We will notify you immediately when a new urgent blood need arises.';

  @override
  String get actionWantBlood => 'I Need Blood';

  @override
  String get actionCanHelp => 'I Can Help';

  @override
  String get designGalleryTitle => 'Design Gallery (Debug)';

  @override
  String get onboardingV2Slide1Title => 'One drop, one hope';

  @override
  String get onboardingV2Slide1Body =>
      'We quickly connect people in need of blood with nearby voluntary donors.';

  @override
  String get onboardingV2Slide2Title => 'See needs near you';

  @override
  String get onboardingV2Slide2Body =>
      'Track urgent blood requests in your province and district on a single screen.';

  @override
  String get onboardingV2Slide3Title => 'Help with one tap';

  @override
  String get onboardingV2Slide3Body =>
      'If your blood type matches, offer help with a single tap and navigate to the hospital.';

  @override
  String get onboardingV2Slide4Title => 'Your data is safe';

  @override
  String get onboardingV2Slide4Body =>
      'Your phone number and location are protected; shared only with your approval.';

  @override
  String get onboardingStartButton => 'Start';

  @override
  String get kvkkSummaryCardTitle => 'Your Data Is Under Your Control';

  @override
  String get kvkkSummaryCardBody =>
      'Your health data is stored encrypted, never shared with third parties, and can be deleted anytime.';

  @override
  String get kvkkIlluminationLink => 'Disclosure Text';

  @override
  String get kvkkExplicitConsentLink => 'Explicit Consent Text';

  @override
  String get kvkkRequiredBadge => 'Required';

  @override
  String get kvkkOptionalBadge => 'Optional';

  @override
  String get kvkkContinueButton => 'Continue';

  @override
  String get authSendCodeShort => 'Send Code';

  @override
  String get authOrSimple => 'or';

  @override
  String get authGoogleShort => 'Continue with Google';

  @override
  String get authAppleShort => 'Continue with Apple';

  @override
  String authResendTimer(int seconds) {
    return 'Resend code (${seconds}s)';
  }

  @override
  String get authOtpWrongCodeError =>
      'The verification code you entered is incorrect. Please try again.';

  @override
  String get authOtpVerifiedSuccess => 'Verified!';

  @override
  String get wizardStep1Title => 'Name & Visibility';

  @override
  String get wizardStep2Title => 'Your Blood Type';

  @override
  String get wizardStep3Title => 'Personal Info';

  @override
  String get wizardStep4Title => 'Province & District';

  @override
  String get wizardBloodUnknownCard => 'I Don\'t Know';

  @override
  String get locationPermissionTitle => 'Why Do We Ask?';

  @override
  String get locationPermissionSubtitle =>
      'Your exact location is never shown to others. It is only used to sort urgent blood needs at the nearest hospitals.';

  @override
  String get locationPermissionAllowButton => 'Enable Location';

  @override
  String get locationPermissionSkipButton =>
      'Not Now, continue with province/district';

  @override
  String get readyCelebrationTitle => 'You Are Ready!';

  @override
  String get readyCelebrationSubtitle =>
      'Welcome to the solidarity network. Together we can save lives.';

  @override
  String get readyCelebrationAction => 'Go to Home';

  @override
  String get donorStatusEligibleCard => 'Eligible to donate';

  @override
  String donorStatusWaitingCard(int days) {
    return '$days days until next donation';
  }

  @override
  String get filterMyBloodGroup => 'My blood type';

  @override
  String get filterNearMe => 'Near me';

  @override
  String get filterDistanceTitle => 'Distance';

  @override
  String get filterDistanceAllCity => 'Whole City';

  @override
  String get filterApplyButton => 'Apply';

  @override
  String get filterClearButton => 'Clear';

  @override
  String requestRemainingHours(int hours) {
    return '${hours}h left';
  }

  @override
  String requestRemainingDays(int days) {
    return '${days}d left';
  }

  @override
  String get requestDirectionsButton => 'Directions';

  @override
  String get requestTrustSectionTitle => 'Trust & Verification';

  @override
  String get requestTrustSectionBody =>
      'This request was created by a phone-verified user. Asking for money or fees is strictly prohibited.';

  @override
  String get requestClosedBannerFulfilled =>
      'This blood request has been fulfilled. Thank you to all volunteers.';

  @override
  String get requestClosedBannerCancelled =>
      'This blood request was cancelled by the requester.';

  @override
  String get requestClosedBannerExpired => 'This blood request has expired.';

  @override
  String get shareWhatsAppButton => 'Share on WhatsApp';

  @override
  String get shareImageButton => 'Share as Image';

  @override
  String get draftSavePromptTitle => 'Save draft?';

  @override
  String get draftSavePromptBody =>
      'Your entered details can be saved as a draft without losing progress.';

  @override
  String get draftKeepButton => 'Save Draft';

  @override
  String get draftDiscardButton => 'Discard & Exit';

  @override
  String get requestPublishedSuccessTitle => 'Your Request Is Live';

  @override
  String get requestPublishedSuccessSubtitle =>
      'Nearby compatible donors are being notified. Share to reach more people faster.';

  @override
  String get canHelpConfirmTitle => 'Send Help Offer';

  @override
  String get canHelpConfirmBody =>
      'The requester will be notified, and contact info will unlock once they approve.';

  @override
  String get canHelpEligibilityReminder =>
      'Make sure you haven\'t consumed alcohol in the last 24 hours, feel well, and have your ID with you.';

  @override
  String get donorTrackingTitle => 'Donation Tracking';

  @override
  String get donorStepOffered => 'Offer sent';

  @override
  String get donorStepApproved => 'Approved';

  @override
  String get donorStepOnWay => 'On my way';

  @override
  String get donorStepArrived => 'Arrived';

  @override
  String get donorStepDonated => 'Donated';

  @override
  String get quickMsg15Min => 'I\'ll be there in 15 mins';

  @override
  String get quickMsgWhichWard => 'Which ward?';

  @override
  String get quickMsgArrivedWhere => 'I arrived, where are you?';

  @override
  String get celebrationTitle => 'You touched a life';

  @override
  String get celebrationSubtitle =>
      'Heartfelt thanks for your voluntary support.';

  @override
  String get celebrationBadgeEarned => 'Badge Earned: First Drop of Hope';

  @override
  String get thankYouSheetTitle => 'Send Thanks to Volunteer';

  @override
  String get thankYouChip1 => 'Thank you so much for being there.';

  @override
  String get thankYouChip2 => 'Your support gave us hope.';

  @override
  String get thankYouChip3 => 'Our warmest wishes are with you.';

  @override
  String get thankYouCustomHint => 'Your short thank-you note...';

  @override
  String get thankYouSendButton => 'Send Thanks';

  @override
  String get notificationsGroupToday => 'Today';

  @override
  String get notificationsGroupEarlier => 'Earlier';

  @override
  String get notificationsMarkAllReadShort => 'Mark all as read';

  @override
  String get notificationPermissionSheetTitle => 'Don\'t Miss Urgent Calls';

  @override
  String get notificationPermissionSheetBody =>
      'We only send notifications for urgent requests near you that match your blood type.';

  @override
  String get notificationPermissionAllow => 'Allow Notifications';

  @override
  String get notificationPermissionDeniedBanner =>
      'Notifications are off. Enable them in settings to see urgent calls.';

  @override
  String get notificationOpenSettings => 'Open Settings';

  @override
  String get urgentHeadsUpTitle => 'URGENT Compatible Request Nearby!';

  @override
  String get urgentHeadsUpAction => 'View';

  @override
  String get mapFilterRequests => 'Requests';

  @override
  String get mapFilterCenters => 'Donation centers';

  @override
  String get mapFilterMyBlood => 'My blood type';

  @override
  String get mapMyLocationTooltip => 'Go to my location';

  @override
  String get mapToggleList => 'List';

  @override
  String get mapToggleMap => 'Map';

  @override
  String get mapNearbyListTitle => 'Nearby Points';

  @override
  String get centerOpenNow => 'Open Now';

  @override
  String get centerClosedNow => 'Closed';

  @override
  String get centerMobileUnitBadge => 'Here today';

  @override
  String get centerMobileUnitTitle => 'Mobile Blood Donation Unit';

  @override
  String get mapNoLocationTitle => 'Location permission is off';

  @override
  String get mapNoLocationSubtitle =>
      'Enable location to see nearby hospitals and donation centers on the map, or browse the list.';

  @override
  String get mapOpenLocationButton => 'Enable location';

  @override
  String get mapViewListButton => 'View list';

  @override
  String get directionsSheetTitle => 'Choose Navigation App';

  @override
  String get directionsGoogleMaps => 'Google Maps';

  @override
  String get directionsYandexNavi => 'Yandex Navigation';

  @override
  String get directionsAppleMaps => 'Apple Maps';

  @override
  String donationDaysRemaining(int days) {
    return '$days days left';
  }

  @override
  String get donationEligibleBadge => 'Eligible to donate';

  @override
  String donationLastDate(String date) {
    return 'Last donation: $date';
  }

  @override
  String get donationLivesSavedTitle => 'You saved lives';

  @override
  String get donationLivesSavedSubtitle =>
      'Each whole blood donation can bring hope to up to 3 people (Kızılay info note).';

  @override
  String get donationAmIEligibleTitle => 'Am I eligible?';

  @override
  String get donationAmIEligibleSubtitle =>
      'Take a quick 1-minute pre-check survey';

  @override
  String get donationAddButtonShort => 'Add Donation';

  @override
  String get donationEmptyReadyTitle => 'Ready to make your first donation?';

  @override
  String get badgesSectionTitle => 'Badge Showcase';

  @override
  String get badgeFirstDrop => 'First Drop';

  @override
  String get badgeFirstDropHint =>
      'Complete your first voluntary blood donation';

  @override
  String get badgeRegularHero => 'Regular Volunteer';

  @override
  String get badgeRegularHeroHint => 'Donate blood regularly 3 times';

  @override
  String get badgeEmergencyResponder => 'Emergency Hero';

  @override
  String get badgeEmergencyResponderHint =>
      'Respond to an urgent request on the same day';

  @override
  String get badgeApheresisStar => 'Apheresis Star';

  @override
  String get badgeApheresisStarHint => 'Make a platelet/apheresis donation';

  @override
  String get badgeCommunityBuilder => 'Solidarity Ambassador';

  @override
  String get badgeCommunityBuilderHint => 'Invite 3 friends to the network';

  @override
  String get surveyStaffDecisionNotice =>
      'The decision belongs to healthcare staff at the blood center.';

  @override
  String get profileVerifiedPhone => 'Phone Verified';

  @override
  String get profileSectionMyInfo => 'My Information';

  @override
  String get profileSectionNotifPrefs => 'Notification preferences';

  @override
  String get profileSectionLocationTravel => 'Location & travel mode';

  @override
  String get profileSectionCommunities => 'My Communities';

  @override
  String get profileSectionInvite => 'Invite a friend';

  @override
  String get profileSectionAppearance => 'Appearance';

  @override
  String get profileSectionPrivacyData => 'Privacy & data';

  @override
  String get profileSectionHelpFaq => 'Help & FAQ';

  @override
  String get profileSectionAbout => 'About';

  @override
  String get travelModeTitle => 'Travel Mode';

  @override
  String get travelModeSubtitle =>
      'Temporarily see requests for another city while traveling';

  @override
  String travelModeActiveBanner(String city, String dateRange) {
    return 'Travel Mode Active: $city ($dateRange)';
  }

  @override
  String get deleteAccountTypeConfirmHint => 'Type SİL to confirm';

  @override
  String get deleteAccountTypeConfirmWord => 'SİL';

  @override
  String get communitiesTitle => 'Communities & Rare Blood Network';

  @override
  String get communityJoinButton => 'Join';

  @override
  String get communityLeaveButton => 'Leave';

  @override
  String get rareBloodNetworkTitle => 'Rare Blood Network (Rh Negative)';

  @override
  String get rareBloodNetworkSubtitle =>
      'Join the dedicated solidarity network for rare Rh(-) blood groups.';

  @override
  String get institutionTitle => 'Institutional Account & Campaigns';

  @override
  String get institutionApplyTab => 'Application';

  @override
  String get institutionCampaignsTab => 'Campaigns';

  @override
  String get institutionPendingBanner =>
      'Your institutional application is under review (Pending Approval)';

  @override
  String get institutionVerifiedBadge => 'Verified Institution';

  @override
  String get campaignJoinButton => 'I\'m Joining';

  @override
  String get bloodMatrixTitle => 'Blood Type Compatibility Matrix';

  @override
  String get bloodMatrixCanGiveTo => 'Can Donate To';

  @override
  String get bloodMatrixCanReceiveFrom => 'Can Receive From';

  @override
  String get faqTitle => 'Frequently Asked Questions & Guide';

  @override
  String get mythsAndFactsTab => 'Myths & Facts';

  @override
  String get emergencyGuideTitle => 'I need blood, what should I do?';

  @override
  String get leaderboardTitle => 'Volunteer Honor Board';

  @override
  String get leaderboardOptInWarning =>
      'Volunteering is not a competition; this board is for motivation only and is hidden by default.';

  @override
  String get leaderboardEnableButton => 'Show Board';

  @override
  String get inviteTitle => 'Invite a Friend';

  @override
  String get inviteSubtitle => 'Grow the solidarity network, touch more lives.';

  @override
  String get inviteCopyLink => 'Copy Invite Link';

  @override
  String inviteCountLabel(int count) {
    return '$count friends joined with your invite';
  }

  @override
  String get aboutTitle => 'About & Feedback';

  @override
  String get feedbackTitle => 'Send Feedback';

  @override
  String get maintenanceTitle => 'Under Maintenance';

  @override
  String get maintenanceMessage =>
      'Our system is currently undergoing brief maintenance. Please try again shortly.';

  @override
  String get offlineScreenTitle => 'No Internet Connection';

  @override
  String get adminTitle => 'Türkiye Blood Network — Admin Panel';

  @override
  String get adminLoginTitle => 'Admin Sign In';

  @override
  String get adminNavDashboard => 'Dashboard';

  @override
  String get adminNavReports => 'Reports';

  @override
  String get adminNavRequests => 'Requests';

  @override
  String get adminNavUsers => 'Users';

  @override
  String get adminNavInstitutions => 'Institutions';

  @override
  String get adminNavCampaigns => 'Campaigns';

  @override
  String get adminNavAuditLog => 'Audit Log';

  @override
  String get adminNavSettings => 'Settings';

  @override
  String get adminStatOpenRequests => 'Open Requests';

  @override
  String get adminStatFulfillmentRate => 'Fulfillment Rate';

  @override
  String get adminStatPendingReports => 'Pending Reports';

  @override
  String get adminStatNewUsers => 'New Users';

  @override
  String get adminApproveAction => 'Approve';

  @override
  String get adminRejectAction => 'Reject';

  @override
  String get adminRestrictAction => 'Restrict';
}
