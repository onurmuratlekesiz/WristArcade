import SwiftUI

public struct Merge2048GameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    @State private var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    @State private var isPlaying: Bool = false
    @State private var isNewRecord: Bool = false
    
    public var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width, geo.size.height) - 10
            let tileSize = (boardSize - 15) / 4
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 4) {
                        // Header HUD
                        HStack {
                            Text("\(score)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "merge2048"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        
                        // 4x4 Board
                        VStack(spacing: 3) {
                            ForEach(0..<4, id: \.self) { r in
                                HStack(spacing: 3) {
                                    ForEach(0..<4, id: \.self) { c in
                                        let val = board[r][c]
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(tileColor(val))
                                                .frame(width: tileSize, height: tileSize)
                                            
                                            if val > 0 {
                                                Text("\(val)")
                                                    .font(.system(size: fontSize(for: val), weight: .heavy, design: .rounded))
                                                    .foregroundColor(textColor(for: val))
                                                    .minimumScaleFactor(0.5)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "GAME OVER")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("RETRY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.orange)
                        
                        Text("NUMBER MERGE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Swipe to combine matching tiles")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 15)
                    .onEnded { gesture in
                        guard isPlaying else { return }
                        let h = gesture.translation.width
                        let v = gesture.translation.height
                        var moved = false
                        if abs(h) > abs(v) {
                            moved = h > 0 ? moveRight() : moveLeft()
                        } else {
                            moved = v > 0 ? moveDown() : moveUp()
                        }
                        
                        if moved {
                            spawnRandomTile()
                            HapticManager.shared.play(.tap)
                            if checkGameOver() {
                                isPlaying = false
                                isGameOver = true
                                isNewRecord = scoreManager.recordScore(score, for: "merge2048")
                                HapticManager.shared.play(.gameOver)
                            }
                        }
                    }
            )
        }
    }
    
    private func startNewGame() {
        board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        isGameOver = false
        isNewRecord = false
        spawnRandomTile()
        spawnRandomTile()
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func spawnRandomTile() {
        var emptyCells: [(Int, Int)] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if board[r][c] == 0 {
                    emptyCells.append((r, c))
                }
            }
        }
        if let cell = emptyCells.randomElement() {
            board[cell.0][cell.1] = Double.random(in: 0...1) < 0.9 ? 2 : 4
        }
    }
    
    // 2048 Slide & Merge logic
    private func slideAndMerge(row: [Int]) -> (newLine: [Int], points: Int, moved: Bool) {
        let nonZero = row.filter { $0 != 0 }
        var result: [Int] = []
        var points = 0
        var skip = false
        
        for i in 0..<nonZero.count {
            if skip {
                skip = false
                continue
            }
            if i + 1 < nonZero.count && nonZero[i] == nonZero[i + 1] {
                let mergedVal = nonZero[i] * 2
                result.append(mergedVal)
                points += mergedVal
                skip = true
            } else {
                result.append(nonZero[i])
            }
        }
        while result.count < 4 {
            result.append(0)
        }
        return (result, points, result != row)
    }
    
    private func moveLeft() -> Bool {
        var movedAny = false
        for r in 0..<4 {
            let res = slideAndMerge(row: board[r])
            if res.moved { movedAny = true }
            board[r] = res.newLine
            score += res.points
        }
        return movedAny
    }
    
    private func moveRight() -> Bool {
        var movedAny = false
        for r in 0..<4 {
            let reversed = Array(board[r].reversed())
            let res = slideAndMerge(row: reversed)
            if res.moved { movedAny = true }
            board[r] = Array(res.newLine.reversed())
            score += res.points
        }
        return movedAny
    }
    
    private func moveUp() -> Bool {
        var movedAny = false
        for c in 0..<4 {
            var col: [Int] = [board[0][c], board[1][c], board[2][c], board[3][c]]
            let res = slideAndMerge(row: col)
            if res.moved { movedAny = true }
            for r in 0..<4 { board[r][c] = res.newLine[r] }
            score += res.points
        }
        return movedAny
    }
    
    private func moveDown() -> Bool {
        var movedAny = false
        for c in 0..<4 {
            var col: [Int] = [board[3][c], board[2][c], board[1][c], board[0][c]]
            let res = slideAndMerge(row: col)
            if res.moved { movedAny = true }
            let normal = Array(res.newLine.reversed())
            for r in 0..<4 { board[r][c] = normal[r] }
            score += res.points
        }
        return movedAny
    }
    
    private func checkGameOver() -> Bool {
        for r in 0..<4 {
            for c in 0..<4 {
                if board[r][c] == 0 { return false }
                if c + 1 < 4 && board[r][c] == board[r][c + 1] { return false }
                if r + 1 < 4 && board[r][c] == board[r + 1][c] { return false }
            }
        }
        return true
    }
    
    private func tileColor(_ value: Int) -> Color {
        switch value {
        case 0: return Color.white.opacity(0.08)
        case 2: return Color(white: 0.85)
        case 4: return Color(white: 0.95)
        case 8: return Color.orange.opacity(0.8)
        case 16: return Color.orange
        case 32: return Color.red.opacity(0.85)
        case 64: return Color.red
        case 128: return Color.yellow.opacity(0.85)
        case 256: return Color.yellow
        case 512: return Color.cyan
        case 1024: return Color.blue
        case 2048: return Color.purple
        default: return Color.pink
        }
    }
    
    private func textColor(for value: Int) -> Color {
        return value <= 4 ? .black : .white
    }
    
    private func fontSize(for value: Int) -> CGFloat {
        if value < 100 { return 11 }
        if value < 1000 { return 9 }
        return 8
    }
}
