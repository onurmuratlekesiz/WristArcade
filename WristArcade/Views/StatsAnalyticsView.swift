import SwiftUI

public struct StatsAnalyticsView: View {
    @StateObject private var xpManager = XPManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var challengeManager = ChallengeManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // MARK: - 1. Player Level & XP Card
                VStack(spacing: 4) {
                    HStack {
                        Text(xpManager.currentRank.badge)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Seviye \(xpManager.currentLevel)")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundColor(.white)
                            Text(i18n.selectedLanguage == "tr" ? xpManager.currentRank.titleTr : xpManager.currentRank.titleEn)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(themeManager.currentTheme.accentColor)
                        }
                        Spacer()
                        Text("\(xpManager.totalXP) XP")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    
                    // XP Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [themeManager.currentTheme.accentColor, themeManager.currentTheme.secondaryColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(4, geo.size.width * CGFloat(xpManager.progressToNextLevel)), height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    HStack {
                        Text("Sonraki Seviye:")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(xpManager.xpForCurrentTierRemaining) XP kaldı")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
                
                // MARK: - 2. 7-Day Activity Mini Bar Chart
                VStack(alignment: .leading, spacing: 6) {
                    Text("HAFTALIK AKTİVİTE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                    
                    let activity = scoreManager.activityForLast7Days()
                    let maxCount = max(1, activity.map(\.count).max() ?? 1)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<activity.count, id: \.self) { idx in
                            let item = activity[idx]
                            VStack(spacing: 3) {
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 14, height: 36)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(
                                            idx == activity.count - 1
                                                ? themeManager.currentTheme.accentColor
                                                : Color.cyan.opacity(0.6)
                                        )
                                        .frame(width: 14, height: max(3, CGFloat(item.count) / CGFloat(maxCount) * 36))
                                }
                                Text(item.dayLabel)
                                    .font(.system(size: 7, weight: .medium))
                                    .foregroundColor(idx == activity.count - 1 ? .white : .gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(8)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
                
                // MARK: - 3. Theme Selector
                VStack(alignment: .leading, spacing: 4) {
                    Text("GÖRSEL TEMA")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Picker("Tema", selection: $themeManager.currentTheme) {
                        ForEach(ArcadeTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 44)
                }
                .padding(6)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
                
                // MARK: - 4. Stats Summary
                VStack(spacing: 4) {
                    HStack {
                        Text("Toplam Oynanış:")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(scoreManager.totalGamesPlayed)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    HStack {
                        Text("Günlük Seri:")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(challengeManager.currentStreak) Gün 🔥")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
                .padding(6)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 12)
        }
        .navigationTitle("İstatistik & Seviye")
        .navigationBarTitleDisplayMode(.inline)
    }
}
