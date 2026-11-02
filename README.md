# Türkiye Kan Ağı (`turkiye_kan_agi`)

Kan ihtiyacı olan kişilerle yakındaki, kan grubu uyumlu gönüllü bağışçıları hızlıca buluşturmayı amaçlayan açık standartlı mobil uygulama.
**Önemli:** Bu uygulama Kızılay'ın yerine geçmez, onu tamamlar. Uygulama içinde para karşılığı kan alım-satımına kesinlikle izin verilmez.

---

## Mimari ve Klasör Yapısı (Feature-First)

```text
lib/
├── core/
│   ├── config/        # Ortam (dev/prod) ve Firebase/Emulator başlatıcıları
│   ├── error/         # Result<T>, AppFailure ve CrashlyticsLogger
│   ├── l10n/          # Yerelleştirme yardımcıları (BuildContext.l10n)
│   ├── network/       # connectivity_plus ile çevrimdışı durum izleme
│   ├── router/        # go_router, Auth Guard, Force Update Guard, 404, MainScaffold
│   ├── services/      # RemoteConfigService ve AppVersionService
│   ├── theme/         # Material 3 aydınlık/karanlık tema, AppColors, AppSpacing, AppTypography
│   ├── utils/         # VersionComparator vb. saf yardımcılar
│   └── widgets/       # PrimaryButton, AppTextField, LoadingSkeleton, EmptyState, ErrorState, OfflineBanner
├── features/
│   ├── splash/        # {data, domain, presentation}
│   ├── force_update/  # {data, domain, presentation}
│   ├── requests/      # {data, domain, presentation}
│   ├── map/           # {data, domain, presentation}
│   ├── donation/      # {data, domain, presentation}
│   ├── notifications/ # {data, domain, presentation}
│   └── profile/       # {data, domain, presentation}
├── l10n/              # app_tr.arb (varsayılan) ve app_en.arb
├── app.dart           # MaterialApp.router kök widget'ı
├── bootstrap.dart     # Ortak başlatma (Firebase + Remote Config + ProviderScope)
├── main_dev.dart      # DEV ortamı giriş noktası
├── main_prod.dart     # PROD ortamı giriş noktası
└── main.dart          # Varsayılan giriş noktası
```

---

## Firebase Kurulumu (Dev & Prod Flavors)

Gizli anahtarlar (API key, App ID vb.) **asla** kaynak koda gömülmez. `.env.dev` ve `.env.prod` dosyaları (`.gitignore` içindedir) üzerinden `--dart-define-from-file` ile enjekte edilir.

### 1. Ön Hazırlık
1. [Firebase Console](https://console.firebase.google.com/) üzerinde iki ayrı proje oluşturun:
   - `turkiye-kan-agi-dev` (Geliştirme ortamı)
   - `turkiye-kan-agi-prod` (Canlı ortam)
2. Firebase CLI ve FlutterFire CLI araçlarını kurun:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   ```

### 2. Ortam Değişkenlerini Yapılandırma
Kök dizindeki `.env.example` dosyasını kopyalayarak `.env.dev` ve `.env.prod` oluşturun:
```bash
cp .env.example .env.dev
cp .env.example .env.prod
```
- **DEV (`tr.org.kanagi.turkiyeKanAgi.dev`)**: `USE_FIREBASE_EMULATOR=true` olarak bırakabilir veya `turkiye-kan-agi-dev` projesinin değerlerini girebilirsiniz.
- **PROD (`tr.org.kanagi.turkiyeKanAgi`)**: `APP_ENV=prod`, `USE_FIREBASE_EMULATOR=false` ve `turkiye-kan-agi-prod` projesinin gerçek anahtarlarını girin.
- Android için `android/app/src/dev/google-services.json` ve `android/app/src/prod/google-services.json`, iOS için `ios/Runner/Firebase/dev/GoogleService-Info.plist` ve `ios/Runner/Firebase/prod/GoogleService-Info.plist` dosyalarını ilgili klasörlere yerleştirin (bu dosyalar `.gitignore` tarafından hariç tutulur).

---

## Firebase Emulator Suite Kullanımı

Proje kök dizininde `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json` ve `storage.rules` hazır olarak yapılandırılmıştır:
- **Auth Emulator**: `9099`
- **Functions Emulator**: `5001`
- **Firestore Emulator**: `8080`
- **Storage Emulator**: `9199`
- **Emulator UI**: `http://127.0.0.1:4000`

### Emülatörü Başlatma
```bash
firebase emulators:start
```

> Android emülatörden bağlanırken `FIREBASE_EMULATOR_HOST=10.0.2.2`, iOS simülatör veya masaüstünden bağlanırken `FIREBASE_EMULATOR_HOST=127.0.0.1` kullanın.

---

## Uygulamayı Çalıştırma

### 1. Paketleri ve Yerelleştirme Dosyalarını Yükleme
```bash
flutter pub get
flutter gen-l10n
```

### 2. DEV Ortamında Çalıştırma (Firebase Emulator ile)
```bash
flutter run -t lib/main_dev.dart --dart-define-from-file=.env.example
```

### 3. PROD Ortamında Çalıştırma
```bash
flutter run -t lib/main_prod.dart --release --dart-define-from-file=.env.prod
```

---

## Kod Analizi ve Testler

```bash
flutter analyze
flutter test
```
