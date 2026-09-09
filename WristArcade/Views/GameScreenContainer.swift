import SwiftUI

/// A responsive, high-resolution arcade cabinet wrapper for iPhone & iPad.
/// Automatically scales watchOS mini-games (196x246 reference) to fill the mobile screen
/// with glowing neon arcade bezels, top exit navigation, and live score HUD.
public struct GameScreenContainer<Content: View>: View {
    public let game: GameItem
    @ViewBuilder public let content: () -> Content
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    
    // Virtual Apple Watch screen bounds that the games were engineered for
    private let watchWidth: CGFloat = 196
    private let watchHeight: CGFloat = 246
    
    public init(game: GameItem, @ViewBuilder content: @escaping () -> Content) {
        self.game = game
        self.content = content
    }
    
    public var body: some View {
        #if os(watchOS)
        content()
        #else
        GeometryReader { screenGeo in
            let screenWidth = screenGeo.size.width
            let screenHeight = screenGeo.size.height
            
            // Available space for the arcade cabinet
            let availableWidth = max(screenWidth - 28, 200)
            let availableHeight = max(screenHeight - 130, 260)
            
            // Optimal uniform scale factor (~1.8x to 2.1x on modern iPhones)
            let scale = min(availableWidth / watchWidth, availableHeight / watchHeight)
            let finalWidth = watchWidth * scale
            let finalHeight = watchHeight * scale
            
            ZStack {
                // Futuristic dark arcade background
                Color(red: 0.04, green: 0.05, blue: 0.07)
                    .ignoresSafeArea()
                
                // Ambient game-theme radial glow
                RadialGradient(
                    colors: [game.accentColor.opacity(0.18), Color.clear],
                    center: .center,
                    startRadius: 80,
                    endRadius: 380
                )
                .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Mobile Top Navigation Bar
                    HStack(spacing: 12) {
                        Button(action: {
                            HapticManager.shared.play(.tap)
                            dismiss()
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Kapat")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.14))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        // Game Title & Icon
                        HStack(spacing: 6) {
                            Image(systemName: game.systemIcon)
                                .foregroundColor(game.accentColor)
                                .font(.system(size: 16))
                            Text(game.localizedTitle)
                                .font(.system(size: 17, weight: .heavy))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Best Score Pill
                        let best = scoreManager.getHighScore(for: game.id)
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text("\(best)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .overlay(
                            Capsule().stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 0)
                    
                    // Scaled Arcade Game Cabinet
                    ZStack {
                        // Glowing Arcade Bezel
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                game.accentColor.opacity(0.85),
                                                game.accentColor.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: game.accentColor.opacity(0.35), radius: 18, x: 0, y: 6)
                        
                        // Scaled Watch Game Content
                        content()
                            .frame(width: watchWidth, height: watchHeight)
                            .scaleEffect(scale)
                            .frame(width: finalWidth, height: finalHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .frame(width: finalWidth, height: finalHeight)
                    
                    Spacer(minLength: 0)
                    
                    // Arcade Mobile Footer Info
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundColor(game.accentColor)
                        Text("Apple Watch Arcade • Mobil Büyütme (\(Int(scale * 100))%)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        #endif
    }
}
