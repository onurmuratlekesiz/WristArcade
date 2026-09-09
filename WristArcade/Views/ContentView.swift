import SwiftUI

public struct ContentView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    @StateObject private var challengeManager = ChallengeManager.shared
    @StateObject private var xpManager = XPManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var showingPaywall: Bool = false
    @State private var selectedGame: GameItem? = nil
    @State private var gameForInfo: GameItem? = nil
    @State private var showingSettings: Bool = false
    @State private var selectedCategory: String = "all"
    
    private let games = ArcadeCatalog.allGames
    
    private var filteredGames: [GameItem] {
        if selectedCategory == "all" {
            return games
        }
        return games.filter { $0.categoryKey == selectedCategory }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: isWatchOS ? 7 : 12) {
                        // Header Bar with XP Rank and Settings
                        HStack {
                            HStack(spacing: isWatchOS ? 4 : 8) {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: isWatchOS ? 13 : 20))
                                    .foregroundColor(themeManager.currentTheme.accentColor)
                                Text(i18n.t("app_title"))
                                    .font(.system(size: isWatchOS ? 13 : 22, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Stats & Level Button
                            NavigationLink(destination: StatsAnalyticsView()) {
                                HStack(spacing: 3) {
                                    Text(xpManager.currentRank.badge)
                                        .font(.system(size: isWatchOS ? 10 : 14))
                                    Text("Lv.\(xpManager.currentLevel)")
                                        .font(.system(size: isWatchOS ? 9 : 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(themeManager.currentTheme.accentColor)
                                }
                                .padding(.horizontal, isWatchOS ? 5 : 10)
                                .padding(.vertical, isWatchOS ? 2 : 5)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: isWatchOS ? 12 : 18))
                                    .foregroundColor(.gray)
                                    .padding(isWatchOS ? 0 : 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, isWatchOS ? 6 : 12)
                        .padding(.top, isWatchOS ? 2 : 8)
                        
                        // 2P Wrist Duel Banner
                        NavigationLink(destination: WristDuelView()) {
                            HStack(spacing: isWatchOS ? 6 : 12) {
                                Text("⚔️")
                                    .font(.system(size: isWatchOS ? 12 : 20))
                                VStack(alignment: .leading, spacing: isWatchOS ? 1 : 3) {
                                    Text("BİLEK DÜELLOSU (2P)")
                                        .font(.system(size: isWatchOS ? 9 : 15, weight: .heavy))
                                        .foregroundColor(.cyan)
                                    Text("Aynı cihazda karşılıklı 2 kişi oyna!")
                                        .font(.system(size: isWatchOS ? 7 : 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: isWatchOS ? 8 : 14, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            .padding(isWatchOS ? 5 : 12)
                            .background(
                                RoundedRectangle(cornerRadius: isWatchOS ? 8 : 12)
                                    .fill(Color.cyan.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: isWatchOS ? 8 : 12)
                                            .stroke(Color.cyan.opacity(0.35), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, isWatchOS ? 4 : 12)
                    
                    // Daily Challenge Quest Card
                    let challenge = challengeManager.todayChallenge
                    Button(action: {
                        if let targetGame = games.first(where: { $0.id == challenge.gameId }) {
                            if !targetGame.isFreeByDefault && !storeKit.isProUser {
                                showingPaywall = true
                            } else {
                                selectedGame = targetGame
                            }
                            HapticManager.shared.play(.tap)
                        }
                    }) {
                        HStack(spacing: isWatchOS ? 6 : 12) {
                            Text(challenge.isCompleted ? "✅" : "🔥")
                                .font(.system(size: isWatchOS ? 14 : 22))
                            
                            VStack(alignment: .leading, spacing: isWatchOS ? 1 : 3) {
                                HStack(spacing: 4) {
                                    Text(i18n.isTurkish ? challenge.titleTr : challenge.titleEn)
                                        .font(.system(size: isWatchOS ? 9 : 14, weight: .black))
                                        .foregroundColor(challenge.isCompleted ? .green : .orange)
                                    
                                    if challengeManager.currentStreak > 0 {
                                        Text("• \(challengeManager.currentStreak)d 🔥")
                                            .font(.system(size: isWatchOS ? 8 : 12, weight: .bold))
                                            .foregroundColor(.yellow)
                                    }
                                }
                                
                                Text(challenge.isCompleted ? (i18n.isTurkish ? "GÖREV TAMAMLANDI!" : "COMPLETED!") : (i18n.isTurkish ? challenge.descTr : challenge.descEn))
                                    .font(.system(size: isWatchOS ? 7 : 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: isWatchOS ? 8 : 14, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        .padding(isWatchOS ? 6 : 12)
                        .background(
                            RoundedRectangle(cornerRadius: isWatchOS ? 10 : 14)
                                .fill(challenge.isCompleted ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: isWatchOS ? 10 : 14)
                                        .stroke(challenge.isCompleted ? Color.green.opacity(0.4) : Color.orange.opacity(0.4), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, isWatchOS ? 4 : 12)
                    
                    // Pro Banner if not unlocked
                    if !storeKit.isProUser {
                        Button(action: {
                            showingPaywall = true
                            HapticManager.shared.play(.tap)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(i18n.t("unlock_banner_title"))
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(.white)
                                    Text(i18n.t("unlock_banner_subtitle"))
                                        .font(.system(size: 7))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text(storeKit.proProduct?.displayPrice ?? "$2.99")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.yellow)
                                    .clipShape(Capsule())
                            }
                            .padding(7)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.yellow.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // Category Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: isWatchOS ? 4 : 8) {
                            categoryPill(id: "all", title: i18n.t("filter_all"), icon: "square.grid.2x2.fill")
                            categoryPill(id: "cat_cards", title: i18n.t("cat_cards"), icon: "suit.club.fill")
                            categoryPill(id: "cat_crown", title: i18n.t("cat_crown"), icon: "crown.fill")
                            categoryPill(id: "cat_reflex", title: i18n.t("cat_reflex"), icon: "bolt.fill")
                            categoryPill(id: "cat_puzzle", title: i18n.t("cat_puzzle"), icon: "brain.head.profile")
                        }
                        .padding(.horizontal, isWatchOS ? 4 : 12)
                        .padding(.vertical, isWatchOS ? 2 : 4)
                    }
                    
                    // Games List (60 Games)
                    ForEach(filteredGames) { game in
                        let isDailyFree = game.isPro && game.id == ScoreManager.dailyFreeProGameId()
                        let isLocked = !storeKit.isGameUnlocked(game)
                        let highScore = scoreManager.getHighScore(for: game.id)
                        
                        Button(action: {
                            if isLocked {
                                showingPaywall = true
                                HapticManager.shared.play(.warning)
                            } else {
                                selectedGame = game
                                HapticManager.shared.play(.tap)
                            }
                        }) {
                            GameCardView(
                                game: game,
                                isLocked: isLocked,
                                highScore: highScore,
                                onInfo: {
                                    gameForInfo = game
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, isWatchOS ? 4 : 12)
                    }
                }
                .padding(.bottom, 12)
            }
            
            // Level Up Ceremony Celebration Overlay
            if xpManager.showingLevelUpCeremony {
                ZStack {
                    Color.black.opacity(0.85).ignoresSafeArea()
                    ConfettiView()
                    
                    VStack(spacing: 6) {
                        Text("🎉")
                            .font(.system(size: 28))
                        Text("TEBRİKLER!")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.yellow)
                        Text("SEVİYE \(xpManager.lastUnlockedLevel)")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(xpManager.currentRank.badge + " " + (i18n.isTurkish ? xpManager.currentRank.titleTr : xpManager.currentRank.titleEn))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.accentColor)
                        
                        Button("DEVAM ET") {
                            withAnimation {
                                xpManager.showingLevelUpCeremony = false
                            }
                        }
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                        .padding(.top, 4)
                    }
                    .padding()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
        }
        #if os(watchOS)
        .sheet(item: $selectedGame) { game in
            destinationView(for: game)
        }
        #else
        .fullScreenCover(item: $selectedGame) { game in
            GameScreenContainer(game: game) {
                destinationView(for: game)
            }
        }
        #endif
        .sheet(item: $gameForInfo) { game in
            GameInfoSheet(game: game)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenGameFromComplication"))) { notif in
            if let gameId = notif.object as? String, let game = games.first(where: { $0.id == gameId }) {
                if !game.isFreeByDefault && !storeKit.isProUser {
                    showingPaywall = true
                } else {
                    selectedGame = game
                }
            }
        }
    }
}
    
    @ViewBuilder
    private func destinationView(for game: GameItem) -> some View {
        switch game.id {
        // Cards (6)
        case "blackjack":
            BlackjackGameView()
        case "videopoker":
            VideoPokerGameView()
        case "microsolitaire":
            MicroSolitaireGameView()
        case "cardwar":
            CardWarGameView()
        case "cardpairs":
            CardPairsGameView()
        case "highlow":
            HighLowGameView()
        case "luckydice":
            LuckyDiceGameView()
        case "luckyroulette":
            LuckyRouletteGameView()
        case "baccarat":
            BaccaratGameView()
        case "triplepoker":
            TriplePokerGameView()
            
        // Crown Arcades (10)
        case "paddle":
            PaddleGameView()
        case "snake":
            SnakeGameView()
        case "safecracker":
            SafeCrackerGameView()
        case "crownrunner":
            CrownRunnerGameView()
        case "spaceevade":
            SpaceEvadeGameView()
        case "brickcrusher":
            BrickCrusherGameView()
        case "galaxydefender":
            GalaxyDefenderGameView()
        case "deepreel":
            DeepSeaReelGameView()
        case "crownmaze":
            CrownMazeGameView()
        case "subdive":
            SubDiveGameView()
            
        // Speed & Reflex (10)
        case "speednumbers":
            SpeedNumbersGameView()
        case "wingflap":
            WingFlapGameView()
        case "reflextap":
            ReflexTapGameView()
        case "whackmole":
            WhackDotGameView()
        case "colormemory":
            ColorMemoryGameView()
        case "mathblitz":
            MathBlitzGameView()
        case "towerstack":
            TowerStackerGameView()
        case "highwayracer":
            HighwayRacerGameView()
        case "neonbeat":
            NeonBeatGameView()
        case "quickdraw":
            QuickdrawGameView()
            
        // Puzzle & Strategy (10)
        case "merge2048":
            Merge2048GameView()
        case "numberslide":
            NumberSlideGameView()
        case "wordguess":
            WordGuessGameView()
        case "blockfall":
            ColorBlocksGameView()
        case "mines":
            MinesGameView()
        case "tictactoe":
            TicTacToeGameView()
        case "memorymatrix":
            MemoryMatrixGameView()
        case "bullseyearchery":
            BullseyeArcheryGameView()
        case "pipeconnect":
            PipeConnectGameView()
        case "lasermirror":
            LaserMirrorGameView()
            
        // New Expansion Games (10)
        case "pisti":
            PistiGameView()
        case "klondikesolitaire":
            KlondikeSolitaireGameView()
        case "mazemuncher":
            MazeMuncherGameView()
        case "chess":
            ChessGameView()
        case "checkers":
            CheckersGameView()
        case "slidingblocks":
            SlidingBlocksGameView()
        case "airhockey":
            AirHockeyGameView()
        case "hangman":
            HangmanGameView()
        case "minisudoku":
            MiniSudokuGameView()
        case "lunarlander":
            LunarLanderGameView()
        case "ninemensmorris":
            NineMenMorrisGameView()
        case "seabattle":
            SeaBattleGameView()
        case "reversi":
            ReversiGameView()
        case "word5":
            WordMasterGameView()
        case "darts":
            PrecisionDartsGameView()
        case "microcircuit":
            MicroCircuitGameView()
        case "bombdefusal":
            BombDefusalGameView()
        case "target24":
            Target24GameView()
        case "tabletennis":
            TableTennisGameView()
        case "duel21":
            Duel21GameView()
            
        default:
            Text("Game not found")
        }
    }
    
    @ViewBuilder
    private func categoryPill(id: String, title: String, icon: String) -> some View {
        let isSelected = selectedCategory == id
        Button(action: {
            selectedCategory = id
            HapticManager.shared.play(.click)
        }) {
            HStack(spacing: isWatchOS ? 3 : 6) {
                Image(systemName: icon)
                    .font(.system(size: isWatchOS ? 8 : 13))
                Text(title)
                    .font(.system(size: isWatchOS ? 8 : 13, weight: isSelected ? .black : .semibold))
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, isWatchOS ? 6 : 12)
            .padding(.vertical, isWatchOS ? 3 : 6)
            .background(isSelected ? Color.cyan : Color.white.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
