import Foundation
import Combine

/// Manages overall Arcade XP, player level (1 to 50), rank titles and level-up celebrations.
public final class XPManager: ObservableObject {
    public static let shared = XPManager()
    
    private let defaults = UserDefaults.standard
    private let xpKey = "wristarcade_total_xp"
    
    @Published public private(set) var totalXP: Int = 0
    @Published public private(set) var currentLevel: Int = 1
    @Published public var showingLevelUpCeremony: Bool = false
    @Published public var lastUnlockedLevel: Int = 1
    
    public struct RankInfo {
        public let minLevel: Int
        public let titleEn: String
        public let titleTr: String
        public let badge: String
    }
    
    public static let ranks: [RankInfo] = [
        RankInfo(minLevel: 1, titleEn: "Novice Wrist", titleTr: "Acemi Oyuncu", badge: "🎮"),
        RankInfo(minLevel: 5, titleEn: "Crown Cadet", titleTr: "Kurma Çırağı", badge: "⚙️"),
        RankInfo(minLevel: 10, titleEn: "Arcade Veteran", titleTr: "Salon Koşucusu", badge: "🕹️"),
        RankInfo(minLevel: 20, titleEn: "High Roller", titleTr: "Usta Kumarbaz", badge: "🃏"),
        RankInfo(minLevel: 30, titleEn: "Reflex Ninja", titleTr: "Şimşek Refleks", badge: "⚡"),
        RankInfo(minLevel: 40, titleEn: "Grandmaster", titleTr: "Büyük Usta", badge: "👑"),
        RankInfo(minLevel: 50, titleEn: "Arcade Legend", titleTr: "Bilek Efsanesi", badge: "🌟")
    ]
    
    private init() {
        self.totalXP = defaults.integer(forKey: xpKey)
        self.currentLevel = calculateLevel(from: self.totalXP)
    }
    
    /// Formula: XP required to reach level L from level 1: 60 * L * (L - 1)
    public func xpRequired(forLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        return 60 * level * (level - 1)
    }
    
    public func calculateLevel(from xp: Int) -> Int {
        for lvl in stride(from: 50, through: 1, by: -1) {
            if xp >= xpRequired(forLevel: lvl) {
                return lvl
            }
        }
        return 1
    }
    
    public var currentRank: RankInfo {
        var active = Self.ranks[0]
        for r in Self.ranks {
            if currentLevel >= r.minLevel {
                active = r
            }
        }
        return active
    }
    
    public var progressToNextLevel: Double {
        if currentLevel >= 50 { return 1.0 }
        let currentBaseXP = xpRequired(forLevel: currentLevel)
        let nextTargetXP = xpRequired(forLevel: currentLevel + 1)
        let needed = nextTargetXP - currentBaseXP
        guard needed > 0 else { return 1.0 }
        let earned = totalXP - currentBaseXP
        return min(max(Double(earned) / Double(needed), 0.0), 1.0)
    }
    
    public var xpForCurrentTierRemaining: Int {
        if currentLevel >= 50 { return 0 }
        let nextTargetXP = xpRequired(forLevel: currentLevel + 1)
        return max(0, nextTargetXP - totalXP)
    }
    
    @discardableResult
    public func addXP(_ amount: Int, reason: String = "") -> Bool {
        guard amount > 0 else { return false }
        let previousLevel = currentLevel
        totalXP += amount
        defaults.set(totalXP, forKey: xpKey)
        
        let newLevel = calculateLevel(from: totalXP)
        self.currentLevel = newLevel
        
        if newLevel > previousLevel {
            self.lastUnlockedLevel = newLevel
            self.showingLevelUpCeremony = true
            HapticManager.shared.play(.victory)
            return true
        }
        return false
    }
    
    public func resetXP() {
        defaults.set(0, forKey: xpKey)
        totalXP = 0
        currentLevel = 1
    }
}
