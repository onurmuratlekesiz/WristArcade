import SwiftUI

public struct NumberSlideGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    // 3x3 grid: 0 represents the blank space
    @State private var board: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 0]
    @State private var moveCount: Int = 0
    @State private var isSolved: Bool = false
    @State private var showingInfo: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "numberslide" })!
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                // Header
                HStack {
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        showingInfo = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.mint)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(i18n.isTurkish ? "RAKAM KAYDIRMA" : "NUMBER SLIDE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.mint)
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)
                
                // Status Bar (Moves / Best)
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(i18n.t("moves").uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(moveCount)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        shuffleBoard()
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.mint)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(i18n.t("best").uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        let bestMoves = scoreManager.getHighScore(for: "numberslide")
                        Text(bestMoves > 0 ? "\(bestMoves)" : "--")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 6)
                
                if isSolved {
                    VStack(spacing: 4) {
                        Text(i18n.t("you_win"))
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.green)
                        Text(i18n.isTurkish ? "\(moveCount) hamlede çözüldü!" : "Solved in \(moveCount) moves!")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                        
                        Button(action: {
                            shuffleBoard()
                        }) {
                            Text(i18n.t("tap_to_restart"))
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 26)
                                .background(Color.mint)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.top, 2)
                    }
                    .padding(.vertical, 8)
                } else {
                    // 3x3 Sliding Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                        ForEach(0..<9, id: \.self) { idx in
                            let val = board[idx]
                            Button(action: {
                                handleTileTap(at: idx)
                            }) {
                                ZStack {
                                    if val == 0 {
                                        // Empty hole
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.black.opacity(0.3))
                                    } else {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.mint.opacity(0.2))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.mint.opacity(0.4), lineWidth: 1)
                                            )
                                        
                                        Text("\(val)")
                                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(height: 38)
                            }
                            .buttonStyle(.plain)
                            .disabled(val == 0)
                        }
                    }
                    .padding(.horizontal, 6)
                }
            }
            .padding(.bottom, 6)
        }
        .onAppear {
            shuffleBoard()
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoSheet(game: gameInfo)
        }
    }
    
    private func shuffleBoard() {
        var current = [1, 2, 3, 4, 5, 6, 7, 8, 0]
        var blankIdx = 8
        
        // Guarantee solvable state by simulating 40 random legal moves
        for _ in 0..<40 {
            let neighbors = getNeighbors(of: blankIdx)
            if let next = neighbors.randomElement() {
                current.swapAt(blankIdx, next)
                blankIdx = next
            }
        }
        
        board = current
        moveCount = 0
        isSolved = false
        HapticManager.shared.play(.tap)
    }
    
    private func getNeighbors(of idx: Int) -> [Int] {
        var res: [Int] = []
        let row = idx / 3
        let col = idx % 3
        
        if row > 0 { res.append(idx - 3) }
        if row < 2 { res.append(idx + 3) }
        if col > 0 { res.append(idx - 1) }
        if col < 2 { res.append(idx + 1) }
        return res
    }
    
    private func handleTileTap(at idx: Int) {
        guard !isSolved else { return }
        guard let blankIdx = board.firstIndex(of: 0) else { return }
        
        let neighbors = getNeighbors(of: blankIdx)
        if neighbors.contains(idx) {
            // Valid move: swap with blank
            board.swapAt(idx, blankIdx)
            moveCount += 1
            HapticManager.shared.play(.click)
            
            // Check victory
            if board == [1, 2, 3, 4, 5, 6, 7, 8, 0] {
                isSolved = true
                _ = scoreManager.recordScore(moveCount, for: "numberslide")
                HapticManager.shared.play(.victory)
            }
        } else {
            HapticManager.shared.play(.failure)
        }
    }
}
