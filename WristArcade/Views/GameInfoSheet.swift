import SwiftUI

public typealias GameTutorialSheetView = GameInfoSheet

/// A modern, watchOS-optimized modal sheet that explains How to Play any game
/// with Objectives, Controls, and Pro Tips in the active language.
public struct GameInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var i18n = LocalizationManager.shared
    
    let game: GameItem
    
    public init(game: GameItem) {
        self.game = game
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: isWatchOS ? 8 : 16) {
                // Header
                HStack(spacing: isWatchOS ? 6 : 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: isWatchOS ? 6 : 10)
                            .fill(game.accentColor.opacity(0.2))
                            .frame(width: isWatchOS ? 24 : 38, height: isWatchOS ? 24 : 38)
                        Image(systemName: game.systemIcon)
                            .font(.system(size: isWatchOS ? 12 : 18, weight: .bold))
                            .foregroundColor(game.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.localizedTitle)
                            .font(.system(size: isWatchOS ? 13 : 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(game.localizedCategory)
                            .font(.system(size: isWatchOS ? 8 : 13, weight: .bold))
                            .foregroundColor(game.accentColor)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: isWatchOS ? 16 : 24))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 2)
                
                Divider().background(Color.white.opacity(0.15))
                
                // Section 1: Objective (Amaç)
                VStack(alignment: .leading, spacing: isWatchOS ? 3 : 6) {
                    HStack(spacing: 4) {
                        Text("🎯")
                            .font(.system(size: isWatchOS ? 10 : 15))
                        Text(i18n.t("objective").uppercased())
                            .font(.system(size: isWatchOS ? 9 : 13, weight: .black))
                            .foregroundColor(.cyan)
                    }
                    Text(game.infoObjective)
                        .font(.system(size: isWatchOS ? 10 : 15))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Section 2: Controls (Kontroller)
                VStack(alignment: .leading, spacing: isWatchOS ? 3 : 6) {
                    HStack(spacing: 4) {
                        Text("🕹️")
                            .font(.system(size: isWatchOS ? 10 : 15))
                        Text(i18n.t("controls").uppercased())
                            .font(.system(size: isWatchOS ? 9 : 13, weight: .black))
                            .foregroundColor(.yellow)
                    }
                    Text(game.infoControls)
                        .font(.system(size: isWatchOS ? 10 : 15))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Section 3: Pro Tips (Püf Noktası)
                VStack(alignment: .leading, spacing: isWatchOS ? 3 : 6) {
                    HStack(spacing: 4) {
                        Text("💡")
                            .font(.system(size: isWatchOS ? 10 : 15))
                        Text(i18n.t("pro_tips").uppercased())
                            .font(.system(size: isWatchOS ? 9 : 13, weight: .black))
                            .foregroundColor(.green)
                    }
                    Text(game.infoTips)
                        .font(.system(size: isWatchOS ? 10 : 15))
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Dismiss Button
                Button(action: {
                    HapticManager.shared.play(.tap)
                    dismiss()
                }) {
                    Text(i18n.t("got_it"))
                        .font(.system(size: isWatchOS ? 11 : 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: isWatchOS ? 28 : 44)
                        .background(game.accentColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal, isWatchOS ? 8 : 16)
            .padding(.vertical, isWatchOS ? 6 : 12)
        }
    }
}
