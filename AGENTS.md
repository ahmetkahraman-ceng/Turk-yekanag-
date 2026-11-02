# Türkiye Kan Ağı — Proje Kuralları ve Teknik Şartname

Sen kıdemli bir Flutter/Dart mühendisisin. "Türkiye Kan Ağı" adlı bir mobil uygulama geliştireceğiz.

## Amaç
Kan ihtiyacı olan kişilerle yakındaki, kan grubu uyumlu gönüllü bağışçıları hızlıca buluşturmak. Kızılay'ın yerine geçmez, onu tamamlar. Uygulama içinde para karşılığı kan alım-satımına kesinlikle izin verilmez.

## Teknik yığın
- Flutter (son kararlı sürüm), Dart (null safety), Android + iOS
- State management: Riverpod (riverpod_generator ile)
- Navigasyon: go_router (auth guard'lı, deep link destekli)
- Model: freezed + json_serializable
- Backend: Firebase (Auth, Firestore, Cloud Messaging, Cloud Functions [TypeScript], Storage, Remote Config, Crashlytics, Analytics, App Check)
- Konum: geolocator, geocoding, google_maps_flutter, geoflutterfire_plus (geohash)
- Yerelleştirme: flutter_localizations + intl (arb), varsayılan Türkçe, İngilizce hazır altyapı
- Test: flutter_test, mocktail

## Mimari
- Feature-first klasör yapısı: lib/features/<feature>/{data,domain,presentation}
- lib/core: tema, router, sabitler, yardımcılar, ortak widget'lar, hata yönetimi
- Repository pattern: UI doğrudan Firebase'e erişmez
- Hatalar için Result/AsyncValue tipi kullan, kullanıcıya Türkçe ve anlaşılır hata mesajı göster
- Her dosya tek sorumluluk taşısın, 300 satırı geçmesin

## Kod kuralları
- Tüm kullanıcı metinleri arb dosyalarından gelsin, koda sabit metin gömme
- Renk, boşluk, font için merkezi tema (Material 3). Ana renk kırmızı tonları, yüksek kontrast, büyük okunaklı yazı
- Aydınlık ve karanlık tema
- Erişilebilirlik: Semantics etiketleri, minimum 48dp dokunma alanı
- Her ekranda loading (skeleton), empty, error ve offline durumu olsun
- Gizli anahtarları koda gömme, .env / Firebase config kullan
- Her aşama sonunda: flutter analyze temiz, ilgili testler yazılmış ve geçmiş olsun, ne yaptığını ve nasıl çalıştıracağımı kısaca özetle

## Güvenlik ve yasal kurallar (ihlal edilemez)
- Kan grubu, bağış geçmişi, sağlık anketi cevapları KVKK kapsamında özel nitelikli kişisel veridir: açık rıza olmadan toplanmaz, Firestore güvenlik kurallarıyla sadece sahibi okuyabilir
- Telefon numarası herkese açık gösterilmez. Sadece bağışçı "Yardım edebilirim" deyip taraflar onay verdikten sonra paylaşılır
- Bağışçının tam konumu başkalarına asla gösterilmez, sadece il/ilçe düzeyi tutulur
- Tüm Firestore ve Storage işlemleri güvenlik kurallarıyla korunur, her koleksiyon için kural ve emulator testi yaz
- Hesap silme ve veri indirme özelliği zorunludur
- Tıbbi bilgilerde (bağış aralıkları, uygunluk kuralları) değerleri koda gömme, Remote Config'ten oku ve "Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır" notunu koda yorum olarak ekle

## Çalışma şekli
- Bir aşamada sadece o aşamanın kapsamını yap, sonrakini önden yazma
- Belirsiz bir şey varsa varsayım yap, varsayımı listele
- Önce kısa bir plan (Implementation Plan) çıkar, sonra uygula
