import XCTest
@testable import WristArcade

final class WristArcadeTests: XCTestCase {
    func testArcadeCatalogCompleteness() {
        let games = ArcadeCatalog.allGames
        XCTAssertEqual(games.count, 60, "Catalog must contain exactly 60 mini-games")
        
        let freeGames = games.filter { $0.isFreeByDefault }
        XCTAssertEqual(freeGames.count, 17, "Free tier must contain 17 games (including Micro Circuit, Word Master & Precision Darts)")
        
        let proGames = games.filter { !$0.isFreeByDefault }
        XCTAssertEqual(proGames.count, 43, "Pro tier must contain 43 games to unlock")
        
        let cardGames = games.filter { $0.categoryKey == "cat_cards" }
        XCTAssertEqual(cardGames.count, 13, "Catalog must contain 13 dedicated card & table games including 21 Duel, Pisti & Klondike Solitaire")
        
        let crownGames = games.filter { $0.categoryKey == "cat_crown" }
        XCTAssertEqual(crownGames.count, 15, "Catalog must contain 15 crown games including Air Tennis, Darts, Air Hockey, Lunar Lander, Maze Muncher & Submarine Dive")
        
        let reflexGames = games.filter { $0.categoryKey == "cat_reflex" }
        XCTAssertEqual(reflexGames.count, 11, "Catalog must contain 11 reflex games including Micro Circuit, Neon Beat & Quickdraw")
        
        let puzzleGames = games.filter { $0.categoryKey == "cat_puzzle" }
        XCTAssertEqual(puzzleGames.count, 21, "Catalog must contain 21 puzzle games including Bomb Defusal, 24 Solver, Sea Battle, Reversi, Word Master, Nine Men's Morris, Hangman, Mini Sudoku, Chess, Checkers & Sliding Blocks")
    }
    
    func testLocalizationManager() {
        let i18n = LocalizationManager.shared
        i18n.selectedLanguage = "en"
        XCTAssertEqual(i18n.t("app_title"), "WristArcade")
        XCTAssertEqual(i18n.t("cat_cards"), "Card Games")
        XCTAssertEqual(i18n.t("unlock_banner_title"), "UNLOCK ALL 60 GAMES")
        XCTAssertEqual(i18n.t("title_baccarat"), "Baccarat Mini")
        XCTAssertEqual(i18n.t("title_lasermirror"), "Laser Mirror")
        
        i18n.selectedLanguage = "tr"
        XCTAssertEqual(i18n.t("cat_cards"), "Kart Oyunları")
        XCTAssertEqual(i18n.t("how_to_play"), "Nasıl Oynanır?")
        XCTAssertEqual(i18n.t("unlock_banner_title"), "TÜM 60 OYUNUN KİLİDİNİ AÇ")
        XCTAssertEqual(i18n.t("title_baccarat"), "Mini Baccarat")
        XCTAssertEqual(i18n.t("title_lasermirror"), "Lazer Aynası")
        
        // Ensure every single game has both EN and TR titles defined
        for game in ArcadeCatalog.allGames {
            i18n.selectedLanguage = "en"
            let enTitle = i18n.t(game.titleKey)
            XCTAssertNotEqual(enTitle, game.titleKey, "Missing EN translation for \(game.titleKey)")
            
            i18n.selectedLanguage = "tr"
            let trTitle = i18n.t(game.titleKey)
            XCTAssertNotEqual(trTitle, game.titleKey, "Missing TR translation for \(game.titleKey)")
        }
    }
    
    func testScoreRecording() {
        let scoreManager = ScoreManager.shared
        scoreManager.resetScores()
        
        let isRecord1 = scoreManager.recordScore(100, for: "paddle")
        XCTAssertTrue(isRecord1, "First score should be a new record")
        XCTAssertEqual(scoreManager.getHighScore(for: "paddle"), 100)
        
        let isRecord2 = scoreManager.recordScore(50, for: "paddle")
        XCTAssertFalse(isRecord2, "Lower score should not be a new record")
        XCTAssertEqual(scoreManager.getHighScore(for: "paddle"), 100)
    }
    
    func testSpeedNumbersScoring() {
        let scoreManager = ScoreManager.shared
        scoreManager.resetScores()
        
        // Lower time (in ms) is better
        let rec1 = scoreManager.recordScore(3400, for: "speednumbers")
        XCTAssertTrue(rec1)
        XCTAssertEqual(scoreManager.getHighScore(for: "speednumbers"), 3400)
        
        let rec2 = scoreManager.recordScore(3800, for: "speednumbers")
        XCTAssertFalse(rec2, "Slower time should not overwrite faster time")
        XCTAssertEqual(scoreManager.getHighScore(for: "speednumbers"), 3400)
        
        let rec3 = scoreManager.recordScore(2900, for: "speednumbers")
        XCTAssertTrue(rec3, "Faster time should overwrite")
        XCTAssertEqual(scoreManager.getHighScore(for: "speednumbers"), 2900)
    }
    
    func testStoreKitProductId() {
        XCTAssertEqual(StoreKitManager.proUnlockProductId, "com.wristarcade.pro_unlock")
    }
    
    func testDailyChallengeSystem() {
        let challenge = ChallengeManager.generateTodayChallenge()
        XCTAssertFalse(challenge.id.isEmpty, "Daily challenge must have a valid ID")
        XCTAssertFalse(challenge.gameId.isEmpty, "Daily challenge must point to a mini-game")
        XCTAssertTrue(challenge.targetScore > 0, "Target score must be positive")
        
        let allIds = Set(ArcadeCatalog.allGames.map { $0.id })
        XCTAssertTrue(allIds.contains(challenge.gameId), "Challenge game must exist in 51-game catalog")
    }
    
    func testXPProgressionAndRanks() {
        let xp = XPManager.shared
        xp.resetXP()
        XCTAssertEqual(xp.currentLevel, 1)
        XCTAssertEqual(xp.currentRank.badge, "🎮")
        
        // Add XP to reach level 2 (requires 60 * 2 * 1 = 120 XP)
        let didLevelUp = xp.addXP(150, reason: "Test Score")
        XCTAssertTrue(didLevelUp, "150 XP must trigger level up from level 1")
        XCTAssertEqual(xp.currentLevel, 2)
        XCTAssertEqual(xp.totalXP, 150)
        
        // Check rank progression
        _ = xp.addXP(5000, reason: "Large XP")
        XCTAssertTrue(xp.currentLevel >= 5, "5000 XP must reach at least level 5")
        XCTAssertFalse(xp.currentRank.titleEn.isEmpty)
    }
    
    func testThemesAndActivity() {
        let tm = ThemeManager.shared
        tm.currentTheme = .cyberpunk
        XCTAssertEqual(tm.currentTheme, .cyberpunk)
        
        let scoreManager = ScoreManager.shared
        let activity = scoreManager.activityForLast7Days()
        XCTAssertEqual(activity.count, 7, "Must provide exactly 7 days of activity tracking")
    }
}
