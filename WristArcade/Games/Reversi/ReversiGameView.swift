import SwiftUI

public struct ReversiGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var soundManager = SoundManager.shared
    
    // 6x6 Board = 36 cells. 0: empty, 1: Player (Black), 2: AI (White)
    @State private var board: [Int] = Array(repeating: 0, count: 36)
    @State private var isPlayerTurn: Bool = true
    @State private var isGameOver: Bool = false
    @State private var statusText: String = "Your Turn (Black)"
    
    private let directions = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1),          (0, 1),
        (1, -1),  (1, 0),  (1, 1)
    ]
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                // Score Header
                HStack {
                    HStack(spacing: 4) {
                        Circle().fill(Color.black).frame(width: 10, height: 10).overlay(Circle().stroke(Color.white, lineWidth: 1))
                        Text("\(countDiscs(for: 1))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    
                    Spacer()
                    
                    Text(statusText)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle().fill(Color.white).frame(width: 10, height: 10)
                        Text("\(countDiscs(for: 2))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 6)
                
                // 6x6 Grid
                VStack(spacing: 2) {
                    ForEach(0..<6, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<6, id: \.self) { col in
                                let index = row * 6 + col
                                let canMove = isPlayerTurn && !isGameOver && !getFlippable(for: 1, at: index).isEmpty
                                
                                Button(action: {
                                    handlePlayerMove(at: index)
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.green.opacity(0.4))
                                            .frame(width: 23, height: 23)
                                            .cornerRadius(2)
                                        
                                        if board[index] == 1 {
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 17, height: 17)
                                                .overlay(Circle().stroke(Color.cyan, lineWidth: 1))
                                        } else if board[index] == 2 {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 17, height: 17)
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                        } else if canMove {
                                            Circle()
                                                .stroke(Color.yellow, lineWidth: 2)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .disabled(!canMove)
                            }
                        }
                    }
                }
                .padding(3)
                .background(Color.green.opacity(0.2))
                .cornerRadius(6)
                
                if isGameOver {
                    VStack(spacing: 4) {
                        let p = countDiscs(for: 1)
                        let b = countDiscs(for: 2)
                        Text(p > b ? "YOU WIN! 🏆" : (p < b ? "AI WINS!" : "DRAW!"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(p >= b ? .green : .red)
                        
                        Button(action: startNewGame) {
                            Text("New Match")
                                .font(.system(size: 11, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .background(Color.cyan)
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear(perform: startNewGame)
    }
    
    private func countDiscs(for player: Int) -> Int {
        board.filter { $0 == player }.count
    }
    
    private func getFlippable(for player: Int, at index: Int) -> [Int] {
        guard board[index] == 0 else { return [] }
        let row = index / 6
        let col = index % 6
        let opponent = (player == 1 ? 2 : 1)
        var flippable: [Int] = []
        
        for (dr, dc) in directions {
            var r = row + dr
            var c = col + dc
            var line: [Int] = []
            
            while r >= 0 && r < 6 && c >= 0 && c < 6 {
                let cellIdx = r * 6 + c
                if board[cellIdx] == opponent {
                    line.append(cellIdx)
                } else if board[cellIdx] == player {
                    flippable.append(contentsOf: line)
                    break
                } else {
                    break
                }
                r += dr
                c += dc
            }
        }
        return flippable
    }
    
    private func handlePlayerMove(at index: Int) {
        let flips = getFlippable(for: 1, at: index)
        guard !flips.isEmpty else { return }
        
        board[index] = 1
        for f in flips { board[f] = 1 }
        
        soundManager.play(.flip)
        HapticManager.shared.play(.tap)
        
        isPlayerTurn = false
        statusText = "AI thinking..."
        
        checkGameEndOrPass(nextPlayer: 2)
    }
    
    private func aiTurn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard !isGameOver else { return }
            
            // Collect all valid moves for AI
            var validMoves: [(index: Int, flips: [Int], score: Int)] = []
            let corners = Set([0, 5, 30, 35])
            
            for i in 0..<36 {
                let flips = getFlippable(for: 2, at: i)
                if !flips.isEmpty {
                    var score = flips.count
                    if corners.contains(i) { score += 20 }
                    validMoves.append((i, flips, score))
                }
            }
            
            if let bestMove = validMoves.max(by: { $0.score < $1.score }) {
                board[bestMove.index] = 2
                for f in bestMove.flips { board[f] = 2 }
                soundManager.play(.flip)
                HapticManager.shared.play(.crownTick)
            }
            
            isPlayerTurn = true
            statusText = "Your Turn"
            checkGameEndOrPass(nextPlayer: 1)
        }
    }
    
    private func checkGameEndOrPass(nextPlayer: Int) {
        let pMoves = (0..<36).filter { !getFlippable(for: 1, at: $0).isEmpty }
        let bMoves = (0..<36).filter { !getFlippable(for: 2, at: $0).isEmpty }
        
        if pMoves.isEmpty && bMoves.isEmpty {
            // Game Over
            isGameOver = true
            let pCount = countDiscs(for: 1)
            let bCount = countDiscs(for: 2)
            if pCount > bCount {
                soundManager.play(.victory)
                HapticManager.shared.play(.victory)
                scoreManager.saveHighScore(pCount, for: "reversi")
                scoreManager.addXP(150)
            } else {
                soundManager.play(.gameOver)
            }
            return
        }
        
        if nextPlayer == 2 {
            if bMoves.isEmpty {
                // AI passes
                isPlayerTurn = true
                statusText = "AI passed! Your Turn"
            } else {
                aiTurn()
            }
        } else {
            if pMoves.isEmpty {
                // Player passes
                isPlayerTurn = false
                statusText = "No moves! Pass to AI"
                aiTurn()
            }
        }
    }
    
    private func startNewGame() {
        board = Array(repeating: 0, count: 36)
        // Set standard 4 center discs
        board[2 * 6 + 2] = 2
        board[2 * 6 + 3] = 1
        board[3 * 6 + 2] = 1
        board[3 * 6 + 3] = 2
        
        isPlayerTurn = true
        isGameOver = false
        statusText = "Your Turn (Black)"
    }
}
