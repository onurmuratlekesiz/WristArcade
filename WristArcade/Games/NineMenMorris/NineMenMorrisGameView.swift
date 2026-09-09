import SwiftUI
#if os(watchOS)
import WatchKit
#endif

public struct NineMenMorrisGameView: View {
    enum GamePhase: Equatable {
        case placing
        case moving
        case removing(byPlayer: Bool)
        case gameOver(playerWon: Bool)
    }
    
    // 24 Board Points: 0..7 (Outer), 8..15 (Middle), 16..23 (Inner)
    // 0: Empty, 1: Player (Cyan), 2: Bot (Orange)
    @State private var board: [Int] = Array(repeating: 0, count: 24)
    @State private var playerUnplaced: Int = 9
    @State private var botUnplaced: Int = 9
    @State private var phase: GamePhase = .placing
    @State private var isPlayerTurn: Bool = true
    @State private var selectedIndex: Int? = nil
    @State private var statusText: String = "Taşını boş noktaya koy (9 kaldı)"
    @State private var score: Int = 0
    
    private let haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    // Node coordinates in 170x170 box
    private let nodeCoords: [CGPoint] = [
        // Outer (0..7)
        CGPoint(x: 12, y: 12), CGPoint(x: 85, y: 12), CGPoint(x: 158, y: 12),
        CGPoint(x: 158, y: 85), CGPoint(x: 158, y: 158), CGPoint(x: 85, y: 158),
        CGPoint(x: 12, y: 158), CGPoint(x: 12, y: 85),
        // Middle (8..15)
        CGPoint(x: 36, y: 36), CGPoint(x: 85, y: 36), CGPoint(x: 134, y: 36),
        CGPoint(x: 134, y: 85), CGPoint(x: 134, y: 134), CGPoint(x: 85, y: 134),
        CGPoint(x: 36, y: 134), CGPoint(x: 36, y: 85),
        // Inner (16..23)
        CGPoint(x: 60, y: 60), CGPoint(x: 85, y: 60), CGPoint(x: 110, y: 60),
        CGPoint(x: 110, y: 85), CGPoint(x: 110, y: 110), CGPoint(x: 85, y: 110),
        CGPoint(x: 60, y: 110), CGPoint(x: 60, y: 85)
    ]
    
    // Adjacency Graph
    private let adjacencies: [[Int]] = [
        [1, 7],         // 0
        [0, 2, 9],      // 1
        [1, 3],         // 2
        [2, 4, 11],     // 3
        [3, 5],         // 4
        [4, 6, 13],     // 5
        [5, 7],         // 6
        [6, 0, 15],     // 7
        [9, 15],        // 8
        [8, 10, 1, 17], // 9
        [9, 11],        // 10
        [10, 12, 3, 19],// 11
        [11, 13],       // 12
        [12, 14, 5, 21],// 13
        [14, 8, 7, 23], // 14
        [13, 15],       // 15
        [17, 23],       // 16
        [16, 18, 9],    // 17
        [17, 19],       // 18
        [18, 20, 11],   // 19
        [19, 21],       // 20
        [20, 22, 13],   // 21
        [21, 23],       // 22
        [22, 16, 15]    // 23
    ]
    
    // 16 Mill triplets (3-in-a-row)
    private let mills: [[Int]] = [
        // Outer
        [0, 1, 2], [2, 3, 4], [4, 5, 6], [6, 7, 0],
        // Middle
        [8, 9, 10], [10, 11, 12], [12, 13, 14], [14, 15, 8],
        // Inner
        [16, 17, 18], [18, 19, 20], [20, 21, 22], [22, 23, 16],
        // Cross connections
        [1, 9, 17], [3, 11, 19], [5, 13, 21], [7, 15, 23]
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 2) {
            // Header HUD
            HStack {
                Text(statusText)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(isPlayerTurn ? .cyan : .orange)
                    .lineLimit(1)
                Spacer()
                // Piece counters
                HStack(spacing: 3) {
                    Text("P:\(playerPiecesCount)")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.cyan)
                    Text("B:\(botPiecesCount)")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 4)
            
            // Nine Men's Morris Board
            ZStack {
                // Background Lines
                boardLinesView
                
                // 24 Interactive Nodes
                ForEach(0..<24, id: \.self) { idx in
                    nodeView(idx: idx)
                        .position(nodeCoords[idx])
                }
            }
            .frame(width: 170, height: 170)
            
            // Bottom Status / Controls
            if case .gameOver(let won) = phase {
                Button(action: resetGame) {
                    Text(won ? "👑 ZAFER! YENİDEN OYNA" : "💀 YENİDEN DENE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(won ? Color.yellow : Color.orange)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            resetGame()
        }
    }
    
    // MARK: - Board Lines View
    private var boardLinesView: some View {
        Canvas { context, size in
            var path = Path()
            
            // Outer square
            path.addLines([nodeCoords[0], nodeCoords[2], nodeCoords[4], nodeCoords[6], nodeCoords[0]])
            // Middle square
            path.addLines([nodeCoords[8], nodeCoords[10], nodeCoords[12], nodeCoords[14], nodeCoords[8]])
            // Inner square
            path.addLines([nodeCoords[16], nodeCoords[18], nodeCoords[20], nodeCoords[22], nodeCoords[16]])
            
            // Cross lines connecting midpoints
            path.move(to: nodeCoords[1]); path.addLine(to: nodeCoords[17])
            path.move(to: nodeCoords[3]); path.addLine(to: nodeCoords[19])
            path.move(to: nodeCoords[5]); path.addLine(to: nodeCoords[21])
            path.move(to: nodeCoords[7]); path.addLine(to: nodeCoords[23])
            
            context.stroke(path, with: .color(Color.white.opacity(0.35)), lineWidth: 1.5)
        }
    }
    
    // MARK: - Node View
    private func nodeView(idx: Int) -> some View {
        let val = board[idx]
        let isSelected = selectedIndex == idx
        let isRemovable = isRemovingPhase && isRemovableStone(idx: idx)
        let isValidMoveTarget = selectedIndex != nil && isValidMove(from: selectedIndex!, to: idx)
        
        return Button(action: {
            handleNodeTap(idx: idx)
        }) {
            ZStack {
                // Outer ring for selected or target
                if isSelected {
                    Circle()
                        .stroke(Color.yellow, lineWidth: 2)
                        .frame(width: 18, height: 18)
                } else if isRemovable {
                    Circle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: 18, height: 18)
                } else if isValidMoveTarget {
                    Circle()
                        .stroke(Color.green, lineWidth: 2)
                        .frame(width: 16, height: 16)
                }
                
                // Stone or empty slot
                if val == 1 {
                    // Player stone (Cyan)
                    Circle()
                        .fill(RadialGradient(colors: [.white, .cyan], center: .center, startRadius: 1, endRadius: 6))
                        .frame(width: 13, height: 13)
                        .shadow(color: .cyan.opacity(0.8), radius: 3)
                } else if val == 2 {
                    // Bot stone (Orange)
                    Circle()
                        .fill(RadialGradient(colors: [.white, .orange], center: .center, startRadius: 1, endRadius: 6))
                        .frame(width: 13, height: 13)
                        .shadow(color: .orange.opacity(0.8), radius: 3)
                } else {
                    // Empty slot dot
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Tap Handler
    private func handleNodeTap(idx: Int) {
        guard isPlayerTurn else { return }
        
        switch phase {
        case .placing:
            if board[idx] == 0 {
                haptic.playClick()
                board[idx] = 1
                playerUnplaced -= 1
                
                if checkMillFormed(at: idx, player: 1) {
                    haptic.playSuccess()
                    phase = .removing(byPlayer: true)
                    statusText = "Değirmen! Rakip taşı kaldır."
                } else {
                    checkPlacingDoneAndSwitchTurn()
                }
            }
            
        case .moving:
            if board[idx] == 1 {
                // Select stone to move
                haptic.playClick()
                selectedIndex = idx
                statusText = "Hedef noktayı seç"
            } else if let from = selectedIndex, board[idx] == 0, isValidMove(from: from, to: idx) {
                // Move stone
                haptic.playClick()
                board[from] = 0
                board[idx] = 1
                selectedIndex = nil
                
                if checkMillFormed(at: idx, player: 1) {
                    haptic.playSuccess()
                    phase = .removing(byPlayer: true)
                    statusText = "Değirmen! Rakip taşı kaldır."
                } else {
                    endPlayerTurn()
                }
            }
            
        case .removing(let byPlayer):
            if byPlayer && isRemovableStone(idx: idx) {
                haptic.playImpact()
                board[idx] = 0
                score += 10
                
                // Check if bot lost
                if botPiecesCount < 3 && botUnplaced == 0 {
                    playerWonGame()
                } else {
                    if playerUnplaced > 0 || botUnplaced > 0 {
                        phase = .placing
                    } else {
                        phase = .moving
                    }
                    endPlayerTurn()
                }
            }
            
        case .gameOver:
            break
        }
    }
    
    // MARK: - Turn & Phase Transitions
    private func checkPlacingDoneAndSwitchTurn() {
        if playerUnplaced == 0 && botUnplaced == 0 {
            phase = .moving
        }
        endPlayerTurn()
    }
    
    private func endPlayerTurn() {
        isPlayerTurn = false
        statusText = "Bot düşünüyor..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            executeBotTurn()
        }
    }
    
    // MARK: - Bot AI
    private func executeBotTurn() {
        guard !isGameOver else { return }
        
        if botUnplaced > 0 {
            // Placing phase
            let bestSpot = botFindBestPlaceSpot()
            board[bestSpot] = 2
            botUnplaced -= 1
            haptic.playClick()
            
            if checkMillFormed(at: bestSpot, player: 2) {
                haptic.playFailure()
                botRemovePlayerStone()
            }
            
            if playerUnplaced == 0 && botUnplaced == 0 {
                phase = .moving
            }
            endBotTurn()
            
        } else {
            // Moving phase
            if let (from, to) = botFindBestMove() {
                board[from] = 0
                board[to] = 2
                haptic.playClick()
                
                if checkMillFormed(at: to, player: 2) {
                    haptic.playFailure()
                    botRemovePlayerStone()
                }
                
                // Check if player lost
                if playerPiecesCount < 3 && playerUnplaced == 0 {
                    botWonGame()
                    return
                }
                endBotTurn()
            } else {
                // Bot has no legal moves -> Player wins!
                playerWonGame()
            }
        }
    }
    
    private func endBotTurn() {
        if playerPiecesCount < 3 && playerUnplaced == 0 {
            botWonGame()
            return
        }
        
        isPlayerTurn = true
        if phase == .placing {
            statusText = "Taşını koy (\(playerUnplaced) kaldı)"
        } else {
            let isFlying = playerPiecesCount == 3
            statusText = isFlying ? "Uçuş modu! İstediğin yere taşı" : "Taşını seç ve hareket et"
        }
    }
    
    private func botFindBestPlaceSpot() -> Int {
        // 1. Can bot make a mill?
        for i in 0..<24 where board[i] == 0 {
            board[i] = 2
            let mill = checkMillFormed(at: i, player: 2)
            board[i] = 0
            if mill { return i }
        }
        
        // 2. Can player make a mill? Block it!
        for i in 0..<24 where board[i] == 0 {
            board[i] = 1
            let mill = checkMillFormed(at: i, player: 1)
            board[i] = 0
            if mill { return i }
        }
        
        // 3. Strategic intersections (midpoints have 4 liberties)
        let priorities = [9, 11, 13, 15, 1, 3, 5, 7, 17, 19, 21, 23, 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22]
        for p in priorities where board[p] == 0 {
            return p
        }
        
        let empties = (0..<24).filter { board[$0] == 0 }
        return empties.randomElement() ?? 0
    }
    
    private func botFindBestMove() -> (Int, Int)? {
        let isFlying = botPiecesCount == 3
        var allMoves: [(from: Int, to: Int, formsMill: Bool)] = []
        
        for from in 0..<24 where board[from] == 2 {
            let possibleTos = isFlying ? (0..<24).filter { board[$0] == 0 } : adjacencies[from].filter { board[$0] == 0 }
            for to in possibleTos {
                board[from] = 0
                board[to] = 2
                let formsMill = checkMillFormed(at: to, player: 2)
                board[from] = 2
                board[to] = 0
                allMoves.append((from, to, formsMill))
            }
        }
        
        if allMoves.isEmpty { return nil }
        
        // Prioritize mill
        if let millMove = allMoves.first(where: { $0.formsMill }) {
            return (millMove.from, millMove.to)
        }
        
        return (allMoves.randomElement()!.from, allMoves.randomElement()!.to)
    }
    
    private func botRemovePlayerStone() {
        let candidates = (0..<24).filter { board[$0] == 1 }
        // Try to remove a stone not in a mill
        let notInMill = candidates.filter { !checkIsInMill(at: $0, player: 1) }
        let target = notInMill.randomElement() ?? candidates.randomElement()
        if let t = target {
            board[t] = 0
        }
    }
    
    // MARK: - Mill & Move Logic
    private func checkMillFormed(at idx: Int, player: Int) -> Bool {
        for mill in mills where mill.contains(idx) {
            if mill.allSatisfy({ board[$0] == player }) {
                return true
            }
        }
        return false
    }
    
    private func checkIsInMill(at idx: Int, player: Int) -> Bool {
        return checkMillFormed(at: idx, player: player)
    }
    
    private func isValidMove(from: Int, to: Int) -> Bool {
        guard board[to] == 0 else { return false }
        let isFlying = (isPlayerTurn ? playerPiecesCount : botPiecesCount) == 3
        if isFlying { return true }
        return adjacencies[from].contains(to)
    }
    
    private func isRemovableStone(idx: Int) -> Bool {
        guard board[idx] == 2 else { return false }
        let inMill = checkIsInMill(at: idx, player: 2)
        if !inMill { return true }
        // If ALL bot stones are in mills, any can be removed
        let allInMills = (0..<24).filter { board[$0] == 2 }.allSatisfy { checkIsInMill(at: $0, player: 2) }
        return allInMills
    }
    
    private var isRemovingPhase: Bool {
        if case .removing(let byPlayer) = phase, byPlayer { return true }
        return false
    }
    
    private var isGameOver: Bool {
        if case .gameOver = phase { return true }
        return false
    }
    
    private var playerPiecesCount: Int {
        board.filter { $0 == 1 }.count
    }
    
    private var botPiecesCount: Int {
        board.filter { $0 == 2 }.count
    }
    
    private func playerWonGame() {
        phase = .gameOver(playerWon: true)
        statusText = "👑 ZAFER! 9 TAŞ KAZANDIN"
        haptic.playVictory()
        _ = scoreManager.recordScore(score + 100, for: "ninemensmorris")
        _ = XPManager.shared.addXP(100, reason: "9 Taş Zaferi")
    }
    
    private func botWonGame() {
        phase = .gameOver(playerWon: false)
        statusText = "💀 OYUN BİTTİ! BOT KAZANDI"
        haptic.playFailure()
    }
    
    private func resetGame() {
        board = Array(repeating: 0, count: 24)
        playerUnplaced = 9
        botUnplaced = 9
        phase = .placing
        isPlayerTurn = true
        selectedIndex = nil
        score = 0
        statusText = "Taşını boş noktaya koy (9 kaldı)"
    }
}
