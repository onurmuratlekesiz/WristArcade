import SwiftUI

@main
struct WristArcadeApp: App {
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var challengeManager = ChallengeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeKit)
                .environmentObject(scoreManager)
                .environmentObject(challengeManager)
                .onOpenURL { url in
                    // Handle deep links from complications: wristarcade://game/{id}
                    if url.scheme == "wristarcade" {
                        NotificationCenter.default.post(name: NSNotification.Name("OpenGameFromComplication"), object: url.host)
                    }
                }
        }
    }
}
