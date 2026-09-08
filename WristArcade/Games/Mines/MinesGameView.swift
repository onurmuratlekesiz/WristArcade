import SwiftUI

public struct MinesGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct Cell: Identifiable {
        let id: Int
        let row: Int
        let col: Int
        var isMine: Bool = false
        var isRevealed: Bool = false
        var isFlagged: Bool = false
        var neighborMines: Int = 0
    }
    
    private let rows = 6
    private let cols = 6
    private let totalMines = 5
    
    @State private var grid: [Cell] = []
    @State private var isFlagMode: Bool = false
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isVictory: Bool = false
    @State private var firstTap: Bool = true
    
    public var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width, geo.size.height) - 20
            let cellSize = (boardSize - 10) / CGFloat(cols)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 4) {
                        // Header HUD
                        HStack {
                            Button(action: {
                                isFlagMode.toggle()
                                HapticManager.shared.play(.tap)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: isFlagMode ? "flag.fill" : "hand.tap.fill")
                                        .font(.system(size: 10))
                                    Text(isFlagMode ? "FLAG" : "DIG")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(isFlagMode ? Color.yellow : Color.cyan)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            HStack(spacing: 3) {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.yellow)
                                Text("\(remainingMinesCount())")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        // 6x6 Grid
                        VStack(spacing: 2) {
                            ForEach(0..<rows, id: \.self) { r in
                                HStack(spacing: 2) {
                                    ForEach(0..<cols, id: \.self) { c in
                                        let index = r * cols + c
                                        let cell = grid[index]
                                        
                                        Button(action: {
                                            handleTap(index: index)
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(cellBgColor(cell))
                                                    .frame(width: cellSize, height: cellSize)
                                                
                                                if cell.isRevealed {
                                                    if cell.isMine {
                                                        Image(systemName: "asterisk.circle.fill")
                                                            .font(.system(size: 11))
                                                            .foregroundColor(.red)
                                                    } else if cell.neighborMines > 0 {
                                                        Text("\(cell.neighborMines)")
                                                            .font(.system(size: 11, weight: .heavy))
                                                            .foregroundColor(numberColor(cell.neighborMines))
                                                    }
                                                } else if cell.isFlagged {
                                                    Image(systemName: "flag.fill")
                                                        .font(.system(size: 9))
                                                        .foregroundColor(.yellow)
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                } else if isGameOver || isVictory {
                    VStack(spacing: 6) {
                        Text(isVictory ? "GRID CLEARED!" : "MINE HIT!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isVictory ? .green : .red)
                        
                        Text(isVictory ? "All mines safely identified!" : "Be careful next time.")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        
                        Button(action: startNewGame) {
                            Text("PLAY AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow)
                        
                        Text("MINE GRID")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Uncover safe tiles without triggering mines")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func remainingMinesCount() -> Int {
        let flagged = grid.filter { $0.isFlagged }.count
        return max(0, totalMines - flagged)
    }
    
    private func startNewGame() {
        var list: [Cell] = []
        var id = 0
        for r in 0..<rows {
            for c in 0..<cols {
                list.append(Cell(id: id, row: r, col: c))
                id += 1
            }
        }
        self.grid = list
        self.isFlagMode = false
        self.firstTap = true
        self.isGameOver = false
        self.isVictory = false
        self.isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func handleTap(index: Int) {
        guard isPlaying, !grid[index].isRevealed else { return }
        
        if isFlagMode {
            grid[index].isFlagged.toggle()
            HapticManager.shared.play(.crownTick)
            checkVictory()
            return
        }
        
        if grid[index].isFlagged { return }
        
        if firstTap {
            firstTap = false
            placeMines(excludingIndex: index)
        }
        
        if grid[index].isMine {
            // Hit mine
            grid[index].isRevealed = true
            for i in 0..<grid.count where grid[i].isMine {
                grid[i].isRevealed = true
            }
            isPlaying = false
            isGameOver = true
            HapticManager.shared.play(.gameOver)
            return
        }
        
        // Safe cell
        revealCell(at: index)
        HapticManager.shared.play(.tap)
        checkVictory()
    }
    
    private func placeMines(excludingIndex: Int) {
        var indices = Array(0..<grid.count)
        indices.removeAll { $0 == excludingIndex }
        indices.shuffle()
        
        for i in 0..<totalMines {
            let mineIdx = indices[i]
            grid[mineIdx].isMine = true
        }
        
        // Calculate neighbors
        for i in 0..<grid.count {
            if !grid[i].isMine {
                grid[i].neighborMines = countNeighbors(for: i)
            }
        }
    }
    
    private func countNeighbors(for index: Int) -> Int {
        let r = grid[index].row
        let c = grid[index].col
        var count = 0
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = r + dr
                let nc = c + dc
                if nr >= 0 && nr < rows && nc >= 0 && nc < cols {
                    let nIdx = nr * cols + nc
                    if grid[nIdx].isMine { count += 1 }
                }
            }
        }
        return count
    }
    
    private func revealCell(at index: Int) {
        guard !grid[index].isRevealed, !grid[index].isFlagged else { return }
        grid[index].isRevealed = true
        
        if grid[index].neighborMines == 0 && !grid[index].isMine {
            let r = grid[index].row
            let c = grid[index].col
            for dr in -1...1 {
                for dc in -1...1 {
                    if dr == 0 && dc == 0 { continue }
                    let nr = r + dr
                    let nc = c + dc
                    if nr >= 0 && nr < rows && nc >= 0 && nc < cols {
                        let nIdx = nr * cols + nc
                        revealCell(at: nIdx)
                    }
                }
            }
        }
    }
    
    private func checkVictory() {
        let unrevealedNonMines = grid.filter { !$0.isMine && !$0.isRevealed }
        if unrevealedNonMines.isEmpty {
            isPlaying = false
            isVictory = true
            _ = scoreManager.recordScore(1, for: "mines")
            HapticManager.shared.play(.victory)
        }
    }
    
    private func cellBgColor(_ cell: Cell) -> Color {
        if cell.isRevealed {
            return cell.isMine ? Color.red.opacity(0.8) : Color.white.opacity(0.2)
        }
        return Color.white.opacity(0.08)
    }
    
    private func numberColor(_ n: Int) -> Color {
        switch n {
        case 1: return .blue
        case 2: return .green
        case 3: return .red
        case 4: return .purple
        default: return .yellow
        }
    }
}
