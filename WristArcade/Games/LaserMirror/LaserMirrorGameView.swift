import SwiftUI

public struct LaserMirrorGameView: View {
    struct MirrorCell: Identifiable {
        let id = UUID()
        var mirrorType: String // "╱", "╲", "•"
        var isHit: Bool
    }
    
    @State private var grid: [MirrorCell] = []
    @State private var moves: Int = 0
    @State private var targetHit: Bool = false
    @State private var puzzleLevel: Int = 1
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Lazer Seviye \(puzzleLevel)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.pink)
                Spacer()
                Text("Hamle: \(moves)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 8)
            
            // Grid with Laser emitter on top-left and Target on bottom-right
            HStack(spacing: 4) {
                Text("🔴") // Laser Source
                    .font(.system(size: 10))
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
                    ForEach(0..<grid.count, id: \.self) { idx in
                        Button(action: { toggleMirror(idx) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(grid[idx].isHit ? Color.red.opacity(0.3) : Color.white.opacity(0.08))
                                    .frame(height: 34)
                                
                                Text(grid[idx].mirrorType)
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(grid[idx].isHit ? .red : .cyan)
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(targetHit)
                    }
                }
                
                Text(targetHit ? "💎" : "⚪") // Target Crystal
                    .font(.system(size: 14))
            }
            .padding(4)
            
            Text(targetHit ? "✨ HEDEF KRİSTAL YANDI!" : "Aynaları çevirerek lazeri hedefe ulaştır")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(targetHit ? .yellow : .gray)
            
            if targetHit {
                Button("SONRAKİ BULMACA") { nextPuzzle() }
                    .font(.system(size: 10, weight: .heavy))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .clipShape(Capsule())
            }
        }
        .navigationTitle("Laser Mirror")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { setupPuzzle() }
    }
    
    private func setupPuzzle() {
        moves = 0
        targetHit = false
        grid = [
            MirrorCell(mirrorType: "╱", isHit: true),
            MirrorCell(mirrorType: "╲", isHit: false),
            MirrorCell(mirrorType: "•", isHit: false),
            MirrorCell(mirrorType: "•", isHit: false),
            MirrorCell(mirrorType: "╱", isHit: false),
            MirrorCell(mirrorType: "╲", isHit: false),
            MirrorCell(mirrorType: "╲", isHit: false),
            MirrorCell(mirrorType: "•", isHit: false),
            MirrorCell(mirrorType: "╱", isHit: false)
        ]
    }
    
    private func toggleMirror(_ idx: Int) {
        if grid[idx].mirrorType == "╱" {
            grid[idx].mirrorType = "╲"
        } else if grid[idx].mirrorType == "╲" {
            grid[idx].mirrorType = "╱"
        }
        moves += 1
        haptic.play(.click)
        
        // Puzzle victory condition
        if moves >= 3 && grid[0].mirrorType == "╲" && grid[4].mirrorType == "╱" {
            targetHit = true
            for i in grid.indices { grid[i].isHit = true }
            haptic.play(.victory)
            _ = scoreManager.recordScore(moves, for: "lasermirror")
        } else if moves >= 6 {
            targetHit = true
            for i in grid.indices { grid[i].isHit = true }
            haptic.play(.victory)
            _ = scoreManager.recordScore(moves, for: "lasermirror")
        }
    }
    
    private func nextPuzzle() {
        puzzleLevel += 1
        setupPuzzle()
    }
}
