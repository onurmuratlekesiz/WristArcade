import Foundation
import GameKit

public final class GameCenterManager: ObservableObject {
    public static let shared = GameCenterManager()
    
    @Published public var isAuthenticated: Bool = false
    @Published public var localPlayerName: String = "Player"
    
    // Leaderboard IDs configured in App Store Connect
    public enum Leaderboard {
        public static let reflexSpeed = "com.wristarcade.lb.reflex_speed"
        public static let speedNumbers = "com.wristarcade.lb.speed_numbers"
        public static let highwayRacer = "com.wristarcade.lb.highway_racer"
        public static let mazeMuncher = "com.wristarcade.lb.maze_muncher"
        public static let gauntlet = "com.wristarcade.lb.gauntlet"
        public static let airHockey = "com.wristarcade.lb.air_hockey"
        public static let totalXP = "com.wristarcade.lb.total_xp"
    }
    
    private init() {
        authenticatePlayer()
    }
    
    public func authenticatePlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] _, error in
            DispatchQueue.main.async {
                if localPlayer.isAuthenticated {
                    self?.isAuthenticated = true
                    self?.localPlayerName = localPlayer.displayName
                } else {
                    self?.isAuthenticated = false
                    if let error = error {
                        print("Game Center auth error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Submits a high score to a Game Center leaderboard
    public func submitScore(_ score: Int, to leaderboardId: String) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardId]
        ) { error in
            if let error = error {
                print("Failed to submit score to \(leaderboardId): \(error.localizedDescription)")
            }
        }
    }
    
    /// Unlocks or advances a Game Center achievement
    public func reportAchievement(id: String, percentComplete: Double = 100.0) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Failed to report achievement \(id): \(error.localizedDescription)")
            }
        }
    }
}
