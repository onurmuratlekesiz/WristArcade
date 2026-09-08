import SwiftUI

struct TowerBlock: Identifiable {
    let id: Int
    var x: Double
    var width: Double
    var color: Color
}

public struct TowerStackerGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var tower: [TowerBlock] = []
    @State private var movingX: Double = 0
    @State private var movingWidth: Double = 70
    @State private var direction: Double = 2.4
    @State private var isGameOver: Bool = false
    @State private var score: Int = 0
    @State private var perfectStreak: Int = 0
    @State private var showingInfo: Bool = false
    
    private let blockColors: [Color] = [.cyan, .mint, .green, .yellow, .orange, .pink, .purple, .blue]
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "towerstack" })!
    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack {
                Button(action: {
                    HapticManager.shared.play(.tap)
                    showingInfo = true
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.cyan)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(i18n.isTurkish ? "KAT: \(score)" : "FLOOR \(score)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.cyan)
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.play(.tap)
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 6)
            
            // Stacker Arena
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    Color.black.cornerRadius(8)
                    
                    // Fixed Base & Tower blocks (shows top 7)
                    let visibleBlocks = tower.suffix(7)
                    VStack(spacing: 2) {
                        Spacer()
                        ForEach(Array(visibleBlocks.enumerated()), id: \.offset) { _, block in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(block.color)
                                .frame(width: max(block.width, 10), height: 12)
                                .offset(x: block.x)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    
                    // Moving Current Block (above tower)
                    if !isGameOver {
                        let activeColor = blockColors[score % blockColors.count]
                        RoundedRectangle(cornerRadius: 3)
                            .fill(activeColor)
                            .frame(width: max(movingWidth, 10), height: 12)
                            .offset(x: movingX, y: -Double(min(tower.count, 7)) * 14.0 - 16.0)
                    }
                    
                    // Game Over Overlay
                    if isGameOver {
                        VStack(spacing: 5) {
                            Text(i18n.isTurkish ? "KULE YIKILDI!" : "TOWER FELL")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.pink)
                            Text(i18n.isTurkish ? "\(score) KAT" : "\(score) FLOORS")
                                .font(.system(size: 15, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Button(action: {
                                restartGame()
                            }) {
                                Text(i18n.isTurkish ? "YENİDEN DENE" : "PLAY AGAIN")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.cyan)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(8)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if isGameOver {
                        restartGame()
                    } else {
                        placeBlock()
                    }
                }
                .onReceive(timer) { _ in
                    if !isGameOver {
                        let boundary = geo.size.width / 2 - 20
                        movingX += direction
                        if movingX > boundary {
                            direction = -abs(direction)
                        } else if movingX < -boundary {
                            direction = abs(direction)
                        }
                    }
                }
            }
        }
        .onAppear {
            restartGame()
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoSheet(game: gameInfo)
        }
    }
    
    private func placeBlock() {
        guard let prev = tower.last else { return }
        
        let diff = movingX - prev.x
        let tolerance: Double = 3.0
        
        if abs(diff) <= tolerance {
            // Perfect placement!
            perfectStreak += 1
            HapticManager.shared.play(.success)
            
            // Combo reward: expand block if 3 perfects in a row
            if perfectStreak >= 3 {
                movingWidth = min(movingWidth + 8, 80)
            }
            
            tower.append(TowerBlock(
                id: tower.count,
                x: prev.x,
                width: movingWidth,
                color: blockColors[score % blockColors.count]
            ))
        } else if abs(diff) < movingWidth {
            // Partial slice
            perfectStreak = 0
            HapticManager.shared.play(.click)
            
            let newWidth = movingWidth - abs(diff)
            let newX = prev.x + (diff / 2.0)
            
            movingWidth = newWidth
            tower.append(TowerBlock(
                id: tower.count,
                x: newX,
                width: newWidth,
                color: blockColors[score % blockColors.count]
            ))
        } else {
            // Complete miss -> Game Over
            isGameOver = true
            HapticManager.shared.play(.warning)
            scoreManager.recordScore(score, for: "towerstack")
            return
        }
        
        score += 1
        // Speed up gradually
        let speed = 2.4 + Double(score) * 0.1
        direction = (direction > 0 ? 1 : -1) * min(speed, 6.0)
        movingX = direction > 0 ? -40 : 40
    }
    
    private func restartGame() {
        score = 0
        perfectStreak = 0
        isGameOver = false
        movingWidth = 70
        movingX = -30
        direction = 2.4
        tower = [
            TowerBlock(id: 0, x: 0, width: 70, color: .cyan)
        ]
    }
}
