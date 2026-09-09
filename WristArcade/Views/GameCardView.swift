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
        HStack(spacing: isWatchOS ? 8 : 12) {
            // Game Icon
            ZStack {
                RoundedRectangle(cornerRadius: isWatchOS ? 9 : 12)
                    .fill(game.accentColor.opacity(0.2))
                    .frame(width: isWatchOS ? 36 : 48, height: isWatchOS ? 36 : 48)
                
                Image(systemName: game.systemIcon)
                    .font(.system(size: isWatchOS ? 17 : 22))
                    .foregroundColor(game.accentColor)
            }
            
            // Text info
            VStack(alignment: .leading, spacing: isWatchOS ? 2 : 3) {
                HStack(spacing: 4) {
                    Text(game.localizedTitle)
                        .font(.system(size: isWatchOS ? 12 : 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: isWatchOS ? 9 : 12))
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(game.localizedSubtitle)
                    .font(.system(size: isWatchOS ? 9 : 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                if highScore > 0 && !isLocked {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: isWatchOS ? 8 : 11))
                            .foregroundColor(.yellow)
                        
                        let bestText: String = {
                            if game.id == "reflextap" || game.id == "speednumbers" {
                                return String(format: "%.2fs", Double(highScore) / 1000.0)
                            }
                            return "\(highScore)"
                        }()
                        
                        Text("\(LocalizationManager.shared.t("best")): \(bestText)")
                            .font(.system(size: isWatchOS ? 8 : 11, weight: .semibold, design: .monospaced))
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
                        .font(.system(size: isWatchOS ? 14 : 20))
                        .foregroundColor(.gray)
                        .padding(isWatchOS ? 2 : 4)
                }
                .buttonStyle(.plain)
            }
            
            Image(systemName: isLocked ? "lock.circle.fill" : "chevron.right")
                .font(.system(size: isWatchOS ? 11 : 14))
                .foregroundColor(isLocked ? .yellow : .gray.opacity(0.6))
        }
        .padding(.horizontal, isWatchOS ? 8 : 12)
        .padding(.vertical, isWatchOS ? 6 : 10)
        .background(
            RoundedRectangle(cornerRadius: isWatchOS ? 10 : 14)
                .fill(Color.white.opacity(0.08))
        )
    }
}
