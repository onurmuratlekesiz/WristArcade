import SwiftUI

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
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(game.accentColor.opacity(0.2))
                            .frame(width: 24, height: 24)
                        Image(systemName: game.systemIcon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(game.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(game.localizedTitle)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(game.localizedCategory)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(game.accentColor)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 2)
                
                Divider().background(Color.white.opacity(0.15))
                
                // Section 1: Objective (Amaç)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text("🎯")
                            .font(.system(size: 10))
                        Text(i18n.t("objective").uppercased())
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.cyan)
                    }
                    Text(game.infoObjective)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Section 2: Controls (Kontroller)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text("🕹️")
                            .font(.system(size: 10))
                        Text(i18n.t("controls").uppercased())
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.yellow)
                    }
                    Text(game.infoControls)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Section 3: Pro Tips (Püf Noktası)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text("💡")
                            .font(.system(size: 10))
                        Text(i18n.t("pro_tips").uppercased())
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.green)
                    }
                    Text(game.infoTips)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Dismiss Button
                Button(action: {
                    HapticManager.shared.play(.tap)
                    dismiss()
                }) {
                    Text(i18n.t("got_it"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(game.accentColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }
}
