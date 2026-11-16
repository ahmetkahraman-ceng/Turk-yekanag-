# Türkiye Kan Ağı — UI Master Prompt Final Raporu (`RAPOR.md`)

## 1. Tasarım Sistemi ve Mimari Özeti

### Tasarım Değerleri (Token Sınıfları — `lib/core/theme/`)
- **Renkler ([`AppColors`](lib/core/theme/app_colors.dart))**:
  - Aydınlık: `primary: #D32F2F`, `primaryDark: #9A0007`, `primaryLight: #FF6659`, `background: #FFF8F6`, `surface: #FFFFFF`, `textPrimary: #2B1B1B`, `textSecondary: #6B5B5B`, `success: #2E7D32`, `warning: #EF6C00`, `info: #1565C0`, `error: #B00020`.
  - Karanlık: `background: #1A0E0E`, `surface: #261616`, `primary: #EF5350`, `textPrimary: #F5E9E7`.
- **Tipografi ([`AppTypography`](lib/core/theme/app_typography.dart))**:
  - Yerel gömülü `assets/fonts/Nunito-Variable.ttf` (offline çalışır). Başlıklar `700-800`, gövde `400-600`, minimum gövde `16sp`.
- **Boşluk & Köşe Yuvarlaklığı ([`AppSpacing`](lib/core/theme/app_spacing.dart), [`AppRadius`](lib/core/theme/app_radius.dart))**:
  - Boşluk: `4 / 8 / 12 / 16 / 24 / 32`.
  - Köşe: Kart `20`, Buton `16`, Çip `999`, Bottom Sheet üst köşe `28`.
  - Dokunma alanı minimum `48dp`, birincil buton yüksekliği `52dp`.
- **Hareket ([`AppMotion`](lib/core/theme/app_motion.dart))**:
  - Süreler `150ms / 250ms / 400ms`, eğriler `Curves.easeOutCubic` ve `Curves.easeInOutCubic`. `MediaQuery.disableAnimations` açıkken animasyonlar devre dışı bırakılır.

---

## 2. Aşamalar Bazında Tamamlanan İşler (Aşama 1 – Aşama 9)

### Aşama 1: Altyapı, Bileşen Kitaplığı, Logo, Splash, Ana İskelet, Mock Altyapısı
- **Marka & Logo**: [`BloodLogo`](lib/core/branding/blood_logo.dart) (`CustomPainter`, kübik bezier damla, dikey gradyan, kalp biçimli 3 düğümlü ağ çizgileri, `size`, `progress`, `monochrome`), `assets/branding/logo.svg` ve `assets/branding/logo_1024.png`.
- **Ortak Bileşenler (`lib/core/widgets/`)**: [`AppButton`](lib/core/widgets/app_button.dart), [`AppTextField`](lib/core/widgets/app_text_field.dart), [`AppSearchField`](lib/core/widgets/app_text_field.dart), [`AppCard`](lib/core/widgets/app_card.dart), [`AppChip`](lib/core/widgets/app_chip.dart), [`SectionHeader`](lib/core/widgets/section_header.dart), [`BloodTypeBadge`](lib/core/widgets/blood_type_badge.dart), [`UrgencyTag`](lib/core/widgets/status_and_urgency_tags.dart), [`StatusTag`](lib/core/widgets/status_and_urgency_tags.dart), [`VerifiedBadge`](lib/core/widgets/status_and_urgency_tags.dart), [`AppBottomSheet`](lib/core/widgets/app_overlays.dart), [`ConfirmSheet`](lib/core/widgets/app_overlays.dart), [`StepIndicator`](lib/core/widgets/step_and_progress.dart), [`ProgressDots`](lib/core/widgets/step_and_progress.dart), [`SkeletonBox`](lib/core/widgets/skeleton_widgets.dart), [`EmptyState`](lib/core/widgets/empty_state.dart), [`ErrorState`](lib/core/widgets/error_state.dart), [`OfflineBanner`](lib/core/widgets/offline_banner.dart), [`AsyncValueView`](lib/core/widgets/async_value_view.dart), [`SwitchTile`](lib/core/widgets/tiles_and_selection_sheet.dart), [`RadioTile`](lib/core/widgets/tiles_and_selection_sheet.dart), [`SelectionSheet`](lib/core/widgets/tiles_and_selection_sheet.dart), [`CountdownRing`](lib/core/widgets/countdown_ring.dart), [`ConfettiOverlay`](lib/core/widgets/confetti_overlay.dart) ve [`DesignGalleryScreen`](lib/core/widgets/design_gallery_screen.dart) (`/debug/gallery`).
- **Animasyonlu Splash**: [`SplashScreen`](lib/features/splash/presentation/splash_screen.dart) (~2.6 sn tek `AnimationController`, damla düşüşü, dalga halkası, ağ çizimi, çift kalp atışı, metin kayması, `disableAnimations` desteği).
- **Ana İskelet & Mock Veri**: [`MainScaffold`](lib/core/router/main_scaffold.dart) (5 sekmeli Material 3 `NavigationBar`, okunmamış bildirim rozeti, sekme koruma) ve [`MockData`](lib/core/mock/mock_data.dart) / [`FakeRequestRepository`](lib/core/mock/fake_repositories.dart) (32 gerçekçi talep, 10 bağış merkezi, 15 bildirim).

### Aşama 2: Onboarding, Giriş, KVKK, Profil Sihirbazı
- [`OnboardingScreen`](lib/features/onboarding/presentation/onboarding_screen.dart) ve [`OnboardingIllustration`](lib/features/onboarding/presentation/widgets/onboarding_illustrations.dart) (4 slayt `CustomPainter` illüstrasyon, parallax, `ProgressDots`).
- [`KvkkConsentScreen`](lib/features/onboarding/presentation/kvkk_consent_screen.dart) (zorunlu sağlık & konum rızası onaylanmadan "Devam" pasif).
- [`LoginScreen`](lib/features/auth/presentation/login_screen.dart) (`+90` sabit, `5XX XXX XX XX` maskeli telefon, Google/Apple giriş butonları) ve [`OtpVerificationScreen`](lib/features/auth/presentation/otp_verification_screen.dart) (6 hane, 45 sn geri sayım, hatalı kodda sallanma animasyonu).
- [`ProfileSetupWizardScreen`](lib/features/profile/presentation/profile_setup_wizard_screen.dart) (4 adım, 8 kan grubu kartı + "Bilmiyorum", 81 il/ilçe aramalı seçici, konum izni açıklama ve konfeti kutlama ekranı).

### Aşama 3: Talepler, Kart, Detay, Talep Açma Sihirbazı
- [`RequestsScreen`](lib/features/requests/presentation/requests_screen.dart) (`CustomScrollView` + `SliverAppBar`, `CountdownRing` durum kartı, yatay filtre çipleri, kaydırırken küçülen "Kan İstiyorum" FAB).
- [`RequestCard`](lib/features/requests/presentation/widgets/request_card.dart), [`RequestFilterSheet`](lib/features/requests/presentation/widgets/request_filter_sheet.dart), [`RequestDetailScreen`](lib/features/requests/presentation/request_detail_screen.dart), [`ShareRequestCardDialog`](lib/features/requests/presentation/share_request_card_dialog.dart) (`RepaintBoundary` + PNG paylaşım kartı) ve [`CreateRequestWizardScreen`](lib/features/requests/presentation/create_request_wizard_screen.dart) (4 adım, para/ücret filtresi, taslak koruma).

### Aşama 4: Bağışçı Akışı, Bildirimler, İletişim, Kutlama
- [`DonorTrackingScreen`](lib/features/matching/presentation/screens/donor_tracking_screen.dart) (5 adımlı `StepIndicator`, hızlı mesaj çipleri, Ara/WhatsApp/Yol tarifi).
- [`DonorOfferPanel`](lib/features/matching/presentation/donor_offer_panel.dart), [`ThankYouSheet`](lib/features/matching/presentation/widgets/thank_you_sheet.dart), [`DonationCelebrationScreen`](lib/features/matching/presentation/screens/donation_celebration_screen.dart) (`ConfettiOverlay` + kalp atışı), [`NotificationsScreen`](lib/features/notifications/presentation/notifications_screen.dart) (Bugün/Daha önce gruplu, `Dismissible`, bildirim izni akışı) ve [`UrgentInAppBanner`](lib/features/notifications/presentation/widgets/urgent_in_app_banner.dart).

### Aşama 5: Harita ve Bağış Merkezleri
- [`MapScreen`](lib/features/map/presentation/map_screen.dart) ve [`MapCanvasAndSheets`](lib/features/map/presentation/widgets/map_canvas_and_sheets.dart) (Talepler/Bağış merkezleri/Kan grubum çipleri, kümeleme, gezici kan bağış aracı "Bugün burada" etiketi, liste/harita geçişi, konum izni kapalı fallback durumu, Google/Yandex/Apple yol tarifi seçici).

### Aşama 6: Bağış Sekmesi, Uygunluk Anketi, Rozetler
- [`DonationScreen`](lib/features/donation/presentation/donation_screen.dart), [`DonationCountdownCard`](lib/features/donation/presentation/donation_countdown_card.dart), [`BadgeShowcase`](lib/features/donation/presentation/widgets/badge_showcase.dart), [`EligibilitySurveyScreen`](lib/features/donation/presentation/eligibility_survey_screen.dart) ("Karar kan merkezindeki sağlık personelindedir" sabit uyarılı) ve [`DonationTipsScreen`](lib/features/donation/presentation/donation_tips_screen.dart).

### Aşama 7: Profil, Ayarlar, Topluluk, Kurumsal, İçerik
- [`ProfileScreen`](lib/features/profile/presentation/profile_screen.dart) (Avatar, doğrulama rozeti, uygunluk anahtarı, seyahat modu aktif bandı, tema/dil seçimi, JSON veri indirme, "SİL" yazarak iki adımlı hesap silme).
- [`CommunitiesScreen`](lib/features/profile/presentation/screens/communities_screen.dart), [`InstitutionsScreen`](lib/features/profile/presentation/screens/institutions_screen.dart), [`BloodCompatibilityMatrixScreen`](lib/features/profile/presentation/screens/blood_compatibility_matrix_screen.dart), [`FaqScreen`](lib/features/profile/presentation/screens/faq_and_guides_screen.dart), [`EmergencyGuideScreen`](lib/features/profile/presentation/screens/faq_and_guides_screen.dart), [`LeaderboardScreen`](lib/features/profile/presentation/screens/leaderboard_invite_about_screens.dart), [`InviteFriendScreen`](lib/features/profile/presentation/screens/leaderboard_invite_about_screens.dart), [`AboutAndFeedbackScreen`](lib/features/profile/presentation/screens/leaderboard_invite_about_screens.dart) ve [`MaintenanceScreen`](lib/features/profile/presentation/screens/leaderboard_invite_about_screens.dart).

### Aşama 8: Admin Web Paneli UI (`/admin`)
- [`AdminWebScreen`](lib/features/admin/presentation/admin_web_screen.dart) ve [`AdminChartsRow`](lib/features/admin/presentation/widgets/admin_charts.dart) (Rol kontrollü giriş, 8 sekmeli `NavigationRail`, istatistik kartları, `CustomPainter` il bazlı sütun ve 30 gün çizgi grafikleri, rapor kuyruğu Onayla/Reddet/Kısıtla aksiyonları ve `A`/`R` klavye kısayolları).

### Aşama 9: Cila, Hareket, Erişilebilirlik, Performans ve Canlı Emülatör Doğrulaması
- Android emülatör (`emulator-5554`) üzerinde uygulama derlenip çalıştırıldı; sekmeler (Talepler, Harita, Bağış, Bildirimler, Profil) canlı olarak gezilerek taşma/hata olmadığı doğrulandı.
- Windows'ta proje klasör adındaki Türkçe karakter (`turkiye-kan-agı`) nedeniyle Android `aapt` aracının APK manifest'ini okuyamaması sorunu `subst K:` sürücü eşlemesi ve `gradle.properties` / `android/build.gradle.kts` (`compileSdk 36` + `kotlin.incremental=false`) yapılandırmasıyla çözüldü.

---

## 3. Analiz ve Test Sonuçları

- **`dart analyze --fatal-infos`**: `No issues found!` (0 hata, 0 uyarı, 0 bilgi).
- **`flutter test`**: **52/52 test başarılı (`All tests passed!`)**.
  - [`core_widgets_test.dart`](test/core/widgets/core_widgets_test.dart)
  - [`onboarding_and_kvkk_test.dart`](test/features/onboarding/onboarding_and_kvkk_test.dart)
  - [`profile_and_wizard_test.dart`](test/features/profile/profile_and_wizard_test.dart)
  - [`prohibited_content_and_requests_test.dart`](test/features/requests/prohibited_content_and_requests_test.dart)
  - [`blood_compatibility_and_eligibility_test.dart`](test/features/matching/blood_compatibility_and_eligibility_test.dart)
  - [`donation_domain_and_sync_test.dart`](test/features/donation/donation_domain_and_sync_test.dart)
  - [`donation_screens_widget_test.dart`](test/features/donation/donation_screens_widget_test.dart)
  - [`navigation_and_force_update_test.dart`](test/navigation_and_force_update_test.dart)
  - [`ui_master_all_stages_test.dart`](test/features/ui_master_all_stages_test.dart)

---

## 4. Varsayımlar, Bilinen Kusurlar ve TODO Listesi

### Varsayımlar
1. Harita ekranında Google Maps API anahtarı bulunmayan ortamlarda çökme olmaması için etkileşimli `CustomPainter` tabanlı harita tuvali, pin kümeleme ve gezici kan bağışı aracı katmanı varsayılan olarak aktif çalışır.
2. Gönüllü Onur Tablosu (`LeaderboardScreen`) yarış algısı yaratmamak adına varsayılan olarak kapalı (`opt-in = false`) gelir; kullanıcı açıkça onayladığında listelenir.

### Bilinen Kusurlar / Ortam Notları
- Windows üzerinde proje dizin yolunda ASCII dışı karakter (`ı`) bulunduğunda Android SDK `aapt.exe` aracı `Illegal byte sequence` hatası vermektedir. `subst K: "C:\Users\MSI\Documents\antigravity\turkiye-kan-agı"` ile `K:\` üzerinden çalıştırıldığında sorunsuz derlenip emülatöre yüklenmektedir.

### TODO Listesi (Sonraki Backend Entegrasyon Görevleri İçin)
- Canlı Firebase projesinde (`turkiye-kan-agi-prod`) gerçek API anahtarlarının ve Google Maps Android/iOS API anahtarlarının `.env` / manifest dosyalarına tanımlanması.
