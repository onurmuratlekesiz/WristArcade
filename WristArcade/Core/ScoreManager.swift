import Foundation
import Combine

/// Manages and persists high scores, stats and games played locally on the watch.
public final class ScoreManager: ObservableObject {
    public static let shared = ScoreManager()
    
    private let defaults = UserDefaults.standard
    
    @Published public private(set) var scores: [String: Int] = [:]
    @Published public private(set) var totalGamesPlayed: Int = 0
    
    public static let allGameIds = [
        "blackjack", "videopoker", "microsolitaire", "cardwar", "cardpairs", "highlow", "luckydice", "luckyroulette", "baccarat", "triplepoker",
        "paddle", "snake", "safecracker", "crownrunner", "spaceevade", "brickcrusher", "galaxydefender", "deepreel", "crownmaze", "subdive",
        "speednumbers", "wingflap", "reflextap", "whackmole", "colormemory", "mathblitz", "towerstack", "highwayracer", "neonbeat", "quickdraw",
        "merge2048", "numberslide", "wordguess", "blockfall", "mines", "tictactoe", "memorymatrix", "bullseyearchery", "pipeconnect", "lasermirror",
        "pisti", "klondikesolitaire", "mazemuncher", "chess", "checkers", "slidingblocks",
        "airhockey", "hangman", "minisudoku", "lunarlander", "ninemensmorris",
        "seabattle", "reversi", "word5", "darts",
        "microcircuit", "bombdefusal", "target24", "tabletennis", "duel21"
    ]
    
    public static let proGameIds = [
        "videopoker", "microsolitaire", "cardwar", "cardpairs", "highlow", "luckydice", "luckyroulette", "baccarat", "triplepoker",
        "safecracker", "crownrunner", "spaceevade", "brickcrusher", "galaxydefender", "deepreel", "crownmaze", "subdive", "lunarlander",
        "reflextap", "whackmole", "colormemory", "mathblitz", "quickdraw",
        "numberslide", "wordguess", "blockfall", "mines", "tictactoe", "memorymatrix", "bullseyearchery", "pipeconnect", "lasermirror",
        "klondikesolitaire", "chess", "checkers", "slidingblocks", "minisudoku", "ninemensmorris", "seabattle", "reversi",
        "bombdefusal", "target24", "tabletennis", "duel21"
    ]
    
    public static func dailyFreeProGameId() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return proGameIds[dayOfYear % proGameIds.count]
    }
    
    private init() {
        loadScores()
    }
    
    private func keyForGame(_ gameId: String) -> String {
        return "high_score_\(gameId)"
    }
    
    public func getHighScore(for gameId: String) -> Int {
        return defaults.integer(forKey: keyForGame(gameId))
    }
    
    public func saveHighScore(_ score: Int, for gameId: String) {
        _ = recordScore(score, for: gameId)
    }
    
    public func highScore(for gameId: String) -> Int {
        return getHighScore(for: gameId)
    }
    
    public static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    public func addXP(_ amount: Int) {
        XPManager.shared.addXP(amount, reason: "Fitness / Activity Goal")
    }
    
    public func recordScore(_ score: Int, for gameId: String) -> Bool {
        let currentBest = getHighScore(for: gameId)
        totalGamesPlayed += 1
        defaults.set(totalGamesPlayed, forKey: "total_games_played")
        
        // Record Daily Activity for 7-day analytics
        let today = Self.todayDateString()
        let actKey = "daily_activity_\(today)"
        let todayCount = defaults.integer(forKey: actKey) + 1
        defaults.set(todayCount, forKey: actKey)
        
        // Award XP for playing
        XPManager.shared.addXP(20, reason: "Played \(gameId)")
        
        // Notify ChallengeManager
        if ChallengeManager.shared.recordGameScore(score, for: gameId) {
            XPManager.shared.addXP(250, reason: "Completed Daily Quest")
        }
        
        var isNewBest = false
        // For reflex tap, card pairs, speed numbers, number slide, quickdraw, and sliding blocks (lower is better)
        if gameId == "reflextap" || gameId == "cardpairs" || gameId == "speednumbers" || gameId == "numberslide" || gameId == "quickdraw" || gameId == "slidingblocks" {
            if currentBest == 0 || score < currentBest {
                defaults.set(score, forKey: keyForGame(gameId))
                scores[gameId] = score
                isNewBest = true
            }
        } else {
            if score > currentBest {
                defaults.set(score, forKey: keyForGame(gameId))
                scores[gameId] = score
                isNewBest = true
            }
        }
        
        if isNewBest {
            XPManager.shared.addXP(100, reason: "New High Score")
        }
        
        return isNewBest
    }
    
    /// Returns 7 data points for (Day Name, Game Count) for the last 7 days
    public func activityForLast7Days() -> [(dayLabel: String, count: Int)] {
        var results: [(String, Int)] = []
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let labelFormatter = DateFormatter()
        labelFormatter.dateFormat = "EEE"
        
        for offset in stride(from: -6, through: 0, by: 1) {
            if let date = calendar.date(byAdding: .day, value: offset, to: Date()) {
                let dateStr = formatter.string(from: date)
                let label = labelFormatter.string(from: date)
                let count = defaults.integer(forKey: "daily_activity_\(dateStr)")
                results.append((label, count))
            }
        }
        return results
    }
    
    public func resetScores() {
        for id in Self.allGameIds {
            defaults.removeObject(forKey: keyForGame(id))
        }
        defaults.set(0, forKey: "total_games_played")
        totalGamesPlayed = 0
        scores.removeAll()
    }
    
    private func loadScores() {
        var loaded: [String: Int] = [:]
        for id in Self.allGameIds {
            loaded[id] = defaults.integer(forKey: keyForGame(id))
        }
        self.scores = loaded
        self.totalGamesPlayed = defaults.integer(forKey: "total_games_played")
    }
}
