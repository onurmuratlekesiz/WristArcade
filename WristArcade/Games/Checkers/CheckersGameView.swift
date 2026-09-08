import SwiftUI

public struct CheckersGameView: View {
    struct CheckerPiece: Equatable {
        let isPlayer: Bool // true: Red/Player, false: Black/Bot
        var isKing: Bool = false
    }
    
    // 6x6 Compact Checkers Board
    @State private var board: [[CheckerPiece?]] = []
    @State private var selectedPos: (r: Int, c: Int)? = nil
    @State private var validMoves: [(r: Int, c: Int, jumpR: Int?, jumpC: Int?)] = []
    
    @State private var statusMessage: String = "Taşını seç ve çapraz ilerle!"
    @State private var isPlayerTurn: Bool = true
    @State private var isGameOver: Bool = false
    @State private var score: Int = 0
    @State private var capturedByPlayer: Int = 0
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack {
                Text(statusMessage)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.yellow)
                    .lineLimit(1)
                Spacer()
                Text("Alınan: \(capturedByPlayer)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 6)
            
            // 6x6 Board
            VStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { r in
                    HStack(spacing: 0) {
                        ForEach(0..<6, id: \.self) { c in
                            squareView(r: r, c: c)
                        }
                    }
                }
            }
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            
            if isGameOver {
                Button("YENİDEN BAŞLA") {
                    startNewGame()
                }
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.yellow)
                .clipShape(Capsule())
            }
        }
        .navigationTitle("Klasik Dama")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startNewGame()
        }
    }
    
    @ViewBuilder
    private func squareView(r: Int, c: Int) -> some View {
        let isDark = (r + c) % 2 != 0
        let isSelected = selectedPos?.r == r && selectedPos?.c == c
        let isValidTarget = validMoves.contains(where: { $0.r == r && $0.c == c })
        let piece = board.indices.contains(r) && board[r].indices.contains(c) ? board[r][c] : nil
        
        Button(action: {
            handleSquareTap(r: r, c: c)
        }) {
            ZStack {
                Rectangle()
                    .fill(isValidTarget ? Color.green.opacity(0.7) : (isSelected ? Color.yellow.opacity(0.5) : (isDark ? Color.black.opacity(0.8) : Color.gray.opacity(0.3))))
                    .frame(width: 25, height: 25)
                
                if let p = piece {
                    Circle()
                        .fill(p.isPlayer ? Color.red : Color.gray)
                        .frame(width: 18, height: 18)
                        .shadow(color: .black.opacity(0.5), radius: 1)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if p.isKing {
                                    Text("👑").font(.system(size: 8))
                                }
                            }
                        )
                } else if isValidTarget {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private func startNewGame() {
        // 6x6 Checkers setup:
        // Rows 0-1: Black/Bot pieces on dark squares
        // Row 2-3: Empty
        // Rows 4-5: Red/Player pieces on dark squares
        var newBoard: [[CheckerPiece?]] = Array(repeating: Array(repeating: nil, count: 6), count: 6)
        
        for r in 0...1 {
            for c in 0..<6 where (r + c) % 2 != 0 {
                newBoard[r][c] = CheckerPiece(isPlayer: false)
            }
        }
        
        for r in 4...5 {
            for c in 0..<6 where (r + c) % 2 != 0 {
                newBoard[r][c] = CheckerPiece(isPlayer: true)
            }
        }
        
        board = newBoard
        selectedPos = nil
        validMoves = []
        isPlayerTurn = true
        isGameOver = false
        score = 0
        capturedByPlayer = 0
        statusMessage = "Sıra sende (Kırmızı)!"
        haptic.play(.click)
    }
    
    private func handleSquareTap(r: Int, c: Int) {
        guard isPlayerTurn && !isGameOver else { return }
        
        // Deselect
        if let sel = selectedPos, sel.r == r && sel.c == c {
            selectedPos = nil
            validMoves = []
            return
        }
        
        // Execute move
        if let sel = selectedPos, let targetMove = validMoves.first(where: { $0.r == r && $0.c == c }) {
            executeMove(from: sel, move: targetMove, isPlayer: true)
            selectedPos = nil
            validMoves = []
            
            if !isGameOver {
                isPlayerTurn = false
                statusMessage = "Bot düşünüyor..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    executeBotMove()
                }
            }
            return
        }
        
        // Select player piece
        if let p = board[r][c], p.isPlayer {
            selectedPos = (r, c)
            validMoves = generateMoves(r: r, c: c, isPlayer: true)
            haptic.play(.click)
        }
    }
    
    private func executeMove(from: (r: Int, c: Int), move: (r: Int, c: Int, jumpR: Int?, jumpC: Int?), isPlayer: Bool) {
        var movingPiece = board[from.r][from.c]!
        board[from.r][from.c] = nil
        
        // King promotion
        if isPlayer && move.r == 0 {
            movingPiece.isKing = true
            haptic.play(.victory)
        } else if !isPlayer && move.r == 5 {
            movingPiece.isKing = true
        }
        
        board[move.r][move.c] = movingPiece
        
        // If it was a jump, remove jumped piece
        if let jr = move.jumpR, let jc = move.jumpC {
            board[jr][jc] = nil
            if isPlayer {
                capturedByPlayer += 1
                score += 50
                haptic.play(.victory)
            } else {
                haptic.play(.warning)
            }
        } else {
            haptic.play(.click)
        }
        
        checkGameOver()
    }
    
    private func executeBotMove() {
        guard !isGameOver else { return }
        
        var allBotMoves: [(from: (r: Int, c: Int), move: (r: Int, c: Int, jumpR: Int?, jumpC: Int?))] = []
        var jumpMoves: [(from: (r: Int, c: Int), move: (r: Int, c: Int, jumpR: Int?, jumpC: Int?))] = []
        
        for r in 0..<6 {
            for c in 0..<6 {
                if let p = board[r][c], !p.isPlayer {
                    let moves = generateMoves(r: r, c: c, isPlayer: false)
                    for m in moves {
                        if m.jumpR != nil {
                            jumpMoves.append(((r, c), m))
                        } else {
                            allBotMoves.append(((r, c), m))
                        }
                    }
                }
            }
        }
        
        let pool = !jumpMoves.isEmpty ? jumpMoves : allBotMoves
        if pool.isEmpty {
            isGameOver = true
            score += 200
            statusMessage = "🏆 KAZANDIN! Bot hamlesiz kaldı."
            haptic.play(.victory)
            _ = scoreManager.recordScore(score, for: "checkers")
            return
        }
        
        let chosen = pool.randomElement()!
        executeMove(from: chosen.from, move: chosen.move, isPlayer: false)
        
        if !isGameOver {
            isPlayerTurn = true
            statusMessage = "Sıra sende (Kırmızı)!"
        }
    }
    
    private func generateMoves(r: Int, c: Int, isPlayer: Bool) -> [(r: Int, c: Int, jumpR: Int?, jumpC: Int?)] {
        guard let p = board[r][c] else { return [] }
        var moves: [(r: Int, c: Int, jumpR: Int?, jumpC: Int?)] = []
        
        let rowDirs: [Int]
        if p.isKing {
            rowDirs = [-1, 1]
        } else {
            rowDirs = [isPlayer ? -1 : 1]
        }
        let colDirs = [-1, 1]
        
        for dr in rowDirs {
            for dc in colDirs {
                let nr = r + dr
                let nc = c + dc
                
                // Regular 1-step move
                if nr >= 0 && nr < 6 && nc >= 0 && nc < 6 && board[nr][nc] == nil {
                    moves.append((nr, nc, nil, nil))
                }
                
                // Jump 2-step move over opposing piece
                let jr = r + 2 * dr
                let jc = c + 2 * dc
                if jr >= 0 && jr < 6 && jc >= 0 && jc < 6 && board[jr][jc] == nil {
                    if let midPiece = board[nr][nc], midPiece.isPlayer != isPlayer {
                        moves.append((jr, jc, nr, nc))
                    }
                }
            }
        }
        
        return moves
    }
    
    private func checkGameOver() {
        var playerCount = 0
        var botCount = 0
        
        for row in board {
            for cell in row {
                if let p = cell {
                    if p.isPlayer { playerCount += 1 } else { botCount += 1 }
                }
            }
        }
        
        if botCount == 0 {
            isGameOver = true
            score += 300
            statusMessage = "🏆 TEBRİKLER! DAMA ŞAMPİYONU!"
            haptic.play(.victory)
            _ = scoreManager.recordScore(score, for: "checkers")
        } else if playerCount == 0 {
            isGameOver = true
            statusMessage = "OYUN BİTTİ! Bot kazandı."
            haptic.play(.warning)
        }
    }
}
