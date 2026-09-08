import SwiftUI

struct MatrixTile: Identifiable {
    let id: Int
    var number: Int? // nil if empty
    var isRevealed: Bool
    var isCleared: Bool
}

public struct MemoryMatrixGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var level: Int = 1
    @State private var tiles: [MatrixTile] = []
    @State private var isShowingNumbers: Bool = true
    @State private var nextTarget: Int = 1
    @State private var isGameOver: Bool = false
    @State private var showingInfo: Bool = false
    @State private var score: Int = 0
    
    private let gridSize = 3 // 3x3 = 9 cells
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "memorymatrix" })!
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 5) {
            // Header
            HStack {
                Button(action: {
                    HapticManager.shared.play(.tap)
                    showingInfo = true
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.indigo)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(i18n.isTurkish ? "SEVİYE \(level)" : "LVL \(level)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.indigo)
                
                Spacer()
                
                Text("\(score) P")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
                
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
            
            // Sub-status
            Text(isShowingNumbers ? (i18n.isTurkish ? "Sayıları Ezberle!" : "Memorize Numbers!") : (i18n.isTurkish ? "Sırayla Dokun: \(nextTarget)" : "Tap Next: \(nextTarget)"))
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(isShowingNumbers ? .cyan : .yellow)
            
            // 3x3 Grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(tiles) { tile in
                    Button(action: {
                        handleTileTap(tile)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(tileBackgroundColor(tile))
                                .frame(height: 38)
                            
                            if let num = tile.number {
                                if isShowingNumbers || tile.isCleared {
                                    Text("\(num)")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(tile.isCleared ? .gray : .white)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(tile.number == nil || isShowingNumbers || tile.isCleared || isGameOver)
                }
            }
            .padding(.horizontal, 6)
            
            // Game Over overlay
            if isGameOver {
                VStack(spacing: 3) {
                    Text(i18n.isTurkish ? "YANLIŞ SIRA!" : "WRONG SEQUENCE!")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.red)
                    Button(action: {
                        restartGame()
                    }) {
                        Text(i18n.isTurkish ? "YENİDEN BAŞLA" : "RESTART")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.indigo)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
        }
        .onAppear {
            restartGame()
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoSheet(game: gameInfo)
        }
    }
    
    private func tileBackgroundColor(_ tile: MatrixTile) -> Color {
        guard let _ = tile.number else {
            return Color.gray.opacity(0.12)
        }
        if tile.isCleared {
            return Color.green.opacity(0.25)
        }
        if isShowingNumbers {
            return Color.indigo
        }
        return Color.white // Masked blank tile
    }
    
    private func handleTileTap(_ tile: MatrixTile) {
        guard let num = tile.number, !isShowingNumbers, !isGameOver else { return }
        
        if num == nextTarget {
            // Correct tap!
            HapticManager.shared.play(.click)
            if let idx = tiles.firstIndex(where: { $0.id == tile.id }) {
                tiles[idx].isCleared = true
            }
            
            let totalTargets = min(3 + level, 8)
            if nextTarget == totalTargets {
                // Level cleared!
                score += level * 50
                level += 1
                HapticManager.shared.play(.success)
                scoreManager.recordScore(score, for: "memorymatrix")
                startLevel()
            } else {
                nextTarget += 1
            }
        } else {
            // Wrong tap!
            isGameOver = true
            HapticManager.shared.play(.warning)
            scoreManager.recordScore(score, for: "memorymatrix")
        }
    }
    
    private func startLevel() {
        nextTarget = 1
        isShowingNumbers = true
        isGameOver = false
        
        let count = min(3 + level, 8)
        var numbers = Array(1...count)
        numbers.shuffle()
        
        var availableSlots = Array(0..<9)
        availableSlots.shuffle()
        
        var newTiles: [MatrixTile] = (0..<9).map { MatrixTile(id: $0, number: nil, isRevealed: false, isCleared: false) }
        
        for i in 0..<count {
            let slot = availableSlots[i]
            newTiles[slot].number = i + 1
        }
        
        tiles = newTiles
        
        // Hide numbers after delay
        let hideDelay = max(1.6 - Double(level) * 0.1, 0.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowingNumbers = false
            }
        }
    }
    
    private func restartGame() {
        score = 0
        level = 1
        startLevel()
    }
}
