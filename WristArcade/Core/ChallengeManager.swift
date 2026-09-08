import SwiftUI

public struct DailyChallenge: Identifiable, Codable {
    public let id: String
    public let gameId: String
    public let targetScore: Int
    public let titleEn: String
    public let titleTr: String
    public let descEn: String
    public let descTr: String
    public var isCompleted: Bool
}

public final class ChallengeManager: ObservableObject {
    public static let shared = ChallengeManager()
    
    @AppStorage("wa_streak_count") public var currentStreak: Int = 0
    @AppStorage("wa_last_completed_day") private var lastCompletedDay: String = ""
    @AppStorage("wa_today_completed") public var isTodayCompleted: Bool = false
    
    @Published public private(set) var todayChallenge: DailyChallenge
    
    private init() {
        let challenge = ChallengeManager.generateTodayChallenge()
        self.todayChallenge = challenge
        self.checkDayTransition()
    }
    
    /// Checks if a new day has arrived and resets completion state if needed
    public func checkDayTransition() {
        let todayStr = ChallengeManager.todayDateString()
        if lastCompletedDay != todayStr {
            isTodayCompleted = false
        }
        todayChallenge = ChallengeManager.generateTodayChallenge(completed: isTodayCompleted)
    }
    
    /// Records game score and evaluates if the daily challenge has been accomplished
    public func recordGameScore(_ score: Int, for gameId: String) -> Bool {
        guard !isTodayCompleted, todayChallenge.gameId == gameId else { return false }
        
        var accomplished = false
        if gameId == "speednumbers" || gameId == "reflextap" {
            // Lower score (time in ms) is better
            if score > 0 && score <= todayChallenge.targetScore {
                accomplished = true
            }
        } else {
            // Higher score is better
            if score >= todayChallenge.targetScore {
                accomplished = true
            }
        }
        
        if accomplished {
            completeChallenge()
            return true
        }
        return false
    }
    
    public func completeChallenge() {
        guard !isTodayCompleted else { return }
        
        let todayStr = ChallengeManager.todayDateString()
        let yesterdayStr = ChallengeManager.yesterdayDateString()
        
        if lastCompletedDay == yesterdayStr {
            currentStreak += 1
        } else if lastCompletedDay != todayStr {
            currentStreak = 1
        }
        
        lastCompletedDay = todayStr
        isTodayCompleted = true
        todayChallenge.isCompleted = true
        
        HapticManager.shared.play(.success)
        objectWillChange.send()
    }
    
    // Deterministic daily challenge generator based on calendar day
    public static func generateTodayChallenge(completed: Bool = false) -> DailyChallenge {
        let calendar = Calendar.current
        let now = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let year = calendar.component(.year, from: now)
        let seed = dayOfYear + year * 365
        
        // Curated rotation of engaging daily tasks across all 4 categories
        let tasks: [(String, Int, String, String, String, String)] = [
            ("blackjack", 3, "Blackjack Master", "Blackjack Ustası", "Win 3 hands of Classic 21", "Classic 21'de 3 el kazan"),
            ("speednumbers", 4000, "Lightning Schulte", "Şimşek Sıralama", "Clear 1-9 in under 4.0 seconds", "1-9 sayılarını 4.0 saniye altında bitir"),
            ("deepreel", 40, "Deep Sea Trophy", "Derin Deniz Trofesi", "Catch a fish weighing over 40kg", "40kg üzerinde trofe balık yakala"),
            ("highwayracer", 120, "Highway Drift", "Otoyol Kaçışı", "Drive 120m without crashing", "Kaza yapmadan 120m yol kat et"),
            ("towerstack", 10, "Skyline Architect", "Gökdelen Mimarı", "Stack 10 continuous neon floors", "Üst üste 10 kat neon blok çık"),
            ("luckyroulette", 50, "Roulette Rush", "Rulet Şansı", "Win $50 or more in Lucky Roulette", "Lucky Roulette'te $50 veya üzeri kazan"),
            ("bullseyearchery", 35, "Robin Hood", "Hedef Avcısı", "Score 35+ points across 5 arrows", "5 okta 35 ve üzeri puan topla"),
            ("paddle", 25, "Paddle Rally", "Duvar Tenisi Ustası", "Rally ball 25 times in Crown Paddle", "Crown Paddle'da topu 25 kez sektir"),
            ("snake", 15, "Crown Nibbler", "Kral Yılan", "Eat 15 food dots in Crown Snake", "Crown Snake'te 15 yem topla"),
            ("mathblitz", 10, "Mental Math Prodigy", "Zihin Matı Dahisi", "Answer 10 equations correctly", "Hızlı Matematik'te 10 işlemi doğru bil"),
            ("memorymatrix", 4, "Chimp Memory Elite", "Maymun Hafızası", "Reach level 4 in Memory Matrix", "Hafıza Matrisinde Seviye 4'e ulaş"),
            ("merge2048", 512, "Tile Fusion", "Blok Birleştirici", "Merge tiles to create 512 or higher", "2048'de 512 taşı veya daha büyüğünü yap")
        ]
        
        let index = seed % tasks.count
        let item = tasks[index]
        
        return DailyChallenge(
            id: "challenge_\(todayDateString())",
            gameId: item.0,
            targetScore: item.1,
            titleEn: item.2,
            titleTr: item.3,
            descEn: item.4,
            descTr: item.5,
            isCompleted: completed
        )
    }
    
    public static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    public static func yesterdayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            return formatter.string(from: yesterday)
        }
        return ""
    }
}
