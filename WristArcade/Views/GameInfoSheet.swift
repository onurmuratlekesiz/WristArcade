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
            VStack(alignment: .leading, spacing: #if os(watchOS) 8 #else 16 #endif) {
                // Header
                HStack(spacing: #if os(watchOS) 6 #else 10 #endif) {
                    ZStack {
                        RoundedRectangle(cornerRadius: #if os(watchOS) 6 #else 10 #endif)
                            .fill(game.accentColor.opacity(0.2))
                            .frame(width: #if os(watchOS) 24 #else 38 #endif, height: #if os(watchOS) 24 #else 38 #endif)
                        Image(systemName: game.systemIcon)
                            .font(.system(size: #if os(watchOS) 12 #else 18 #endif, weight: .bold))
                            .foregroundColor(game.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.localizedTitle)
                            .font(.system(size: #if os(watchOS) 13 #else 18 #endif, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(game.localizedCategory)
                            .font(.system(size: #if os(watchOS) 8 #else 13 #endif, weight: .bold))
                            .foregroundColor(game.accentColor)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: #if os(watchOS) 16 #else 24 #endif))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 2)
                
                Divider().background(Color.white.opacity(0.15))
                
                // Section 1: Objective (Amaç)
                VStack(alignment: .leading, spacing: #if os(watchOS) 3 #else 6 #endif) {
                    HStack(spacing: 4) {
                        Text("🎯")
                            .font(.system(size: #if os(watchOS) 10 #else 15 #endif))
                        Text(i18n.t("objective").uppercased())
                            .font(.system(size: #if os(watchOS) 9 #else 13 #endif, weight: .black))
                            .foregroundColor(.cyan)
                    }
                    Text(game.infoObjective)
                        .font(.system(size: #if os(watchOS) 10 #else 15 #endif))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Section 2: Controls (Kontroller)
                VStack(alignment: .leading, spacing: #if os(watchOS) 3 #else 6 #endif) {
                    HStack(spacing: 4) {
                        Text("🕹️")
                            .font(.system(size: #if os(watchOS) 10 #else 15 #endif))
                        Text(i18n.t("controls").uppercased())
                            .font(.system(size: #if os(watchOS) 9 #else 13 #endif, weight: .black))
                            .foregroundColor(.yellow)
                    }
                    Text(game.infoControls)
                        .font(.system(size: #if os(watchOS) 10 #else 15 #endif))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Section 3: Pro Tips (Püf Noktası)
                VStack(alignment: .leading, spacing: #if os(watchOS) 3 #else 6 #endif) {
                    HStack(spacing: 4) {
                        Text("💡")
                            .font(.system(size: #if os(watchOS) 10 #else 15 #endif))
                        Text(i18n.t("pro_tips").uppercased())
                            .font(.system(size: #if os(watchOS) 9 #else 13 #endif, weight: .black))
                            .foregroundColor(.green)
                    }
                    Text(game.infoTips)
                        .font(.system(size: #if os(watchOS) 10 #else 15 #endif))
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Dismiss Button
                Button(action: {
                    HapticManager.shared.play(.tap)
                    dismiss()
                }) {
                    Text(i18n.t("got_it"))
                        .font(.system(size: #if os(watchOS) 11 #else 16 #endif, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: #if os(watchOS) 28 #else 44 #endif)
                        .background(game.accentColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal, #if os(watchOS) 8 #else 16 #endif)
            .padding(.vertical, #if os(watchOS) 6 #else 12 #endif)
        }
    }
}
