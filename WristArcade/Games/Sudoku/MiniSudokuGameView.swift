import SwiftUI
#if os(watchOS)
import WatchKit
#endif

public struct MiniSudokuGameView: View {
    // 4x4 Mini Sudoku: 4 rows of 4 digits
    // 0 represents empty cell
    struct Cell: Identifiable, Equatable {
        let id: Int
        let row: Int
        let col: Int
        var value: Int
        let isInitial: Bool
        var isError: Bool = false
    }
    
    @State private var grid: [Cell] = []
    @State private var selectedIndex: Int? = nil
    @State private var mistakes: Int = 0
    @State private var isSolved: Bool = false
    @State private var timerSeconds: Int = 0
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // Preset valid 4x4 boards with some clues removed
    private let puzzlePresets: [([[Int]], [[Int]])] = [
        (
            // Solution
            [[1, 2, 3, 4], [3, 4, 1, 2], [2, 1, 4, 3], [4, 3, 2, 1]],
            // Initial Clues (0 = empty)
            [[1, 0, 3, 0], [0, 4, 0, 2], [2, 0, 4, 0], [0, 3, 0, 1]]
        ),
        (
            [[2, 4, 1, 3], [1, 3, 4, 2], [4, 2, 3, 1], [3, 1, 2, 4]],
            [[2, 0, 0, 3], [0, 3, 4, 0], [0, 2, 3, 0], [3, 0, 0, 4]]
        ),
        (
            [[4, 1, 2, 3], [2, 3, 4, 1], [1, 4, 3, 2], [3, 2, 1, 4]],
            [[4, 0, 2, 0], [0, 3, 0, 1], [1, 0, 3, 0], [0, 2, 0, 4]]
        )
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            // Header: Status & Timer
            HStack {
                Text("MINI SUDOKU")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("⏱️ \(timerSeconds)s")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal, 8)
            
            // 4x4 Grid
            let cellWidth: CGFloat = 34
            VStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<4, id: \.self) { col in
                            let index = row * 4 + col
                            if index < grid.count {
                                let cell = grid[index]
                                let isSelected = selectedIndex == index
                                
                                Button(action: {
                                    if !cell.isInitial && !isSolved {
                                        selectedIndex = index
                                        WKInterfaceDevice.current().play(.click)
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                cell.isError ? Color.red.opacity(0.4) :
                                                (isSelected ? Color.blue.opacity(0.4) :
                                                (cell.isInitial ? Color.white.opacity(0.12) : Color.white.opacity(0.06)))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(
                                                        isSelected ? Color.cyan : Color.white.opacity(0.2),
                                                        lineWidth: isSelected ? 2 : 1
                                                    )
                                            )
                                        
                                        if cell.value > 0 {
                                            Text("\(cell.value)")
                                                .font(.system(size: 15, weight: cell.isInitial ? .heavy : .bold))
                                                .foregroundColor(cell.isInitial ? .white : (cell.isError ? .red : .yellow))
                                        }
                                    }
                                    .frame(width: cellWidth, height: cellWidth)
                                }
                                .buttonStyle(.plain)
                                .disabled(cell.isInitial || isSolved)
                            }
                        }
                    }
                    // Thicker divider between 2x2 boxes
                    if row == 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                            .padding(.horizontal, 10)
                    }
                }
            }
            .padding(4)
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)
            
            // Input Number Pad (1, 2, 3, 4, Clear)
            if isSolved {
                VStack(spacing: 4) {
                    Text("SOLVED! 🏆")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.green)
                    
                    Button(action: setupNewPuzzle) {
                        Text("NEW PUZZLE")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 6) {
                    ForEach(1...4, id: \.self) { num in
                        Button(action: {
                            enterNumber(num)
                        }) {
                            Text("\(num)")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 26, height: 26)
                                .background(Color.cyan.opacity(0.25))
                                .foregroundColor(.cyan)
                                .cornerRadius(5)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button(action: {
                        clearCurrentCell()
                    }) {
                        Text("✕")
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 26, height: 26)
                            .background(Color.red.opacity(0.25))
                            .foregroundColor(.red)
                            .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
        }
        .onAppear {
            setupNewPuzzle()
        }
        .onReceive(timer) { _ in
            guard !isSolved else { return }
            timerSeconds += 1
        }
    }
    
    private func setupNewPuzzle() {
        let preset = puzzlePresets.randomElement() ?? puzzlePresets[0]
        var cells: [Cell] = []
        for r in 0..<4 {
            for c in 0..<4 {
                let initialVal = preset.1[r][c]
                cells.append(
                    Cell(
                        id: r * 4 + c,
                        row: r,
                        col: c,
                        value: initialVal,
                        isInitial: initialVal != 0
                    )
                )
            }
        }
        grid = cells
        selectedIndex = nil
        mistakes = 0
        isSolved = false
        timerSeconds = 0
    }
    
    private func enterNumber(_ num: Int) {
        guard let idx = selectedIndex, !grid[idx].isInitial else { return }
        grid[idx].value = num
        WKInterfaceDevice.current().play(.click)
        checkBoard()
    }
    
    private func clearCurrentCell() {
        guard let idx = selectedIndex, !grid[idx].isInitial else { return }
        grid[idx].value = 0
        grid[idx].isError = false
        WKInterfaceDevice.current().play(.click)
    }
    
    private func checkBoard() {
        // Reset errors
        for i in 0..<grid.count {
            grid[i].isError = false
        }
        
        var hasConflict = false
        
        // Check rows
        for r in 0..<4 {
            var seen = [Int: Int]()
            for c in 0..<4 {
                let idx = r * 4 + c
                let val = grid[idx].value
                if val > 0 {
                    if let prevIdx = seen[val] {
                        grid[idx].isError = true
                        grid[prevIdx].isError = true
                        hasConflict = true
                    } else {
                        seen[val] = idx
                    }
                }
            }
        }
        
        // Check columns
        for c in 0..<4 {
            var seen = [Int: Int]()
            for r in 0..<4 {
                let idx = r * 4 + c
                let val = grid[idx].value
                if val > 0 {
                    if let prevIdx = seen[val] {
                        grid[idx].isError = true
                        grid[prevIdx].isError = true
                        hasConflict = true
                    } else {
                        seen[val] = idx
                    }
                }
            }
        }
        
        // Check 2x2 blocks
        let blockOffsets = [(0, 0), (0, 2), (2, 0), (2, 2)]
        for (br, bc) in blockOffsets {
            var seen = [Int: Int]()
            for r in 0..<2 {
                for c in 0..<2 {
                    let idx = (br + r) * 4 + (bc + c)
                    let val = grid[idx].value
                    if val > 0 {
                        if let prevIdx = seen[val] {
                            grid[idx].isError = true
                            grid[prevIdx].isError = true
                            hasConflict = true
                        } else {
                            seen[val] = idx
                        }
                    }
                }
            }
        }
        
        let allFilled = grid.allSatisfy { $0.value > 0 }
        if allFilled && !hasConflict {
            isSolved = true
            WKInterfaceDevice.current().play(.success)
            let score = max(50, 1000 - timerSeconds * 5)
            _ = ScoreManager.shared.recordScore(score, for: "minisudoku")
            _ = XPManager.shared.addXP(75, reason: "Mini Sudoku Solved")
        }
    }
}
