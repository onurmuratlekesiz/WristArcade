#if os(watchOS)
import WidgetKit
import SwiftUI

// Entry model for WristArcade Watch Complications
public struct WristArcadeWidgetEntry: TimelineEntry {
    public let date: Date
    public let dailyChallengeTitle: String
    public let dailyChallengeTarget: String
    public let currentStreak: Int
    public let playerLevel: Int
    public let isChallengeCompleted: Bool
    
    public init(
        date: Date,
        dailyChallengeTitle: String,
        dailyChallengeTarget: String,
        currentStreak: Int,
        playerLevel: Int,
        isChallengeCompleted: Bool
    ) {
        self.date = date
        self.dailyChallengeTitle = dailyChallengeTitle
        self.dailyChallengeTarget = dailyChallengeTarget
        self.currentStreak = currentStreak
        self.playerLevel = playerLevel
        self.isChallengeCompleted = isChallengeCompleted
    }
}

// Timeline Provider
public struct WristArcadeTimelineProvider: TimelineProvider {
    public typealias Entry = WristArcadeWidgetEntry
    
    public func placeholder(in context: Context) -> WristArcadeWidgetEntry {
        WristArcadeWidgetEntry(
            date: Date(),
            dailyChallengeTitle: "Blackjack Master",
            dailyChallengeTarget: "Win 3 hands",
            currentStreak: 5,
            playerLevel: 12,
            isChallengeCompleted: false
        )
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (WristArcadeWidgetEntry) -> Void) {
        let challenge = ChallengeManager.generateTodayChallenge()
        let streak = ChallengeManager.shared.currentStreak
        let level = XPManager.shared.currentLevel
        let completed = ChallengeManager.shared.isTodayCompleted
        
        let entry = WristArcadeWidgetEntry(
            date: Date(),
            dailyChallengeTitle: challenge.titleEn,
            dailyChallengeTarget: "\(challenge.targetScore) pts",
            currentStreak: streak,
            playerLevel: level,
            isChallengeCompleted: completed
        )
        completion(entry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<WristArcadeWidgetEntry>) -> Void) {
        let challenge = ChallengeManager.generateTodayChallenge()
        let streak = ChallengeManager.shared.currentStreak
        let level = XPManager.shared.currentLevel
        let completed = ChallengeManager.shared.isTodayCompleted
        
        let entry = WristArcadeWidgetEntry(
            date: Date(),
            dailyChallengeTitle: challenge.titleEn,
            dailyChallengeTarget: "\(challenge.targetScore) pts",
            currentStreak: streak,
            playerLevel: level,
            isChallengeCompleted: completed
        )
        
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// Complication Views for watchOS accessory families
public struct WristArcadeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: WristArcadeWidgetEntry
    
    public var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text(entry.isChallengeCompleted ? "🏆" : "🎮")
                        .font(.system(size: 14))
                    Text(entry.isChallengeCompleted ? "DONE" : "\(entry.currentStreak)🔥")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(entry.isChallengeCompleted ? .green : .orange)
                }
            }
            .widgetURL(URL(string: "wristarcade://daily"))
            
        case .accessoryCorner:
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 14))
                .foregroundColor(.cyan)
                .widgetLabel {
                    Text("\(entry.playerLevel)Lv • \(entry.currentStreak)🔥")
                }
                .widgetURL(URL(string: "wristarcade://play"))
            
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 3) {
                    Text("🎮 WRIST ARCADE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.yellow)
                    Spacer()
                    Text("Lv.\(entry.playerLevel)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.cyan)
                }
                Text(entry.dailyChallengeTitle)
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(1)
                HStack {
                    Text(entry.isChallengeCompleted ? "Completed! +100XP" : "Goal: \(entry.dailyChallengeTarget)")
                        .font(.system(size: 9))
                        .foregroundColor(entry.isChallengeCompleted ? .green : .white.opacity(0.8))
                    Spacer()
                    Text("\(entry.currentStreak)🔥")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            .widgetURL(URL(string: "wristarcade://daily"))
            
        case .accessoryInline:
            Text("🎮 \(entry.dailyChallengeTitle) • \(entry.currentStreak)🔥")
                .widgetURL(URL(string: "wristarcade://daily"))
            
        default:
            Text("WristArcade")
        }
    }
}

// Main Widget Definition
public struct WristArcadeComplicationWidget: Widget {
    public let kind: String = "WristArcadeComplicationWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WristArcadeTimelineProvider()) { entry in
            WristArcadeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WristArcade Daily")
        .description("Track your daily gaming quests, streaks, and XP directly on your Apple Watch face.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

#endif
