# Apple App Store Yayınlama ve Gelir Elde Etme Rehberi (Adım Adım)

Bu rehber; daha önce Apple ekosistemine uygulama yüklememiş veya Windows kullanan bir geliştiricinin **WristArcade** uygulamasını sıfırdan Apple App Store'da yayınlaması ve para kazanması için gereken tüm aşamaları anlatır.

---

## 1. Apple Geliştirici Hesabı Açılışı (Apple Developer Program)

Apple Watch uygulamalarını App Store'da satabilmek için Apple Developer Program üyesi olmanız gerekir.

1. **Gereksinimler**:
   - Bir Apple ID (İki faktörlü kimlik doğrulaması açık olmalı).
   - Yıllık üyelik ücreti: **$99/yıl** (Apple tarafından doğrudan tahsil edilir).
2. **Bireysel (Individual) vs. Kurumsal (Company / Organization)**:
   - **Bireysel Hesap**: Şirket kurmanıza gerek yoktur. Kendi adınız ve soyadınızla hemen açabilirsiniz. Pasaport veya kimlik doğrulama yeterlidir.
   - **Kurumsal Hesap**: Şirket adı altında yayınlamak isterseniz, şirketiniz için ücretsiz bir **D-U-N-S Numarası** (Dun & Bradstreet) almanız gerekir.
3. **Başvuru Adresi**: [developer.apple.com/programs/enroll/](https://developer.apple.com/programs/enroll/)

---

## 2. Windows Üzerinden Derleme ve Yükleme Stratejileri

Apple, watchOS uygulamalarının derlenmesi ve kod imzalanması (Code Signing) için macOS gerektirir. Windows ortamındayken bunu 3 kolay yolla çözebilirsiniz:

### Seçenek A: GitHub Actions (En Pratik & Ücretsiz)
Projemizin içerisine eklediğimiz `.github/workflows/build-watchos.yml` dosyası sayesinde:
1. Kodunuzu özel (private) bir GitHub reposuna yükleyin (`git push`).
2. GitHub'ın ücretsiz sunduğu **macOS sanal makineleri** devreye girer.
3. Xcode otomatik olarak çalışır, `WristArcade` projesini derler ve testleri çalıştırır.
4. Apple App Store Connect API anahtarınızı (API Key) GitHub Secrets'a ekleyerek tek tıkla doğrudan **TestFlight** veya **App Store Connect**'e otomatik yükleme yaptırabilirsiniz (Fastlane entegrasyonu).

### Seçenek B: Kiralık Bulut Mac (MacInCloud / Codemagic)
- Aylık veya saatlik kiralayabileceğiniz bulut Mac'lere Windows Uzak Masaüstü (RDP) ile bağlanabilir, Xcode'u açıp "Archive -> Distribute App" diyerek App Store'a gönderebilirsiniz.

### Seçenek C: Bir Tanıdığın Mac'i
- Projeyi bir flash belleğe veya Git'e atıp herhangi bir Mac'te Xcode ile açın. Apple ID'nizi girip doğrudan "Archive" butonuna basın.

---

## 3. App Store Connect Yapılandırması

Uygulamanızı mağazada listelemek için [appstoreconnect.apple.com](https://appstoreconnect.apple.com) paneline giriş yapın:

1. **Uygulama Oluşturma**:
   - `Apps` sekmesinden `+` -> `New App` seçin.
   - Platform: **watchOS** (veya iOS + watchOS).
   - Name: `WristArcade: 60 Watch Games`
   - Primary Language: `English` (veya Türkçe).
   - Bundle ID: `com.wristarcade.app`
   - SKU: `wristarcade01`
2. **Fiyatlandırma & Bulunabilirlik (Pricing & Availability)**:
   - Fiyat: **Ücretsiz (Free)** (İçerisinde In-App Purchase barındıracağı için indirme ücretsiz seçilir).
3. **Uygulama İçi Satın Alma (In-App Purchase) Tanımlama**:
   - `In-App Purchases` -> `+` -> **Non-Consumable (Tüketilmeyen Ürün)** seçin.
   - Reference Name: `WristArcade Pro All Games Unlock`
   - Product ID: `com.wristarcade.pro_unlock` *(Kodumuzdaki StoreKitManager ile birebir aynı olmalı)*.
   - Price Tier: Tier 3 ($2.99 / veya dilediğiniz tutar).
   - Review Screenshot: Saat ekranındaki Pro kilit ekranının ekran görüntüsünü yükleyin.
4. **Yaş Sınırı (Age Rating)**:
   - Mini oyunlarımız şiddet, kumar, cinsellik veya zararlı içerik barındırmadığı için **4+ (Her Yaş İçin Uygun)** derecesi alır.
5. **Gizlilik Politikası (App Privacy)**:
   - WristArcade hiçbir kullanıcı verisi, konum veya çerez toplamaz (`Data Not Collected`).
   - Apple'ın gizlilik anketinde "We do not collect any data from this app" seçeneğini işaretlemeniz yeterlidir. Bu, Apple onay sürecini inanılmaz hızlandırır!

---

## 4. Ekran Görüntüleri ve Mağaza Varlıkları (Store Assets)

Apple Watch için ekran görüntüleri boyutları:
- **Apple Watch Ultra (49mm)**: 410 x 502 piksel veya 502 x 410 piksel.
- **Apple Watch Series 9/10 (45mm/46mm)**: 396 x 484 piksel.
- **App Icon**: 1024 x 1024 piksel PNG (şeffaflık içermeyen düz arka plan).

Hazırladığımız web simülatöründen tam çözünürlükte ekran görüntüleri yakalayabilir ve App Store'a yükleyebilirsiniz!

---

## 5. Apple İnceleme Kılavuzu Uyumluluğu (Review Guidelines)

Apple inceleme ekibinin (App Review Team) en sık ret verdiği kurallar ve bizim projemizde aldığımız önlemler:

1. **Guideline 4.2 - Minimum Functionality (Yetersiz İşlevsellik)**:
   - *Risk*: Tek bir basit oyun yüklerseniz "Bu uygulama çok basit" diyerek reddedebilirler.
   - *Çözümümüz*: Projemizde 4 farklı kategoride 60 farklı mini oyun (17 Ücretsiz, 43 Pro), CoreMotion Bilek Eğim (Jiroskop) fiziği, Günün Ücretsiz Pro Oyunu (Daily Free Pass), Taptic haptics, Digital Crown desteği, 8-bit sentetik retro ses motoru, 4 ekran teması (Cyberpunk, GameBoy, Amber CRT, OLED), watchOS 10/11 Çift Dokunma jesti (Double Tap), Fitness adım XP ödülleri, Arcade Gauntlet blitz modu, Smart Stack komplikasyonları, Game Center liderlik tablosu, yüksek skor tablosu, günlük görevler ve özelleştirmeler sunduğumuz için zengin içerik onay garantisi sağlar.
2. **Guideline 2.1 - App Completeness (Eksiksizlik)**:
   - Uygulama içinde "Yapım aşamasında" veya çalışmayan buton bulunmamalıdır. Kodlarımız %100 tamamlanmıştır.
3. **Guideline 3.1.1 - In-App Purchase**:
   - Dijital oyun kilidi açma işlemi yalnızca Apple StoreKit aracılığıyla yapılmalıdır. Projemiz en modern **StoreKit 2** ile yazılmıştır.
4. **Guideline 2.3 - Accurate Metadata (Doğru İsimlendirme)**:
   - Açıklamalarda veya başlıkta asla "Tetris", "Wordle", "Pacman" gibi tescilli markaları doğrudan kullanmayın. "Retro Block Crusher", "Classic Snake", "Number Merge Puzzle", "Word Master" gibi jenerik ifadeler kullanın.
