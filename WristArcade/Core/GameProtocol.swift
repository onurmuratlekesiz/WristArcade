import SwiftUI

/// Metadata definition for each mini-game in the WristArcade collection.
public struct GameItem: Identifiable, Hashable {
    public let id: String
    public let titleKey: String
    public let subtitleKey: String
    public let systemIcon: String
    public let accentColor: Color
    public let isFreeByDefault: Bool
    public let crownSupported: Bool
    public let categoryKey: String
    
    // Detailed How-To-Play content keys (English & Turkish)
    public let objectiveKeyEn: String
    public let controlsKeyEn: String
    public let tipsKeyEn: String
    
    public let objectiveKeyTr: String
    public let controlsKeyTr: String
    public let tipsKeyTr: String
    
    public init(
        id: String,
        titleKey: String,
        subtitleKey: String,
        systemIcon: String,
        accentColor: Color,
        isFreeByDefault: Bool,
        crownSupported: Bool = true,
        categoryKey: String = "cat_crown",
        objectiveEn: String,
        controlsEn: String,
        tipsEn: String,
        objectiveTr: String,
        controlsTr: String,
        tipsTr: String
    ) {
        self.id = id
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.systemIcon = systemIcon
        self.accentColor = accentColor
        self.isFreeByDefault = isFreeByDefault
        self.crownSupported = crownSupported
        self.categoryKey = categoryKey
        
        self.objectiveKeyEn = objectiveEn
        self.controlsKeyEn = controlsEn
        self.tipsKeyEn = tipsEn
        
        self.objectiveKeyTr = objectiveTr
        self.controlsKeyTr = controlsTr
        self.tipsKeyTr = tipsTr
    }
    
    // Localized computed helpers
    public var localizedTitle: String {
        return LocalizationManager.shared.t(titleKey)
    }
    
    public var localizedSubtitle: String {
        return LocalizationManager.shared.t(subtitleKey)
    }
    
    public var localizedCategory: String {
        return LocalizationManager.shared.t(categoryKey)
    }
    
    public var infoObjective: String {
        return LocalizationManager.shared.isTurkish ? objectiveKeyTr : objectiveKeyEn
    }
    
    public var infoControls: String {
        return LocalizationManager.shared.isTurkish ? controlsKeyTr : controlsKeyEn
    }
    
    public var infoTips: String {
        return LocalizationManager.shared.isTurkish ? tipsKeyTr : tipsKeyEn
    }
}

public enum ArcadeCatalog {
    public static let allGames: [GameItem] = [
        // ==========================================
        // 🎴 CATEGORY 1: CARD GAMES (6 Games)
        // ==========================================
        GameItem(
            id: "blackjack",
            titleKey: "title_blackjack",
            subtitleKey: "sub_blackjack",
            systemIcon: "suit.club.fill",
            accentColor: Color.teal,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Get closer to 21 than the dealer without busting. Aces count as 1 or 11 automatically.",
            controlsEn: "Tap HIT to draw a card, or STAND to hold and let the dealer play.",
            tipsEn: "Dealers must stand on 17. If you have 16 or lower, consider the dealer's face-up card!",
            objectiveTr: "Krupiyeden 21'e daha yakın bir el yapın ama 21'i geçmeyin. Aslar otomatik 1 veya 11 sayılır.",
            controlsTr: "Kart çekmek için HIT, elinizi sabitleyip sırayı krupiyeye vermek için STAND dokunun.",
            tipsTr: "Krupiye 17 veya üzerinde durmak zorundadır. Eliniz 16 ve altındaysa dikkatli oynayın!"
        ),
        GameItem(
            id: "videopoker",
            titleKey: "title_videopoker",
            subtitleKey: "sub_videopoker",
            systemIcon: "suit.diamond.fill",
            accentColor: Color.yellow,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Draw 5 cards, choose which ones to HOLD, then DRAW new cards to form winning poker hands.",
            controlsEn: "Tap cards to toggle HOLD. Tap DRAW to replace unheld cards and evaluate your hand.",
            tipsEn: "Pairs of Jacks or higher qualify for points. Always hold 4 cards to an open-ended straight or flush!",
            objectiveTr: "5 kart çekin, tutmak istediklerinizi HOLD yapın, sonra DRAW ile diğerlerini değiştirip en iyi eli yapın.",
            controlsTr: "Kartlara dokunarak TUT (HOLD) durumuna getirin. Kalanları yenilemek için DRAW butonuna dokunun.",
            tipsTr: "Vale çifti (Jacks) ve üstü puan kazandırır. Dörtlü kent veya renk ihtimalini asla kaçırmayın!"
        ),
        GameItem(
            id: "microsolitaire",
            titleKey: "title_microsolitaire",
            subtitleKey: "sub_microsolitaire",
            systemIcon: "suit.spade.fill",
            accentColor: Color.cyan,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Clear all cards from the table by matching cards that are 1 rank higher or lower (+1 / -1).",
            controlsEn: "Tap any face-up tableau card that is +/- 1 rank of the current waste pile card.",
            tipsEn: "Kings wrap to Aces in Golf Solitaire! Plan 2-3 moves ahead to create long clearing streaks.",
            objectiveTr: "Açık kartın 1 üstü veya 1 altı (+1 / -1) olan kartlara dokunarak masadaki tüm kartları temizleyin.",
            controlsTr: "Masanın ortasındaki kartın 1 sıra büyüğü veya küçüğü olan masa kartına dokunun.",
            tipsTr: "Papazlar ve Aslar birbirine bağlanabilir! Uzun seriler yakalayarak yüksek puan toplayın."
        ),
        GameItem(
            id: "cardwar",
            titleKey: "title_cardwar",
            subtitleKey: "sub_cardwar",
            systemIcon: "shield.lefthalf.filled",
            accentColor: Color.orange,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Classic high-card war against the dealer! Highest card rank wins the round.",
            controlsEn: "Tap BATTLE to draw cards. If tied, WAR begins with 3 burnt cards and double points!",
            tipsEn: "Aces are the highest cards (Rank 14). Win streaks multiply your combo bonuses.",
            objectiveTr: "Krupiyeye karşı klasik yüksek kart savaşı! En yüksek karta sahip olan raundu kazanır.",
            controlsTr: "Kart çekmek için SAVAŞ butonuna dokunun. Beraberlikte 3 kart yakılır ve çift puan verilir!",
            tipsTr: "As en yüksek karttır (Değer: 14). Peş peşe galibiyet serisi puanınızı katlar."
        ),
        GameItem(
            id: "cardpairs",
            titleKey: "title_cardpairs",
            subtitleKey: "sub_cardpairs",
            systemIcon: "square.stack.3d.down.right.fill",
            accentColor: Color.indigo,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Find all 6 matching pairs of cards in the 3x4 grid using the fewest flips possible.",
            controlsEn: "Tap any covered card to flip it over. Flip two matching cards to lock them in.",
            tipsEn: "Memorize card locations even when you miss a pair to solve future turns in single guesses.",
            objectiveTr: "3x4 ızgaradaki 12 kart arasından 6 eşleşen çifti en az hamlede bularak açın.",
            controlsTr: "Kapalı kartlara dokunarak çevirin. Aynı sembol ve renkteki iki kartı eşleştirin.",
            tipsTr: "Eşleşmeyen kartların yerini aklınızda tutun; sonraki hamlelerde ezberiniz hız kazandırır."
        ),
        GameItem(
            id: "highlow",
            titleKey: "title_highlow",
            subtitleKey: "sub_highlow",
            systemIcon: "suit.heart.fill",
            accentColor: Color.red,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Predict whether the next drawn card will be Higher or Lower than the current card.",
            controlsEn: "Tap HIGHER or LOWER buttons. Build long prediction streaks without making a mistake.",
            tipsEn: "Cards range from 2 to Ace (High). If current card is 2 or 3, HIGHER is almost guaranteed!",
            objectiveTr: "Bir sonraki gelecek kartın mevcut karttan daha YÜKSEK mi DÜŞÜK mü olacağını tahmin edin.",
            controlsTr: "YÜKSEK veya DÜŞÜK butonlarına dokunun. Hata yapmadan seri tahmin komboları kurun.",
            tipsTr: "Kartlar 2'den As'a kadardır. Ekranda 2 veya 3 varken YÜKSEK demek neredeyse kesin kazandırır!"
        ),
        GameItem(
            id: "luckydice",
            titleKey: "title_luckydice",
            subtitleKey: "sub_luckydice",
            systemIcon: "dice.fill",
            accentColor: Color.yellow,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Roll 3 dice, tap dice to HOLD desired numbers, then roll again to form poker combos or high totals!",
            controlsEn: "Tap ROLL to shake and throw dice. Tap any die to toggle HOLD. Score matches after 2 rolls.",
            tipsEn: "Triples award 100 bonus points! If you roll a pair, hold them and aim for the 3-of-a-kind jackpot.",
            objectiveTr: "3 zar atın, tutmak istediğiniz zarlara dokunup HOLD yapın, kombinasyonlar (3'lü, Seri) oluşturun!",
            controlsTr: "Zarları atmak için ROLL dokunun. Kilitlemek için zara dokunun. 2 atışta en iyi kombinasyonu yapın.",
            tipsTr: "Aynı 3 rakam (Triples) 100 ekstra puan verir! Çift geldiğinde onları tutup üçlüye oynayın."
        ),
        GameItem(
            id: "luckyroulette",
            titleKey: "title_luckyroulette",
            subtitleKey: "sub_luckyroulette",
            systemIcon: "circle.circle.fill",
            accentColor: Color.red,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Place chips on Red, Black, Even, Odd or Lucky Numbers. Spin the roulette wheel and watch the ball land!",
            controlsEn: "Tap bet options to place $10 chips, then tap SPIN. Digital Crown can also accelerate wheel rotation.",
            tipsEn: "Red/Black bets give almost 50% chance to double your chips! Direct number hits pay out 35 to 1.",
            objectiveTr: "Kırmızı, Siyah, Çift, Tek veya Şanslı Sayılara fiş koyun. Rulet çarkını çevirin ve topun düşüşünü izleyin!",
            controlsTr: "Bahis seçeneğine dokunup 10$ koyun, ardından ÇEVİR'e basın. Crown ile çarka ekstra ivme verin.",
            tipsTr: "Kırmızı/Siyah bahisleri %50'ye yakın şansla 2 kat verir! Tek bir sayıya doğrudan bahis 35 kat kazandırır."
        ),
        GameItem(
            id: "baccarat",
            titleKey: "title_baccarat",
            subtitleKey: "sub_baccarat",
            systemIcon: "suit.club",
            accentColor: Color.teal,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Bet on Player, Banker or Tie. Hand closest to 9 wins according to classic Punto Banco rules.",
            controlsEn: "Select your bet target, choose bet chips, and tap DEAL to receive cards.",
            tipsEn: "Banker bet has the lowest house edge in casino games! Ties pay 8 to 1.",
            objectiveTr: "Oyuncu, Kasa veya Beraberliğe bahis yapın. 9'a en yakın olan el Punto Banco kurallarıyla kazanır.",
            controlsTr: "Bahis hedefinizi seçin, fiş miktarını belirleyin ve DAĞIT'a dokunun.",
            tipsTr: "Kasa (Banker) bahsi istatistiksel olarak en avantajlı seçenektir! Beraberlik 8 kat kazandırır."
        ),
        GameItem(
            id: "triplepoker",
            titleKey: "title_triplepoker",
            subtitleKey: "sub_triplepoker",
            systemIcon: "suit.diamond",
            accentColor: Color.yellow,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Fast-paced 3-card poker showdown vs Dealer! Form a pair, flush, straight, or 3-of-a-kind to win.",
            controlsEn: "Place ANTE, review your 3 cards, and decide to PLAY (Call) or FOLD.",
            tipsEn: "Play any hand with Queen-6-4 or better; fold anything weaker!",
            objectiveTr: "Dağıtıcıya karşı 3 kartlı hızlı poker! Per, kent, renk veya üçlü yaparak dağıtıcıyı alt edin.",
            controlsTr: "ANTE koyun, 3 kartınızı inceleyin ve OYNA veya PAS GEÇ kararı verin.",
            tipsTr: "Kız-6-4 veya daha iyi ellere sahipseniz mutlaka oynayın; altındaki ellerde pas geçin!"
        ),

        // ==========================================
        // ⌚ CATEGORY 2: CROWN ARCADES (10 Games)
        // ==========================================
        GameItem(
            id: "paddle",
            titleKey: "title_paddle",
            subtitleKey: "sub_paddle",
            systemIcon: "circle.grid.cross.fill",
            accentColor: Color.cyan,
            isFreeByDefault: true,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Bounce the ball off the bottom paddle and walls to score points as ball speed ramps up.",
            controlsEn: "Rotate Digital Crown clockwise / counter-clockwise to glide paddle horizontally.",
            tipsEn: "Hitting the ball with the edge of the paddle angles it sharply, making recovery tricky!",
            objectiveTr: "Raket ve duvarlardan topu sektirerek puan kazanın. Top her vuruşta hızlanır.",
            controlsTr: "Raketi yatay hareket ettirmek için Digital Crown'u saat yönünde veya tersine çevirin.",
            tipsTr: "Topu raketin köşeleriyle karşılamak keskin açılar yaratır, topun merkezini hedefleyin!"
        ),
        GameItem(
            id: "snake",
            titleKey: "title_snake",
            subtitleKey: "sub_snake",
            systemIcon: "waveform.path.ecg",
            accentColor: Color.green,
            isFreeByDefault: true,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Guide the snake to eat food dots, grow longer, and survive without hitting walls or your tail.",
            controlsEn: "Rotate Crown to turn Left/Right or swipe across the watch screen.",
            tipsEn: "As you grow longer, hug the outer walls to leave maximum turning space in the center.",
            objectiveTr: "Yılanı yönlendirerek yemleri yiyin, uzayın ve duvarlara veya kuyruğunuza çarpmayın.",
            controlsTr: "Dönüş yapmak için Digital Crown'u çevirin veya ekranda 4 yöne kaydırın.",
            tipsTr: "Yılan uzadıkça duvar kenarlarından dönerek merkezde boş alan bırakmaya çalışın."
        ),
        GameItem(
            id: "safecracker",
            titleKey: "title_safecracker",
            subtitleKey: "sub_safecracker",
            systemIcon: "lock.shield.fill",
            accentColor: Color.yellow,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Crack the 3-digit secret vault combination using physical Taptic Engine dial feedback.",
            controlsEn: "Slowly rotate Digital Crown to spin the dial. Feel the distinct haptic click on the secret number.",
            tipsEn: "The haptic clicks vibrate faster and stronger as you get within +/- 3 digits of the combination!",
            objectiveTr: "Taptic Engine titreşim geri bildirimlerini dinleyerek kasanın 3 haneli şifresini çözün.",
            controlsTr: "Digital Crown'u yavaşça çevirin. Doğru rakama ulaştığınızda kilit tık sesi ve sert titreşim hissedin.",
            tipsTr: "Doğru rakama 3 hane kala titreşimler sıklaşır. Şifreyi bulunca tekeri durdurun!"
        ),
        GameItem(
            id: "crownrunner",
            titleKey: "title_crownrunner",
            subtitleKey: "sub_crownrunner",
            systemIcon: "figure.run",
            accentColor: Color.orange,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Run endlessly, jump over spikes and obstacles, and collect shiny gold coins.",
            controlsEn: "Flick Digital Crown upward or tap the screen to jump into the air.",
            tipsEn: "Time your jumps late so you don't land directly onto a consecutive trailing hazard.",
            objectiveTr: "Sonsuz koşuda engellerin ve sivri tuzakların üzerinden zıplayarak altınları toplayın.",
            controlsTr: "Zıplamak için Digital Crown'u yukarı çevirin veya ekrana dokunun.",
            tipsTr: "Zıplamayı en son anda yapın, böylece art arda gelen engellerin üzerine düşmezsiniz."
        ),
        GameItem(
            id: "spaceevade",
            titleKey: "title_spaceevade",
            subtitleKey: "sub_spaceevade",
            systemIcon: "airplane.departure",
            accentColor: Color.mint,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Pilot your spacecraft through asteroid showers while collecting golden energy stars.",
            controlsEn: "Rotate Digital Crown to smoothly steer your starship left and right across the bottom.",
            tipsEn: "Small, gentle Crown rotations prevent oversteering into sudden incoming meteors.",
            objectiveTr: "Uzay geminizi asteroit yağmurundan korurken altın enerji yıldızlarını toplayın.",
            controlsTr: "Uzay gemisini sağa ve sola kaydırmak için Digital Crown'u akıcı şekilde çevirin.",
            tipsTr: "Ani hareketler yerine küçük dönüşler yapın; böylece ani beliren meteorlardan kaçabilirsiniz."
        ),
        GameItem(
            id: "brickcrusher",
            titleKey: "title_brickcrusher",
            subtitleKey: "sub_brickcrusher",
            systemIcon: "square.split.bottomrightquarter.fill",
            accentColor: Color.pink,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Smash through all multi-colored brick layers using the paddle and energy ball.",
            controlsEn: "Turn Digital Crown to position paddle underneath the descending ball.",
            tipsEn: "Break a tunnel through to the top of the brick ceiling to let the ball bounce automatically!",
            objectiveTr: "Topu raketle sektirerek yukarıdaki tüm renkli tuğla katmanlarını parçalayın.",
            controlsTr: "Aşağı inen topu karşılamak için Digital Crown ile raketi yönlendirin.",
            tipsTr: "Tuğlaların üst tarafına bir delik açabilirseniz, top tavanda sıkışarak onlarca tuğlayı kendiliğinden yıkar!"
        ),
        GameItem(
            id: "galaxydefender",
            titleKey: "title_galaxydefender",
            subtitleKey: "sub_galaxydefender",
            systemIcon: "shield.lefthalf.fill",
            accentColor: Color.mint,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Defend Earth against waves of descending alien invaders! Steer cannon with Crown and fire plasma lasers.",
            controlsEn: "Rotate Digital Crown to steer plasma turret horizontally. Tap screen anywhere to shoot laser beams.",
            tipsEn: "Shoot the red bonus UFO mothership across the top for massive 200-point multipliers!",
            objectiveTr: "Dünyayı uzaylı istilasından koruyun! Digital Crown ile lazer bataryasını yönlendirip ateş edin.",
            controlsTr: "Tareti sağa/sola sürmek için Digital Crown'u çevirin. Ateş etmek için ekrana dokunun.",
            tipsTr: "Üstte beliren kırmızı UFO ana gemisini vurmak 200 ekstra bonus puan kazandırır!"
        ),
        GameItem(
            id: "deepreel",
            titleKey: "title_deepreel",
            subtitleKey: "sub_deepreel",
            systemIcon: "fish.fill",
            accentColor: Color.blue,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Deep sea sport fishing! Cast your line, detect the bite haptic, and rotate Crown to reel in prize fish.",
            controlsEn: "Tap CAST to drop line. When BITE flashes, rotate Crown smoothly. Keep tension in the green zone!",
            tipsEn: "Reeling too fast snaps the line, while reeling too slow lets the fish escape! Balance the tension meter.",
            objectiveTr: "Derin deniz balıkçılığı! Oltayı atın, balık vuruşunu hissedin ve Crown'u çevirerek trofe balıkları çekin.",
            controlsTr: "OLTA AT'a dokunun. VURUŞ uyarısı gelince Crown'u çevirin. Gerilim çubuğunu yeşil bölgede tutun!",
            tipsTr: "Çok hızlı çekerseniz misina kopar, çok yavaş çekerseniz balık kaçar! Gerilim çubuğunu dengede tutun."
        ),
        GameItem(
            id: "crownmaze",
            titleKey: "title_crownmaze",
            subtitleKey: "sub_crownmaze",
            systemIcon: "circle.circle",
            accentColor: Color.cyan,
            isFreeByDefault: true,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Concentric circular labyrinth! Rotate Crown to spin rings, line up gate openings, and guide marble to center.",
            controlsEn: "Rotate Digital Crown to spin the active ring until slot aligns with marble.",
            tipsEn: "Inner rings rotate faster with Crown acceleration! Keep a steady turning pace.",
            objectiveTr: "İç içe dairesel halka labirenti! Crown ile halkaları çevirin, boşlukları hizalayıp bilyeyi merkeze ulaştırın.",
            controlsTr: "Aktif halkayı döndürmek ve bilyeyi bir alt halkaya düşürmek için Digital Crown'u çevirin.",
            tipsTr: "İç halkalar daha hızlı döner! Düşüş anında ani hızlanmalardan kaçınarak sakin çevirin."
        ),
        GameItem(
            id: "subdive",
            titleKey: "title_subdive",
            subtitleKey: "sub_subdive",
            systemIcon: "water.waves",
            accentColor: Color.blue,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Pilot submarine through deep sea trenches! Adjust depth with Crown, avoid sea mines, and collect oxygen bubbles.",
            controlsEn: "Rotate Digital Crown to adjust dive depth vertically.",
            tipsEn: "Oxygen drains continuously; prioritize collecting oxygen bubbles over long distances.",
            objectiveTr: "Okyanus yarığında denizaltı dalışı! Crown ile derinliği ayarlayın, mayınlardan kaçıp oksijen toplayın.",
            controlsTr: "Denizaltını yukarı veya aşağı yönlendirmek için Digital Crown'u çevirin.",
            tipsTr: "Oksijen sürekli tükenir; baloncukları kaçırmamak için derinliği erkenden ayarlayın."
        ),

        // ==========================================
        // ⚡ CATEGORY 3: SPEED & REFLEX (10 Games)
        // ==========================================
        GameItem(
            id: "speednumbers",
            titleKey: "title_speednumbers",
            subtitleKey: "sub_speednumbers",
            systemIcon: "list.number",
            accentColor: Color.cyan,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "Tap numbers from 1 to 9 in strict ascending order as fast as humanly possible! (Schulte Table)",
            controlsEn: "Tap number tiles in order: 1, then 2, 3... up to 9. Wrong taps add a time penalty.",
            tipsEn: "Use peripheral vision to spot numbers 2 and 3 while tapping 1 for lightning-fast clears!",
            objectiveTr: "Karma tablodaki sayıları 1'den 9'a kadar sırasıyla en hızlı şekilde dokunarak tamamlayın!",
            controlsTr: "1, 2, 3... 9 sırasıyla basarak ilerleyin. Yanlış basışta ceza süresi eklenir.",
            tipsTr: "1'e basarken gözünüzle 2 ve 3'ün nerede olduğunu tarayın; rekor kırmak için akıcı olun!"
        ),
        GameItem(
            id: "wingflap",
            titleKey: "title_wingflap",
            subtitleKey: "sub_wingflap",
            systemIcon: "bird.fill",
            accentColor: Color.green,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "Flap your wings to stay airborne and navigate cleanly through neon obstacle pillars.",
            controlsEn: "Tap the watch screen anywhere to give your bird an upward flap burst.",
            tipsEn: "Rhythmic, gentle taps maintain an even cruising altitude better than frantic tapping.",
            objectiveTr: "Kanat çırparak havada kalın ve neon sütunların arasındaki boşluklardan geçin.",
            controlsTr: "Kuşu yukarı doğru zıplatmak için ekranda herhangi bir yere dokunun.",
            tipsTr: "Panikle art arda basmak yerine ritmik ve sakin dokunuşlarla yüksekliği koruyun."
        ),
        GameItem(
            id: "reflextap",
            titleKey: "title_reflextap",
            subtitleKey: "sub_reflextap",
            systemIcon: "bolt.fill",
            accentColor: Color.yellow,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "Wait during the RED preparation state, then tap the millisecond the screen turns GREEN.",
            controlsEn: "Tap anywhere on the screen immediately when it flashes bright GREEN.",
            tipsEn: "Do not tap early during RED or you will receive a false-start penalty!",
            objectiveTr: "Kırmızı bekleme durumunda bekleyin, ekran YEŞİL yandığı milisaniyede dokunun.",
            controlsTr: "Ekran yeşile döndüğü an gecikmeden ekrana tek dokunuş yapın.",
            tipsTr: "Kırmızıdayken erken basarsanız hatalı çıkış cezası alırsınız, gözünüzü yeşile odaklayın!"
        ),
        GameItem(
            id: "whackmole",
            titleKey: "title_whackmole",
            subtitleKey: "sub_whackmole",
            systemIcon: "circle.grid.3x3.fill",
            accentColor: Color.red,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "Tap glowing targets that appear randomly in the 3x3 grid before they fade away.",
            controlsEn: "Tap directly on the illuminated red target circle.",
            tipsEn: "Targets disappear faster as your score climbs. Keep your finger floating close to the screen!",
            objectiveTr: "3x3 ızgarada aniden beliren parlak hedeflere kaybolmadan önce hızlıca vurun.",
            controlsTr: "Yanan kırmızı hedef çemberine doğrudan parmağınızla dokunun.",
            tipsTr: "Skor yükseldikçe hedefler daha hızlı söner. Parmağınızı ekranın hemen üstünde hazır tutun!"
        ),
        GameItem(
            id: "colormemory",
            titleKey: "title_colormemory",
            subtitleKey: "sub_colormemory",
            systemIcon: "sparkles",
            accentColor: Color.purple,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "Memorize the sequence of flashing color quadrants and tones, then repeat it identically.",
            controlsEn: "Tap the Green, Red, Yellow, or Blue quadrants in the exact demonstrated sequence.",
            tipsEn: "Chant the color initials or numbers in your head (e.g. 1-2-1-4) to easily recall sequences past 8!",
            objectiveTr: "Yanıp sönen renk kadranlarının sesli sırasını aklınızda tutun ve aynen tekrarlayın.",
            controlsTr: "Yeşil, Kırmızı, Sarı ve Mavi kadranlara gösterilen sırayla dokunun.",
            tipsTr: "Renkleri zihninizde numaralandırın (örneğin 1-2-1-3); bu yöntemle 10'lu serileri bile geçebilirsiniz."
        ),
        GameItem(
            id: "mathblitz",
            titleKey: "title_mathblitz",
            subtitleKey: "sub_mathblitz",
            systemIcon: "plus.forwardslash.minus",
            accentColor: Color.blue,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "Decide whether the presented arithmetic equation is TRUE or FALSE before 3 seconds expires.",
            controlsEn: "Tap TRUE (Green Checkmark) or FALSE (Red X).",
            tipsEn: "Check the units digit of the answer first — it often reveals false equations instantly!",
            objectiveTr: "3 saniye dolmadan ekrandaki matematik işleminin DOĞRU mu YANLIŞ mı olduğuna karar verin.",
            controlsTr: "DOĞRU (Yeşil Tik) veya YANLIŞ (Kırmızı X) butonuna dokunun.",
            tipsTr: "İşlem sonucunun birler basamağına bakın; çoğunlukla cevabın yanlış olduğunu hemen ele verir!"
        ),
        GameItem(
            id: "towerstack",
            titleKey: "title_towerstack",
            subtitleKey: "sub_towerstack",
            systemIcon: "rectangle.stack.fill",
            accentColor: Color.cyan,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "Stack sliding neon block slabs as high as possible. Misaligned overhangs are sliced off!",
            controlsEn: "Tap screen or flick Crown to drop the moving slab onto the tower. Align perfectly for combo bonuses.",
            tipsEn: "Three perfect placements in a row will expand your platform width back out!",
            objectiveTr: "Sağa sola kayan neon blokları tam üst üste koyarak gökdelen inşa edin. Taşan kısımlar kesilir!",
            controlsTr: "Bloğu sabitlemek için ekrana dokunun. Tam üst üste getirdikçe kombo ses tonu yükselir.",
            tipsTr: "Üst üste 3 mükemmel yerleştirme yaparsanız kesilen platformunuz tekrar genişler!"
        ),
        GameItem(
            id: "highwayracer",
            titleKey: "title_highwayracer",
            subtitleKey: "sub_highwayracer",
            systemIcon: "car.fill",
            accentColor: Color.yellow,
            isFreeByDefault: true,
            crownSupported: true,
            categoryKey: "cat_reflex",
            objectiveEn: "High-speed 3-lane neon highway traffic dodger! Weave between cars, collect nitro boosts, and go the distance.",
            controlsEn: "Rotate Crown or tap Left/Right lanes to switch positions. Tap NITRO when charged for invincible turbo speed.",
            tipsEn: "Near-miss overtaking gives +50 drift bonus points! Watch for blinking tail lights warning of sudden lane shifts.",
            objectiveTr: "3 şeritli neon otoyolda yüksek hızlı araba kaçışı! Araçların arasından sıyrılın, nitroları toplayın ve rekor kırın.",
            controlsTr: "Şerit değiştirmek için Crown'u çevirin veya Sol/Sağ tarafa dokunun. Nitro dolunca turbo hız için dokunun.",
            tipsTr: "Araçların hemen dibinden teğet geçmek +50 drift puanı verir! Şerit değiştirecek araçların sinyallerine dikkat edin."
        ),
        GameItem(
            id: "neonbeat",
            titleKey: "title_neonbeat",
            subtitleKey: "sub_neonbeat",
            systemIcon: "music.note",
            accentColor: Color.cyan,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "Rhythm beat drop! Tap Left or Right lane when falling neon bars hit the target line in perfect sync.",
            controlsEn: "Tap LEFT or RIGHT button as musical notes cross the lower hit line.",
            tipsEn: "Maintain uninterrupted streaks to trigger the 2x, 3x, and 4x combo multipliers!",
            objectiveTr: "Müzikal neon ritim dokunuşu! Kayan notalar hedef çizgisine ulaştığı anda Sol veya Sağ butona basın.",
            controlsTr: "Notalar alt çizgiyi kestiği milisaniyede SOL veya SAĞ butonuna dokunun.",
            tipsTr: "Seriyi bozmadan devam ederek 2x, 3x ve 4x kombo puan çarpanlarını aktif tutun!"
        ),
        GameItem(
            id: "quickdraw",
            titleKey: "title_quickdraw",
            subtitleKey: "sub_quickdraw",
            systemIcon: "bolt.fill",
            accentColor: Color.orange,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_reflex",
            objectiveEn: "High noon western duel! Stare down the outlaw, wait for the DRAW! cue, and tap screen in under 350ms.",
            controlsEn: "Wait through the tense heartbeat cue, tap immediately when DRAW! flashes on screen.",
            tipsEn: "Tapping before the cue results in a false-start penalty! Stay calm and twitch-ready.",
            objectiveTr: "Vahşi batı kovboy düellosu! Hayduta odaklanın, ÇEK! uyarısı geldiğinde 350ms altında dokunun.",
            controlsTr: "Kalp atışı geriliminde bekleyin, ekranda ÇEK! belirdiği an ekrana vurun.",
            tipsTr: "Uyarıdan önce basarsanız erken ateş cezası alırsınız! Sakin olun ve ani refleksi bekleyin."
        ),

        // ==========================================
        // 🧩 CATEGORY 4: PUZZLE & STRATEGY (10 Games)
        // ==========================================
        GameItem(
            id: "merge2048",
            titleKey: "title_merge2048",
            subtitleKey: "sub_merge2048",
            systemIcon: "square.grid.2x2.fill",
            accentColor: Color.orange,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Slide tiles across the 4x4 grid. When two identical numbers collide, they merge into their sum!",
            controlsEn: "Swipe Up, Down, Left, or Right on the screen to slide all active tiles.",
            tipsEn: "Keep your highest value tile locked in a corner (e.g. bottom-right) and build around it.",
            objectiveTr: "4x4 ızgarada sayıları kaydırın. Aynı iki sayı çarpıştığında birleşerek iki katına çıkar!",
            controlsTr: "Tüm taşları kaydırmak için ekranda Yukarı, Aşağı, Sola veya Sağa kaydırın.",
            tipsTr: "En büyük sayınızı her zaman tek bir köşeye (örneğin sağ alt) sabitleyin ve oradan taşmayın."
        ),
        GameItem(
            id: "numberslide",
            titleKey: "title_numberslide",
            subtitleKey: "sub_numberslide",
            systemIcon: "square.grid.3x3.fill",
            accentColor: Color.mint,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Slide numbered tiles (1 to 8) around the empty space to arrange them in sequential order.",
            controlsEn: "Tap any tile adjacent to the blank space to slide it into the empty slot.",
            tipsEn: "Solve row by row! Complete row 1 (1, 2, 3), then solve the remaining two rows systematically.",
            objectiveTr: "Boşluğu kullanarak 1'den 8'e kadar sayıları sırayla dizme klasik 8-puzzle bulmacası.",
            controlsTr: "Boşluğun yanındaki komşu taşa dokunarak boşluğa kaydırın.",
            tipsTr: "Satır satır çözün! Önce ilk satırı (1, 2, 3) tamamlayıp sabitleyin, ardından alt kısmı çözün."
        ),
        GameItem(
            id: "wordguess",
            titleKey: "title_wordguess",
            subtitleKey: "sub_wordguess",
            systemIcon: "character.book.closed.fill",
            accentColor: Color.green,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Deduce the secret 4-letter word within 5 guesses using color-coded feedback.",
            controlsEn: "Tap on-screen letters to type, ENTER to submit guess, DEL to backspace.",
            tipsEn: "Green = letter in correct spot; Yellow = letter in word but wrong spot; Gray = not in word.",
            objectiveTr: "5 deneme hakkı içinde 4 harfli gizli kelimeyi renkli ipuçlarını kullanarak bulun.",
            controlsTr: "Harflere dokunarak yazın, ENTER ile tahmininizi gönderin, DEL ile silin.",
            tipsTr: "Yeşil = harf doğru yerde; Sarı = kelimede var ama yeri yanlış; Gri = harf kelimede yok."
        ),
        GameItem(
            id: "blockfall",
            titleKey: "title_blockfall",
            subtitleKey: "sub_blockfall",
            systemIcon: "square.stack.fill",
            accentColor: Color.pink,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_puzzle",
            objectiveEn: "Stack falling colored blocks to create horizontal, vertical, or diagonal matches of 3 or more.",
            controlsEn: "Rotate Crown to move left/right, tap screen to cycle color order, swipe down to drop.",
            tipsEn: "Set up chain reaction cascades by matching blocks underneath large stacks!",
            objectiveTr: "Düşen renkli blokları yatay, dikey veya çapraz 3'lü eşleştirerek patlatın.",
            controlsTr: "Crown ile sağa/sola hareket edin, renk sırasını değiştirmek için dokunun, kaydırarak düşürün.",
            tipsTr: "Alt katmanları patlatarak üstteki blokların düşüp zincirleme kombo yapmasını sağlayın!"
        ),
        GameItem(
            id: "mines",
            titleKey: "title_mines",
            subtitleKey: "sub_mines",
            systemIcon: "flag.fill",
            accentColor: Color.yellow,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Uncover all safe squares across the 6x6 grid without detonating any hidden mines.",
            controlsEn: "Tap squares in DIG mode to clear them. Switch to FLAG mode to safely mark suspected mines.",
            tipsEn: "Numbers represent how many mines are directly touching that cell (including diagonals).",
            objectiveTr: "6x6 ızgarada gizli mayınları patlatmadan tüm güvenli kareleri açın.",
            controlsTr: "KAZ modunda karelere dokunarak açın. Şüphelendiğiniz mayınları işaretlemek için BAYRAK moduna geçin.",
            tipsTr: "Karelerdeki sayılar o kareye temas eden toplam mayın adedini gösterir."
        ),
        GameItem(
            id: "tictactoe",
            titleKey: "title_tictactoe",
            subtitleKey: "sub_tictactoe",
            systemIcon: "xmark.circle.fill",
            accentColor: Color.teal,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Place 3 of your marks in a horizontal, vertical, or diagonal line to defeat smart AI or a friend.",
            controlsEn: "Tap any empty grid cell to place your X or O symbol.",
            tipsEn: "Claiming the center square on your first turn maximizes your offensive and defensive paths.",
            objectiveTr: "Yapay zekayı veya arkadaşınızı yenmek için 3 sembolünüzü yatay, dikey veya çapraz dizin.",
            controlsTr: "Sembolünüzü (X veya O) yerleştirmek için boş bir kareye dokunun.",
            tipsTr: "İlk hamlede merkez kareyi almak hem hücum hem savunma yollarını açık tutar."
        ),
        GameItem(
            id: "memorymatrix",
            titleKey: "title_memorymatrix",
            subtitleKey: "sub_memorymatrix",
            systemIcon: "brain.head.profile",
            accentColor: Color.indigo,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Famous Chimp Memory Test! Memorize numbered tiles before they hide, then tap them in order (1, 2, 3...).",
            controlsEn: "Study numbers during 1.5s countdown. Once hidden into white tiles, tap them in strict sequence.",
            tipsEn: "Group numbers spatially in your mind (e.g. triangle on left, pair on right) to recall up to 9 tiles!",
            objectiveTr: "Meşhur Maymun Hafıza Testi! Sayılar kapanmadan önce yerlerini ezberleyin, sonra 1-2-3... sırasıyla açın.",
            controlsTr: "1.5 saniye içinde sayıları aklınızda tutun. Beyaz kareye döndüklerinde küçükten büyüğe dokunun.",
            tipsTr: "Sayıları zihninizde geometrik gruplar halinde kodlayın (örneğin sol üçgen, sağ ikili)."
        ),
        GameItem(
            id: "bullseyearchery",
            titleKey: "title_bullseyearchery",
            subtitleKey: "sub_bullseyearchery",
            systemIcon: "scope",
            accentColor: Color.orange,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Master wind physics and draw tension to shoot precision arrows into the dead center of the 10-point bullseye!",
            controlsEn: "Hold screen to draw bow string, compensate crosshair for wind arrow & speed, release finger to loose arrow.",
            tipsEn: "Strong crosswinds blow your arrow sideways! Aim slightly in the opposite direction of the wind indicator.",
            objectiveTr: "Rüzgar fiziğini ve yay gerginliğini hesaplayıp okunuzu hedef tahtasının tam 10 puanlık göbeğine fırlatın!",
            controlsTr: "Yayı germek için ekrana basılı tutun, rüzgar yönüne göre nişangahı kaydırın, fırlatmak için parmağınızı çekin.",
            tipsTr: "Şiddetli rüzgar oku yana savurur! Rüzgar göstergesinin tam tersi yöne hafifçe nişan alarak dengeli atış yapın."
        ),
        GameItem(
            id: "pipeconnect",
            titleKey: "title_pipeconnect",
            subtitleKey: "sub_pipeconnect",
            systemIcon: "point.3.connected.trianglepath.dotted",
            accentColor: Color.cyan,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Connect the water flow! Tap pipe tiles on the 3x3 grid to rotate them and create a continuous pipeline.",
            controlsEn: "Tap any pipe tile to rotate it 90 degrees clockwise.",
            tipsEn: "Start connecting backwards from the exit drain to narrow down valid paths!",
            objectiveTr: "Su akışını bağlayın! 3x3 ızgaradaki boru parçalarına dokunarak döndürün ve kesintisiz hat kurun.",
            controlsTr: "Herhangi bir boru parçasına dokunarak saat yönünde 90 derece döndürün.",
            tipsTr: "Çıkış vanasından geriye doğru döşemeye başlayarak doğru yolu daha kolay bulun!"
        ),
        GameItem(
            id: "lasermirror",
            titleKey: "title_lasermirror",
            subtitleKey: "sub_lasermirror",
            systemIcon: "light.beacon.max.fill",
            accentColor: Color.pink,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Laser optics puzzle! Tap angled prism mirrors to redirect the red laser beam into the power crystal.",
            controlsEn: "Tap angled mirrors to toggle their angle 90 degrees.",
            tipsEn: "Diagonal mirrors deflect light perpendicular to their surface. Trace the beam step by step!",
            objectiveTr: "Lazer optik bulmacası! Aynalara dokunarak kırmızı lazer ışınını güç kristaline saptırın.",
            controlsTr: "Açılı aynalara dokunarak 90 derece yönlerini değiştirin.",
            tipsTr: "Aynalar ışığı tam 90 derece büker. Lazer kaynağını adım adım takip edin!"
        ),
        // ==========================================
        // 🃏 NEW EXPANSION: CARDS, STRATEGY & ARCADE
        // ==========================================
        GameItem(
            id: "pisti",
            titleKey: "title_pisti",
            subtitleKey: "sub_pisti",
            systemIcon: "suit.spade.fill",
            accentColor: Color.red,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Classic Turkish Pisti! Match the middle card rank or play a Jack to sweep the pile. Score a Pisti (+10) on a single card!",
            controlsEn: "Tap any card in your hand to play it into the center pile.",
            tipsEn: "Jacks always capture everything on the board. Save your matching cards for isolated table cards!",
            objectiveTr: "Geleneksel Türk Pişti oyunu! Yerdeki kartın aynısını veya Vale atarak yerdeki desteyi toplayın. Tek karta pişti yapın (+10)!",
            controlsTr: "Elinizdeki kartlara dokunarak ortaya kart atın.",
            tipsTr: "Valeler yerdeki tüm kartları süpürür. Yerde tek kart kaldığında aynı kartı atarak pişti yapın!"
        ),
        GameItem(
            id: "klondikesolitaire",
            titleKey: "title_klondikesolitaire",
            subtitleKey: "sub_klondikesolitaire",
            systemIcon: "suit.diamond.fill",
            accentColor: Color.blue,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "Classic Klondike Solitaire! Build 4 foundation suits from Ace to King. Sequence tableau columns in alternating colors descending.",
            controlsEn: "Tap waste/tableau cards to auto-move to foundations or valid tableau columns.",
            tipsEn: "Expose hidden tableau cards as quickly as possible. Empty column spaces can only take Kings!",
            objectiveTr: "Klasik Klondike Soliter! As'tan Papaz'a 4 ana deste serisini tamamlayın. Masadaki sütunları zıt renklerde azalan dizin.",
            controlsTr: "Kartlara dokunarak uygun yuvaya veya kütüğe otomatik taşıyın.",
            tipsTr: "Kapalı kartları mümkün olduğunca hızlı açın. Boş sütunlara yalnızca Papazlar (K) konulabilir!"
        ),
        GameItem(
            id: "mazemuncher",
            titleKey: "title_mazemuncher",
            subtitleKey: "sub_mazemuncher",
            systemIcon: "circle.circle.fill",
            accentColor: Color.yellow,
            isFreeByDefault: true,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Neon Maze Chomp! Eat all dots in the labyrinth while dodging colorful ghosts. Grab power gems to turn the hunt on them!",
            controlsEn: "Rotate Digital Crown to steer or swipe across the screen in 4 directions.",
            tipsEn: "Power gems make ghosts vulnerable for a short period. Turn around and chomp them for massive bonus points!",
            objectiveTr: "Neon Labirent Yemcisi! Renkli hayaletlerden kaçarak labirentteki tüm yemleri yiyin. Güç mücevherini alıp hayaletleri kovalayın!",
            controlsTr: "Digital Crown'ı çevirerek veya ekranda 4 yöne kaydırarak yön verin.",
            tipsTr: "Güç mücevherini aldığınızda hayaletler kaçmaya başlar. Onları yiyerek devasa bonus puanlar kazanın!"
        ),
        GameItem(
            id: "chess",
            titleKey: "title_chess",
            subtitleKey: "sub_chess",
            systemIcon: "crown.fill",
            accentColor: Color.orange,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Watch Tactical Chess! Outsmart the AI chess engine by capturing the opposing King with tactical maneuvers.",
            controlsEn: "Tap your piece to reveal highlighted valid legal moves, then tap destination square to move.",
            tipsEn: "Control center squares early and guard your King with castling. Watch out for Knight forks!",
            objectiveTr: "Akıllı Saat Satrancı! Taktiksel hamlelerle rakip Şah'ı mat etmek için satranç yapay zekasına karşı hamle yapın.",
            controlsTr: "Taşınıza dokunun, yeşil hedef kareler açılınca gideceğiniz kareye dokunarak hamle yapın.",
            tipsTr: "Merkez kareleri erken kontrol edin ve Şahınızı erken güvenceye alın. At çatallarına dikkat edin!"
        ),
        GameItem(
            id: "checkers",
            titleKey: "title_checkers",
            subtitleKey: "sub_checkers",
            systemIcon: "circle.grid.cross.fill",
            accentColor: Color.teal,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Classic Checkers / Draughts! Jump diagonally over opposing checkers to capture them and crown your pieces as Kings.",
            controlsEn: "Tap a checker piece, then tap an available diagonal target square to advance or jump.",
            tipsEn: "Reach the farthest back row to crown a King! Kings can move and jump both forwards and backwards.",
            objectiveTr: "Klasik Dama! Rakip taşların üzerinden çapraz atlayarak taşları toplayın ve en arkaya ulaşıp Dama olun.",
            controlsTr: "Taşınıza dokunun, beliren hedef kareye dokunarak ilerleyin veya rakip taşı yiyin.",
            tipsTr: "En arka sıraya ulaşan taş Dama olur! Damalar hem ileri hem geri çapraz hareket edebilir ve yiyebilir."
        ),
        GameItem(
            id: "slidingblocks",
            titleKey: "title_slidingblocks",
            subtitleKey: "sub_slidingblocks",
            systemIcon: "rectangle.split.3x3.fill",
            accentColor: Color.purple,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Slide Block Escape! Slide horizontal and vertical wooden blocks to clear a path and guide the golden key block to the exit gate.",
            controlsEn: "Tap and drag blocks along their allowed axis (horizontal blocks move left/right, vertical move up/down).",
            tipsEn: "Work backwards from the exit slot. Clear obstacles blocking the key block's direct lane first!",
            objectiveTr: "Kayıcı Blok Kaçışı! Yatay ve dikey blokları kaydırarak yolu açın ve altın anahtar bloğu çıkış kapısından geçirin.",
            controlsTr: "Bloklara dokunup sürükleyin (yatay bloklar sağ/sol, dikey bloklar yukarı/aşağı kayar).",
            tipsTr: "Çıkış kapısından geriye doğru düşünün. Anahtar bloğun önündeki dikey engelleri kenara çekin!"
        ),
        // ==========================================
        // 🌟 50 GAMES GOLDEN MILESTONE EXPANSION
        // ==========================================
        GameItem(
            id: "airhockey",
            titleKey: "title_airhockey",
            subtitleKey: "sub_airhockey",
            systemIcon: "circle.circle",
            accentColor: Color.cyan,
            isFreeByDefault: true,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Neon Air Hockey! Slide your paddle with Digital Crown or touch to deflect the speeding puck into the opponent's goal.",
            controlsEn: "Rotate Crown or drag finger to slide paddle left/right. First to 5 points wins!",
            tipsEn: "Bank pucks off side walls at sharp angles to slip past the defending bot!",
            objectiveTr: "Neon Hava Hokeyi! Digital Crown veya dokunarak raketinizi kaydırın ve hızlı diski rakip kaleye sokun.",
            controlsTr: "Crown çevirerek veya parmağınızı sürükleyerek raketi kaydırın. 5 puana ilk ulaşan kazanır!",
            tipsTr: "Diski yan duvarlara açılı çarptırarak botun savunmasını hazırlıksız yakalayın!"
        ),
        GameItem(
            id: "hangman",
            titleKey: "title_hangman",
            subtitleKey: "sub_hangman",
            systemIcon: "person.fill.questionmark",
            accentColor: Color.green,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Classic Hangman! Guess the hidden word letter by letter before completing 6 mistaken strokes on the neon gallows.",
            controlsEn: "Tap alphabet keyboard buttons to guess letters.",
            tipsEn: "Start by guessing common vowels (A, E, I, O) to uncover the word framework quickly!",
            objectiveTr: "Klasik Adam Asmaca! 6 hata hakkınızı tüketmeden gizli kelimeyi harf harf tahmin edin.",
            controlsTr: "Harfleri seçmek için ekrandaki klavye tuşlarına dokunun.",
            tipsTr: "Kelimenin iskeletini hızlıca ortaya çıkarmak için önce sesli harflerle başlayın!"
        ),
        GameItem(
            id: "minisudoku",
            titleKey: "title_minisudoku",
            subtitleKey: "sub_minisudoku",
            systemIcon: "grid",
            accentColor: Color.yellow,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Mini Sudoku 4x4! Fill the grid so numbers 1 to 4 appear exactly once in each row, column, and 2x2 box.",
            controlsEn: "Tap an empty cell, then tap numbers 1 to 4 on the keypad below.",
            tipsEn: "Look for rows or 2x2 boxes that only have one missing number first!",
            objectiveTr: "Mini Sudoku 4x4! 1'den 4'e kadar sayıları her satır, sütun ve 2x2 kutuda tek birer kez yerleştirin.",
            controlsTr: "Boş hücreye dokunun, ardından aşağıdaki tuş takımından 1-4 arası sayıyı seçin.",
            tipsTr: "Önce sadece tek bir boşluğu kalan satır veya 2x2 blokları tamamlayın!"
        ),
        GameItem(
            id: "lunarlander",
            titleKey: "title_lunarlander",
            subtitleKey: "sub_lunarlander",
            systemIcon: "airplane.departure",
            accentColor: Color.orange,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Lunar Lander! Pilot lunar module through gravity and touch down smoothly on the landing pad before fuel runs out.",
            controlsEn: "Tap or rotate Crown upwards for thruster burst. Crown downwards/steer left or right.",
            tipsEn: "Keep descent speed under 1.6 m/s just before touchdown to avoid hard crashes!",
            objectiveTr: "Ay Modülü İnişi! Yerçekimine karşı itki vererek yakıtınız bitmeden iniş platformuna yumuşak iniş yapın.",
            controlsTr: "İtki vermek için ekrana dokunun veya Crown çevirin. Yana yönlenmek için sola/sağa kaydırın.",
            tipsTr: "Sert çarpmamak için yere tam temas anında iniş hızınızı 1.6 m/s altında tutun!"
        ),
        GameItem(
            id: "ninemensmorris",
            titleKey: "title_ninemensmorris",
            subtitleKey: "sub_ninemensmorris",
            systemIcon: "circle.grid.3x3.fill",
            accentColor: Color.cyan,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Nine Men's Morris! Form 3-in-a-row mills to capture enemy stones and reduce opponent to 2 pieces.",
            controlsEn: "Phase 1: Tap empty point to place. Phase 2: Tap your stone then adjacent spot to slide. When mill forms, tap enemy stone.",
            tipsEn: "Control the midpoints on the middle square for maximum mobility and double-mill traps!",
            objectiveTr: "9 Taş (Dokuz Taş)! 3'lü değirmen kurarak rakip taşları toplayın ve rakibi 2 taşa düşürün.",
            controlsTr: "1. Aşama: Boş noktaya dokunup koyun. 2. Aşama: Taşınızı seçip komşu noktaya kaydırın. Değirmen olunca rakip taşı seçin.",
            tipsTr: "Orta karenin kenar orta noktalarını tutarak çift değirmen kapanları kurun!"
        ),
        GameItem(
            id: "seabattle",
            titleKey: "title_seabattle",
            subtitleKey: "sub_seabattle",
            systemIcon: "shield.lefthalf.filled",
            accentColor: Color.blue,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Sea Battle Radar! Fire sonar torpedos on a 5x5 grid to locate and sink 3 hidden enemy naval vessels.",
            controlsEn: "Tap an unrevealed grid coordinate to launch torpedo. Red hit indicates ship damage, blue indicates water splash.",
            tipsEn: "Ships cannot overlap! Once you score a hit, target adjacent cells immediately.",
            objectiveTr: "Amiral Battı! 5x5 radar ızgarasında torpido fırlatarak gizlenmiş 3 düşman savaş gemisini batırın.",
            controlsTr: "Ateş etmek için haritada bir kareye dokunun. Kırmızı isabet gemiyi vurur, mavi su sıçratır.",
            tipsTr: "Gemiler üst üste gelemez! İsabet aldıktan sonra hemen komşu kareleri tarayın."
        ),
        GameItem(
            id: "reversi",
            titleKey: "title_reversi",
            subtitleKey: "sub_reversi",
            systemIcon: "circle.lefthalf.filled",
            accentColor: Color.green,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Reversi / Othello! Trap opponent discs between yours to flip them to your color. Most discs on board wins!",
            controlsEn: "Tap any valid highlighted green circle to place your disc and flip opponent line.",
            tipsEn: "Corners can never be flipped! Prioritize securing corner nodes for permanent territorial control.",
            objectiveTr: "Reversi (Othello)! Rakibin taşlarını iki taşınız arasına kıstırarak kendi renginize çevirin. En çok taşı olan kazanır!",
            controlsTr: "Geçerli hamle noktalarını gösteren yeşil halkalara dokunarak taşınızı koyun.",
            tipsTr: "Köşe kareler asla geri çevrilemez! Köşeleri ele geçirmek oyunu kazanmanın altın kuralıdır."
        ),
        GameItem(
            id: "word5",
            titleKey: "title_word5",
            subtitleKey: "sub_word5",
            systemIcon: "character.book.closed.fill",
            accentColor: Color.yellow,
            isFreeByDefault: true,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "5-Letter Word Master! Guess the hidden 5-letter word in 6 tries with dynamic color letter hints.",
            controlsEn: "Tap virtual alphabet keys to type. Green = correct spot, Yellow = in word wrong spot, Gray = not in word.",
            tipsEn: "Start with vowel-rich opener words like 'ARISE' or 'AUDIO' to uncover letter patterns quickly!",
            objectiveTr: "5 Harfli Kelime Ustası! Gizli 5 harfli kelimeyi 6 denemede yeşil/sarı/gri renk ipuçlarıyla çözün.",
            controlsTr: "Harf klavyesine dokunarak kelimeyi yazın. Yeşil = tam yerinde, Sarı = kelimede var ama başka yerde, Gri = yok.",
            tipsTr: "Sesli harf sayısı bol başlangıç kelimeleriyle (ör. RAKET, KAVUN) başlayarak harfleri hızla eleyin!"
        ),
        GameItem(
            id: "darts",
            titleKey: "title_darts",
            subtitleKey: "sub_darts",
            systemIcon: "target",
            accentColor: Color.red,
            isFreeByDefault: true,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Precision Darts! Aim using Digital Crown dial and gauge your throw power to hit Triple 20s and Bullseyes.",
            controlsEn: "Rotate Digital Crown to align dart crosshair angle. Hold & release the THROW button when power meter peaks.",
            tipsEn: "Triple 20 (worth 60 points) scores higher than the 50-point Inner Bullseye!",
            objectiveTr: "Hassas Dart! Digital Crown ile nişan açısını ayarlayın ve güç göstergesini tutturarak hedefi 12'den vurun.",
            controlsTr: "Nişangahı yönlendirmek için Crown'u çevirin. Güç barı dolduğunda FIRLAT butonuna basıp bırakın.",
            tipsTr: "Üçlü 20 bölgesi (60 puan) hedefin tam ortasındaki Kırmızı Merkezden (50 puan) daha değerlidir!"
        ),
        GameItem(
            id: "microcircuit",
            titleKey: "title_microcircuit",
            subtitleKey: "sub_microcircuit",
            systemIcon: "car.fill",
            accentColor: Color.orange,
            isFreeByDefault: true,
            crownSupported: true,
            categoryKey: "cat_reflex",
            objectiveEn: "Micro Circuit! Drift through neon curves and beat the lap record using Crown steering or Wrist Tilt.",
            controlsEn: "Rotate Digital Crown or tilt your wrist to steer. Tap or hold ACCEL to burn rubber!",
            tipsEn: "Start turning slightly before the apex to execute a high-speed powerslide!",
            objectiveTr: "Mikro Pist! Crown tekeri veya bileğinizi eğerek virajları dönün ve en iyi tur rekorunu kırın.",
            controlsTr: "Direksiyonu çevirmek için Crown'u çevirin veya bileğinizi eğin. Hızlanmak için GAZA basın!",
            tipsTr: "Viraja girmeden hafifçe direksiyon kırarak drift çizgisine oturun!"
        ),
        GameItem(
            id: "bombdefusal",
            titleKey: "title_bombdefusal",
            subtitleKey: "sub_bombdefusal",
            systemIcon: "timer",
            accentColor: Color.red,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "Bomb Defusal! Cut the correct colored wire under intense countdown based on tactical logic rules.",
            controlsEn: "Read serial rules and tap the specific wire to cut it. One wrong cut triggers detonation!",
            tipsEn: "If the last serial digit is odd and there is a red wire, the second wire is always safe!",
            objectiveTr: "Bomba İmha! Geri sayan saatte dedüksiyon kurallarına uyarak doğru renkli kabloyu kesin.",
            controlsTr: "Seri numarası kuralını okuyun ve kesmek istediğiniz kabloya dokunun. Yanlış kablo patlatır!",
            tipsTr: "Seri sonu tekse ve kırmızı kablo varsa, ikinci sıradaki kabloyu kesmek güvenlidir!"
        ),
        GameItem(
            id: "target24",
            titleKey: "title_target24",
            subtitleKey: "sub_target24",
            systemIcon: "number.square.fill",
            accentColor: Color.purple,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_puzzle",
            objectiveEn: "24 Solver! Combine 4 given numbers with arithmetic (+, -, ×, ÷) to reach exactly 24.",
            controlsEn: "Tap numbers and operators sequentially to build mathematical expressions.",
            tipsEn: "Look for factor pairs of 24 like 3×8, 4×6, or 2×12 to build your strategy!",
            objectiveTr: "Hedef 24! Verilen 4 rakamı ve dört işlemi kullanarak tam olarak 24 sayısına ulaşın.",
            controlsTr: "Sırasıyla rakam ve işlem butonlarına dokunarak denklemi oluşturun.",
            tipsTr: "24'ün çarpanlarını (3×8, 4×6, 2×12) elde etmeye çalışarak çözüm yolunu bulun!"
        ),
        GameItem(
            id: "tabletennis",
            titleKey: "title_tabletennis",
            subtitleKey: "sub_tabletennis",
            systemIcon: "tennisball.fill",
            accentColor: Color.cyan,
            isFreeByDefault: false,
            crownSupported: true,
            categoryKey: "cat_crown",
            objectiveEn: "Air Tennis! High-speed retro table tennis against an adaptive AI with topspin and side angles.",
            controlsEn: "Rotate Digital Crown to position your paddle along the baseline.",
            tipsEn: "Hit the ball on the paddle edges to apply steep slice angles that trick the bot!",
            objectiveTr: "Masa Tenisi! Hızlı retro kortta yapay zekaya karşı falsolu kesme vuruşlarla sayı kazanın.",
            controlsTr: "Raketinizi hareket ettirmek için Digital Crown'u çevirin.",
            tipsTr: "Topu raketin köşeleriyle karşılayarak botun yetişemeyeceği sert falso açıları verin!"
        ),
        GameItem(
            id: "duel21",
            titleKey: "title_duel21",
            subtitleKey: "sub_duel21",
            systemIcon: "person.2.fill",
            accentColor: Color.yellow,
            isFreeByDefault: false,
            crownSupported: false,
            categoryKey: "cat_cards",
            objectiveEn: "21 Duel! Pass-and-play heads-up Blackjack between 2 players on a single Apple Watch.",
            controlsEn: "Player 1 takes turn (Hit/Stand), passes watch to Player 2. Closest to 21 without busting wins!",
            tipsEn: "Stand on 17+ if your opponent already finished with a lower total!",
            objectiveTr: "21 Düellosu! Tek bir Apple Watch üzerinde arkadaşınızla sırayla kapıştığınız 2 kişilik Blackjack.",
            controlsTr: "1. Oyuncu kart çeker veya kalır, sonra saati arkadaşına uzatır. 21'e en yakın olan kazanır!",
            tipsTr: "Rakibiniz düşük puanla kaldıysa 16-17 gibi ellerde risk almayıp durmayı seçin!"
        )
    ]
}
