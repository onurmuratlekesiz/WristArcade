import SwiftUI

public struct SeaBattleGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var soundManager = SoundManager.shared
    
    // Grid 5x5 = 25 cells (0..24)
    // 0: unrevealed, 1: miss (water), 2: hit (ship part damaged)
    @State private var grid: [Int] = Array(repeating: 0, count: 25)
    @State private var shipCells: Set<Int> = []
    @State private var torpedosUsed: Int = 0
    @State private var maxTorpedos: Int = 18
    @State private var isGameOver: Bool = false
    @State private var hasWon: Bool = false
    @State private var statusMessage: String = "Fire Sonar Torpedo!"
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                // Top Radar Header
                HStack {
                    Label("\(torpedosUsed)/\(maxTorpedos)", systemImage: "bolt.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(torpedosUsed > 14 ? .orange : .cyan)
                    
                    Spacer()
                    
                    Text("Hits: \(shipCells.filter { grid[$0] == 2 }.count)/\(shipCells.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 8)
                
                // 5x5 Radar Grid
                VStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(0..<5, id: \.self) { col in
                                let index = row * 5 + col
                                cellView(at: index)
                            }
                        }
                    }
                }
                .padding(4)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                )
                
                Text(statusMessage)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                if isGameOver {
                    VStack(spacing: 4) {
                        Text(hasWon ? "FLEET DESTROYED! 🏆" : "OUT OF TORPEDOS! 💥")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(hasWon ? .green : .red)
                        
                        Button(action: startNewGame) {
                            Text("Play Again")
                                .font(.system(size: 12, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Color.cyan)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 6)
        }
        .onAppear(perform: startNewGame)
    }
    
    @ViewBuilder
    private func cellView(at index: Int) -> some View {
        Button(action: {
            fireTorpedo(at: index)
        }) {
            ZStack {
                Rectangle()
                    .fill(cellColor(for: grid[index]))
                    .frame(width: 28, height: 28)
                    .cornerRadius(4)
                
                if grid[index] == 1 {
                    Circle()
                        .fill(Color.cyan.opacity(0.6))
                        .frame(width: 8, height: 8)
                } else if grid[index] == 2 {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(grid[index] != 0 || isGameOver)
    }
    
    private func cellColor(for state: Int) -> Color {
        switch state {
        case 1: return Color.blue.opacity(0.3)
        case 2: return Color.red.opacity(0.35)
        default: return Color.white.opacity(0.1)
        }
    }
    
    private func fireTorpedo(at index: Int) {
        guard grid[index] == 0, !isGameOver else { return }
        
        torpedosUsed += 1
        
        if shipCells.contains(index) {
            grid[index] = 2
            soundManager.play(.explosion)
            HapticManager.shared.play(.score)
            statusMessage = "DIRECT HIT!"
            
            // Check win
            let hits = shipCells.filter { grid[$0] == 2 }.count
            if hits == shipCells.count {
                hasWon = true
                isGameOver = true
                soundManager.play(.victory)
                HapticManager.shared.play(.victory)
                let score = max(10, 1000 - (torpedosUsed * 40))
                scoreManager.saveHighScore(score, for: "seabattle")
                scoreManager.addXP(150)
                statusMessage = "All ships sunk in \(torpedosUsed) shots!"
            }
        } else {
            grid[index] = 1
            soundManager.play(.point)
            HapticManager.shared.play(.tap)
            statusMessage = "Splash... Water miss."
            
            if torpedosUsed >= maxTorpedos {
                isGameOver = true
                hasWon = false
                soundManager.play(.gameOver)
                HapticManager.shared.play(.gameOver)
                statusMessage = "Defeat! Fleets escaped."
            }
        }
    }
    
    private func startNewGame() {
        grid = Array(repeating: 0, count: 25)
        torpedosUsed = 0
        isGameOver = false
        hasWon = false
        statusMessage = "Tap grid to fire torpedo!"
        
        // Spawn 3 ships: 3-cell Cruiser, 2-cell Sub, 1-cell Patrol
        var occupied = Set<Int>()
        
        // 3-cell Cruiser
        let cruiserHorizontal = Bool.random()
        if cruiserHorizontal {
            let r = Int.random(in: 0..<5)
            let c = Int.random(in: 0...2)
            for i in 0..<3 { occupied.insert(r * 5 + (c + i)) }
        } else {
            let r = Int.random(in: 0...2)
            let c = Int.random(in: 0..<5)
            for i in 0..<3 { occupied.insert((r + i) * 5 + c) }
        }
        
        // 2-cell Submarine
        var subPlaced = false
        var attempts = 0
        while !subPlaced && attempts < 50 {
            attempts += 1
            let isHoriz = Bool.random()
            var candidate = Set<Int>()
            if isHoriz {
                let r = Int.random(in: 0..<5)
                let c = Int.random(in: 0...3)
                candidate.insert(r * 5 + c)
                candidate.insert(r * 5 + c + 1)
            } else {
                let r = Int.random(in: 0...3)
                let c = Int.random(in: 0..<5)
                candidate.insert(r * 5 + c)
                candidate.insert((r + 1) * 5 + c)
            }
            if candidate.isDisjoint(with: occupied) {
                occupied.formUnion(candidate)
                subPlaced = true
            }
        }
        
        // 1-cell Patrol
        var patrolPlaced = false
        while !patrolPlaced {
            let cell = Int.random(in: 0..<25)
            if !occupied.contains(cell) {
                occupied.insert(cell)
                patrolPlaced = true
            }
        }
        
        shipCells = occupied
    }
}
