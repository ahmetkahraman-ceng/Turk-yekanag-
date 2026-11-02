# Türkiye Kan Ağı — Uygulama ve Doğrulama Raporu (`RAPOR.md`)

## 1. Yapılan İşler Özeti

### Alt Aşama A: Bağış Takibi ve Sağlık (`lib/features/donation`)
1. **Bağış Geçmişi (Manuel ve Talep Akışından Otomatik Ekleme)**
   - [`DonationRecord`](lib/features/donation/domain/donation_record.dart): Tarih (`donatedAt`), yer (`place`), ürün tipi (`BloodProductType`) ve kaynak (`manual` / `request`) alanlarıyla modellendi.
   - [`FirestoreDonationRepository`](lib/features/donation/data/firestore_donation_repository.dart): Manuel bağış ekleme (gelecek tarih ve boş yer doğrulamasıyla), manuel kaydı silme ve talep akışında onaylanan (`confirmed`) bağışları otomatik kaydetme işlevleri yazıldı.
   - [`FirestoreMatchingRepository`](lib/features/matching/data/firestore_matching_repository.dart) ve [`onDonationOfferUpdated`](functions/src/index.ts): Talep sahibi bağışı onayladığında hem istemci önbelleğine hem de Cloud Function üzerinden `users/{donorUid}/donation_history/{requestId}` koleksiyonuna otomatik kayıt düşülür.
   - [`FirestoreProfileRepository.exportUserDataJson`](lib/features/profile/data/firestore_profile_repository.dart): KVKK "Verilerimi İndir" JSON çıktısına `donationHistory`, `healthSurveys` ve `donationStatus` eklendi.
2. **Sonraki Bağış Tarihi Hesaplama, Geri Sayım ve Otomatik Uygunluk Güncellemesi**
   - [`RemoteConfigService`](lib/core/services/remote_config_service.dart) ve [`DonationIntervalPolicy`](lib/features/donation/domain/donation_interval_policy.dart): Tam kan erkek (`whole_blood_interval_days_male`: 90 gün), tam kan kadın (`whole_blood_interval_days_female`: 120 gün), trombosit/aferez (`apheresis_interval_hours`: 48 saat) ve plazma (`plasma_interval_days`: 14 gün) süreleri Remote Config'ten okunur. Kod içinde *"Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır"* yorumu eklendi.
   - [`NextDonationCalculator`](lib/features/donation/domain/next_donation_calculator.dart): Saf Dart fonksiyonu olarak sonraki uygun bağış tarihini ve kalan gün/saat geri sayımını hesaplar.
   - [`AvailabilityAutoUpdater`](lib/features/donation/domain/donation_availability_state.dart) ve [`DonationAvailabilitySync`](lib/features/donation/data/donation_availability_sync.dart): Bekleme süresindeyken `"Bağışa uygunum"` (`isAvailableToDonate`) anahtarını otomatik kapatır (`autoPaused = true`), süre dolduğunda tekrar açar.
3. **Bağışa Uygunluk Ön Kontrol Anketi (Remote Config / JSON)**
   - [`assets/data/eligibility_survey.json`](assets/data/eligibility_survey.json) ve [`EligibilityQuestionnaireSource`](lib/features/donation/data/eligibility_questionnaire_source.dart): Hastalık, ilaç, dövme/piercing, ameliyat, hamilelik/emzirme, seyahat ve yakın zamanda aşı/diş tedavisi kategorilerinde TR/EN sorular önce Remote Config (`eligibility_survey_json`), boşsa yerel JSON asset üzerinden yüklenir.
   - [`EligibilitySurveyEvaluator`](lib/features/donation/domain/eligibility_survey.dart) ve [`EligibilitySurveyScreen`](lib/features/donation/presentation/eligibility_survey_screen.dart): Sonucu `"Uygun Görünüyor"`, `"Emin Değilim"` veya `"Uygun Görünmüyor"` olarak hesaplar; kesin tıbbi karar vermez ve *"Karar kan merkezindeki sağlık personelindedir"* uyarısını gösterir.
4. **Bağış Öncesi ve Sonrası Öneriler Ekranı**
   - [`DonationTipsScreen`](lib/features/donation/presentation/donation_tips_screen.dart): Bağış öncesi ve sonrası dikkat edilmesi gereken önerileri ve Kızılay/Sağlık Bakanlığı doğrulama notunu içerir.
5. **Hatırlatıcılar (`flutter_local_notifications` ve Takvime Ekleme)**
   - [`LocalNotificationReminderService`](lib/features/donation/data/local_notification_reminder_service.dart): Sonraki uygun bağış tarihinde yerel saatte (`donation_reminder_hour`) *"Tekrar Bağış Yapabilirsiniz"* bildirimi planlar.
   - [`DeviceCalendarExportService`](lib/features/donation/data/local_notification_reminder_service.dart): `add_2_calendar` ile sonraki uygun bağış gününü cihaz takvimine ekler.
6. **KVKK Özel Nitelikli Sağlık Verisi Güvenliği (`firestore.rules` ve Emulator Testleri)**
   - [`firestore.rules`](firestore.rules): `users/{userId}/donation_history` ve `users/{userId}/health_surveys` koleksiyonları yalnızca hesap sahibi (`isOwner(userId)`) tarafından okunabilir; yazma işlemi için `private_data/consents.healthDataConsent == true` açık rıza şartı ve şema doğrulaması zorunludur. İstemci `source == 'request'` kaydı sahteleyemez ve silemez.
   - [`test/firestore_rules/donation_rules_test.js`](test/firestore_rules/donation_rules_test.js): Firestore Emulator üzerinde açık rıza, sahiplik ve talep kaydı bütünlüğü test edildi.

---

## 2. Varsayımlar

1. **Kesilen Kullanıcı Mesajı (A.6 ve Alt Aşama B–E)**:
   - Gönderilen mesaj `6. Bu veriler özel nitelikli sağlık verisidir: Firestore` ifadesinde kesilmiştir; Alt Aşama B, C, D ve E maddeleri mesajda yer almamaktadır.
   - **A.6 için varsayım**: `AGENTS.md` içindeki KVKK ve Firestore güvenlik kuralları maddesi doğrultusunda `donation_history` ve `health_surveys` alt koleksiyonlarının yalnızca sahibi tarafından okunabilmesi, açık rıza (`healthDataConsent == true`) olmadan yazılamaması ve emulator testlerinin yazılması olarak tamamlanmıştır.
   - **Alt Aşama B–E için varsayım**: `AGENTS.md` (*"Bir aşamada sadece o aşamanın kapsamını yap, sonrakini önden yazma"*) kuralı gereği metni bulunmayan B–E alt aşamaları için varsayımsal modül uydurulmamıştır. B–E maddelerinin metni paylaşıldığında kesintisiz olarak uygulanmaya hazırdır.
2. **Ürün Tipi ve Cinsiyete Göre Bekleme Süreleri**:
   - Eritrosit süspansiyonu (`erythrocyte`) bağışı, tam kan (`whole_blood`) ile aynı bekleme süresine tabi tutulmuştur.
   - Kullanıcının cinsiyeti `unspecified` ise ihtiyatlı yaklaşım olarak daha uzun olan kadın tam kan bekleme süresi (varsayılan 120 gün) uygulanır.
   - Geçmişte birden fazla bağış varsa her birinin `donatedAt + beklemeSüresi` değerleri arasından en ileri tarih (`max`) sonraki uygun bağış tarihi olarak kabul edilir.
3. **Otomatik Uygunluk Anahtarı Davranışı**:
   - Kullanıcı `"Bağışa uygunum"` anahtarını kendi isteğiyle kapattıysa (`autoPaused == false`), bekleme süresi dolmuş olsa dahi sistem anahtarı kullanıcı adına zorla açmaz; yalnızca sistemin bekleme süresi nedeniyle otomatik kapattığı (`autoPaused == true`) anahtarlar süre dolunca otomatik açılır.

---

## 3. Test ve Analiz Sonuçları

- **Statik Analiz (`dart analyze --fatal-infos`)**: `No issues found!` (0 hata, 0 uyarı)
- **Birim ve Widget Testleri (`flutter test`)**: Tüm testler (`donation_domain_and_sync_test.dart`, `donation_screens_widget_test.dart` ve önceki aşama testleri dahil) başarılı.
- **Firestore Güvenlik Kuralları Emulator Testleri (`firebase emulators:exec --only firestore "npm --prefix test/firestore_rules test"`)**: 2 suite, 7 test (`firestore_rules_test.js` + `donation_rules_test.js`) tamamı başarılı (`pass 7, fail 0`).

---

## 4. TODO Listesi ve Manuel Yapılması Gereken İşler

### TODO Listesi
- Kullanıcı mesajında kesilen **Alt Aşama B, C, D, E** gereksinim metinleri paylaşıldığında ilgili alt aşamalar uygulanacaktır (mevcut kodda çözülmemiş hata veya yarım bırakılmış TODO bulunmamaktadır).

### Manuel Yapılması Gereken İşler (Canlı Ortam / Prod Hazırlığı)
1. **Firebase Console & Remote Config**:
   - Canlı Firebase projesinde (`turkiye-kan-agi-prod`) Remote Config parametrelerini (`whole_blood_interval_days_male`, `whole_blood_interval_days_female`, `apheresis_interval_hours`, `plasma_interval_days`, `eligibility_survey_json`, `donation_reminder_hour`) Kızılay ve Sağlık Bakanlığı güncel rehberlerine göre doğrulayarak yayınlayın.
2. **Android / iOS Bildirim ve Takvim İzinleri**:
   - Android 13+ için `POST_NOTIFICATIONS` ve iOS için yerel bildirim/takvim izin metinlerini (`Info.plist` içinde `NSCalendarsUsageDescription`) mağaza gönderimi öncesinde doğrulayın.
3. **Cloud Functions & Kuralların Dağıtımı**:
   - `firebase deploy --only firestore:rules,storage:rules,functions` komutu ile güncellenen güvenlik kurallarını ve `onDonationOfferUpdated` fonksiyonunu canlı ortama dağıtın.
