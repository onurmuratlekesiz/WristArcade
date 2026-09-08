import WidgetKit
import SwiftUI

/// Timeline Entry providing daily game challenge and streak data for Apple Watch complications
public struct WristArcadeEntry: TimelineEntry {
    public let date: Date
    public let challenge: DailyChallenge
    public let streak: Int
    public let highScore: Int
}

/// Provider that refreshes complications daily at midnight
public struct WristArcadeTimelineProvider: TimelineProvider {
    public init() {}
    
    public func placeholder(in context: Context) -> WristArcadeEntry {
        let challenge = ChallengeManager.generateTodayChallenge()
        return WristArcadeEntry(date: Date(), challenge: challenge, streak: 3, highScore: 150)
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (WristArcadeEntry) -> Void) {
        let challenge = ChallengeManager.shared.todayChallenge
        let streak = ChallengeManager.shared.currentStreak
        let best = ScoreManager.shared.getHighScore(for: challenge.gameId)
        let entry = WristArcadeEntry(date: Date(), challenge: challenge, streak: streak, highScore: best)
        completion(entry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<WristArcadeEntry>) -> Void) {
        ChallengeManager.shared.checkDayTransition()
        let challenge = ChallengeManager.shared.todayChallenge
        let streak = ChallengeManager.shared.currentStreak
        let best = ScoreManager.shared.getHighScore(for: challenge.gameId)
        
        let currentEntry = WristArcadeEntry(date: Date(), challenge: challenge, streak: streak, highScore: best)
        
        // Refresh at next midnight
        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextMidnight))
        completion(timeline)
    }
}

/// Complication Entry View rendering across various Apple Watch face slots
public struct WristArcadeComplicationEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: WristArcadeEntry
    
    public init(entry: WristArcadeEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                circularView
            case .accessoryCorner:
                cornerView
            case .accessoryInline:
                inlineView
            case .accessoryRectangular:
                rectangularView
            default:
                circularView
            }
        }
        .widgetURL(URL(string: "wristarcade://game/\(entry.challenge.gameId)"))
    }
    
    // Circular complication (e.g. Infograph, Modular, Ultra Wayfinder)
    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text(entry.challenge.isCompleted ? "✅" : "🔥")
                    .font(.system(size: 16))
                Text("\(max(1, entry.streak))d")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(entry.challenge.isCompleted ? .green : .yellow)
            }
        }
    }
    
    // Corner complication (e.g. Infograph corner slots)
    private var cornerView: some View {
        Text("🔥 \(entry.streak)d • \(entry.challenge.isCompleted ? "DONE" : entry.challenge.titleEn)")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.yellow)
    }
    
    // Inline complication (single line top text)
    private var inlineView: some View {
        Text("🔥 \(entry.streak)d Streak • \(entry.challenge.isCompleted ? "Quest Complete!" : entry.challenge.titleEn)")
            .font(.system(size: 11, weight: .bold))
    }
    
    // Rectangular complication (large multi-line slot on Modular face)
    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(entry.challenge.isCompleted ? "✅" : "🔥")
                Text(entry.challenge.isCompleted ? "Daily Quest Done" : "Daily: \(entry.challenge.titleEn)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(entry.challenge.isCompleted ? .green : .yellow)
                    .lineLimit(1)
            }
            Text(entry.challenge.descEn)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .lineLimit(1)
            HStack {
                Text("Streak: \(entry.streak) days")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.orange)
                Spacer()
                Text("Best: \(entry.highScore)")
                    .font(.system(size: 8))
                    .foregroundColor(.cyan)
            }
        }
        .padding(2)
    }
}

/// WidgetKit Configuration declaration for WristArcade Complications
public struct WristArcadeWidget: Widget {
    public let kind: String = "WristArcadeComplication"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WristArcadeTimelineProvider()) { entry in
            WristArcadeComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("WristArcade Quest")
        .description("Tracks daily mini-game challenge, streak, and quick launch into games.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}
