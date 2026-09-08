import SwiftUI

public struct MazeMuncherGameView: View {
    enum Direction {
        case up, down, left, right
        
        var offset: (r: Int, c: Int) {
            switch self {
            case .up: return (-1, 0)
            case .down: return (1, 0)
            case .left: return (0, -1)
            case .right: return (0, 1)
            }
        }
    }
    
    // 9x9 Compact Watch Maze Grid
    // 1: Wall, 0: Dot, 2: Power Pellet, 3: Empty
    private let initialGrid: [[Int]] = [
        [1,1,1,1,1,1,1,1,1],
        [1,2,0,0,1,0,0,2,1],
        [1,0,1,0,1,0,1,0,1],
        [1,0,0,0,0,0,0,0,1],
        [1,1,0,1,3,1,0,1,1],
        [1,0,0,0,0,0,0,0,1],
        [1,0,1,0,1,0,1,0,1],
        [1,2,0,0,1,0,0,2,1],
        [1,1,1,1,1,1,1,1,1]
    ]
    
    @State private var grid: [[Int]] = []
    @State private var playerR: Int = 5
    @State private var playerC: Int = 4
    @State private var currentDir: Direction = .right
    
    // Ghost Positions
    @State private var ghost1: (r: Int, c: Int) = (3, 3)
    @State private var ghost2: (r: Int, c: Int) = (3, 5)
    @State private var powerTimer: Int = 0 // Seconds remaining of ghost vulnerability
    
    @State private var score: Int = 0
    @State private var lives: Int = 3
    @State private var isGameOver: Bool = false
    @State private var isWon: Bool = false
    @State private var timer: Timer? = nil
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 3) {
            // Header Bar
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<lives, id: \.self) { _ in
                        Text("🟡").font(.system(size: 8))
                    }
                }
                Spacer()
                Text("Skor: \(score)")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.yellow)
                if powerTimer > 0 {
                    Text("⚡\(powerTimer)s")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal, 8)
            
            // Maze Canvas
            VStack(spacing: 1) {
                ForEach(0..<grid.count, id: \.self) { r in
                    HStack(spacing: 1) {
                        ForEach(0..<grid[r].count, id: \.self) { c in
                            cellView(r: r, c: c)
                        }
                    }
                }
            }
            .padding(3)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
            )
            
            // On-Screen Direction Controls
            HStack(spacing: 8) {
                Button(action: { changeDir(.left) }) {
                    Text("◀").font(.system(size: 11, weight: .black)).frame(width: 28, height: 20)
                }
                .buttonStyle(.bordered)
                
                VStack(spacing: 2) {
                    Button(action: { changeDir(.up) }) {
                        Text("▲").font(.system(size: 10, weight: .black)).frame(width: 26, height: 16)
                    }
                    .buttonStyle(.bordered)
                    Button(action: { changeDir(.down) }) {
                        Text("▼").font(.system(size: 10, weight: .black)).frame(width: 26, height: 16)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: { changeDir(.right) }) {
                    Text("▶").font(.system(size: 11, weight: .black)).frame(width: 28, height: 20)
                }
                .buttonStyle(.bordered)
            }
            
            if isGameOver || isWon {
                Button(isWon ? "🎉 TEBRİKLER! YENİ TUR" : "TEKRAR DENE") {
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
        .navigationTitle("Maze Muncher")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startNewGame()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    @ViewBuilder
    private func cellView(r: Int, c: Int) -> some View {
        let isPlayer = (r == playerR && c == playerC)
        let isG1 = (r == ghost1.r && c == ghost1.c)
        let isG2 = (r == ghost2.r && c == ghost2.c)
        let val = grid.indices.contains(r) && grid[r].indices.contains(c) ? grid[r][c] : 1
        
        ZStack {
            if val == 1 {
                // Wall
                Rectangle()
                    .fill(Color.blue)
                    .cornerRadius(1)
            } else {
                Rectangle()
                    .fill(Color.black)
                
                if val == 0 {
                    Circle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: 3, height: 3)
                } else if val == 2 {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)
                }
            }
            
            if isPlayer {
                Text("🟡")
                    .font(.system(size: 9))
            } else if isG1 || isG2 {
                Text(powerTimer > 0 ? "🔵" : (isG1 ? "🔴" : "🟣"))
                    .font(.system(size: 9))
            }
        }
        .frame(width: 14, height: 14)
    }
    
    private func changeDir(_ d: Direction) {
        currentDir = d
        haptic.play(.click)
    }
    
    private func startNewGame() {
        grid = initialGrid
        playerR = 5
        playerC = 4
        currentDir = .right
        ghost1 = (3, 3)
        ghost2 = (3, 5)
        score = 0
        lives = 3
        powerTimer = 0
        isGameOver = false
        isWon = false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.38, repeats: true) { _ in
            gameTick()
        }
    }
    
    private func gameTick() {
        guard !isGameOver && !isWon else { return }
        
        if powerTimer > 0 {
            powerTimer -= 1
        }
        
        // Move player
        let nextR = playerR + currentDir.offset.r
        let nextC = playerC + currentDir.offset.c
        
        if canMoveTo(r: nextR, c: nextC) {
            playerR = nextR
            playerC = nextC
            
            // Eat dot or power pellet
            if grid[playerR][playerC] == 0 {
                grid[playerR][playerC] = 3
                score += 10
                haptic.play(.click)
            } else if grid[playerR][playerC] == 2 {
                grid[playerR][playerC] = 3
                score += 50
                powerTimer = 10 // 10 steps of vulnerability
                haptic.play(.victory)
            }
        }
        
        // Move Ghosts
        moveGhost(&ghost1)
        moveGhost(&ghost2)
        
        // Check collisions
        checkCollisions()
        
        // Check dots remaining
        var dotsLeft = 0
        for row in grid {
            for cell in row where cell == 0 || cell == 2 {
                dotsLeft += 1
            }
        }
        
        if dotsLeft == 0 {
            isWon = true
            score += 200
            haptic.play(.victory)
            timer?.invalidate()
            _ = scoreManager.recordScore(score, for: "mazemuncher")
        }
    }
    
    private func canMoveTo(r: Int, c: Int) -> Bool {
        guard r >= 0 && r < grid.count && c >= 0 && c < grid[0].count else { return false }
        return grid[r][c] != 1
    }
    
    private func moveGhost(_ ghost: inout (r: Int, c: Int)) {
        let dirs: [Direction] = [.up, .down, .left, .right]
        var validMoves: [(r: Int, c: Int)] = []
        
        for d in dirs {
            let nr = ghost.r + d.offset.r
            let nc = ghost.c + d.offset.c
            if canMoveTo(r: nr, c: nc) {
                validMoves.append((nr, nc))
            }
        }
        
        if !validMoves.isEmpty {
            // If vulnerable, move away from player, else towards
            if powerTimer > 0 {
                validMoves.sort { dist($0, (playerR, playerC)) > dist($1, (playerR, playerC)) }
            } else {
                validMoves.sort { dist($0, (playerR, playerC)) < dist($1, (playerR, playerC)) }
            }
            ghost = validMoves.first!
        }
    }
    
    private func dist(_ p1: (r: Int, c: Int), _ p2: (r: Int, c: Int)) -> Int {
        return abs(p1.r - p2.r) + abs(p1.c - p2.c)
    }
    
    private func checkCollisions() {
        let coll1 = (playerR == ghost1.r && playerC == ghost1.c)
        let coll2 = (playerR == ghost2.r && playerC == ghost2.c)
        
        if coll1 || coll2 {
            if powerTimer > 0 {
                score += 100
                haptic.play(.victory)
                if coll1 { ghost1 = (1, 1) }
                if coll2 { ghost2 = (1, 7) }
            } else {
                lives -= 1
                haptic.play(.warning)
                playerR = 5
                playerC = 4
                if lives <= 0 {
                    isGameOver = true
                    timer?.invalidate()
                    _ = scoreManager.recordScore(score, for: "mazemuncher")
                }
            }
        }
    }
}
