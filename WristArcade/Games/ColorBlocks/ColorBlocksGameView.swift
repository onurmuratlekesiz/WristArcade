import SwiftUI

public struct ColorBlocksGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    private let cols = 5
    private let rows = 8
    
    enum BlockColor: Int, CaseIterable {
        case empty = 0
        case red = 1
        case green = 2
        case blue = 3
        case yellow = 4
        
        var color: Color {
            switch self {
            case .empty: return Color.white.opacity(0.06)
            case .red: return Color.red
            case .green: return Color.green
            case .blue: return Color.blue
            case .yellow: return Color.yellow
            }
        }
    }
    
    @State private var grid: [[BlockColor]] = Array(repeating: Array(repeating: .empty, count: 5), count: 8)
    @State private var activeCol: Int = 2
    @State private var activeRow: Int = 0
    @State private var activeBlockColor: BlockColor = .red
    
    @State private var score: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    
    @State private var crownVal: Double = 2.0
    
    var body: some View {
        GeometryReader { geo in
            let boardW = geo.size.width - 24
            let blockSize = boardW / CGFloat(cols)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 3) {
                        // Header HUD
                        HStack {
                            Text("SCORE: \(score)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.pink)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "blockfall"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        
                        // 5x8 Grid
                        VStack(spacing: 2) {
                            ForEach(0..<rows, id: \.self) { r in
                                HStack(spacing: 2) {
                                    ForEach(0..<cols, id: \.self) { c in
                                        let isFalling = (r == activeRow && c == activeCol)
                                        let cellColor = isFalling ? activeBlockColor.color : grid[r][c].color
                                        
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(cellColor)
                                            .frame(width: blockSize, height: blockSize)
                                    }
                                }
                            }
                        }
                        .padding(3)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "GRID FULL!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("PLAY AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.pink)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "square.stack.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.pink)
                        
                        Text("COLOR BLOCKS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Turn Crown to guide falling blocks. Match 3 to pop!")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.pink)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Drop faster
                dropStep()
            }
            .focusable(true)
            .digitalCrownRotation(
                $crownVal,
                from: 0.0,
                through: 4.0,
                by: 1.0,
                sensitivity: .high,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownVal) { newVal in
                activeCol = min(4, max(0, Int(round(newVal))))
            }
            .onReceive(Timer.publish(every: 0.45, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                dropStep()
            }
        }
    }
    
    private func startNewGame() {
        grid = Array(repeating: Array(repeating: .empty, count: cols), count: rows)
        score = 0
        activeCol = 2
        activeRow = 0
        crownVal = 2.0
        activeBlockColor = [BlockColor.red, .green, .blue, .yellow].randomElement()!
        isGameOver = false
        isNewRecord = false
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func dropStep() {
        if activeRow + 1 < rows && grid[activeRow + 1][activeCol] == .empty {
            activeRow += 1
        } else {
            // Lock into place
            grid[activeRow][activeCol] = activeBlockColor
            HapticManager.shared.play(.bounce)
            checkMatches()
            
            // Spawn next
            activeRow = 0
            activeCol = min(4, max(0, Int(round(crownVal))))
            activeBlockColor = [BlockColor.red, .green, .blue, .yellow].randomElement()!
            
            if grid[0][activeCol] != .empty {
                // Top full -> Game Over
                isPlaying = false
                isGameOver = true
                isNewRecord = scoreManager.recordScore(score, for: "blockfall")
                HapticManager.shared.play(.gameOver)
            }
        }
    }
    
    private func checkMatches() {
        var toClear: Set<[Int]> = []
        
        // Horizontal matches of 3
        for r in 0..<rows {
            for c in 0..<(cols - 2) {
                let color = grid[r][c]
                if color != .empty && grid[r][c+1] == color && grid[r][c+2] == color {
                    toClear.insert([r, c])
                    toClear.insert([r, c+1])
                    toClear.insert([r, c+2])
                }
            }
        }
        // Vertical matches of 3
        for c in 0..<cols {
            for r in 0..<(rows - 2) {
                let color = grid[r][c]
                if color != .empty && grid[r+1][c] == color && grid[r+2][c] == color {
                    toClear.insert([r, c])
                    toClear.insert([r+1, c])
                    toClear.insert([r+2, c])
                }
            }
        }
        
        if !toClear.isEmpty {
            for coord in toClear {
                grid[coord[0]][coord[1]] = .empty
            }
            score += toClear.count * 10
            HapticManager.shared.play(.score)
        }
    }
}
