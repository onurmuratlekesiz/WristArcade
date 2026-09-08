import SwiftUI

public struct TicTacToeGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    enum Player: String {
        case x = "X"
        case o = "O"
        
        var color: Color {
            return self == .x ? .cyan : .pink
        }
    }
    
    @State private var board: [Player?] = Array(repeating: nil, count: 9)
    @State private var currentPlayer: Player = .x
    @State private var isVsAI: Bool = true
    @State private var winner: Player? = nil
    @State private var isDraw: Bool = false
    @State private var isPlaying: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width, geo.size.height) - 24
            let cellSize = (boardSize - 12) / 3
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 4) {
                        // Header info
                        HStack {
                            Text(isVsAI ? "VS AI" : "2-PLAYER")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            if winner == nil && !isDraw {
                                HStack(spacing: 4) {
                                    Text("TURN:")
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.gray)
                                    Text(currentPlayer.rawValue)
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(currentPlayer.color)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        
                        // 3x3 Grid
                        VStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { r in
                                HStack(spacing: 4) {
                                    ForEach(0..<3, id: \.self) { c in
                                        let idx = r * 3 + c
                                        Button(action: {
                                            playerMove(at: idx)
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.white.opacity(0.1))
                                                    .frame(width: cellSize, height: cellSize)
                                                
                                                if let player = board[idx] {
                                                    Text(player.rawValue)
                                                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                                                        .foregroundColor(player.color)
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(board[idx] != nil || winner != nil || isDraw)
                                    }
                                }
                            }
                        }
                        
                        // Result banner & retry
                        if winner != nil || isDraw {
                            HStack(spacing: 8) {
                                Text(winner != nil ? "\(winner!.rawValue) WINS!" : "DRAW!")
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundColor(winner != nil ? winner!.color : .yellow)
                                
                                Button(action: resetGame) {
                                    Text("AGAIN")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 2)
                        }
                    }
                } else {
                    // Mode selector
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.teal)
                        
                        Text("TIC-TAC-TOE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Button(action: {
                            isVsAI = true
                            startNewGame()
                        }) {
                            HStack {
                                Image(systemName: "cpu")
                                Text("VS SMART AI")
                            }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .background(Color.cyan)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        
                        Button(action: {
                            isVsAI = false
                            startNewGame()
                        }) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("PASS & PLAY")
                            }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .background(Color.pink.opacity(0.8))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
    
    private func startNewGame() {
        board = Array(repeating: nil, count: 9)
        currentPlayer = .x
        winner = nil
        isDraw = false
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func resetGame() {
        board = Array(repeating: nil, count: 9)
        currentPlayer = .x
        winner = nil
        isDraw = false
        HapticManager.shared.play(.tap)
    }
    
    private func playerMove(at index: Int) {
        guard board[index] == nil, winner == nil, !isDraw else { return }
        
        board[index] = currentPlayer
        HapticManager.shared.play(.tap)
        
        if checkWin(for: currentPlayer) {
            winner = currentPlayer
            if currentPlayer == .x {
                _ = scoreManager.recordScore(1, for: "tictactoe")
            }
            HapticManager.shared.play(.victory)
            return
        }
        
        if !board.contains(nil) {
            isDraw = true
            HapticManager.shared.play(.bounce)
            return
        }
        
        currentPlayer = (currentPlayer == .x) ? .o : .x
        
        if isVsAI && currentPlayer == .o {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                aiMove()
            }
        }
    }
    
    private func aiMove() {
        guard winner == nil, !isDraw else { return }
        
        // 1. Can AI win right now?
        for i in 0..<9 where board[i] == nil {
            board[i] = .o
            if checkWin(for: .o) {
                winner = .o
                HapticManager.shared.play(.gameOver)
                return
            }
            board[i] = nil
        }
        
        // 2. Can Player win next move? Block them!
        for i in 0..<9 where board[i] == nil {
            board[i] = .x
            if checkWin(for: .x) {
                board[i] = .o
                currentPlayer = .x
                HapticManager.shared.play(.tap)
                return
            }
            board[i] = nil
        }
        
        // 3. Take center if available
        if board[4] == nil {
            board[4] = .o
        } else {
            // 4. Take random available corner/edge
            let available = board.indices.filter { board[$0] == nil }
            if let pick = available.randomElement() {
                board[pick] = .o
            }
        }
        
        if checkWin(for: .o) {
            winner = .o
            HapticManager.shared.play(.gameOver)
            return
        }
        
        if !board.contains(nil) {
            isDraw = true
            HapticManager.shared.play(.bounce)
            return
        }
        
        currentPlayer = .x
        HapticManager.shared.play(.tap)
    }
    
    private func checkWin(for player: Player) -> Bool {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
            [0, 4, 8], [2, 4, 6]             // Diagonals
        ]
        for pattern in winPatterns {
            if board[pattern[0]] == player &&
                board[pattern[1]] == player &&
                board[pattern[2]] == player {
                return true
            }
        }
        return false
    }
}
