# 📲 Windows'tan iPhone ve Apple Watch'a Sideloadly ile Yükleme Rehberi

Bu rehber, elinizde bir Mac bilgisayar olmasa dahi Windows bilgisayarınız üzerinden **WristArcade (60 Oyun)** uygulamasını kabloyla doğrudan kendi **iPhone ve Apple Watch** cihazınıza yüklemenizi sağlar.

---

## 🛠️ Genel Çalışma Mantığı

Windows bilgisayarlar tek başına iOS/watchOS kodlarını derleyemez. Ancak formülümüz çok basittir:
1. **GitHub Actions (Buluttaki Ücretsiz Mac):** Kodlarınızı bulutta otomatik olarak derler ve size hazır bir `WristArcade.ipa` dosyası üretir.
2. **Sideloadly (Windows Programı):** İndirdiğiniz bu `.ipa` dosyasını ücretsiz Apple ID'niz ile anında imzalar ve USB kablosuyla iPhone'unuza (ve oradan saatinize) yükler.

---

## 1. Aşama: Bilgisayara Gerekli 2 Ücretsiz Programı Kurma

1. **iTunes for Windows (Apple Sürümü):**
   - Sideloadly'nin iPhone ile USB üzerinden konuşabilmesi için iTunes gereklidir.
   - *Önemli Not:* Microsoft Store sürümü yerine doğrudan Apple'ın kendi yükleyicisini kurun:
   - [iTunes 64-bit Doğrudan İndirme Linki (Apple)](https://www.apple.com/itunes/download/win64)
2. **Sideloadly:**
   - Resmi adresinden Windows için indirin ve kurun:
   - [sideloadly.io](https://sideloadly.io)

---

## 2. Aşama: `WristArcade.ipa` Dosyasını GitHub'dan İndirme (Bulut Mac)

Projenize eklediğimiz `.github/workflows/build-watchos.yml` dosyası sayesinde GitHub sizin yerinize `.ipa` dosyasını otomatik oluşturur:

1. [github.com](https://github.com) adresine girin ve ücretsiz bir hesap açın (zaten varsa giriş yapın).
2. Sağ üstten **`+` -> New repository** deyin. Repoyu **Private (Gizli)** yapabilirsiniz.
3. Proje klasörünüzdeki dosyaları repoya yükleyin:
   - GitHub web arayüzündeki **"uploading an existing file"** butonuna basıp dosyaları sürükleyip bırakabilirsiniz.
4. Reponun üst menüsündeki **"Actions"** sekmesine tıklayın.
5. Soldaki **"Build & Package WristArcade (IPA for Sideloadly)"** iş akışını seçin ve sağdaki **"Run workflow"** butonuna basın.
6. Yaklaşık 2-3 dakika içinde yeşil onay işareti (✅) çıkar.
7. Çalıştırılan işin içine tıklayın; en altta **"Artifacts"** bölümünde **`WristArcade-IPA`** indirme linkini göreceksiniz. Tıklayıp bilgisayarınıza indirin (ZIP olarak iner, içinden `WristArcade.ipa` çıkar).

---

## 3. Aşama: Sideloadly ile Cihaza Yükleme

1. iPhone'unuzu USB kablosu ile Windows bilgisayarınıza bağlayın.
2. Telefonun ekranında **"Bu Bilgisayara Güvenilsin mi?"** uyarısı çıkarsa **"Güven"** deyin ve telefon şifrenizi girin.
3. **Sideloadly** programını açın:
   - **Connected Device:** iPhone'unuzun adı görünmelidir.
   - **Apple account:** Normal (ücretsiz) Apple ID e-postanızı yazın.
   - **IPA:** İndirdiğiniz `WristArcade.ipa` dosyasını Sideloadly penceresine sürükleyip bırakın (veya solundaki büyük IPA simgesine tıklayıp dosyayı seçin).
4. **"Start"** butonuna basın.
   - İlk seferde Apple ID şifrenizi ve telefonunuza gelen 6 haneli iki faktörlü doğrulama kodunu soracaktır (Bu bilgi doğrudan Apple sunucularına sertifika istemek için gider).
5. 1-2 dakika içinde alttaki logda **"Done!"** yazar. Uygulama artık iPhone'unuzdadır!

---

## 4. Aşama: Telefondan ve Saatten Açma (İlk Seferlik Güvenlik İzni)

Apple, dışarıdan yüklenen uygulamalar için tek seferlik şu iki ayarı yapmanızı ister:

1. **Geliştiriciyi Doğrulama (iPhone):**
   - iPhone'da: `Ayarlar -> Genel -> VPN ve Cihaz Yönetimi`
   - Kendi Apple ID'nizi göreceksiniz. Üzerine tıklayıp **"Güven" (Trust)** butonuna basın.
2. **Geliştirici Modunu Açma (iOS 16+ & watchOS 9+):**
   - iPhone'da: `Ayarlar -> Gizlilik ve Güvenlik -> Geliştirici Modu (Developer Mode) -> Açık` yapıp telefonu yeniden başlatın.
   - Apple Watch'ta: Saatin `Ayarlar -> Gizlilik ve Güvenlik -> Geliştirici Modu -> Açık` yapıp saati yeniden başlatın.
3. **Saate Yükleme:**
   - iPhone'daki yerel **"Watch" (Saatim)** uygulamasını açın.
   - En alta kaydırıp **"WristArcade"** yanındaki **"Yükle" (Install)** butonuna basın.

🎉 **Tebrikler!** 60 oyunluk WristArcade artık saatinizde ve telefonunuzda kablosuz olarak çalışıyor!
