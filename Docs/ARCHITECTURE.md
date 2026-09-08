# WristArcade Teknik Mimari Dokümantasyonu (60 Oyun Elmas Sürümü)

**Platform**: watchOS 9.0+ / watchOS 10+ / watchOS 11+  
**Teknolojiler**: Swift 5.10, SwiftUI, WatchKit, WidgetKit, GameKit, StoreKit 2, AVFoundation, CoreMotion  
**Tasarım Deseni**: Modüler Mini-Oyun Motoru & Single Source of Truth  
**Yerelleştirme**: Çoklu Dil Desteği (Türkçe & İngilizce - Otomatik Telefon/Saat Dili Tespiti)  

---

## 1. Dizin ve Dosya Yapısı

```
d:/projeler/WatchGames/
├── WristArcade/                    # Yerel watchOS Swift/SwiftUI Kaynak Kodları
│   ├── WristArcadeApp.swift        # Uygulama giriş noktası (@main)
│   ├── Info.plist                  # watchOS izinleri ve bağımsız saat modu
│   ├── Package.swift               # Swift Package Manager yapılandırması
│   ├── Assets.xcassets/            # AppIcon ve renk tanımları
│   ├── Core/                       # Çekirdek Sistemler
│   │   ├── LocalizationManager.swift # Türkçe/İngilizce dil motoru ve sistem dili tespiti
│   │   ├── HapticManager.swift     # WKInterfaceDevice Taptic titreşim yöneticisi
│   │   ├── SoundManager.swift      # 8-bit retro arcade ses motoru (AVFoundation)
│   │   ├── ThemeManager.swift      # 4 adet retro ekran teması yöneticisi
│   │   ├── MotionManager.swift     # CoreMotion jiroskop ve ivmeölçer bilek eğim motoru
│   │   ├── FitnessManager.swift    # Günlük hareket & aktivite halkaları XP ödül motoru
│   │   ├── ScoreManager.swift      # UserDefaults tabanlı 60 oyun rekorları, XP ve seviyeler
│   │   ├── StoreKitManager.swift   # StoreKit 2 IAP yöneticisi (17 Free, 43 Pro + Günün Ücretsiz Pro Oyunu)
│   │   ├── GameCenterManager.swift # GameKit küresel liderlik tablosu ve başarımlar
│   │   └── GameProtocol.swift      # 60 oyun veri modeli ve Nasıl Oynanır kılavuzları
│   ├── Views/                      # Arayüz Bileşenleri
│   │   ├── ContentView.swift       # Ana menü, Kategori Filtreleme, 60 oyun seçici, arama, günlük görev
│   │   ├── GameCardView.swift      # Menüdeki oyun kartları, rekorlar ve (i) butonları
│   │   ├── GameInfoSheet.swift     # Açılır "Nasıl Oynanır?" modalı (Amaç, Kontroller, Tüyolar)
│   │   ├── GauntletGameView.swift  # Arcade Gauntlet (5 Aşamalı Hızlı Blitz Maraton Modu)
│   │   ├── PaywallView.swift       # Pro satın alma ekranı ($2.99 tek seferlik)
│   │   ├── SettingsView.swift      # Ayarlar, tema, hareket eğim hassasiyeti, ses ve skor sıfırlama
│   │   ├── TrophyModalView.swift   # Kupa ve başarımlar modalı
│   │   └── StatsModalView.swift    # Oyuncu XP, Seviye, Unvan ve İstatistikler modalı
│   ├── Widgets/                    # watchOS 9/10/11 Smart Stack ve Komplikasyonlar
│   │   └── WristArcadeWidget.swift # AccessoryCircular, AccessoryCorner, AccessoryRectangular
│   ├── Games/                      # 60 Adet Mini Oyun
│   │   ├── Blackjack/BlackjackGameView.swift          # Classic 21 (Kart)
│   │   ├── Poker/VideoPokerGameView.swift            # Video Poker (5-Kart Jacks+)
│   │   ├── Solitaire/MicroSolitaireGameView.swift    # Micro Solitaire (Golf Kart)
│   │   ├── CardWar/CardWarGameView.swift              # Card War (Kart Savaşı)
│   │   ├── CardPairs/CardPairsGameView.swift          # Card Pairs Match (Hafıza Kartı)
│   │   ├── HighLow/HighLowGameView.swift              # High-Low Streak (Kart)
│   │   ├── Dice/LuckyDiceGameView.swift              # Lucky Dice (3'lü Zar & Düello)
│   │   ├── Roulette/LuckyRouletteGameView.swift      # Lucky Roulette (Rulet Çarkı)
│   │   ├── Baccarat/BaccaratGameView.swift            # Mini Baccarat (Punto Banco)
│   │   ├── TriplePoker/TriplePokerGameView.swift      # Triple Pocket Poker
│   │   ├── Paddle/PaddleGameView.swift                # Crown Paddle (Pong)
│   │   ├── Snake/SnakeGameView.swift                  # Crown Snake
│   │   ├── SafeCracker/SafeCrackerGameView.swift      # Safe Cracker (Crown Haptic Dial)
│   │   ├── CrownRunner/CrownRunnerGameView.swift      # Crown Runner (Infinite Hop)
│   │   ├── SpaceEvade/SpaceEvadeGameView.swift        # Space Evade (Crown Action)
│   │   ├── BrickCrusher/BrickCrusherGameView.swift    # Brick Crusher (Crown Breakout)
│   │   ├── GalaxyDefender/GalaxyDefenderGameView.swift # Galaxy Defender (Crown Taret Lazer)
│   │   ├── Fishing/DeepSeaReelGameView.swift          # Deep Sea Reel (Crown Olta & Balık)
│   │   ├── CrownMaze/CrownMazeGameView.swift          # Crown Maze (Döner Labirent)
│   │   ├── SubDive/SubDiveGameView.swift              # Submarine Depth Dive (Crown Denizaltı)
│   │   ├── AirHockey/AirHockeyGameView.swift          # Neon Air Hockey (Crown/Dokunmatik Hava Hokeyi - Ücretsiz)
│   │   ├── LunarLander/LunarLanderGameView.swift      # Lunar Lander (Yerçekimi & Roket İnişi)
│   │   ├── SpeedNumbers/SpeedNumbersGameView.swift    # Speed Tap 1-9 (Schulte Grid)
│   │   ├── WingFlap/WingFlapGameView.swift            # Wing Flap (Tap to Fly)
│   │   ├── ReflexTap/ReflexTapGameView.swift          # Reflex Speed Test (ms)
│   │   ├── WhackDot/WhackDotGameView.swift            # Whack-A-Dot (3x3 Reflex)
│   │   ├── ColorMemory/ColorMemoryGameView.swift      # Color Sequence Reflex
│   │   ├── MathBlitz/MathBlitzGameView.swift          # Math Blitz (Rapid Mental Math)
│   │   ├── TowerStack/TowerStackerGameView.swift      # Tower Stacker (Kule Kat Çıkma)
│   │   ├── Racing/HighwayRacerGameView.swift          # Highway Racer (Neon Otoyol Kaçışı)
│   │   ├── NeonBeat/NeonBeatGameView.swift            # Neon Beat (Ritim Dokunuşu)
│   │   ├── QuickDraw/QuickDrawGameView.swift          # Quick Draw Duel (Vahşi Batı Refleks)
│   │   ├── Merge2048/Merge2048GameView.swift          # Number Merge 2048
│   │   ├── NumberSlide/NumberSlideGameView.swift      # Number Slide (8-Puzzle)
│   │   ├── WordGuess/WordGuessGameView.swift          # Word Guess (4-Letter Deduction)
│   │   ├── ColorBlocks/ColorBlocksGameView.swift      # Color Blocks (Falling 3-Match)
│   │   ├── Mines/MinesGameView.swift                  # Mine Grid (Compact Sweeper)
│   │   ├── TicTacToe/TicTacToeGameView.swift          # Tic-Tac-Toe Smart AI
│   │   ├── MemoryMatrix/MemoryMatrixGameView.swift    # Memory Matrix (Maymun Testi)
│   │   ├── Archery/BullseyeArcheryGameView.swift      # Bullseye Archery (Rüzgar Fiziği Hedefi)
│   │   ├── PipeConnect/PipeConnectGameView.swift      # Pipe Connect (Akış Döndürme)
│   │   ├── LaserMirror/LaserMirrorGameView.swift      # Laser Mirror (Optik Prizma)
│   │   ├── Pisti/PistiGameView.swift                  # Pişti (Geleneksel Türk Kartı - Ücretsiz)
│   │   ├── Klondike/KlondikeSolitaireGameView.swift  # Klondike Solitaire (7 Sütunlu Klasik Kart)
│   │   ├── MazeMuncher/MazeMuncherGameView.swift      # Maze Muncher (Neon Labirent Yemcisi - Ücretsiz)
│   │   ├── Chess/ChessGameView.swift                  # Mini Chess (5x5 Satranç Yapay Zekası)
│   │   ├── Checkers/CheckersGameView.swift            # Classic Checkers (Dama Yapay Zekası)
│   │   ├── SlidingBlocks/SlidingBlocksGameView.swift  # Sliding Blocks (Kayıcı Blok Kaçış Bulmacası)
│   │   ├── Hangman/HangmanGameView.swift              # Classic Hangman (Adam Asmaca - TR/EN - Ücretsiz)
│   │   ├── Sudoku/MiniSudokuGameView.swift            # Mini Sudoku 4x4 (Mantık Bulmacası)
│   │   ├── NineMenMorris/NineMenMorrisGameView.swift  # Nine Men's Morris (9 Taş / Dokuz Taş)
│   │   ├── SeaBattle/SeaBattleGameView.swift          # Sea Battle (5x5 Radar Torpido Deniz Savaşı)
│   │   ├── Reversi/ReversiGameView.swift              # Reversi / Othello (6x6 Taktik Çevirme YZ)
│   │   ├── WordMaster/WordMasterGameView.swift        # Word Master 5 (5 Harfli Kelime Tahmini - Ücretsiz)
│   │   ├── Darts/PrecisionDartsGameView.swift         # Precision Darts (Crown Hedef & Güç - Ücretsiz)
│   │   ├── MicroCircuit/MicroCircuitGameView.swift    # Micro Circuit (Crown & CoreMotion Eğim Drift Yarışı - Ücretsiz)
│   │   ├── BombDefusal/BombDefusalGameView.swift      # Bomb Defusal (Kablo Kesme Dedüksiyonu)
│   │   ├── Target24/Target24GameView.swift            # 24 Solver (4 Rakamla 24 Hedefi)
│   │   ├── TableTennis/TableTennisGameView.swift      # Air Tennis (Crown Masa Tenisi & Falso Fiziği)
│   │   └── Duel21/Duel21GameView.swift                # 21 Duel (2 Kişilik Sıralı Blackjack Düellosu)
│   └── Tests/                      # Birim Testler
│       └── WristArcadeTests.swift  # 60 oyun katalog bütünlüğü, 17 free/43 pro ve yerelleştirme testleri
├── Simulator/                      # Windows'ta Canlı Apple Watch Simülatörü
│   ├── index.html                  # Apple Watch Ultra Kasa, Kordon Stilleri, Kategori Filtreleri & Kupalar
│   ├── styles.css                  # Kart tasarımları, kordon temaları, oyun mekanikleri ve watchOS stilleri
│   └── app.js                      # 60 oyunun JavaScript motoru, Gauntlet blitz modu, i18n, Web Audio ve başarılar
├── server.js                       # Sıfır bağımlılıklı yerel HTTP sunucusu (Node.js)
├── package.json                    # npm run dev / npm start yapılandırması
├── start-simulator.bat             # Çift tıklamalı simülatör başlatıcı
├── .github/workflows/              # CI/CD Bulut Derleme
│   └── build-watchos.yml           # Mac olmadan GitHub Actions ile derleme
└── Docs/                           # Kılavuzlar
    ├── APP_STORE_SUBMISSION.md     # App Store yayınlama rehberi
    ├── LEGAL_COMPLIANCE.md         # Telif ve hukuki uyumluluk belgesi
    ├── STORE_LISTING.md            # App Store başlık, açıklama ve anahtar kelimeler
    └── ARCHITECTURE.md             # Teknik mimari dokümanı
```

---

### 2. Kategoriler ve Oyun Dağılımı (4 Kategori = 60 Oyun: 13 Kart, 15 Crown, 11 Hız, 21 Zeka)

| Kategori | Oyun | Kontrol Tipi | Model |
| :--- | :--- | :--- | :--- |
| **🎴 Kart & Masa** | **Classic 21** | Dokunmatik (Hit / Stand) | Ücretsiz |
| **🎴 Kart & Masa** | **Video Poker** | Dokunmatik (5 Kart Draw / Hold) | Pro Kilitli |
| **🎴 Kart & Masa** | **Micro Solitaire** | Dokunmatik (+1 / -1 Kart Temizleme) | Pro Kilitli |
| **🎴 Kart & Masa** | **Card War (Kart Savaşı)** | Dokunmatik (Yüksek Kart / Savaş) | Pro Kilitli |
| **🎴 Kart & Masa** | **Card Pairs** | Dokunmatik (3x4 Izgara Hafıza) | Pro Kilitli |
| **🎴 Kart & Masa** | **High-Low** | Dokunmatik (Yüksek / Düşük Tahmin) | Pro Kilitli |
| **🎴 Kart & Masa** | **Lucky Dice (Zar Düellosu)** | Dokunmatik (3 Zar Atma / Kilitleme) | Pro Kilitli |
| **🎴 Kart & Masa** | **Lucky Roulette (Şanslı Rulet)** | Dokunmatik & Crown Çark Çevirme | Pro Kilitli |
| **🎴 Kart & Masa** | **Mini Baccarat** | Dokunmatik (Player / Banker / Tie) | Pro Kilitli |
| **🎴 Kart & Masa** | **Triple Pocket Poker** | Dokunmatik (3 Cepten En İyiyi Tut) | Pro Kilitli |
| **🎴 Kart & Masa** | **Pişti (Geleneksel Türk Kartı)** | Dokunmatik (Ortaya Kart Atma & Süpürme) | Ücretsiz |
| **🎴 Kart & Masa** | **Klondike Solitaire** | Dokunmatik (7 Sütun & As-Papaz Dizilim) | Pro Kilitli |
| **🎴 Kart & Masa** | **21 Duel (2 Kişilik Blackjack)** | Dokunmatik & Double Tap (Pass & Play) | Pro Kilitli |
| **⌚ Crown Arcades** | **Crown Paddle** | Digital Crown (Döner Tepe ile Raket) | Ücretsiz |
| **⌚ Crown Arcades** | **Crown Snake** | Crown veya 4 Yöne Kaydırma | Ücretsiz |
| **⌚ Crown Arcades** | **Maze Muncher (Neon Labirent)** | Digital Crown & 4 Yöne Kaydırma | Ücretsiz |
| **⌚ Crown Arcades** | **Safe Cracker** | Digital Crown + Titreşimli Şifre Kırma | Pro Kilitli |
| **⌚ Crown Arcades** | **Crown Runner** | Digital Crown / Dokunma ile Zıplama | Pro Kilitli |
| **⌚ Crown Arcades** | **Space Evade** | Digital Crown ile Yıldız & Engel Kaçışı | Pro Kilitli |
| **⌚ Crown Arcades** | **Brick Crusher** | Digital Crown ile Tuğla Kırma | Pro Kilitli |
| **⌚ Crown Arcades** | **Galaxy Defender** | Digital Crown ile Taret Sürüşü + Lazer | Pro Kilitli |
| **⌚ Crown Arcades** | **Deep Sea Reel (Derin Olta)** | Digital Crown ile Balık Çekme & Gerilim | Pro Kilitli |
| **⌚ Crown Arcades** | **Crown Maze (Döner Labirent)** | Digital Crown ile Labirent Dönüşü | Pro Kilitli |
| **⌚ Crown Arcades** | **Sub Dive (Denizaltı)** | Digital Crown ile Derinlik & Torpido | Pro Kilitli |
| **⌚ Crown Arcades** | **Neon Air Hockey** | Crown veya Parmakla Sürükleme Raket & Bot AI | Ücretsiz |
| **⌚ Crown Arcades** | **Lunar Lander** | Crown Hassas İtme, Açı & Ay Yüzeyi İnişi | Pro Kilitli |
| **⌚ Crown Arcades** | **Precision Darts** | Digital Crown ile Açı Nişanı, Güç Barı & Double Tap | Ücretsiz |
| **⌚ Crown Arcades** | **Air Tennis (Masa Tenisi)** | Digital Crown ile Raket Konumu, Falso & Bot AI | Pro Kilitli |
| **⚡ Hız & Refleks** | **Speed Tap 1-9** | Dokunmatik (1'den 9'a Hızlı Sıralama) | Ücretsiz |
| **⚡ Hız & Refleks** | **Wing Flap** | Dokunmatik Kanat Çırpma & Engel Geçişi | Ücretsiz |
| **⚡ Hız & Refleks** | **Tower Stacker** | Dokunmatik (Neon Blok Kule Kat Çıkma) | Ücretsiz |
| **⚡ Hız & Refleks** | **Highway Racer (Otoyol Yarışçısı)** | Crown & Dokunmatik 3 Şerit Trafik Kaçışı | Ücretsiz |
| **⚡ Hız & Refleks** | **Neon Beat (Neon Ritim)** | Dokunmatik İki Şerit Ritim Vuruşu | Ücretsiz |
| **⚡ Hız & Refleks** | **Micro Circuit (Drift Pisti)** | Crown veya CoreMotion Bilek Hareketi Eğim Dümeni | Ücretsiz |
| **⚡ Hız & Refleks** | **Reflex Tap** | Milisaniye Dokunma Reaksiyon Testi | Pro Kilitli |
| **⚡ Hız & Refleks** | **Whack-A-Dot** | 3x3 Izgarada Ani Beliren Hedefler | Pro Kilitli |
| **⚡ Hız & Refleks** | **Color Sequence** | 4 Renkli Sıra Hafızası (Simon Ritim) | Pro Kilitli |
| **⚡ Hız & Refleks** | **Math Blitz** | 3 Saniyede Hızlı Zihin Matematiği (D/Y) | Pro Kilitli |
| **⚡ Hız & Refleks** | **Quick Draw Duel (Kovboy Düello)** | Ani Tepki Vuruşu (<350ms Çekim) | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Number Merge 2048** | 4 Yöne Dokunmatik Kaydırma | Ücretsiz |
| **🧩 Zeka & Strateji** | **Word Master 5** | 6 Denemeli 5 Harfli Kelime Dedüksiyonu (TR/EN) | Ücretsiz |
| **🧩 Zeka & Strateji** | **Number Slide (8-Puzzle)** | 3x3 Rakam Kaydırma Bulmacası | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Word Guess** | 4 Harfli Kelime Dedüksiyonu (5 Hak) | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Color Blocks** | Düşen 3'lü Renkli Blok Eşleştirme | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Mine Grid** | Taktik Mayın Temizleme (Kaz / Bayrak) | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Tic-Tac-Toe** | Smart Minimax AI / 2 Kişilik Mod | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Memory Matrix** | Sayı Ezberleme & Sıralı Dokunma (Chimp Test) | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Bullseye Archery (Hedef Okçuluk)** | Rüzgar Fiziği ve Gerilim Nişan Atışı | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Pipe Connect (Boru Bağlama)** | 3x3 Boru Döndürme & Su Akışı | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Laser Mirror (Lazer Aynası)** | Açılı Prizma Aynaları & Işın Yönlendirme | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Mini Chess (Satranç)** | 5x5 Gardner Taktik Satranç Yapay Zekası | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Classic Checkers (Dama)** | 6x6 Çapraz Atlama & Şah Terfisi | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Sliding Blocks (Blok Kaçış)** | 6x6 Klotski Blok Kaydırma & Çıkış | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Classic Hangman (Adam Asmaca)** | TR/EN Kelime Havuzu & Sanal Klavye | Ücretsiz |
| **🧩 Zeka & Strateji** | **Mini Sudoku 4x4** | 4x4 Satır/Sütun/Kare Çakışmasız Rakam Dizimi | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Nine Men's Morris (9 Taş)** | 24 Düğümlü Vektör Tahta, Değirmen & Taş Kırma YZ | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Sea Battle (Deniz Savaşı)** | 5x5 Radar Taktik Torpido & 3 Savaş Gemisi | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Reversi (Othello)** | 6x6 Taş Çevirme, Köşe Stratejisi & Bot AI | Pro Kilitli |
| **🧩 Zeka & Strateji** | **Bomb Defusal (Bomba İmha)** | Geri Sayım, Seri Numarası & Kablo Dedüksiyonu | Pro Kilitli |
| **🧩 Zeka & Strateji** | **24 Solver (Hedef 24)** | 4 Rakam ve Dört İşlemle 24 Sayısına Ulaşma | Pro Kilitli |

---

## 3. Arayüz & Ekosistem Özellikleri

1. **Kategori Hap Filtreleri:** Menü üzerinden Tümü (60), Kartlar (13), Crown (15), Hız (11) ve Zeka (21) kategorilerine anında filtreleme.
2. **Anlık Arama (Quick Search):** 60 oyun içinde isim, alt başlık ve mekaniğe göre filtreleyebilme.
3. **CoreMotion Bilek Hareketi (Gyroscope / Tilt):** `MotionManager.swift` üzerinden saatin fiziksel eğimini (Pitch & Roll) algılayarak Micro Circuit gibi oyunlarda bileği eğerek yön verme özelliği.
4. **Arcade Gauntlet (5 Aşamalı Blitz Maraton Modu):** Math, Reflex, Whack, Dial ve Turbo modlarından oluşan 3 canlı hızlı maraton ve +250 XP ödülü.
5. **Günün Ücretsiz Pro Oyunu (Daily Free Pro Pass):** Ücretsiz oyuncular her gün deterministik olarak belirlenen 1 Pro oyununa 24 saat boyunca sınırsız erişir.
6. **8-Bit Retro Arcade Ses Motoru:** `SoundManager` (AVFoundation) ve Web Audio sentezleyicisi ile bleep, click, flip, point, victory, game over, laser, torpedo sesleri.
7. **4 Ekran Teması:** Cyberpunk Neon, GameBoy DMG Retro Yeşil, Amber CRT Monitör ve Stealth OLED Siyahı.
8. **watchOS 10/11 Çift Dokunma Desteği (Double Tap):** `.handGestureShortcut(.primaryAction)` ile tek elle parmak şıklatarak oynama (Wing Flap, Blackjack, Precision Darts, 21 Duel).
9. **Fitness & Aktivite XP Görevleri:** Günlük adım hedefine ulaşıldığında +100 XP ödülü (`FitnessManager`).
10. **watchOS Smart Stack & WidgetKit:** AccessoryCircular, AccessoryCorner ve AccessoryRectangular saat kadranı komplikasyonları ile hızlı oyun başlatma ve seri takibi.
11. **Game Center & Küresel Skor Tabloları:** Apple GameKit ile liderlik tablosu ve başarımlar.
12. **Günlük Görev (Daily Quest):** Her gün rastgele seçilen bir oyun hedefi ve ekstra XP ödülü.
13. **XP & Seviye Sistemi:** Oynadıkça kazanılan XP, 7 farklı rütbe derecesi (Acemi'den Efsane'ye).
14. **2 Kişilik Bilek Düellosu (Pass & Play):** Tek saat üzerinde arkadaşla karşılıklı oynanabilen düello modu.
15. **Başarılar & Rozetler (Achievements):** 10 adet kupa ve açılabilir başarı simgesi.
