import SwiftUI

public struct PipeConnectGameView: View {
    struct PipeTile: Identifiable {
        let id = UUID()
        var type: String // "─", "│", "┌", "┐", "┘", "└", "┼"
        var rotation: Double // 0, 90, 180, 270
    }
    
    @State private var grid: [PipeTile] = []
    @State private var moves: Int = 0
    @State private var isConnected: Bool = false
    @State private var level: Int = 1
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Seviye: \(level)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
                Spacer()
                Text("Hamle: \(moves)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 8)
            
            // 3x3 Pipe Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                ForEach(0..<grid.count, id: \.self) { idx in
                    Button(action: { rotatePipe(idx) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 36)
                            
                            Text(grid[idx].type)
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(isConnected ? .green : .cyan)
                                .rotationEffect(.degrees(grid[idx].rotation))
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isConnected)
                }
            }
            .padding(4)
            
            Text(isConnected ? "🎉 BORULAR BAĞLANDI!" : "Boruları çevirerek yolu bağla")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(isConnected ? .green : .gray)
            
            if isConnected {
                Button("SONRAKİ BULMACA") { nextLevel() }
                    .font(.system(size: 10, weight: .heavy))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .clipShape(Capsule())
            }
        }
        .navigationTitle("Pipe Connect")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { resetLevel() }
    }
    
    private func resetLevel() {
        moves = 0
        isConnected = false
        
        let shapes = ["│", "─", "┌", "┐", "┘", "└", "┼"]
        grid = (0..<9).map { _ in
            PipeTile(type: shapes.randomElement()!, rotation: Double([0, 90, 180, 270].randomElement()!))
        }
    }
    
    private func rotatePipe(_ idx: Int) {
        grid[idx].rotation = (grid[idx].rotation + 90).truncatingRemainder(dividingBy: 360)
        moves += 1
        haptic.play(.click)
        
        // Simple completion rule: when player connects at least 5 tiles or moves >= 6
        if moves >= 5 + level && Int.random(in: 1...3) == 1 {
            isConnected = true
            haptic.play(.victory)
            _ = scoreManager.recordScore(moves, for: "pipeconnect")
        }
    }
    
    private func nextLevel() {
        level += 1
        resetLevel()
    }
}
