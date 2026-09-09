import SwiftUI

public struct GameCardView: View {
    public let game: GameItem
    public let isLocked: Bool
    public let highScore: Int
    public var onInfo: (() -> Void)? = nil
    
    public init(game: GameItem, isLocked: Bool, highScore: Int, onInfo: (() -> Void)? = nil) {
        self.game = game
        self.isLocked = isLocked
        self.highScore = highScore
        self.onInfo = onInfo
    }
    
    public var body: some View {
        HStack(spacing: #if os(watchOS) 8 #else 12 #endif) {
            // Game Icon
            ZStack {
                RoundedRectangle(cornerRadius: #if os(watchOS) 9 #else 12 #endif)
                    .fill(game.accentColor.opacity(0.2))
                    .frame(width: #if os(watchOS) 36 #else 48 #endif, height: #if os(watchOS) 36 #else 48 #endif)
                
                Image(systemName: game.systemIcon)
                    .font(.system(size: #if os(watchOS) 17 #else 22 #endif))
                    .foregroundColor(game.accentColor)
            }
            
            // Text info
            VStack(alignment: .leading, spacing: #if os(watchOS) 2 #else 3 #endif) {
                HStack(spacing: 4) {
                    Text(game.localizedTitle)
                        .font(.system(size: #if os(watchOS) 12 #else 16 #endif, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: #if os(watchOS) 9 #else 12 #endif))
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(game.localizedSubtitle)
                    .font(.system(size: #if os(watchOS) 9 #else 12 #endif))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                if highScore > 0 && !isLocked {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: #if os(watchOS) 8 #else 11 #endif))
                            .foregroundColor(.yellow)
                        
                        let bestText: String = {
                            if game.id == "reflextap" || game.id == "speednumbers" {
                                return String(format: "%.2fs", Double(highScore) / 1000.0)
                            }
                            return "\(highScore)"
                        }()
                        
                        Text("\(LocalizationManager.shared.t("best")): \(bestText)")
                            .font(.system(size: #if os(watchOS) 8 #else 11 #endif, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            Spacer()
            
            // Info button for How to Play
            if let onInfo = onInfo {
                Button(action: {
                    HapticManager.shared.play(.tap)
                    onInfo()
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: #if os(watchOS) 14 #else 20 #endif))
                        .foregroundColor(.gray)
                        .padding(#if os(watchOS) 2 #else 4 #endif)
                }
                .buttonStyle(.plain)
            }
            
            Image(systemName: isLocked ? "lock.circle.fill" : "chevron.right")
                .font(.system(size: #if os(watchOS) 11 #else 14 #endif))
                .foregroundColor(isLocked ? .yellow : .gray.opacity(0.6))
        }
        .padding(.horizontal, #if os(watchOS) 8 #else 12 #endif)
        .padding(.vertical, #if os(watchOS) 6 #else 10 #endif)
        .background(
            RoundedRectangle(cornerRadius: #if os(watchOS) 10 #else 14 #endif)
                .fill(Color.white.opacity(0.08))
        )
    }
}
