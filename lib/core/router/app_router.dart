import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/router/main_scaffold.dart';
import 'package:turkiye_kan_agi/core/router/not_found_screen.dart';
import 'package:turkiye_kan_agi/core/services/app_version_service.dart';
import 'package:turkiye_kan_agi/core/widgets/design_gallery_screen.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/login_screen.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/otp_verification_screen.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/donation_screen.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/donation_tips_screen.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/eligibility_survey_screen.dart';
import 'package:turkiye_kan_agi/features/force_update/presentation/force_update_screen.dart';
import 'package:turkiye_kan_agi/features/map/presentation/map_screen.dart';
import 'package:turkiye_kan_agi/features/notifications/presentation/notifications_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/kvkk_consent_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/legal_document_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/notification_preferences_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/profile_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/profile_setup_wizard_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/unknown_blood_type_info_screen.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/create_request_wizard_screen.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/request_detail_screen.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/requests_screen.dart';
import 'package:turkiye_kan_agi/features/splash/presentation/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

const Set<String> _publicAuthRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.kvkkConsent,
  AppRoutes.privacyPolicy,
  AppRoutes.termsOfUse,
  AppRoutes.login,
  AppRoutes.otpVerification,
  AppRoutes.unknownBloodTypeGuide,
  AppRoutes.designGallery,
  AppRoutes.admin,
};

/// Auth guard, Force Update guard, Deep Link (`/requests/:requestId`) ve 404 destekli GoRouter sağlayıcısı.
final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final forceUpdateStatus = ref.watch(forceUpdateStatusProvider).valueOrNull;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;

      // 1. Force Update kontrolü: min_version > currentVersion ise zorunlu güncelleme ekranında tut.
      if (forceUpdateStatus != null) {
        if (forceUpdateStatus.isRequired) {
          return location == AppRoutes.forceUpdate
              ? null
              : AppRoutes.forceUpdate;
        }
        if (location == AppRoutes.splash) {
          return isAuthenticated ? AppRoutes.requests : AppRoutes.onboarding;
        }
      }

      // 2. Auth Guard: Oturum kapalıysa korumalı sekmelerden Onboarding'e yönlendir.
      if (!isAuthenticated && !_publicAuthRoutes.contains(location)) {
        return AppRoutes.onboarding;
      }

      return null;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.forceUpdate,
        builder: (context, state) => const ForceUpdateScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.kvkkConsent,
        builder: (context, state) => const KvkkConsentScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const LegalDocumentScreen(
          documentType: LegalDocumentType.privacyPolicy,
        ),
      ),
      GoRoute(
        path: AppRoutes.termsOfUse,
        builder: (context, state) => const LegalDocumentScreen(
          documentType: LegalDocumentType.termsOfUse,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) {
          final args = state.extra as OtpRouteArgs? ??
              const OtpRouteArgs(
                phoneNumber: '+905000000000',
                verificationId: 'dev-verification-+905000000000',
              );
          return OtpVerificationScreen(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupWizardScreen(),
      ),
      GoRoute(
        path: AppRoutes.unknownBloodTypeGuide,
        builder: (context, state) => const UnknownBloodTypeInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationPreferences,
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.designGallery,
        builder: (context, state) => const DesignGalleryScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.requests,
                builder: (context, state) => const RequestsScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => CreateRequestWizardScreen(
                      editingRequest: state.extra as BloodRequest?,
                    ),
                  ),
                  GoRoute(
                    path: ':requestId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => RequestDetailScreen(
                      requestId: state.pathParameters['requestId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.donation,
                builder: (context, state) => const DonationScreen(),
                routes: [
                  GoRoute(
                    path: 'survey',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) =>
                        const EligibilitySurveyScreen(),
                  ),
                  GoRoute(
                    path: 'tips',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const DonationTipsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
