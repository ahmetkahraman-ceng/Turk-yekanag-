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
}
