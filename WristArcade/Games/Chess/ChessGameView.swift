import SwiftUI

public struct ChessGameView: View {
    enum PieceType: String {
        case king = "K", queen = "Q", rook = "R", bishop = "B", knight = "N", pawn = "P"
        
        var symbol: String {
            switch self {
            case .king: return "♔"
            case .queen: return "♕"
            case .rook: return "♖"
            case .bishop: return "♗"
            case .knight: return "♘"
            case .pawn: return "♙"
            }
        }
        
        var value: Int {
            switch self {
            case .pawn: return 10
            case .knight: return 30
            case .bishop: return 30
            case .rook: return 50
            case .queen: return 90
            case .king: return 900
            }
        }
    }
    
    struct ChessPiece: Equatable {
        let isWhite: Bool
        let type: PieceType
    }
    
    // 5x5 Gardner Mini-Chess Board (Optimized for Apple Watch screen touch accuracy)
    // Row 0: Black pieces (R, N, B, Q, K)
    // Row 1: Black pawns
    // Row 2: Empty
    // Row 3: White pawns
    // Row 4: White pieces (R, N, B, Q, K)
    @State private var board: [[ChessPiece?]] = []
    @State private var selectedPos: (r: Int, c: Int)? = nil
    @State private var validMoves: [(r: Int, c: Int)] = []
    
    @State private var statusMessage: String = "Taşını seç ve hamle yap!"
    @State private var isWhiteTurn: Bool = true
    @State private var isGameOver: Bool = false
    @State private var score: Int = 0
    
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
                Text("Skor: \(score)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 6)
            
            // 5x5 Chess Board
            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { r in
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { c in
                            squareView(r: r, c: c)
                        }
                    }
                }
            }
            .background(Color.brown.opacity(0.8))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            
            if isGameOver {
                Button("YENİ OYUN") {
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
        .navigationTitle("Mini Satranç")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startNewGame()
        }
    }
    
    @ViewBuilder
    private func squareView(r: Int, c: Int) -> some View {
        let isLight = (r + c) % 2 == 0
        let isSelected = selectedPos?.r == r && selectedPos?.c == c
        let isValidTarget = validMoves.contains(where: { $0.r == r && $0.c == c })
        let piece = board.indices.contains(r) && board[r].indices.contains(c) ? board[r][c] : nil
        
        Button(action: {
            handleSquareTap(r: r, c: c)
        }) {
            ZStack {
                Rectangle()
                    .fill(isValidTarget ? Color.green.opacity(0.6) : (isSelected ? Color.cyan.opacity(0.6) : (isLight ? Color.white.opacity(0.85) : Color.brown.opacity(0.6))))
                    .frame(width: 28, height: 28)
                
                if let p = piece {
                    Text(p.type.symbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(p.isWhite ? .white : .black)
                        .shadow(color: p.isWhite ? .black : .white.opacity(0.4), radius: 1)
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
        // Initial 5x5 Gardner Board Setup
        board = [
            // Row 0: Black
            [ChessPiece(isWhite: false, type: .rook), ChessPiece(isWhite: false, type: .knight), ChessPiece(isWhite: false, type: .bishop), ChessPiece(isWhite: false, type: .queen), ChessPiece(isWhite: false, type: .king)],
            // Row 1: Black Pawns
            [ChessPiece(isWhite: false, type: .pawn), ChessPiece(isWhite: false, type: .pawn), ChessPiece(isWhite: false, type: .pawn), ChessPiece(isWhite: false, type: .pawn), ChessPiece(isWhite: false, type: .pawn)],
            // Row 2: Empty
            [nil, nil, nil, nil, nil],
            // Row 3: White Pawns
            [ChessPiece(isWhite: true, type: .pawn), ChessPiece(isWhite: true, type: .pawn), ChessPiece(isWhite: true, type: .pawn), ChessPiece(isWhite: true, type: .pawn), ChessPiece(isWhite: true, type: .pawn)],
            // Row 4: White
            [ChessPiece(isWhite: true, type: .rook), ChessPiece(isWhite: true, type: .knight), ChessPiece(isWhite: true, type: .bishop), ChessPiece(isWhite: true, type: .queen), ChessPiece(isWhite: true, type: .king)]
        ]
        
        selectedPos = nil
        validMoves = []
        isWhiteTurn = true
        isGameOver = false
        score = 0
        statusMessage = "Sıra sende (Beyaz)!"
        haptic.play(.click)
    }
    
    private func handleSquareTap(r: Int, c: Int) {
        guard isWhiteTurn && !isGameOver else { return }
        
        // If clicking on already selected piece, deselect
        if let sel = selectedPos, sel.r == r && sel.c == c {
            selectedPos = nil
            validMoves = []
            return
        }
        
        // If valid move target tapped
        if let sel = selectedPos, validMoves.contains(where: { $0.r == r && $0.c == c }) {
            executeMove(from: sel, to: (r, c), isWhite: true)
            selectedPos = nil
            validMoves = []
            
            if !isGameOver {
                isWhiteTurn = false
                statusMessage = "Bot düşünüyor..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    executeBotMove()
                }
            }
            return
        }
        
        // If white piece tapped, select it
        if let piece = board[r][c], piece.isWhite {
            selectedPos = (r, c)
            validMoves = generateMoves(r: r, c: c, isWhite: true)
            haptic.play(.click)
        }
    }
    
    private func executeMove(from: (r: Int, c: Int), to: (r: Int, c: Int), isWhite: Bool) {
        guard let movingPiece = board[from.r][from.c] else { return }
        
        let captured = board[to.r][to.c]
        board[to.r][to.c] = movingPiece
        board[from.r][from.c] = nil
        
        // Pawn promotion at end row
        if movingPiece.type == .pawn {
            if isWhite && to.r == 0 {
                board[to.r][to.c] = ChessPiece(isWhite: true, type: .queen)
            } else if !isWhite && to.r == 4 {
                board[to.r][to.c] = ChessPiece(isWhite: false, type: .queen)
            }
        }
        
        if let cap = captured {
            if isWhite {
                score += cap.type.value
                haptic.play(.click)
            }
            if cap.type == .king {
                isGameOver = true
                if isWhite {
                    score += 500
                    statusMessage = "🏆 ŞAH MAT! KAZANDIN!"
                    haptic.play(.victory)
                } else {
                    statusMessage = "ŞAH MAT! Bot kazandı."
                    haptic.play(.warning)
                }
                _ = scoreManager.recordScore(score, for: "chess")
            }
        } else {
            haptic.play(.click)
        }
    }
    
    private func executeBotMove() {
        guard !isGameOver else { return }
        
        var allBotMoves: [(from: (r: Int, c: Int), to: (r: Int, c: Int), value: Int)] = []
        
        for r in 0..<5 {
            for c in 0..<5 {
                if let piece = board[r][c], !piece.isWhite {
                    let moves = generateMoves(r: r, c: c, isWhite: false)
                    for m in moves {
                        var moveVal = 0
                        if let target = board[m.r][m.c] {
                            moveVal = target.type.value
                        }
                        allBotMoves.append((from: (r, c), to: m, value: moveVal))
                    }
                }
            }
        }
        
        if allBotMoves.isEmpty {
            isGameOver = true
            statusMessage = "🏆 PAT! Oyun bitti."
            return
        }
        
        // Pick best capture or random move
        allBotMoves.sort { $0.value > $1.value }
        let chosen = allBotMoves.first!
        executeMove(from: chosen.from, to: chosen.to, isWhite: false)
        
        if !isGameOver {
            isWhiteTurn = true
            statusMessage = "Senin sıran (Beyaz)!"
        }
    }
    
    private func generateMoves(r: Int, c: Int, isWhite: Bool) -> [(r: Int, c: Int)] {
        guard let piece = board[r][c] else { return [] }
        var result: [(r: Int, c: Int)] = []
        
        func tryAdd(_ nr: Int, _ nc: Int) -> Bool {
            guard nr >= 0 && nr < 5 && nc >= 0 && nc < 5 else { return false }
            if let target = board[nr][nc] {
                if target.isWhite != isWhite {
                    result.append((nr, nc))
                }
                return false // blocked
            } else {
                result.append((nr, nc))
                return true // continue ray
            }
        }
        
        switch piece.type {
        case .pawn:
            let step = isWhite ? -1 : 1
            let fRow = r + step
            if fRow >= 0 && fRow < 5 && board[fRow][c] == nil {
                result.append((fRow, c))
            }
            // diagonal capture
            for dc in [-1, 1] {
                let diagC = c + dc
                if fRow >= 0 && fRow < 5 && diagC >= 0 && diagC < 5 {
                    if let target = board[fRow][diagC], target.isWhite != isWhite {
                        result.append((fRow, diagC))
                    }
                }
            }
            
        case .knight:
            let offsets = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]
            for o in offsets {
                _ = tryAdd(r + o.0, c + o.1)
            }
            
        case .bishop:
            let dirs = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
            for d in dirs {
                var step = 1
                while tryAdd(r + d.0 * step, c + d.1 * step) {
                    step += 1
                }
            }
            
        case .rook:
            let dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
            for d in dirs {
                var step = 1
                while tryAdd(r + d.0 * step, c + d.1 * step) {
                    step += 1
                }
            }
            
        case .queen:
            let dirs = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)]
            for d in dirs {
                var step = 1
                while tryAdd(r + d.0 * step, c + d.1 * step) {
                    step += 1
                }
            }
            
        case .king:
            let dirs = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)]
            for d in dirs {
                _ = tryAdd(r + d.0, c + d.1)
            }
        }
        
        return result
    }
}
