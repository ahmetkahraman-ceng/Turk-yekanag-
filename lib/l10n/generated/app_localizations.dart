import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Kan Ağı'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü kan bağışçıları ile ihtiyaç sahiplerini buluşturan dayanışma ağı'**
  String get appTagline;

  /// No description provided for @nonCommercialNotice.
  ///
  /// In tr, this message translates to:
  /// **'Bu uygulamada para karşılığı kan alım-satımına kesinlikle izin verilmez. Kızılay\'ı tamamlayıcı gönüllü bir dayanışma ağıdır.'**
  String get nonCommercialNotice;

  /// No description provided for @splashLoading.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama hazırlanıyor...'**
  String get splashLoading;

  /// No description provided for @navRequests.
  ///
  /// In tr, this message translates to:
  /// **'Talepler'**
  String get navRequests;

  /// No description provided for @navRequestsSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Kan talepleri sekmesi'**
  String get navRequestsSemantics;

  /// No description provided for @navMap.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get navMap;

  /// No description provided for @navMapSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki kan talepleri harita sekmesi'**
  String get navMapSemantics;

  /// No description provided for @navDonation.
  ///
  /// In tr, this message translates to:
  /// **'Bağış'**
  String get navDonation;

  /// No description provided for @navDonationSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Kan bağışı uygunluk ve geçmiş sekmesi'**
  String get navDonationSemantics;

  /// No description provided for @navNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get navNotifications;

  /// No description provided for @navNotificationsSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler sekmesi'**
  String get navNotificationsSemantics;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navProfileSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı profili ve ayarlar sekmesi'**
  String get navProfileSemantics;

  /// No description provided for @requestsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan Talepleri'**
  String get requestsTitle;

  /// No description provided for @requestsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz aktif kan talebi yok'**
  String get requestsEmptyTitle;

  /// No description provided for @requestsEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakın çevrenizde kan grubunuza uygun acil bir talep oluşturulduğunda burada listelenecektir.'**
  String get requestsEmptySubtitle;

  /// No description provided for @mapTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talep Haritası'**
  String get mapTitle;

  /// No description provided for @mapEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harita görünümü hazırlanıyor'**
  String get mapEmptyTitle;

  /// No description provided for @mapEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağışçı gizliliği gereği tam konumlar asla paylaşılmaz; yalnızca il, ilçe ve hastane noktaları gösterilir.'**
  String get mapEmptySubtitle;

  /// No description provided for @donationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Rehberi'**
  String get donationTitle;

  /// No description provided for @donationEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağış kaydınız bulunmuyor'**
  String get donationEmptyTitle;

  /// No description provided for @donationEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kızılay ve Sağlık Bakanlığı kurallarına göre bağış aralıklarınızı buradan takip edebileceksiniz.'**
  String get donationEmptySubtitle;

  /// No description provided for @donationIntervalInfo.
  ///
  /// In tr, this message translates to:
  /// **'Tam kan bağışı aralığı: Erkek {maleDays} gün, Kadın {femaleDays} gün (Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır).'**
  String donationIntervalInfo(int maleDays, int femaleDays);

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bildiriminiz yok'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubunuza uygun acil çağrılar ve eşleşme onayları burada görünür.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil ve KVKK Ayarları'**
  String get profileTitle;

  /// No description provided for @profileEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgileriniz henüz tamamlanmadı'**
  String get profileEmptyTitle;

  /// No description provided for @profileEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubu ve sağlık verileriniz açık rızanızla korunur; hesap silme ve veri indirme işlemlerinizi buradan yönetebilirsiniz.'**
  String get profileEmptySubtitle;

  /// No description provided for @commonRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get commonRetry;

  /// No description provided for @commonRetrySemantics.
  ///
  /// In tr, this message translates to:
  /// **'İşlemi tekrar dene butonu'**
  String get commonRetrySemantics;

  /// No description provided for @commonLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get commonLoading;

  /// No description provided for @commonErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu'**
  String get commonErrorTitle;

  /// No description provided for @commonErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'İşlem sırasında beklenmeyen bir hata meydana geldi. Lütfen tekrar deneyin.'**
  String get commonErrorMessage;

  /// No description provided for @networkErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin.'**
  String get networkErrorMessage;

  /// No description provided for @unauthorizedErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için oturum açmanız gerekiyor.'**
  String get unauthorizedErrorMessage;

  /// No description provided for @notFoundTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa Bulunamadı (404)'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In tr, this message translates to:
  /// **'Aradığınız sayfa mevcut değil veya taşınmış olabilir.'**
  String get notFoundMessage;

  /// No description provided for @notFoundBackHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfaya Dön'**
  String get notFoundBackHome;

  /// No description provided for @offlineBannerMessage.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı moddasınız. İnternet bağlantınız geldiğinde veriler güncellenecektir.'**
  String get offlineBannerMessage;

  /// No description provided for @offlineBannerSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı: İnternet bağlantısı yok'**
  String get offlineBannerSemantics;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme Gerekli'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateMessage.
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğiniz ve kesintisiz hizmet için uygulamanın en güncel sürümünü ({minVersion}) yüklemeniz gerekmektedir. Mevcut sürümünüz: {currentVersion}.'**
  String forceUpdateMessage(String minVersion, String currentVersion);

  /// No description provided for @forceUpdateAction.
  ///
  /// In tr, this message translates to:
  /// **'Mağazadan Güncelle'**
  String get forceUpdateAction;

  /// No description provided for @statePreviewNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get statePreviewNormal;

  /// No description provided for @statePreviewLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor'**
  String get statePreviewLoading;

  /// No description provided for @statePreviewEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get statePreviewEmpty;

  /// No description provided for @statePreviewError.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get statePreviewError;

  /// No description provided for @themeToggleSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Tema görünümünü değiştir'**
  String get themeToggleSemantics;

  /// No description provided for @commonNext.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get commonBack;

  /// No description provided for @commonSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get commonSkip;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get commonConfirm;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü Kan Dayanışması'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Description.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Kan Ağı, acil kan ihtiyacı olan hastalarla yakındaki uyumlu gönüllü bağışçıları hızlıca buluşturur. Kızılay\'ın yerine geçmez, onu tamamlar ve para karşılığı kan alım-satımına kesinlikle izin vermez.'**
  String get onboardingSlide1Description;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Çalışır?'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Description.
  ///
  /// In tr, this message translates to:
  /// **'Bir hastanede kan ihtiyacı oluştuğunda talep açılır. Sistem yalnızca kan grubu uyumlu ve yakın ilçedeki müsait bağışçılara bildirim gönderir.'**
  String get onboardingSlide2Description;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Verileriniz Güvende'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Description.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubunuz ve sağlık bilgileriniz KVKK kapsamında yalnızca sizin erişiminize açıktır. Telefon numaranız, siz \'Yardım edebilirim\' deyip onay verene kadar kimseyle paylaşılmaz.'**
  String get onboardingSlide3Description;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In tr, this message translates to:
  /// **'Konum İzni Neden Gerekli?'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Description.
  ///
  /// In tr, this message translates to:
  /// **'Tam konumunuz başkalarına asla gösterilmez; yalnızca il/ilçe düzeyinde tutulur ve size en yakın hastanedeki acil çağrıları filtrelemek için kullanılır.'**
  String get onboardingSlide4Description;

  /// No description provided for @onboardingStartAction.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get onboardingStartAction;

  /// No description provided for @kvkkScreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma ve Açık Rıza'**
  String get kvkkScreenTitle;

  /// No description provided for @kvkkLightingTitle.
  ///
  /// In tr, this message translates to:
  /// **'6698 Sayılı KVKK Aydınlatma Metni Özeti'**
  String get kvkkLightingTitle;

  /// No description provided for @kvkkLightingBody.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Kan Ağı olarak; kan grubu, kilo ve bağış uygunluk durumu gibi özel nitelikli kişisel verilerinizi yalnızca kan ihtiyacı eşleştirmesi amacıyla, açık rızanıza dayanarak işliyoruz. Verileriniz üçüncü taraflara satılmaz ve istediğiniz an hesabınızı silerek tüm verilerinizi kalıcı olarak kaldırabilirsiniz.'**
  String get kvkkLightingBody;

  /// No description provided for @kvkkConsentHealthTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özel Nitelikli Sağlık Verisi Açık Rızası (Zorunlu)'**
  String get kvkkConsentHealthTitle;

  /// No description provided for @kvkkConsentHealthSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubu, kilo, doğum tarihi ve bağış uygunluk bilgilerimin kan talebi eşleştirmesi amacıyla işlenmesine açık rıza veriyorum.'**
  String get kvkkConsentHealthSubtitle;

  /// No description provided for @kvkkConsentLocationTitle.
  ///
  /// In tr, this message translates to:
  /// **'İl/İlçe ve Yakınlık Verisi Açık Rızası (Zorunlu)'**
  String get kvkkConsentLocationTitle;

  /// No description provided for @kvkkConsentLocationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tam konumum paylaşılmaksızın, yakınımdaki hastane taleplerinin listelenmesi amacıyla il/ilçe ve mesafe bilgimin işlenmesini onaylıyorum.'**
  String get kvkkConsentLocationSubtitle;

  /// No description provided for @kvkkConsentNotificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Acil Kan Çağrısı Bildirim Rızası (Zorunlu)'**
  String get kvkkConsentNotificationTitle;

  /// No description provided for @kvkkConsentNotificationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubuma uygun acil kan talepleri ve eşleşme durumları hakkında anlık bildirim gönderilmesini kabul ediyorum.'**
  String get kvkkConsentNotificationSubtitle;

  /// No description provided for @kvkkReadPrivacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası Metnini Oku'**
  String get kvkkReadPrivacyPolicy;

  /// No description provided for @kvkkReadTermsOfUse.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları Metnini Oku'**
  String get kvkkReadTermsOfUse;

  /// No description provided for @kvkkApproveAndContinue.
  ///
  /// In tr, this message translates to:
  /// **'Açık Rıza Ver ve Devam Et'**
  String get kvkkApproveAndContinue;

  /// No description provided for @kvkkAllConsentsRequiredWarning.
  ///
  /// In tr, this message translates to:
  /// **'Devam edebilmek için lütfen tüm açık rıza kutularını onaylayın.'**
  String get kvkkAllConsentsRequiredWarning;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası ve KVKK Metni'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyPlaceholderBody.
  ///
  /// In tr, this message translates to:
  /// **'1. Veri Sorumlusu ve Amaç:\nTürkiye Kan Ağı, gönüllü kan bağışçıları ile ihtiyaç sahiplerini buluşturmak amacıyla faaliyet gösterir.\n\n2. İşlenen Özel Nitelikli Kişisel Veriler:\nKan grubu, kilo ve bağış geçmişi verileriniz 6698 sayılı KVKK Madde 6 kapsamında yalnızca açık rızanız ile işlenir ve Firestore güvenlik kurallarıyla yalnızca sizin hesabınız tarafından okunabilir.\n\n3. Konum ve İletişim Gizliliği:\nBağışçının tam konumu asla kaydedilmez veya paylaşılmaz; yalnızca il ve ilçe bilgisi tutulur. Telefon numaranız sadece \'Yardım edebilirim\' onayı sonrasında karşı tarafla paylaşılır.\n\n4. Veri Sahibi Hakları (Madde 11):\nProfil ekranından tüm verilerinizi JSON formatında indirebilir veya \'Hesabımı Sil\' adımıyla tüm kayıtlarınızı kalıcı olarak silebilirsiniz.'**
  String get privacyPolicyPlaceholderBody;

  /// No description provided for @termsOfUseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get termsOfUseTitle;

  /// No description provided for @termsOfUsePlaceholderBody.
  ///
  /// In tr, this message translates to:
  /// **'1. Gönüllülük Esası ve Ücretsizlik:\nUygulama içerisinde kan veya kan bileşenlerinin para ya da herhangi bir maddi menfaat karşılığında talep edilmesi veya teklif edilmesi kesinlikle yasaktır.\n\n2. Kızılay ve Resmi Kurumlar:\nBu uygulama Türk Kızılayı\'nın veya Sağlık Bakanlığı\'nın yerine geçmez; yalnızca hastane bazlı acil gönüllü yönlendirmesini kolaylaştırır.\n\n3. Tıbbi Sorumluluk:\nBağış uygunluğu konusundaki nihai karar, kan bağışı merkezindeki yetkili hekim ve sağlık personeline aittir.'**
  String get termsOfUsePlaceholderBody;

  /// No description provided for @authLoginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numaranız ile güvenli giriş yapın. Numaranız izniniz olmadan kimseyle paylaşılmaz.'**
  String get authLoginSubtitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Numarası'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In tr, this message translates to:
  /// **'5XX XXX XX XX'**
  String get authPhoneHint;

  /// No description provided for @authPhoneInvalidError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir Türkiye cep telefonu numarası girin (5XX XXX XX XX).'**
  String get authPhoneInvalidError;

  /// No description provided for @authSendOtpButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama Kodu Gönder'**
  String get authSendOtpButton;

  /// No description provided for @authOrDivider.
  ///
  /// In tr, this message translates to:
  /// **'veya alternatif giriş'**
  String get authOrDivider;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithApple.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile Giriş Yap'**
  String get authContinueWithApple;

  /// No description provided for @authOtpTitle.
  ///
  /// In tr, this message translates to:
  /// **'SMS Doğrulama'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{phoneNumber} numarasına gönderilen 6 haneli doğrulama kodunu girin.'**
  String authOtpSubtitle(String phoneNumber);

  /// No description provided for @authOtpCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'6 Haneli Doğrulama Kodu'**
  String get authOtpCodeLabel;

  /// No description provided for @authOtpInvalidError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen 6 haneli doğrulama kodunu eksiksiz girin.'**
  String get authOtpInvalidError;

  /// No description provided for @authVerifyOtpButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula ve Giriş Yap'**
  String get authVerifyOtpButton;

  /// No description provided for @authResendCountdown.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kod gönder ({seconds} sn)'**
  String authResendCountdown(int seconds);

  /// No description provided for @authResendNow.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Tekrar Gönder'**
  String get authResendNow;

  /// No description provided for @wizardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil Oluşturma Sihirbazı'**
  String get wizardTitle;

  /// No description provided for @wizardStepIdentity.
  ///
  /// In tr, this message translates to:
  /// **'1. Kimlik ve Görünürlük'**
  String get wizardStepIdentity;

  /// No description provided for @wizardStepMedical.
  ///
  /// In tr, this message translates to:
  /// **'2. Kan Grubu ve Fiziksel Bilgiler'**
  String get wizardStepMedical;

  /// No description provided for @wizardStepLocation.
  ///
  /// In tr, this message translates to:
  /// **'3. İl ve İlçe Seçimi'**
  String get wizardStepLocation;

  /// No description provided for @wizardFullNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get wizardFullNameLabel;

  /// No description provided for @wizardFullNameRequiredError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen adınızı ve soyadınızı girin.'**
  String get wizardFullNameRequiredError;

  /// No description provided for @wizardNicknameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Takma Ad (İsteğe Bağlı)'**
  String get wizardNicknameLabel;

  /// No description provided for @wizardUseNicknameSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Listelerde gerçek adım yerine takma adımı göster'**
  String get wizardUseNicknameSwitch;

  /// No description provided for @wizardBirthDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihi'**
  String get wizardBirthDateLabel;

  /// No description provided for @wizardBirthDateSelectButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihi Seçin'**
  String get wizardBirthDateSelectButton;

  /// No description provided for @wizardAgeValidationError.
  ///
  /// In tr, this message translates to:
  /// **'Bağışçı yaşı {minAge} ile {maxAge} arasında olmalıdır (Kızılay ve Sağlık Bakanlığı kuralları).'**
  String wizardAgeValidationError(int minAge, int maxAge);

  /// No description provided for @wizardGenderLabel.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get wizardGenderLabel;

  /// No description provided for @wizardGenderMale.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get wizardGenderMale;

  /// No description provided for @wizardGenderFemale.
  ///
  /// In tr, this message translates to:
  /// **'Kadın'**
  String get wizardGenderFemale;

  /// No description provided for @wizardGenderUnspecified.
  ///
  /// In tr, this message translates to:
  /// **'Belirtmek İstemiyorum'**
  String get wizardGenderUnspecified;

  /// No description provided for @wizardWeightLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kilo (kg)'**
  String get wizardWeightLabel;

  /// No description provided for @wizardWeightValidationError.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü kan bağışı için minimum kilo {minWeight} kg olmalıdır.'**
  String wizardWeightValidationError(int minWeight);

  /// No description provided for @wizardBloodTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kan Grubunuz'**
  String get wizardBloodTypeLabel;

  /// No description provided for @wizardBloodTypeUnknownOption.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubumu bilmiyorum'**
  String get wizardBloodTypeUnknownOption;

  /// No description provided for @wizardBloodTypeHowToLearnLink.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubumu nasıl öğrenebilirim?'**
  String get wizardBloodTypeHowToLearnLink;

  /// No description provided for @wizardProvinceLabel.
  ///
  /// In tr, this message translates to:
  /// **'İl Seçin (81 İl)'**
  String get wizardProvinceLabel;

  /// No description provided for @wizardDistrictLabel.
  ///
  /// In tr, this message translates to:
  /// **'İlçe Seçin'**
  String get wizardDistrictLabel;

  /// No description provided for @wizardLocationRequiredError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen il ve ilçe seçiminizi tamamlayın.'**
  String get wizardLocationRequiredError;

  /// No description provided for @wizardSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'İl veya ilçe ara...'**
  String get wizardSearchHint;

  /// No description provided for @wizardCompleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Profili Kaydet ve Başla'**
  String get wizardCompleteButton;

  /// No description provided for @unknownBloodGuideTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan Grubumu Nasıl Öğrenebilirim?'**
  String get unknownBloodGuideTitle;

  /// No description provided for @unknownBloodGuideIntro.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubunuzu henüz bilmiyorsanız uygulamayı kullanmaya devam edebilir, öğrendiğinizde profilinizden güncelleyebilirsiniz.'**
  String get unknownBloodGuideIntro;

  /// No description provided for @unknownBloodGuideStep1Title.
  ///
  /// In tr, this message translates to:
  /// **'1. Türk Kızılayı Kan Bağışı Noktaları'**
  String get unknownBloodGuideStep1Title;

  /// No description provided for @unknownBloodGuideStep1Body.
  ///
  /// In tr, this message translates to:
  /// **'Size en yakın Kızılay kan bağışı merkezine veya mobil kan bağışı aracına başvurarak ücretsiz kan bağışı ön muayenesinde kan grubunuzu öğrenebilirsiniz.'**
  String get unknownBloodGuideStep1Body;

  /// No description provided for @unknownBloodGuideStep2Title.
  ///
  /// In tr, this message translates to:
  /// **'2. Aile Sağlığı Merkezleri (Aile Hekimliği)'**
  String get unknownBloodGuideStep2Title;

  /// No description provided for @unknownBloodGuideStep2Body.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı olduğunuz Aile Hekiminize başvurarak basit bir kan grubu testi (ABO ve Rh tayini) yaptırabilirsiniz.'**
  String get unknownBloodGuideStep2Body;

  /// No description provided for @unknownBloodGuideStep3Title.
  ///
  /// In tr, this message translates to:
  /// **'3. e-Nabız ve Ehliyet Kayıtları'**
  String get unknownBloodGuideStep3Title;

  /// No description provided for @unknownBloodGuideStep3Body.
  ///
  /// In tr, this message translates to:
  /// **'Daha önce hastanede kan tahlili yaptırdıysanız e-Nabız hesabınızdaki \'Tahlillerim\' bölümünden veya sürücü belgesi sağlık raporunuzdan kan grubunuzu kontrol edebilirsiniz.'**
  String get unknownBloodGuideStep3Body;

  /// No description provided for @profileAvailableSwitchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağışa Uygunum'**
  String get profileAvailableSwitchTitle;

  /// No description provided for @profileAvailableSwitchSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Açık olduğunda kan grubunuza uygun yakın talepler için bildirim alırsınız.'**
  String get profileAvailableSwitchSubtitle;

  /// No description provided for @profilePhotoChangeButton.
  ///
  /// In tr, this message translates to:
  /// **'Profil Fotoğrafı Seç (İsteğe Bağlı)'**
  String get profilePhotoChangeButton;

  /// No description provided for @profileEditButton.
  ///
  /// In tr, this message translates to:
  /// **'Profil Bilgilerini Düzenle'**
  String get profileEditButton;

  /// No description provided for @profileNotificationPrefsButton.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Tercihleri'**
  String get profileNotificationPrefsButton;

  /// No description provided for @profileThemeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema Görünümü'**
  String get profileThemeTitle;

  /// No description provided for @profileThemeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık'**
  String get profileThemeDark;

  /// No description provided for @profileLanguageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get profileLanguageTitle;

  /// No description provided for @profileLanguageTr.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get profileLanguageTr;

  /// No description provided for @profileLanguageEn.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @profileExportDataButton.
  ///
  /// In tr, this message translates to:
  /// **'Verilerimi İndir (JSON)'**
  String get profileExportDataButton;

  /// No description provided for @profileExportDataSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz Hazır (JSON)'**
  String get profileExportDataSuccessTitle;

  /// No description provided for @profileDeleteAccountButton.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı ve Verilerimi Kalıcı Olarak Sil'**
  String get profileDeleteAccountButton;

  /// No description provided for @profileDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı Silmek İstediğinize Emin Misiniz?'**
  String get profileDeleteConfirmTitle;

  /// No description provided for @profileDeleteConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz. KVKK rıza kayıtlarınız, özel nitelikli sağlık bilgileriniz ve profiliniz Cloud Function aracılığıyla kalıcı olarak silinecektir.'**
  String get profileDeleteConfirmBody;

  /// No description provided for @profileDeleteConfirmAction.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Hesabımı Sil'**
  String get profileDeleteConfirmAction;

  /// No description provided for @profileSignOutButton.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu Kapat'**
  String get profileSignOutButton;

  /// No description provided for @notifPrefsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Tercihleri'**
  String get notifPrefsTitle;

  /// No description provided for @notifUrgencyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Minimum Aciliyet Seviyesi'**
  String get notifUrgencyTitle;

  /// No description provided for @notifUrgencyAll.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Talepler'**
  String get notifUrgencyAll;

  /// No description provided for @notifUrgencyUrgentOnly.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca Acil ve Kritik Talepler'**
  String get notifUrgencyUrgentOnly;

  /// No description provided for @notifUrgencyCriticalOnly.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca Kritik (Hayati) Talepler'**
  String get notifUrgencyCriticalOnly;

  /// No description provided for @notifRadiusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Mesafe Yarıçapı'**
  String get notifRadiusTitle;

  /// No description provided for @notifRadiusKm.
  ///
  /// In tr, this message translates to:
  /// **'{km} km'**
  String notifRadiusKm(int km);

  /// No description provided for @notifQuietHoursTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz Saatler'**
  String get notifQuietHoursTitle;

  /// No description provided for @notifQuietHoursEnable.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz saatleri etkinleştir (23:00 - 07:00)'**
  String get notifQuietHoursEnable;

  /// No description provided for @notifQuietHoursAllowCritical.
  ///
  /// In tr, this message translates to:
  /// **'Acil/kritik durumları sessiz saatlerde de bildir'**
  String get notifQuietHoursAllowCritical;

  /// No description provided for @notifPrefsSavedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim tercihleriniz kaydedildi.'**
  String get notifPrefsSavedMessage;

  /// No description provided for @requestCreateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan Talebi Oluştur'**
  String get requestCreateTitle;

  /// No description provided for @requestEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan Talebini Düzenle'**
  String get requestEditTitle;

  /// No description provided for @requestStepPatientProduct.
  ///
  /// In tr, this message translates to:
  /// **'1. Hasta ve Kan Bileşeni'**
  String get requestStepPatientProduct;

  /// No description provided for @requestStepHospitalUrgency.
  ///
  /// In tr, this message translates to:
  /// **'2. Hastane ve Aciliyet'**
  String get requestStepHospitalUrgency;

  /// No description provided for @requestStepContactReport.
  ///
  /// In tr, this message translates to:
  /// **'3. İletişim ve Belge'**
  String get requestStepContactReport;

  /// No description provided for @requestPatientInitialsLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hasta Adı Soyadı Baş Harfleri (Örn: A.Y.)'**
  String get requestPatientInitialsLabel;

  /// No description provided for @requestPatientInitialsHint.
  ///
  /// In tr, this message translates to:
  /// **'A.Y.'**
  String get requestPatientInitialsHint;

  /// No description provided for @requestPatientInitialsError.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik gereği lütfen yalnızca baş harfleri girin (Örn: A.Y.).'**
  String get requestPatientInitialsError;

  /// No description provided for @requestProductTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kan Ürünü Tipi'**
  String get requestProductTypeLabel;

  /// No description provided for @productWholeBlood.
  ///
  /// In tr, this message translates to:
  /// **'Tam Kan'**
  String get productWholeBlood;

  /// No description provided for @productErythrocyte.
  ///
  /// In tr, this message translates to:
  /// **'Eritrosit Süspansiyonu'**
  String get productErythrocyte;

  /// No description provided for @productPlatelet.
  ///
  /// In tr, this message translates to:
  /// **'Trombosit (Aferez)'**
  String get productPlatelet;

  /// No description provided for @productPlasma.
  ///
  /// In tr, this message translates to:
  /// **'Taze Donmuş Plazma'**
  String get productPlasma;

  /// No description provided for @requestUnitsLabel.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyaç Duyulan Ünite Sayısı'**
  String get requestUnitsLabel;

  /// No description provided for @requestUnitsValue.
  ///
  /// In tr, this message translates to:
  /// **'{count} Ünite'**
  String requestUnitsValue(int count);

  /// No description provided for @requestHospitalSelectLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hastane Seçin'**
  String get requestHospitalSelectLabel;

  /// No description provided for @requestHospitalSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Hastane adı, il veya ilçe ara...'**
  String get requestHospitalSearchHint;

  /// No description provided for @requestHospitalRequiredError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen hastaneyi seçin.'**
  String get requestHospitalRequiredError;

  /// No description provided for @requestDepartmentLabel.
  ///
  /// In tr, this message translates to:
  /// **'Servis / Bölüm (Örn: Yoğun Bakım, Hematoloji)'**
  String get requestDepartmentLabel;

  /// No description provided for @requestDepartmentRequiredError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen servis veya bölüm bilgisini girin.'**
  String get requestDepartmentRequiredError;

  /// No description provided for @requestUrgencyLabel.
  ///
  /// In tr, this message translates to:
  /// **'Aciliyet Durumu'**
  String get requestUrgencyLabel;

  /// No description provided for @urgencyCritical.
  ///
  /// In tr, this message translates to:
  /// **'Acil (Hemen)'**
  String get urgencyCritical;

  /// No description provided for @urgencyToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get urgencyToday;

  /// No description provided for @urgencyThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get urgencyThisWeek;

  /// No description provided for @requestContactNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hasta Yakını Adı / Baş Harfleri'**
  String get requestContactNameLabel;

  /// No description provided for @requestContactPhoneLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hasta Yakını Telefonu (Herkese Açık Görünmez)'**
  String get requestContactPhoneLabel;

  /// No description provided for @requestNotesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ek Açıklama (Para/Ücret İfadesi Yasaktır)'**
  String get requestNotesLabel;

  /// No description provided for @requestMedicalReportButton.
  ///
  /// In tr, this message translates to:
  /// **'Doktor Raporu / Talep Belgesi Ekle (İsteğe Bağlı)'**
  String get requestMedicalReportButton;

  /// No description provided for @requestMedicalReportAttached.
  ///
  /// In tr, this message translates to:
  /// **'Doktor raporu eklendi (Yalnızca moderatör ve siz görebilirsiniz)'**
  String get requestMedicalReportAttached;

  /// No description provided for @requestProhibitedTextError.
  ///
  /// In tr, this message translates to:
  /// **'Metinde para, ücret, IBAN veya maddi karşılık içeren yasaklı ifadeler tespit edildi. Gönüllülük esası gereği bu ifadeler kullanılamaz.'**
  String get requestProhibitedTextError;

  /// No description provided for @requestLimitActiveError.
  ///
  /// In tr, this message translates to:
  /// **'Aynı anda en fazla {maxActive} açık talebiniz olabilir.'**
  String requestLimitActiveError(int maxActive);

  /// No description provided for @requestLimitDailyError.
  ///
  /// In tr, this message translates to:
  /// **'Günlük talep oluşturma sınırına ({maxDaily}) ulaştınız.'**
  String requestLimitDailyError(int maxDaily);

  /// No description provided for @requestSubmitButton.
  ///
  /// In tr, this message translates to:
  /// **'Talebi Yayınla'**
  String get requestSubmitButton;

  /// No description provided for @requestSaveChangesButton.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri Kaydet'**
  String get requestSaveChangesButton;

  /// No description provided for @requestStatusOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get requestStatusOpen;

  /// No description provided for @requestStatusFulfilled.
  ///
  /// In tr, this message translates to:
  /// **'Karşılandı'**
  String get requestStatusFulfilled;

  /// No description provided for @requestStatusCancelled.
  ///
  /// In tr, this message translates to:
  /// **'İptal Edildi'**
  String get requestStatusCancelled;

  /// No description provided for @requestStatusExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi Doldu'**
  String get requestStatusExpired;

  /// No description provided for @requestFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get requestFilterAll;

  /// No description provided for @requestFilterBloodGroup.
  ///
  /// In tr, this message translates to:
  /// **'Kan Grubu'**
  String get requestFilterBloodGroup;

  /// No description provided for @requestFilterProduct.
  ///
  /// In tr, this message translates to:
  /// **'Ürün'**
  String get requestFilterProduct;

  /// No description provided for @requestFilterUrgency.
  ///
  /// In tr, this message translates to:
  /// **'Aciliyet'**
  String get requestFilterUrgency;

  /// No description provided for @requestFilterProvince.
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get requestFilterProvince;

  /// No description provided for @requestFilterClear.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri Temizle'**
  String get requestFilterClear;

  /// No description provided for @requestLoadMore.
  ///
  /// In tr, this message translates to:
  /// **'Daha Fazla Yükle'**
  String get requestLoadMore;

  /// No description provided for @requestDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talep Detayı'**
  String get requestDetailTitle;

  /// No description provided for @requestOfferCountBadge.
  ///
  /// In tr, this message translates to:
  /// **'{count} gönüllü yardım teklif etti'**
  String requestOfferCountBadge(int count);

  /// No description provided for @requestShareButton.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get requestShareButton;

  /// No description provided for @requestReportButton.
  ///
  /// In tr, this message translates to:
  /// **'Rapor Et'**
  String get requestReportButton;

  /// No description provided for @requestReportDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talebi Rapor Et'**
  String get requestReportDialogTitle;

  /// No description provided for @requestReportReasonHint.
  ///
  /// In tr, this message translates to:
  /// **'Ücret talebi, yanıltıcı bilgi vb. bildirin...'**
  String get requestReportReasonHint;

  /// No description provided for @requestReportSubmittedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bildiriminiz moderasyon ekibine iletildi.'**
  String get requestReportSubmittedMessage;

  /// No description provided for @requestOwnerActionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talep Yönetimi'**
  String get requestOwnerActionsTitle;

  /// No description provided for @requestMarkFulfilledButton.
  ///
  /// In tr, this message translates to:
  /// **'Karşılandı İşaretle'**
  String get requestMarkFulfilledButton;

  /// No description provided for @requestExtendExpiryButton.
  ///
  /// In tr, this message translates to:
  /// **'Süreyi Uzat (+24 Saat)'**
  String get requestExtendExpiryButton;

  /// No description provided for @requestCancelButton.
  ///
  /// In tr, this message translates to:
  /// **'Talebi İptal Et'**
  String get requestCancelButton;

  /// No description provided for @requestStopNewOffersSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Yeterli kişi geldi (Yeni teklif almayı kapat)'**
  String get requestStopNewOffersSwitch;

  /// No description provided for @requestShareCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Acil Kan Çağrısı Paylaşım Kartı'**
  String get requestShareCardTitle;

  /// No description provided for @requestShareCopyTextButton.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Metni ve Linki Kopyala'**
  String get requestShareCopyTextButton;

  /// No description provided for @requestShareCopiedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım metni ve bağlantı panoya kopyalandı.'**
  String get requestShareCopiedMessage;

  /// No description provided for @matchingCanHelpButton.
  ///
  /// In tr, this message translates to:
  /// **'Yardım Edebilirim'**
  String get matchingCanHelpButton;

  /// No description provided for @matchingCompatibilityIncompatible.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubunuz ({donorBlood}) bu talep ({recipientBlood} {product}) ile tıbbi olarak uyumlu görünmüyor.'**
  String matchingCompatibilityIncompatible(
      String donorBlood, String recipientBlood, String product);

  /// No description provided for @matchingCompatibilityCompatible.
  ///
  /// In tr, this message translates to:
  /// **'Kan grubunuz bu talep ile uyumludur.'**
  String get matchingCompatibilityCompatible;

  /// No description provided for @matchingSelectTimeSlotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini Geliş Saatinizi Seçin (Koordinasyon)'**
  String get matchingSelectTimeSlotTitle;

  /// No description provided for @matchingTimeSlotNow.
  ///
  /// In tr, this message translates to:
  /// **'Hemen (0-1 Saat İçinde)'**
  String get matchingTimeSlotNow;

  /// No description provided for @matchingTimeSlotMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah (09:00 - 12:00)'**
  String get matchingTimeSlotMorning;

  /// No description provided for @matchingTimeSlotAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'Öğleden Sonra (12:00 - 17:00)'**
  String get matchingTimeSlotAfternoon;

  /// No description provided for @matchingTimeSlotEvening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam (17:00 - 21:00)'**
  String get matchingTimeSlotEvening;

  /// No description provided for @matchingOfferPending.
  ///
  /// In tr, this message translates to:
  /// **'Onay Bekleniyor (Talep sahibi onayladığında telefonlar açılır)'**
  String get matchingOfferPending;

  /// No description provided for @matchingOfferApproved.
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı — Karşılıklı İletişim Açık'**
  String get matchingOfferApproved;

  /// No description provided for @matchingStepOnTheWay.
  ///
  /// In tr, this message translates to:
  /// **'Yoldayım'**
  String get matchingStepOnTheWay;

  /// No description provided for @matchingStepArrived.
  ///
  /// In tr, this message translates to:
  /// **'Hastaneye Vardım'**
  String get matchingStepArrived;

  /// No description provided for @matchingStepDonated.
  ///
  /// In tr, this message translates to:
  /// **'Bağışı Yaptım'**
  String get matchingStepDonated;

  /// No description provided for @matchingStepConfirmed.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Onaylandı (Geçmişe Kaydedildi)'**
  String get matchingStepConfirmed;

  /// No description provided for @matchingQuickMsg1.
  ///
  /// In tr, this message translates to:
  /// **'Yola çıktım, yakında hastanedeyim.'**
  String get matchingQuickMsg1;

  /// No description provided for @matchingQuickMsg2.
  ///
  /// In tr, this message translates to:
  /// **'Kan merkezindeyim, kayıt yaptırıyorum.'**
  String get matchingQuickMsg2;

  /// No description provided for @matchingQuickMsg3.
  ///
  /// In tr, this message translates to:
  /// **'Bağış işlemini tamamladım, geçmiş olsun.'**
  String get matchingQuickMsg3;

  /// No description provided for @matchingCallButton.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get matchingCallButton;

  /// No description provided for @matchingWhatsAppButton.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp'**
  String get matchingWhatsAppButton;

  /// No description provided for @matchingOwnerApproveDonorButton.
  ///
  /// In tr, this message translates to:
  /// **'Bağışçıyı Onayla (İletişimi Aç)'**
  String get matchingOwnerApproveDonorButton;

  /// No description provided for @matchingOwnerConfirmDonationButton.
  ///
  /// In tr, this message translates to:
  /// **'Bağışı Onayla (Tamamlandı)'**
  String get matchingOwnerConfirmDonationButton;

  /// No description provided for @matchingOffersClosedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Talep sahibi yeterli bağışçıya ulaşıldığını belirttiği için yeni teklif alımı kapatılmıştır.'**
  String get matchingOffersClosedNotice;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Okundu İşaretle'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsFilterUnreadOnly.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca Okunmamışlar'**
  String get notificationsFilterUnreadOnly;

  /// No description provided for @donationStatusEligibleNowTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu Anda Bağışa Uygun Görünüyorsunuz'**
  String get donationStatusEligibleNowTitle;

  /// No description provided for @donationStatusWaitingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Bağış İçin Bekleme Süresindesiniz'**
  String get donationStatusWaitingTitle;

  /// No description provided for @donationCountdownDaysHours.
  ///
  /// In tr, this message translates to:
  /// **'Kalan süre: {days} gün ({hours} saat)'**
  String donationCountdownDaysHours(int days, int hours);

  /// No description provided for @donationNextEligibleDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki uygun tarih: {dateText}'**
  String donationNextEligibleDateLabel(String dateText);

  /// No description provided for @donationAutoPausedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Bekleme süreniz dolana kadar \'Bağışa uygunum\' durumunuz otomatik olarak kapatıldı.'**
  String get donationAutoPausedNotice;

  /// No description provided for @donationAutoResumedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Bekleme süreniz tamamlandığında \'Bağışa uygunum\' durumunuz otomatik olarak açılır.'**
  String get donationAutoResumedNotice;

  /// No description provided for @donationReminderToggleTitle.
  ///
  /// In tr, this message translates to:
  /// **'\'Tekrar bağış yapabilirsin\' bildirimi'**
  String get donationReminderToggleTitle;

  /// No description provided for @donationReminderToggleSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bekleme süreniz dolduğunda yerel bildirim gönderilir'**
  String get donationReminderToggleSubtitle;

  /// No description provided for @donationReminderScheduledSnack.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma bildirimi planlandı.'**
  String get donationReminderScheduledSnack;

  /// No description provided for @donationAddToCalendarButton.
  ///
  /// In tr, this message translates to:
  /// **'Takvime Ekle'**
  String get donationAddToCalendarButton;

  /// No description provided for @donationCalendarEventTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kan Bağışı Uygunluk Günü (Türkiye Kan Ağı)'**
  String get donationCalendarEventTitle;

  /// No description provided for @donationCalendarEventDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bekleme süreniz doldu. Kızılay veya kan merkezinde bağış yapabilirsiniz.'**
  String get donationCalendarEventDesc;

  /// No description provided for @donationCalendarAddedSnack.
  ///
  /// In tr, this message translates to:
  /// **'Takvim etkinliği oluşturuldu.'**
  String get donationCalendarAddedSnack;

  /// No description provided for @donationReminderNotifTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Bağış Yapabilirsiniz'**
  String get donationReminderNotifTitle;

  /// No description provided for @donationReminderNotifBody.
  ///
  /// In tr, this message translates to:
  /// **'Son bağışınızdan sonraki bekleme süreniz tamamlandı. Uygun hissediyorsanız kan bağışında bulunabilirsiniz.'**
  String get donationReminderNotifBody;

  /// No description provided for @donationAddManualButton.
  ///
  /// In tr, this message translates to:
  /// **'Manuel Bağış Ekle'**
  String get donationAddManualButton;

  /// No description provided for @donationAddSheetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş Bağış Kaydı Ekle'**
  String get donationAddSheetTitle;

  /// No description provided for @donationPlaceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Yeri (Kan Merkezi / Hastane)'**
  String get donationPlaceLabel;

  /// No description provided for @donationPlaceHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Kızılay Çankaya Kan Bağışı Merkezi'**
  String get donationPlaceHint;

  /// No description provided for @donationDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Tarihi'**
  String get donationDateLabel;

  /// No description provided for @donationSelectDateButton.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seç'**
  String get donationSelectDateButton;

  /// No description provided for @donationProductTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bağışlanan Ürün Tipi'**
  String get donationProductTypeLabel;

  /// No description provided for @donationSourceManualBadge.
  ///
  /// In tr, this message translates to:
  /// **'Manuel Kayıt'**
  String get donationSourceManualBadge;

  /// No description provided for @donationSourceRequestBadge.
  ///
  /// In tr, this message translates to:
  /// **'Talep Akışı (Onaylı)'**
  String get donationSourceRequestBadge;

  /// No description provided for @donationDeleteManualTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Manuel bağış kaydını sil'**
  String get donationDeleteManualTooltip;

  /// No description provided for @donationValidationPlaceRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bağış yapılan yeri girin.'**
  String get donationValidationPlaceRequired;

  /// No description provided for @donationValidationFutureDate.
  ///
  /// In tr, this message translates to:
  /// **'Gelecek tarihli bağış kaydı eklenemez.'**
  String get donationValidationFutureDate;

  /// No description provided for @donationHistorySectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Geçmişim'**
  String get donationHistorySectionTitle;

  /// No description provided for @donationQuickSurveyButton.
  ///
  /// In tr, this message translates to:
  /// **'Uygunluk Ön Kontrol Anketi'**
  String get donationQuickSurveyButton;

  /// No description provided for @donationQuickTipsButton.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Öncesi ve Sonrası Öneriler'**
  String get donationQuickTipsButton;

  /// No description provided for @donationSurveyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağışa Uygunluk Ön Kontrol Anketi'**
  String get donationSurveyTitle;

  /// No description provided for @donationSurveyDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'ÖNEMLİ UYARI: Bu anket kesin tıbbi karar vermez, yalnızca ön bilgilendirme amaçlıdır. Karar kan merkezindeki sağlık personelindedir. Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.'**
  String get donationSurveyDisclaimer;

  /// No description provided for @donationSurveyAnswerYes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get donationSurveyAnswerYes;

  /// No description provided for @donationSurveyAnswerNo.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get donationSurveyAnswerNo;

  /// No description provided for @donationSurveyAnswerUnsure.
  ///
  /// In tr, this message translates to:
  /// **'Emin Değilim'**
  String get donationSurveyAnswerUnsure;

  /// No description provided for @donationSurveyEvaluateButton.
  ///
  /// In tr, this message translates to:
  /// **'Ön Kontrol Sonucunu Gör'**
  String get donationSurveyEvaluateButton;

  /// No description provided for @donationSurveyIncompleteError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm soruları yanıtlayın.'**
  String get donationSurveyIncompleteError;

  /// No description provided for @donationSurveyOutcomeEligibleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygun Görünüyor'**
  String get donationSurveyOutcomeEligibleTitle;

  /// No description provided for @donationSurveyOutcomeEligibleBody.
  ///
  /// In tr, this message translates to:
  /// **'Yanıtlarınıza göre belirgin bir engel görünmüyor. Kesin karar kan merkezindeki hekim ve sağlık personelindedir.'**
  String get donationSurveyOutcomeEligibleBody;

  /// No description provided for @donationSurveyOutcomeUnsureTitle.
  ///
  /// In tr, this message translates to:
  /// **'Emin Değilim (Hekime Danışın)'**
  String get donationSurveyOutcomeUnsureTitle;

  /// No description provided for @donationSurveyOutcomeUnsureBody.
  ///
  /// In tr, this message translates to:
  /// **'Bazı yanıtlarınız ek değerlendirme gerektiriyor. Kan merkezindeki görevli hekime danışmanız önerilir.'**
  String get donationSurveyOutcomeUnsureBody;

  /// No description provided for @donationSurveyOutcomeIneligibleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygun Görünmüyor (Geçici Erteleme Olabilir)'**
  String get donationSurveyOutcomeIneligibleTitle;

  /// No description provided for @donationSurveyOutcomeIneligibleBody.
  ///
  /// In tr, this message translates to:
  /// **'Yanıtlarınızdan en az biri geçici veya kalıcı erteleme sebebi olabilir. Kesin karar kan merkezindeki sağlık personelindedir.'**
  String get donationSurveyOutcomeIneligibleBody;

  /// No description provided for @donationSurveySavedSnack.
  ///
  /// In tr, this message translates to:
  /// **'Ön kontrol sonucunuz özel sağlık verileriniz altına kaydedildi.'**
  String get donationSurveySavedSnack;

  /// No description provided for @donationTipsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Öncesi ve Sonrası Öneriler'**
  String get donationTipsTitle;

  /// No description provided for @donationTipsMedicalNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu bilgiler genel rehber niteliğindedir; Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.'**
  String get donationTipsMedicalNote;

  /// No description provided for @donationTipsBeforeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Öncesi Öneriler'**
  String get donationTipsBeforeTitle;

  /// No description provided for @donationTipsBefore1.
  ///
  /// In tr, this message translates to:
  /// **'Bağıştan önce bol su için ve hafif, yağsız bir öğün tüketin; aç karnına bağışa gitmeyin.'**
  String get donationTipsBefore1;

  /// No description provided for @donationTipsBefore2.
  ///
  /// In tr, this message translates to:
  /// **'Uykunuzu almış ve dinlenmiş olun; son 24 saatte alkol tüketmeyin.'**
  String get donationTipsBefore2;

  /// No description provided for @donationTipsBefore3.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kimlik belgenizi yanınıza alın ve kullandığınız ilaçları sağlık personeline bildirin.'**
  String get donationTipsBefore3;

  /// No description provided for @donationTipsAfterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağış Sonrası Öneriler'**
  String get donationTipsAfterTitle;

  /// No description provided for @donationTipsAfter1.
  ///
  /// In tr, this message translates to:
  /// **'Bağış sonrasında en az 10-15 dakika dinlenin ve ikram edilen sıvı/gıdaları tüketin.'**
  String get donationTipsAfter1;

  /// No description provided for @donationTipsAfter2.
  ///
  /// In tr, this message translates to:
  /// **'İlk 24 saat boyunca bol sıvı tüketin; bağış yapılan kolunuzla ağır yük kaldırmayın.'**
  String get donationTipsAfter2;

  /// No description provided for @donationTipsAfter3.
  ///
  /// In tr, this message translates to:
  /// **'İlk birkaç saat sigara kullanmayın; baş dönmesi hissederseniz hemen uzanıp ayaklarınızı yükseltin.'**
  String get donationTipsAfter3;

  /// No description provided for @donationKvkkConsentRequiredTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık Verisi Açık Rızası Gerekli'**
  String get donationKvkkConsentRequiredTitle;

  /// No description provided for @donationKvkkConsentRequiredBody.
  ///
  /// In tr, this message translates to:
  /// **'Bağış geçmişi ve sağlık anketi verileriniz KVKK kapsamında özel nitelikli kişisel veridir. Devam etmek için açık rıza vermeniz gerekmektedir.'**
  String get donationKvkkConsentRequiredBody;

  /// No description provided for @donationKvkkGrantConsentButton.
  ///
  /// In tr, this message translates to:
  /// **'Açık Rıza Ver ve Devam Et'**
  String get donationKvkkGrantConsentButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
