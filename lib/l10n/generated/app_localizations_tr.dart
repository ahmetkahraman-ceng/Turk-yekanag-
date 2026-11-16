// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Türkiye Kan Ağı';

  @override
  String get appTagline =>
      'Gönüllü kan bağışçıları ile ihtiyaç sahiplerini buluşturan dayanışma ağı';

  @override
  String get nonCommercialNotice =>
      'Bu uygulamada para karşılığı kan alım-satımına kesinlikle izin verilmez. Kızılay\'ı tamamlayıcı gönüllü bir dayanışma ağıdır.';

  @override
  String get splashLoading => 'Uygulama hazırlanıyor...';

  @override
  String get navRequests => 'Talepler';

  @override
  String get navRequestsSemantics => 'Kan talepleri sekmesi';

  @override
  String get navMap => 'Harita';

  @override
  String get navMapSemantics => 'Yakındaki kan talepleri harita sekmesi';

  @override
  String get navDonation => 'Bağış';

  @override
  String get navDonationSemantics => 'Kan bağışı uygunluk ve geçmiş sekmesi';

  @override
  String get navNotifications => 'Bildirimler';

  @override
  String get navNotificationsSemantics => 'Bildirimler sekmesi';

  @override
  String get navProfile => 'Profil';

  @override
  String get navProfileSemantics => 'Kullanıcı profili ve ayarlar sekmesi';

  @override
  String get requestsTitle => 'Kan Talepleri';

  @override
  String get requestsEmptyTitle => 'Henüz aktif kan talebi yok';

  @override
  String get requestsEmptySubtitle =>
      'Yakın çevrenizde kan grubunuza uygun acil bir talep oluşturulduğunda burada listelenecektir.';

  @override
  String get mapTitle => 'Talep Haritası';

  @override
  String get mapEmptyTitle => 'Harita görünümü hazırlanıyor';

  @override
  String get mapEmptySubtitle =>
      'Bağışçı gizliliği gereği tam konumlar asla paylaşılmaz; yalnızca il, ilçe ve hastane noktaları gösterilir.';

  @override
  String get donationTitle => 'Bağış Rehberi';

  @override
  String get donationEmptyTitle => 'Bağış kaydınız bulunmuyor';

  @override
  String get donationEmptySubtitle =>
      'Kızılay ve Sağlık Bakanlığı kurallarına göre bağış aralıklarınızı buradan takip edebileceksiniz.';

  @override
  String donationIntervalInfo(int maleDays, int femaleDays) {
    return 'Tam kan bağışı aralığı: Erkek $maleDays gün, Kadın $femaleDays gün (Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır).';
  }

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationsEmptyTitle => 'Yeni bildiriminiz yok';

  @override
  String get notificationsEmptySubtitle =>
      'Kan grubunuza uygun acil çağrılar ve eşleşme onayları burada görünür.';

  @override
  String get profileTitle => 'Profil ve KVKK Ayarları';

  @override
  String get profileEmptyTitle => 'Profil bilgileriniz henüz tamamlanmadı';

  @override
  String get profileEmptySubtitle =>
      'Kan grubu ve sağlık verileriniz açık rızanızla korunur; hesap silme ve veri indirme işlemlerinizi buradan yönetebilirsiniz.';

  @override
  String get commonRetry => 'Tekrar Dene';

  @override
  String get commonRetrySemantics => 'İşlemi tekrar dene butonu';

  @override
  String get commonLoading => 'Yükleniyor...';

  @override
  String get commonErrorTitle => 'Bir sorun oluştu';

  @override
  String get commonErrorMessage =>
      'İşlem sırasında beklenmeyen bir hata meydana geldi. Lütfen tekrar deneyin.';

  @override
  String get networkErrorMessage =>
      'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin.';

  @override
  String get unauthorizedErrorMessage =>
      'Bu işlem için oturum açmanız gerekiyor.';

  @override
  String get notFoundTitle => 'Sayfa Bulunamadı (404)';

  @override
  String get notFoundMessage =>
      'Aradığınız sayfa mevcut değil veya taşınmış olabilir.';

  @override
  String get notFoundBackHome => 'Ana Sayfaya Dön';

  @override
  String get offlineBannerMessage =>
      'Çevrimdışı moddasınız. İnternet bağlantınız geldiğinde veriler güncellenecektir.';

  @override
  String get offlineBannerSemantics => 'Uyarı: İnternet bağlantısı yok';

  @override
  String get forceUpdateTitle => 'Güncelleme Gerekli';

  @override
  String forceUpdateMessage(String minVersion, String currentVersion) {
    return 'Güvenliğiniz ve kesintisiz hizmet için uygulamanın en güncel sürümünü ($minVersion) yüklemeniz gerekmektedir. Mevcut sürümünüz: $currentVersion.';
  }

  @override
  String get forceUpdateAction => 'Mağazadan Güncelle';

  @override
  String get statePreviewNormal => 'Normal';

  @override
  String get statePreviewLoading => 'Yükleniyor';

  @override
  String get statePreviewEmpty => 'Boş';

  @override
  String get statePreviewError => 'Hata';

  @override
  String get themeToggleSemantics => 'Tema görünümünü değiştir';

  @override
  String get commonNext => 'İleri';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonSkip => 'Atla';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonConfirm => 'Onayla';

  @override
  String get onboardingSlide1Title => 'Gönüllü Kan Dayanışması';

  @override
  String get onboardingSlide1Description =>
      'Türkiye Kan Ağı, acil kan ihtiyacı olan hastalarla yakındaki uyumlu gönüllü bağışçıları hızlıca buluşturur. Kızılay\'ın yerine geçmez, onu tamamlar ve para karşılığı kan alım-satımına kesinlikle izin vermez.';

  @override
  String get onboardingSlide2Title => 'Nasıl Çalışır?';

  @override
  String get onboardingSlide2Description =>
      'Bir hastanede kan ihtiyacı oluştuğunda talep açılır. Sistem yalnızca kan grubu uyumlu ve yakın ilçedeki müsait bağışçılara bildirim gönderir.';

  @override
  String get onboardingSlide3Title => 'Kişisel Verileriniz Güvende';

  @override
  String get onboardingSlide3Description =>
      'Kan grubunuz ve sağlık bilgileriniz KVKK kapsamında yalnızca sizin erişiminize açıktır. Telefon numaranız, siz \'Yardım edebilirim\' deyip onay verene kadar kimseyle paylaşılmaz.';

  @override
  String get onboardingSlide4Title => 'Konum İzni Neden Gerekli?';

  @override
  String get onboardingSlide4Description =>
      'Tam konumunuz başkalarına asla gösterilmez; yalnızca il/ilçe düzeyinde tutulur ve size en yakın hastanedeki acil çağrıları filtrelemek için kullanılır.';

  @override
  String get onboardingStartAction => 'Devam Et';

  @override
  String get kvkkScreenTitle => 'KVKK Aydınlatma ve Açık Rıza';

  @override
  String get kvkkLightingTitle => '6698 Sayılı KVKK Aydınlatma Metni Özeti';

  @override
  String get kvkkLightingBody =>
      'Türkiye Kan Ağı olarak; kan grubu, kilo ve bağış uygunluk durumu gibi özel nitelikli kişisel verilerinizi yalnızca kan ihtiyacı eşleştirmesi amacıyla, açık rızanıza dayanarak işliyoruz. Verileriniz üçüncü taraflara satılmaz ve istediğiniz an hesabınızı silerek tüm verilerinizi kalıcı olarak kaldırabilirsiniz.';

  @override
  String get kvkkConsentHealthTitle =>
      'Özel Nitelikli Sağlık Verisi Açık Rızası (Zorunlu)';

  @override
  String get kvkkConsentHealthSubtitle =>
      'Kan grubu, kilo, doğum tarihi ve bağış uygunluk bilgilerimin kan talebi eşleştirmesi amacıyla işlenmesine açık rıza veriyorum.';

  @override
  String get kvkkConsentLocationTitle =>
      'İl/İlçe ve Yakınlık Verisi Açık Rızası (Zorunlu)';

  @override
  String get kvkkConsentLocationSubtitle =>
      'Tam konumum paylaşılmaksızın, yakınımdaki hastane taleplerinin listelenmesi amacıyla il/ilçe ve mesafe bilgimin işlenmesini onaylıyorum.';

  @override
  String get kvkkConsentNotificationTitle =>
      'Acil Kan Çağrısı Bildirim Rızası (Zorunlu)';

  @override
  String get kvkkConsentNotificationSubtitle =>
      'Kan grubuma uygun acil kan talepleri ve eşleşme durumları hakkında anlık bildirim gönderilmesini kabul ediyorum.';

  @override
  String get kvkkReadPrivacyPolicy => 'Gizlilik Politikası Metnini Oku';

  @override
  String get kvkkReadTermsOfUse => 'Kullanım Şartları Metnini Oku';

  @override
  String get kvkkApproveAndContinue => 'Açık Rıza Ver ve Devam Et';

  @override
  String get kvkkAllConsentsRequiredWarning =>
      'Devam edebilmek için lütfen tüm açık rıza kutularını onaylayın.';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası ve KVKK Metni';

  @override
  String get privacyPolicyPlaceholderBody =>
      '1. Veri Sorumlusu ve Amaç:\nTürkiye Kan Ağı, gönüllü kan bağışçıları ile ihtiyaç sahiplerini buluşturmak amacıyla faaliyet gösterir.\n\n2. İşlenen Özel Nitelikli Kişisel Veriler:\nKan grubu, kilo ve bağış geçmişi verileriniz 6698 sayılı KVKK Madde 6 kapsamında yalnızca açık rızanız ile işlenir ve Firestore güvenlik kurallarıyla yalnızca sizin hesabınız tarafından okunabilir.\n\n3. Konum ve İletişim Gizliliği:\nBağışçının tam konumu asla kaydedilmez veya paylaşılmaz; yalnızca il ve ilçe bilgisi tutulur. Telefon numaranız sadece \'Yardım edebilirim\' onayı sonrasında karşı tarafla paylaşılır.\n\n4. Veri Sahibi Hakları (Madde 11):\nProfil ekranından tüm verilerinizi JSON formatında indirebilir veya \'Hesabımı Sil\' adımıyla tüm kayıtlarınızı kalıcı olarak silebilirsiniz.';

  @override
  String get termsOfUseTitle => 'Kullanım Şartları';

  @override
  String get termsOfUsePlaceholderBody =>
      '1. Gönüllülük Esası ve Ücretsizlik:\nUygulama içerisinde kan veya kan bileşenlerinin para ya da herhangi bir maddi menfaat karşılığında talep edilmesi veya teklif edilmesi kesinlikle yasaktır.\n\n2. Kızılay ve Resmi Kurumlar:\nBu uygulama Türk Kızılayı\'nın veya Sağlık Bakanlığı\'nın yerine geçmez; yalnızca hastane bazlı acil gönüllü yönlendirmesini kolaylaştırır.\n\n3. Tıbbi Sorumluluk:\nBağış uygunluğu konusundaki nihai karar, kan bağışı merkezindeki yetkili hekim ve sağlık personeline aittir.';

  @override
  String get authLoginTitle => 'Giriş Yap';

  @override
  String get authLoginSubtitle =>
      'Telefon numaranız ile güvenli giriş yapın. Numaranız izniniz olmadan kimseyle paylaşılmaz.';

  @override
  String get authPhoneLabel => 'Telefon Numarası';

  @override
  String get authPhoneHint => '5XX XXX XX XX';

  @override
  String get authPhoneInvalidError =>
      'Lütfen geçerli bir Türkiye cep telefonu numarası girin (5XX XXX XX XX).';

  @override
  String get authSendOtpButton => 'Doğrulama Kodu Gönder';

  @override
  String get authOrDivider => 'veya alternatif giriş';

  @override
  String get authContinueWithGoogle => 'Google ile Giriş Yap';

  @override
  String get authContinueWithApple => 'Apple ile Giriş Yap';

  @override
  String get authOtpTitle => 'SMS Doğrulama';

  @override
  String authOtpSubtitle(String phoneNumber) {
    return '$phoneNumber numarasına gönderilen 6 haneli doğrulama kodunu girin.';
  }

  @override
  String get authOtpCodeLabel => '6 Haneli Doğrulama Kodu';

  @override
  String get authOtpInvalidError =>
      'Lütfen 6 haneli doğrulama kodunu eksiksiz girin.';

  @override
  String get authVerifyOtpButton => 'Doğrula ve Giriş Yap';

  @override
  String authResendCountdown(int seconds) {
    return 'Yeni kod gönder ($seconds sn)';
  }

  @override
  String get authResendNow => 'Kodu Tekrar Gönder';

  @override
  String get wizardTitle => 'Profil Oluşturma Sihirbazı';

  @override
  String get wizardStepIdentity => '1. Kimlik ve Görünürlük';

  @override
  String get wizardStepMedical => '2. Kan Grubu ve Fiziksel Bilgiler';

  @override
  String get wizardStepLocation => '3. İl ve İlçe Seçimi';

  @override
  String get wizardFullNameLabel => 'Ad Soyad';

  @override
  String get wizardFullNameRequiredError =>
      'Lütfen adınızı ve soyadınızı girin.';

  @override
  String get wizardNicknameLabel => 'Takma Ad (İsteğe Bağlı)';

  @override
  String get wizardUseNicknameSwitch =>
      'Listelerde gerçek adım yerine takma adımı göster';

  @override
  String get wizardBirthDateLabel => 'Doğum Tarihi';

  @override
  String get wizardBirthDateSelectButton => 'Doğum Tarihi Seçin';

  @override
  String wizardAgeValidationError(int minAge, int maxAge) {
    return 'Bağışçı yaşı $minAge ile $maxAge arasında olmalıdır (Kızılay ve Sağlık Bakanlığı kuralları).';
  }

  @override
  String get wizardGenderLabel => 'Cinsiyet';

  @override
  String get wizardGenderMale => 'Erkek';

  @override
  String get wizardGenderFemale => 'Kadın';

  @override
  String get wizardGenderUnspecified => 'Belirtmek İstemiyorum';

  @override
  String get wizardWeightLabel => 'Kilo (kg)';

  @override
  String wizardWeightValidationError(int minWeight) {
    return 'Gönüllü kan bağışı için minimum kilo $minWeight kg olmalıdır.';
  }

  @override
  String get wizardBloodTypeLabel => 'Kan Grubunuz';

  @override
  String get wizardBloodTypeUnknownOption => 'Kan grubumu bilmiyorum';

  @override
  String get wizardBloodTypeHowToLearnLink =>
      'Kan grubumu nasıl öğrenebilirim?';

  @override
  String get wizardProvinceLabel => 'İl Seçin (81 İl)';

  @override
  String get wizardDistrictLabel => 'İlçe Seçin';

  @override
  String get wizardLocationRequiredError =>
      'Lütfen il ve ilçe seçiminizi tamamlayın.';

  @override
  String get wizardSearchHint => 'İl veya ilçe ara...';

  @override
  String get wizardCompleteButton => 'Profili Kaydet ve Başla';

  @override
  String get unknownBloodGuideTitle => 'Kan Grubumu Nasıl Öğrenebilirim?';

  @override
  String get unknownBloodGuideIntro =>
      'Kan grubunuzu henüz bilmiyorsanız uygulamayı kullanmaya devam edebilir, öğrendiğinizde profilinizden güncelleyebilirsiniz.';

  @override
  String get unknownBloodGuideStep1Title =>
      '1. Türk Kızılayı Kan Bağışı Noktaları';

  @override
  String get unknownBloodGuideStep1Body =>
      'Size en yakın Kızılay kan bağışı merkezine veya mobil kan bağışı aracına başvurarak ücretsiz kan bağışı ön muayenesinde kan grubunuzu öğrenebilirsiniz.';

  @override
  String get unknownBloodGuideStep2Title =>
      '2. Aile Sağlığı Merkezleri (Aile Hekimliği)';

  @override
  String get unknownBloodGuideStep2Body =>
      'Kayıtlı olduğunuz Aile Hekiminize başvurarak basit bir kan grubu testi (ABO ve Rh tayini) yaptırabilirsiniz.';

  @override
  String get unknownBloodGuideStep3Title => '3. e-Nabız ve Ehliyet Kayıtları';

  @override
  String get unknownBloodGuideStep3Body =>
      'Daha önce hastanede kan tahlili yaptırdıysanız e-Nabız hesabınızdaki \'Tahlillerim\' bölümünden veya sürücü belgesi sağlık raporunuzdan kan grubunuzu kontrol edebilirsiniz.';

  @override
  String get profileAvailableSwitchTitle => 'Bağışa Uygunum';

  @override
  String get profileAvailableSwitchSubtitle =>
      'Açık olduğunda kan grubunuza uygun yakın talepler için bildirim alırsınız.';

  @override
  String get profilePhotoChangeButton => 'Profil Fotoğrafı Seç (İsteğe Bağlı)';

  @override
  String get profileEditButton => 'Profil Bilgilerini Düzenle';

  @override
  String get profileNotificationPrefsButton => 'Bildirim Tercihleri';

  @override
  String get profileThemeTitle => 'Tema Görünümü';

  @override
  String get profileThemeSystem => 'Sistem';

  @override
  String get profileThemeLight => 'Aydınlık';

  @override
  String get profileThemeDark => 'Karanlık';

  @override
  String get profileLanguageTitle => 'Uygulama Dili';

  @override
  String get profileLanguageTr => 'Türkçe';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileExportDataButton => 'Verilerimi İndir (JSON)';

  @override
  String get profileExportDataSuccessTitle => 'Verileriniz Hazır (JSON)';

  @override
  String get profileDeleteAccountButton =>
      'Hesabımı ve Verilerimi Kalıcı Olarak Sil';

  @override
  String get profileDeleteConfirmTitle =>
      'Hesabınızı Silmek İstediğinize Emin Misiniz?';

  @override
  String get profileDeleteConfirmBody =>
      'Bu işlem geri alınamaz. KVKK rıza kayıtlarınız, özel nitelikli sağlık bilgileriniz ve profiliniz Cloud Function aracılığıyla kalıcı olarak silinecektir.';

  @override
  String get profileDeleteConfirmAction => 'Evet, Hesabımı Sil';

  @override
  String get profileSignOutButton => 'Oturumu Kapat';

  @override
  String get notifPrefsTitle => 'Bildirim Tercihleri';

  @override
  String get notifUrgencyTitle => 'Minimum Aciliyet Seviyesi';

  @override
  String get notifUrgencyAll => 'Tüm Talepler';

  @override
  String get notifUrgencyUrgentOnly => 'Yalnızca Acil ve Kritik Talepler';

  @override
  String get notifUrgencyCriticalOnly => 'Yalnızca Kritik (Hayati) Talepler';

  @override
  String get notifRadiusTitle => 'Bildirim Mesafe Yarıçapı';

  @override
  String notifRadiusKm(int km) {
    return '$km km';
  }

  @override
  String get notifQuietHoursTitle => 'Sessiz Saatler';

  @override
  String get notifQuietHoursEnable =>
      'Sessiz saatleri etkinleştir (23:00 - 07:00)';

  @override
  String get notifQuietHoursAllowCritical =>
      'Acil/kritik durumları sessiz saatlerde de bildir';

  @override
  String get notifPrefsSavedMessage => 'Bildirim tercihleriniz kaydedildi.';

  @override
  String get requestCreateTitle => 'Kan Talebi Oluştur';

  @override
  String get requestEditTitle => 'Kan Talebini Düzenle';

  @override
  String get requestStepPatientProduct => '1. Hasta ve Kan Bileşeni';

  @override
  String get requestStepHospitalUrgency => '2. Hastane ve Aciliyet';

  @override
  String get requestStepContactReport => '3. İletişim ve Belge';

  @override
  String get requestPatientInitialsLabel =>
      'Hasta Adı Soyadı Baş Harfleri (Örn: A.Y.)';

  @override
  String get requestPatientInitialsHint => 'A.Y.';

  @override
  String get requestPatientInitialsError =>
      'Gizlilik gereği lütfen yalnızca baş harfleri girin (Örn: A.Y.).';

  @override
  String get requestProductTypeLabel => 'Kan Ürünü Tipi';

  @override
  String get productWholeBlood => 'Tam Kan';

  @override
  String get productErythrocyte => 'Eritrosit Süspansiyonu';

  @override
  String get productPlatelet => 'Trombosit (Aferez)';

  @override
  String get productPlasma => 'Taze Donmuş Plazma';

  @override
  String get requestUnitsLabel => 'İhtiyaç Duyulan Ünite Sayısı';

  @override
  String requestUnitsValue(int count) {
    return '$count Ünite';
  }

  @override
  String get requestHospitalSelectLabel => 'Hastane Seçin';

  @override
  String get requestHospitalSearchHint => 'Hastane adı, il veya ilçe ara...';

  @override
  String get requestHospitalRequiredError => 'Lütfen hastaneyi seçin.';

  @override
  String get requestDepartmentLabel =>
      'Servis / Bölüm (Örn: Yoğun Bakım, Hematoloji)';

  @override
  String get requestDepartmentRequiredError =>
      'Lütfen servis veya bölüm bilgisini girin.';

  @override
  String get requestUrgencyLabel => 'Aciliyet Durumu';

  @override
  String get urgencyCritical => 'Acil (Hemen)';

  @override
  String get urgencyToday => 'Bugün';

  @override
  String get urgencyThisWeek => 'Bu Hafta';

  @override
  String get requestContactNameLabel => 'Hasta Yakını Adı / Baş Harfleri';

  @override
  String get requestContactPhoneLabel =>
      'Hasta Yakını Telefonu (Herkese Açık Görünmez)';

  @override
  String get requestNotesLabel => 'Ek Açıklama (Para/Ücret İfadesi Yasaktır)';

  @override
  String get requestMedicalReportButton =>
      'Doktor Raporu / Talep Belgesi Ekle (İsteğe Bağlı)';

  @override
  String get requestMedicalReportAttached =>
      'Doktor raporu eklendi (Yalnızca moderatör ve siz görebilirsiniz)';

  @override
  String get requestProhibitedTextError =>
      'Metinde para, ücret, IBAN veya maddi karşılık içeren yasaklı ifadeler tespit edildi. Gönüllülük esası gereği bu ifadeler kullanılamaz.';

  @override
  String requestLimitActiveError(int maxActive) {
    return 'Aynı anda en fazla $maxActive açık talebiniz olabilir.';
  }

  @override
  String requestLimitDailyError(int maxDaily) {
    return 'Günlük talep oluşturma sınırına ($maxDaily) ulaştınız.';
  }

  @override
  String get requestSubmitButton => 'Talebi Yayınla';

  @override
  String get requestSaveChangesButton => 'Değişiklikleri Kaydet';

  @override
  String get requestStatusOpen => 'Açık';

  @override
  String get requestStatusFulfilled => 'Karşılandı';

  @override
  String get requestStatusCancelled => 'İptal Edildi';

  @override
  String get requestStatusExpired => 'Süresi Doldu';

  @override
  String get requestFilterAll => 'Tümü';

  @override
  String get requestFilterBloodGroup => 'Kan Grubu';

  @override
  String get requestFilterProduct => 'Ürün';

  @override
  String get requestFilterUrgency => 'Aciliyet';

  @override
  String get requestFilterProvince => 'İl';

  @override
  String get requestFilterClear => 'Filtreleri Temizle';

  @override
  String get requestLoadMore => 'Daha Fazla Yükle';

  @override
  String get requestDetailTitle => 'Talep Detayı';

  @override
  String requestOfferCountBadge(int count) {
    return '$count gönüllü yardım teklif etti';
  }

  @override
  String get requestShareButton => 'Paylaş';

  @override
  String get requestReportButton => 'Rapor Et';

  @override
  String get requestReportDialogTitle => 'Talebi Rapor Et';

  @override
  String get requestReportReasonHint =>
      'Ücret talebi, yanıltıcı bilgi vb. bildirin...';

  @override
  String get requestReportSubmittedMessage =>
      'Bildiriminiz moderasyon ekibine iletildi.';

  @override
  String get requestOwnerActionsTitle => 'Talep Yönetimi';

  @override
  String get requestMarkFulfilledButton => 'Karşılandı İşaretle';

  @override
  String get requestExtendExpiryButton => 'Süreyi Uzat (+24 Saat)';

  @override
  String get requestCancelButton => 'Talebi İptal Et';

  @override
  String get requestStopNewOffersSwitch =>
      'Yeterli kişi geldi (Yeni teklif almayı kapat)';

  @override
  String get requestShareCardTitle => 'Acil Kan Çağrısı Paylaşım Kartı';

  @override
  String get requestShareCopyTextButton => 'Hazır Metni ve Linki Kopyala';

  @override
  String get requestShareCopiedMessage =>
      'Paylaşım metni ve bağlantı panoya kopyalandı.';

  @override
  String get matchingCanHelpButton => 'Yardım Edebilirim';

  @override
  String matchingCompatibilityIncompatible(
      String donorBlood, String recipientBlood, String product) {
    return 'Kan grubunuz ($donorBlood) bu talep ($recipientBlood $product) ile tıbbi olarak uyumlu görünmüyor.';
  }

  @override
  String get matchingCompatibilityCompatible =>
      'Kan grubunuz bu talep ile uyumludur.';

  @override
  String get matchingSelectTimeSlotTitle =>
      'Tahmini Geliş Saatinizi Seçin (Koordinasyon)';

  @override
  String get matchingTimeSlotNow => 'Hemen (0-1 Saat İçinde)';

  @override
  String get matchingTimeSlotMorning => 'Sabah (09:00 - 12:00)';

  @override
  String get matchingTimeSlotAfternoon => 'Öğleden Sonra (12:00 - 17:00)';

  @override
  String get matchingTimeSlotEvening => 'Akşam (17:00 - 21:00)';

  @override
  String get matchingOfferPending =>
      'Onay Bekleniyor (Talep sahibi onayladığında telefonlar açılır)';

  @override
  String get matchingOfferApproved => 'Onaylandı — Karşılıklı İletişim Açık';

  @override
  String get matchingStepOnTheWay => 'Yoldayım';

  @override
  String get matchingStepArrived => 'Hastaneye Vardım';

  @override
  String get matchingStepDonated => 'Bağışı Yaptım';

  @override
  String get matchingStepConfirmed => 'Bağış Onaylandı (Geçmişe Kaydedildi)';

  @override
  String get matchingQuickMsg1 => 'Yola çıktım, yakında hastanedeyim.';

  @override
  String get matchingQuickMsg2 => 'Kan merkezindeyim, kayıt yaptırıyorum.';

  @override
  String get matchingQuickMsg3 => 'Bağış işlemini tamamladım, geçmiş olsun.';

  @override
  String get matchingCallButton => 'Ara';

  @override
  String get matchingWhatsAppButton => 'WhatsApp';

  @override
  String get matchingOwnerApproveDonorButton =>
      'Bağışçıyı Onayla (İletişimi Aç)';

  @override
  String get matchingOwnerConfirmDonationButton => 'Bağışı Onayla (Tamamlandı)';

  @override
  String get matchingOffersClosedNotice =>
      'Talep sahibi yeterli bağışçıya ulaşıldığını belirttiği için yeni teklif alımı kapatılmıştır.';

  @override
  String get notificationsMarkAllRead => 'Tümünü Okundu İşaretle';

  @override
  String get notificationsFilterUnreadOnly => 'Yalnızca Okunmamışlar';

  @override
  String get donationStatusEligibleNowTitle =>
      'Şu Anda Bağışa Uygun Görünüyorsunuz';

  @override
  String get donationStatusWaitingTitle =>
      'Sonraki Bağış İçin Bekleme Süresindesiniz';

  @override
  String donationCountdownDaysHours(int days, int hours) {
    return 'Kalan süre: $days gün ($hours saat)';
  }

  @override
  String donationNextEligibleDateLabel(String dateText) {
    return 'Sonraki uygun tarih: $dateText';
  }

  @override
  String get donationAutoPausedNotice =>
      'Bekleme süreniz dolana kadar \'Bağışa uygunum\' durumunuz otomatik olarak kapatıldı.';

  @override
  String get donationAutoResumedNotice =>
      'Bekleme süreniz tamamlandığında \'Bağışa uygunum\' durumunuz otomatik olarak açılır.';

  @override
  String get donationReminderToggleTitle =>
      '\'Tekrar bağış yapabilirsin\' bildirimi';

  @override
  String get donationReminderToggleSubtitle =>
      'Bekleme süreniz dolduğunda yerel bildirim gönderilir';

  @override
  String get donationReminderScheduledSnack =>
      'Hatırlatma bildirimi planlandı.';

  @override
  String get donationAddToCalendarButton => 'Takvime Ekle';

  @override
  String get donationCalendarEventTitle =>
      'Kan Bağışı Uygunluk Günü (Türkiye Kan Ağı)';

  @override
  String get donationCalendarEventDesc =>
      'Bekleme süreniz doldu. Kızılay veya kan merkezinde bağış yapabilirsiniz.';

  @override
  String get donationCalendarAddedSnack => 'Takvim etkinliği oluşturuldu.';

  @override
  String get donationReminderNotifTitle => 'Tekrar Bağış Yapabilirsiniz';

  @override
  String get donationReminderNotifBody =>
      'Son bağışınızdan sonraki bekleme süreniz tamamlandı. Uygun hissediyorsanız kan bağışında bulunabilirsiniz.';

  @override
  String get donationAddManualButton => 'Manuel Bağış Ekle';

  @override
  String get donationAddSheetTitle => 'Geçmiş Bağış Kaydı Ekle';

  @override
  String get donationPlaceLabel => 'Bağış Yeri (Kan Merkezi / Hastane)';

  @override
  String get donationPlaceHint => 'Örn: Kızılay Çankaya Kan Bağışı Merkezi';

  @override
  String get donationDateLabel => 'Bağış Tarihi';

  @override
  String get donationSelectDateButton => 'Tarih Seç';

  @override
  String get donationProductTypeLabel => 'Bağışlanan Ürün Tipi';

  @override
  String get donationSourceManualBadge => 'Manuel Kayıt';

  @override
  String get donationSourceRequestBadge => 'Talep Akışı (Onaylı)';

  @override
  String get donationDeleteManualTooltip => 'Manuel bağış kaydını sil';

  @override
  String get donationValidationPlaceRequired =>
      'Lütfen bağış yapılan yeri girin.';

  @override
  String get donationValidationFutureDate =>
      'Gelecek tarihli bağış kaydı eklenemez.';

  @override
  String get donationHistorySectionTitle => 'Bağış Geçmişim';

  @override
  String get donationQuickSurveyButton => 'Uygunluk Ön Kontrol Anketi';

  @override
  String get donationQuickTipsButton => 'Bağış Öncesi ve Sonrası Öneriler';

  @override
  String get donationSurveyTitle => 'Bağışa Uygunluk Ön Kontrol Anketi';

  @override
  String get donationSurveyDisclaimer =>
      'ÖNEMLİ UYARI: Bu anket kesin tıbbi karar vermez, yalnızca ön bilgilendirme amaçlıdır. Karar kan merkezindeki sağlık personelindedir. Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.';

  @override
  String get donationSurveyAnswerYes => 'Evet';

  @override
  String get donationSurveyAnswerNo => 'Hayır';

  @override
  String get donationSurveyAnswerUnsure => 'Emin Değilim';

  @override
  String get donationSurveyEvaluateButton => 'Ön Kontrol Sonucunu Gör';

  @override
  String get donationSurveyIncompleteError => 'Lütfen tüm soruları yanıtlayın.';

  @override
  String get donationSurveyOutcomeEligibleTitle => 'Uygun Görünüyor';

  @override
  String get donationSurveyOutcomeEligibleBody =>
      'Yanıtlarınıza göre belirgin bir engel görünmüyor. Kesin karar kan merkezindeki hekim ve sağlık personelindedir.';

  @override
  String get donationSurveyOutcomeUnsureTitle =>
      'Emin Değilim (Hekime Danışın)';

  @override
  String get donationSurveyOutcomeUnsureBody =>
      'Bazı yanıtlarınız ek değerlendirme gerektiriyor. Kan merkezindeki görevli hekime danışmanız önerilir.';

  @override
  String get donationSurveyOutcomeIneligibleTitle =>
      'Uygun Görünmüyor (Geçici Erteleme Olabilir)';

  @override
  String get donationSurveyOutcomeIneligibleBody =>
      'Yanıtlarınızdan en az biri geçici veya kalıcı erteleme sebebi olabilir. Kesin karar kan merkezindeki sağlık personelindedir.';

  @override
  String get donationSurveySavedSnack =>
      'Ön kontrol sonucunuz özel sağlık verileriniz altına kaydedildi.';

  @override
  String get donationTipsTitle => 'Bağış Öncesi ve Sonrası Öneriler';

  @override
  String get donationTipsMedicalNote =>
      'Bu bilgiler genel rehber niteliğindedir; Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.';

  @override
  String get donationTipsBeforeTitle => 'Bağış Öncesi Öneriler';

  @override
  String get donationTipsBefore1 =>
      'Bağıştan önce bol su için ve hafif, yağsız bir öğün tüketin; aç karnına bağışa gitmeyin.';

  @override
  String get donationTipsBefore2 =>
      'Uykunuzu almış ve dinlenmiş olun; son 24 saatte alkol tüketmeyin.';

  @override
  String get donationTipsBefore3 =>
      'Resmi kimlik belgenizi yanınıza alın ve kullandığınız ilaçları sağlık personeline bildirin.';

  @override
  String get donationTipsAfterTitle => 'Bağış Sonrası Öneriler';

  @override
  String get donationTipsAfter1 =>
      'Bağış sonrasında en az 10-15 dakika dinlenin ve ikram edilen sıvı/gıdaları tüketin.';

  @override
  String get donationTipsAfter2 =>
      'İlk 24 saat boyunca bol sıvı tüketin; bağış yapılan kolunuzla ağır yük kaldırmayın.';

  @override
  String get donationTipsAfter3 =>
      'İlk birkaç saat sigara kullanmayın; baş dönmesi hissederseniz hemen uzanıp ayaklarınızı yükseltin.';

  @override
  String get donationKvkkConsentRequiredTitle =>
      'Sağlık Verisi Açık Rızası Gerekli';

  @override
  String get donationKvkkConsentRequiredBody =>
      'Bağış geçmişi ve sağlık anketi verileriniz KVKK kapsamında özel nitelikli kişisel veridir. Devam etmek için açık rıza vermeniz gerekmektedir.';

  @override
  String get donationKvkkGrantConsentButton => 'Açık Rıza Ver ve Devam Et';

  @override
  String get splashSubtitle => 'Bir damla, bir umut.';

  @override
  String get splashSemantics => 'Türkiye Kan Ağı yükleniyor';

  @override
  String get urgencyCriticalShort => 'ACİL';

  @override
  String get urgencyTodayShort => 'Bugün';

  @override
  String get urgencyThisWeekShort => 'Bu hafta';

  @override
  String get statusOpen => 'Açık';

  @override
  String get statusFulfilled => 'Karşılandı';

  @override
  String get statusCancelled => 'İptal';

  @override
  String get statusExpired => 'Süresi doldu';

  @override
  String get verifiedBadgeLabel => 'Doğrulanmış';

  @override
  String get compatibleBadgeLabel => 'Uyumlusun';

  @override
  String get requestsNoOpenNearYouTitle =>
      'Çevrende açık talep yok, bu iyi haber.';

  @override
  String get requestsNoOpenNearYouSubtitle =>
      'Yeni bir acil kan ihtiyacı oluştuğunda seni hemen bilgilendireceğiz.';

  @override
  String get actionWantBlood => 'Kan İstiyorum';

  @override
  String get actionCanHelp => 'Yardım Edebilirim';

  @override
  String get designGalleryTitle => 'Tasarım Galerisi (Debug)';

  @override
  String get onboardingV2Slide1Title => 'Bir damla, bir umut';

  @override
  String get onboardingV2Slide1Body =>
      'Kan ihtiyacı olanlarla yakınındaki gönüllü bağışçıları hızla buluşturuyoruz.';

  @override
  String get onboardingV2Slide2Title => 'Yakınındaki ihtiyacı gör';

  @override
  String get onboardingV2Slide2Body =>
      'Bulunduğun il ve ilçedeki acil kan taleplerini tek ekranda takip et.';

  @override
  String get onboardingV2Slide3Title => 'Tek dokunuşla yardım et';

  @override
  String get onboardingV2Slide3Body =>
      'Kan grubun uyumluysa tek dokunuşla yardım teklif et ve hastaneye yönlen.';

  @override
  String get onboardingV2Slide4Title => 'Verin güvende';

  @override
  String get onboardingV2Slide4Body =>
      'Telefon numaran ve konumun korunur; yalnızca senin onayınla paylaşılır.';

  @override
  String get onboardingStartButton => 'Başla';

  @override
  String get kvkkSummaryCardTitle => 'Verileriniz Sizin Kontrolünüzde';

  @override
  String get kvkkSummaryCardBody =>
      'Sağlık verileriniz şifreli saklanır, üçüncü kişilerle paylaşılmaz ve istediğiniz an silinebilir.';

  @override
  String get kvkkIlluminationLink => 'Aydınlatma Metni';

  @override
  String get kvkkExplicitConsentLink => 'Açık Rıza Metni';

  @override
  String get kvkkRequiredBadge => 'Zorunlu';

  @override
  String get kvkkOptionalBadge => 'İsteğe Bağlı';

  @override
  String get kvkkContinueButton => 'Devam';

  @override
  String get authSendCodeShort => 'Kod Gönder';

  @override
  String get authOrSimple => 'veya';

  @override
  String get authGoogleShort => 'Google ile devam et';

  @override
  String get authAppleShort => 'Apple ile devam et';

  @override
  String authResendTimer(int seconds) {
    return 'Kodu tekrar gönder ($seconds sn)';
  }

  @override
  String get authOtpWrongCodeError =>
      'Girdiğiniz doğrulama kodu hatalı. Lütfen tekrar deneyin.';

  @override
  String get authOtpVerifiedSuccess => 'Doğrulandı!';

  @override
  String get wizardStep1Title => 'Ad ve Görünürlük';

  @override
  String get wizardStep2Title => 'Kan Grubun';

  @override
  String get wizardStep3Title => 'Kişisel Bilgiler';

  @override
  String get wizardStep4Title => 'İl ve İlçe';

  @override
  String get wizardBloodUnknownCard => 'Bilmiyorum';

  @override
  String get locationPermissionTitle => 'Neden İstiyoruz?';

  @override
  String get locationPermissionSubtitle =>
      'Tam konumun başkalarına asla gösterilmez. Yalnızca sana en yakın hastanedeki acil kan ihtiyaçlarını sıralamak için kullanılır.';

  @override
  String get locationPermissionAllowButton => 'Konumu Aç';

  @override
  String get locationPermissionSkipButton =>
      'Şimdi Değil, il/ilçe ile devam et';

  @override
  String get readyCelebrationTitle => 'Hazırsın!';

  @override
  String get readyCelebrationSubtitle =>
      'Dayanışma ağına hoş geldin. Birlikte hayat kurtarabiliriz.';

  @override
  String get readyCelebrationAction => 'Ana Ekrana Geç';

  @override
  String get donorStatusEligibleCard => 'Bağışa uygunsun';

  @override
  String donorStatusWaitingCard(int days) {
    return 'Sonraki bağışına $days gün var';
  }

  @override
  String get filterMyBloodGroup => 'Benim kan grubum';

  @override
  String get filterNearMe => 'Yakınımda';

  @override
  String get filterDistanceTitle => 'Mesafe';

  @override
  String get filterDistanceAllCity => 'Tüm Şehir';

  @override
  String get filterApplyButton => 'Uygula';

  @override
  String get filterClearButton => 'Temizle';

  @override
  String requestRemainingHours(int hours) {
    return '$hours sa kaldı';
  }

  @override
  String requestRemainingDays(int days) {
    return '$days gün kaldı';
  }

  @override
  String get requestDirectionsButton => 'Yol Tarifi';

  @override
  String get requestTrustSectionTitle => 'Güven ve Doğrulama';

  @override
  String get requestTrustSectionBody =>
      'Bu talep telefon doğrulaması yapılmış kullanıcı tarafından oluşturulmuştur. Para veya ücret talep edilmesi kesinlikle yasaktır.';

  @override
  String get requestClosedBannerFulfilled =>
      'Bu kan talebi karşılanmıştır. Tüm gönüllülere teşekkür ederiz.';

  @override
  String get requestClosedBannerCancelled =>
      'Bu kan talebi talep sahibi tarafından iptal edilmiştir.';

  @override
  String get requestClosedBannerExpired => 'Bu kan talebinin süresi dolmuştur.';

  @override
  String get shareWhatsAppButton => 'WhatsApp\'ta paylaş';

  @override
  String get shareImageButton => 'Görsel olarak paylaş';

  @override
  String get draftSavePromptTitle => 'Taslak kaydedilsin mi?';

  @override
  String get draftSavePromptBody =>
      'Girdiğiniz bilgiler silinmeden taslak olarak saklanabilir.';

  @override
  String get draftKeepButton => 'Taslağı Kaydet';

  @override
  String get draftDiscardButton => 'Sil ve Çık';

  @override
  String get requestPublishedSuccessTitle => 'Talebiniz Yayınlandı';

  @override
  String get requestPublishedSuccessSubtitle =>
      'Yakındaki uyumlu bağışçılara bildirim gönderiliyor. Daha hızlı ulaşmak için paylaşabilirsiniz.';

  @override
  String get canHelpConfirmTitle => 'Yardım Teklifi Gönder';

  @override
  String get canHelpConfirmBody =>
      'Talep sahibine bildirim gidecek, onaylarsa iletişim açılacak.';

  @override
  String get canHelpEligibilityReminder =>
      'Son 24 saatte alkol almadığınızdan, kendinizi iyi hissettiğinizden ve kimliğinizin yanınızda olduğundan emin olun.';

  @override
  String get donorTrackingTitle => 'Bağış Takibi';

  @override
  String get donorStepOffered => 'Teklif gönderildi';

  @override
  String get donorStepApproved => 'Onaylandı';

  @override
  String get donorStepOnWay => 'Yoldayım';

  @override
  String get donorStepArrived => 'Vardım';

  @override
  String get donorStepDonated => 'Bağış yaptım';

  @override
  String get quickMsg15Min => '15 dakikada oradayım';

  @override
  String get quickMsgWhichWard => 'Hangi servis?';

  @override
  String get quickMsgArrivedWhere => 'Geldim, neredesiniz?';

  @override
  String get celebrationTitle => 'Bir hayata dokundun';

  @override
  String get celebrationSubtitle =>
      'Gönüllü desteğin için yürekten teşekkürler.';

  @override
  String get celebrationBadgeEarned => 'Kazanılan Rozet: İlk Umut Damlası';

  @override
  String get thankYouSheetTitle => 'Gönüllüye Teşekkür Gönder';

  @override
  String get thankYouChip1 => 'İyi ki varsınız, çok teşekkür ederiz.';

  @override
  String get thankYouChip2 => 'Desteğiniz bize umut oldu.';

  @override
  String get thankYouChip3 => 'Dualarımız sizinle, sağ olun.';

  @override
  String get thankYouCustomHint => 'Kısa teşekkür mesajınız...';

  @override
  String get thankYouSendButton => 'Teşekkür Gönder';

  @override
  String get notificationsGroupToday => 'Bugün';

  @override
  String get notificationsGroupEarlier => 'Daha önce';

  @override
  String get notificationsMarkAllReadShort => 'Hepsini okundu yap';

  @override
  String get notificationPermissionSheetTitle => 'Acil Çağrıları Kaçırma';

  @override
  String get notificationPermissionSheetBody =>
      'Yalnızca kan grubuna uygun ve yakınındaki acil talepler için bildirim göndeririz.';

  @override
  String get notificationPermissionAllow => 'Bildirimlere İzin Ver';

  @override
  String get notificationPermissionDeniedBanner =>
      'Bildirimler kapalı. Acil çağrıları görmek için ayarlardan açabilirsiniz.';

  @override
  String get notificationOpenSettings => 'Ayarları Aç';

  @override
  String get urgentHeadsUpTitle => 'Yakınında ACİL Uyumlu Talep!';

  @override
  String get urgentHeadsUpAction => 'İncele';

  @override
  String get mapFilterRequests => 'Talepler';

  @override
  String get mapFilterCenters => 'Bağış merkezleri';

  @override
  String get mapFilterMyBlood => 'Kan grubum';

  @override
  String get mapMyLocationTooltip => 'Konumuma git';

  @override
  String get mapToggleList => 'Liste';

  @override
  String get mapToggleMap => 'Harita';

  @override
  String get mapNearbyListTitle => 'Yakındaki Noktalar';

  @override
  String get centerOpenNow => 'Şimdi Açık';

  @override
  String get centerClosedNow => 'Kapalı';

  @override
  String get centerMobileUnitBadge => 'Bugün burada';

  @override
  String get centerMobileUnitTitle => 'Gezici Kan Bağış Aracı';

  @override
  String get mapNoLocationTitle => 'Konum izni kapalı';

  @override
  String get mapNoLocationSubtitle =>
      'Haritada yakınındaki hastaneleri ve bağış merkezlerini görmek için konumu açabilir veya listeyi inceleyebilirsin.';

  @override
  String get mapOpenLocationButton => 'Konumu aç';

  @override
  String get mapViewListButton => 'Listeyi gör';

  @override
  String get directionsSheetTitle => 'Yol Tarifi Uygulaması Seçin';

  @override
  String get directionsGoogleMaps => 'Google Maps';

  @override
  String get directionsYandexNavi => 'Yandex Navigasyon';

  @override
  String get directionsAppleMaps => 'Apple Haritalar';

  @override
  String donationDaysRemaining(int days) {
    return '$days gün kaldı';
  }

  @override
  String get donationEligibleBadge => 'Bağışa uygunsun';

  @override
  String donationLastDate(String date) {
    return 'Son bağış: $date';
  }

  @override
  String get donationLivesSavedTitle => 'Hayat kurtardın';

  @override
  String get donationLivesSavedSubtitle =>
      'Her tam kan bağışı 3 kişiye kadar umut olabilir (Kızılay bilgilendirme notu).';

  @override
  String get donationAmIEligibleTitle => 'Uygun muyum?';

  @override
  String get donationAmIEligibleSubtitle =>
      '1 dakikada hızlı ön kontrol testi yap';

  @override
  String get donationAddButtonShort => 'Bağış Ekle';

  @override
  String get donationEmptyReadyTitle => 'İlk bağışını yapmaya hazır mısın?';

  @override
  String get badgesSectionTitle => 'Rozet Vitrini';

  @override
  String get badgeFirstDrop => 'İlk Damla';

  @override
  String get badgeFirstDropHint => 'İlk gönüllü kan bağışını tamamla';

  @override
  String get badgeRegularHero => 'Düzenli Gönüllü';

  @override
  String get badgeRegularHeroHint => '3 kez düzenli kan bağışı yap';

  @override
  String get badgeEmergencyResponder => 'Acil Hızır';

  @override
  String get badgeEmergencyResponderHint =>
      'Acil bir talebe aynı gün yanıt ver';

  @override
  String get badgeApheresisStar => 'Aferez Yıldızı';

  @override
  String get badgeApheresisStarHint => 'Trombosit/aferez bağışında bulun';

  @override
  String get badgeCommunityBuilder => 'Dayanışma Elçisi';

  @override
  String get badgeCommunityBuilderHint => '3 arkadaşını ağa davet et';

  @override
  String get surveyStaffDecisionNotice =>
      'Karar kan merkezindeki sağlık personelindedir.';

  @override
  String get profileVerifiedPhone => 'Telefon Doğrulandı';

  @override
  String get profileSectionMyInfo => 'Bilgilerim';

  @override
  String get profileSectionNotifPrefs => 'Bildirim tercihleri';

  @override
  String get profileSectionLocationTravel => 'Konum ve seyahat modu';

  @override
  String get profileSectionCommunities => 'Topluluklarım';

  @override
  String get profileSectionInvite => 'Arkadaşını davet et';

  @override
  String get profileSectionAppearance => 'Görünüm';

  @override
  String get profileSectionPrivacyData => 'Gizlilik ve veri';

  @override
  String get profileSectionHelpFaq => 'Yardım ve SSS';

  @override
  String get profileSectionAbout => 'Hakkında';

  @override
  String get travelModeTitle => 'Seyahat Modu';

  @override
  String get travelModeSubtitle =>
      'Farklı bir şehirdeyken geçici olarak o şehrin taleplerini gör';

  @override
  String travelModeActiveBanner(String city, String dateRange) {
    return 'Seyahat Modu Aktif: $city ($dateRange)';
  }

  @override
  String get deleteAccountTypeConfirmHint => 'Onaylamak için SİL yazın';

  @override
  String get deleteAccountTypeConfirmWord => 'SİL';

  @override
  String get communitiesTitle => 'Topluluklar ve Nadir Kan Ağı';

  @override
  String get communityJoinButton => 'Katıl';

  @override
  String get communityLeaveButton => 'Ayrıl';

  @override
  String get rareBloodNetworkTitle => 'Nadir Kan Ağı (Rh Negatif)';

  @override
  String get rareBloodNetworkSubtitle =>
      'Nadir bulunan Rh(-) kan grupları için özel dayanışma ağına katılın.';

  @override
  String get institutionTitle => 'Kurumsal Hesap ve Kampanyalar';

  @override
  String get institutionApplyTab => 'Başvuru';

  @override
  String get institutionCampaignsTab => 'Kampanyalar';

  @override
  String get institutionPendingBanner =>
      'Kurum başvurunuz inceleniyor (Onay Bekliyor)';

  @override
  String get institutionVerifiedBadge => 'Doğrulanmış Kurum';

  @override
  String get campaignJoinButton => 'Katılıyorum';

  @override
  String get bloodMatrixTitle => 'Kan Grupları Uyumluluk Matrisi';

  @override
  String get bloodMatrixCanGiveTo => 'Kime Verebilir?';

  @override
  String get bloodMatrixCanReceiveFrom => 'Kimden Alabilir?';

  @override
  String get faqTitle => 'Sıkça Sorulan Sorular ve Rehber';

  @override
  String get mythsAndFactsTab => 'Efsaneler ve Gerçekler';

  @override
  String get emergencyGuideTitle => 'Kan lazım, ne yapmalıyım?';

  @override
  String get leaderboardTitle => 'Gönüllü Onur Tablosu';

  @override
  String get leaderboardOptInWarning =>
      'Gönüllülük yarış değildir; bu tablo yalnızca motivasyon amaçlıdır ve varsayılan olarak kapalıdır.';

  @override
  String get leaderboardEnableButton => 'Tabloyu Göster';

  @override
  String get inviteTitle => 'Arkadaşını Davet Et';

  @override
  String get inviteSubtitle =>
      'Dayanışma ağını büyüt, daha fazla hayata dokun.';

  @override
  String get inviteCopyLink => 'Davet Linkini Kopyala';

  @override
  String inviteCountLabel(int count) {
    return '$count arkadaşın senin davetinle katıldı';
  }

  @override
  String get aboutTitle => 'Hakkında ve Geri Bildirim';

  @override
  String get feedbackTitle => 'Geri Bildirim Gönder';

  @override
  String get maintenanceTitle => 'Bakım Çalışması';

  @override
  String get maintenanceMessage =>
      'Sistemimiz şu anda kısa süreli bakım çalışmasındadır. Lütfen biraz sonra tekrar deneyin.';

  @override
  String get offlineScreenTitle => 'İnternet Bağlantısı Yok';

  @override
  String get adminTitle => 'Türkiye Kan Ağı — Yönetim Paneli';

  @override
  String get adminLoginTitle => 'Yönetici Girişi';

  @override
  String get adminNavDashboard => 'Pano';

  @override
  String get adminNavReports => 'Raporlar';

  @override
  String get adminNavRequests => 'Talepler';

  @override
  String get adminNavUsers => 'Kullanıcılar';

  @override
  String get adminNavInstitutions => 'Kurumlar';

  @override
  String get adminNavCampaigns => 'Kampanyalar';

  @override
  String get adminNavAuditLog => 'Denetim Kaydı';

  @override
  String get adminNavSettings => 'Ayarlar';

  @override
  String get adminStatOpenRequests => 'Açık Talep';

  @override
  String get adminStatFulfillmentRate => 'Karşılanma Oranı';

  @override
  String get adminStatPendingReports => 'Bekleyen Rapor';

  @override
  String get adminStatNewUsers => 'Yeni Kullanıcı';

  @override
  String get adminApproveAction => 'Onayla';

  @override
  String get adminRejectAction => 'Reddet';

  @override
  String get adminRestrictAction => 'Kısıtla';
}
