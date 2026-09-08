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
        HStack(spacing: 8) {
            // Game Icon
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(game.accentColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: game.systemIcon)
                    .font(.system(size: 17))
                    .foregroundColor(game.accentColor)
            }
            
            // Text info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(game.localizedTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(game.localizedSubtitle)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                if highScore > 0 && !isLocked {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                        
                        let bestText: String = {
                            if game.id == "reflextap" || game.id == "speednumbers" {
                                return String(format: "%.2fs", Double(highScore) / 1000.0)
                            }
                            return "\(highScore)"
                        }()
                        
                        Text("\(LocalizationManager.shared.t("best")): \(bestText)")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
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
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(2)
                }
                .buttonStyle(.plain)
            }
            
            Image(systemName: isLocked ? "lock.circle.fill" : "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(isLocked ? .yellow : .gray.opacity(0.6))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.08))
        )
    }
}
