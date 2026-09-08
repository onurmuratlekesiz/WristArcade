import Foundation

/// Manages gamified movement & fitness milestones for bonus XP and trophies
public final class FitnessManager: ObservableObject {
    public static let shared = FitnessManager()
    
    @Published public var dailyStepsGoal: Int = 5000
    @Published public var currentSteps: Int = 0
    @Published public var hasClaimedTodayBonus: Bool = false
    
    private init() {
        loadState()
    }
    
    private func dateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    public func loadState() {
        let today = dateKey()
        let lastClaim = UserDefaults.standard.string(forKey: "fitness_last_claim_date")
        self.hasClaimedTodayBonus = (lastClaim == today)
        
        // Retrieve or initialize simulated daily step progress (or synced via HealthKit if permitted)
        let savedSteps = UserDefaults.standard.integer(forKey: "fitness_steps_\(today)")
        if savedSteps == 0 {
            // Seed a realistic baseline based on time of day
            let hour = Calendar.current.component(.hour, from: Date())
            let estimated = min(8500, max(1200, hour * 380))
            self.currentSteps = estimated
            UserDefaults.standard.set(estimated, forKey: "fitness_steps_\(today)")
        } else {
            self.currentSteps = savedSteps
        }
    }
    
    /// Claim daily active movement XP reward
    public func claimDailyBonus(scoreManager: ScoreManager) -> Bool {
        guard !hasClaimedTodayBonus && currentSteps >= 3000 else { return false }
        
        let today = dateKey()
        UserDefaults.standard.set(today, forKey: "fitness_last_claim_date")
        self.hasClaimedTodayBonus = true
        
        // Award bonus XP and fitness achievement
        scoreManager.addXP(100)
        return true
    }
}
