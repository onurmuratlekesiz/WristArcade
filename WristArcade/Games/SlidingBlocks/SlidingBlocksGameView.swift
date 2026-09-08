import SwiftUI

public struct SlidingBlocksGameView: View {
    struct Block: Identifiable, Equatable {
        let id: Int
        var r: Int
        var c: Int
        let length: Int
        let isHorizontal: Bool
        let isTarget: Bool // Red target key block
        
        var color: Color {
            isTarget ? .red : (isHorizontal ? .cyan : .orange)
        }
    }
    
    // 6x6 Board Grid with exit gate at row 2, col 5
    @State private var blocks: [Block] = []
    @State private var selectedBlockId: Int? = nil
    @State private var moves: Int = 0
    @State private var level: Int = 1
    @State private var isWon: Bool = false
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack {
                Text("Bölüm \(level)")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Hamle: \(moves)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
                Button("↺") {
                    loadLevel(level)
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.cyan)
            }
            .padding(.horizontal, 6)
            
            // 6x6 Board with Exit Indicator on the right
            ZStack(alignment: .trailing) {
                // Exit Slot Marker
                Rectangle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 4, height: 26)
                    .offset(x: 4, y: -26) // Row 2 level
                
                // 6x6 Grid Background
                VStack(spacing: 1) {
                    ForEach(0..<6, id: \.self) { r in
                        HStack(spacing: 1) {
                            ForEach(0..<6, id: \.self) { c in
                                Rectangle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
                .padding(2)
                .background(Color.brown.opacity(0.3))
                .cornerRadius(4)
                .overlay(
                    // Render Active Blocks
                    ZStack(alignment: .topLeading) {
                        ForEach(blocks) { block in
                            blockView(block)
                        }
                    }
                )
            }
            
            // On-screen arrows to slide selected block
            if let selId = selectedBlockId, let b = blocks.first(where: { $0.id == selId }) {
                HStack(spacing: 12) {
                    if b.isHorizontal {
                        Button(action: { slideBlock(b, delta: -1) }) {
                            Text("◀ SOL").font(.system(size: 9, weight: .heavy)).frame(width: 44, height: 18)
                        }
                        .buttonStyle(.bordered)
                        Button(action: { slideBlock(b, delta: 1) }) {
                            Text("SAĞ ▶").font(.system(size: 9, weight: .heavy)).frame(width: 44, height: 18)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button(action: { slideBlock(b, delta: -1) }) {
                            Text("▲ YUKARI").font(.system(size: 8, weight: .heavy)).frame(width: 52, height: 18)
                        }
                        .buttonStyle(.bordered)
                        Button(action: { slideBlock(b, delta: 1) }) {
                            Text("▼ AŞAĞI").font(.system(size: 8, weight: .heavy)).frame(width: 52, height: 18)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.top, 2)
            } else {
                Text("Kaydırmak için bir bloğa dokun")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                    .frame(height: 18)
            }
            
            if isWon {
                Button("SONRAKİ BÖLÜM ➔") {
                    level = (level % 3) + 1
                    loadLevel(level)
                }
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.green)
                .clipShape(Capsule())
            }
        }
        .navigationTitle("Kayıcı Bloklar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadLevel(1)
        }
    }
    
    @ViewBuilder
    private func blockView(_ block: Block) -> some View {
        let isSelected = selectedBlockId == block.id
        let cellW: CGFloat = 25
        let cellH: CGFloat = 25
        
        let w: CGFloat = block.isHorizontal ? (CGFloat(block.length) * cellW - 2) : (cellW - 2)
        let h: CGFloat = block.isHorizontal ? (cellH - 2) : (CGFloat(block.length) * cellH - 2)
        
        let x: CGFloat = CGFloat(block.c) * cellW + 1
        let y: CGFloat = CGFloat(block.r) * cellH + 1
        
        Button(action: {
            selectedBlockId = block.id
            haptic.play(.click)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(block.color)
                    .frame(width: w, height: h)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(isSelected ? Color.white : Color.black.opacity(0.3), lineWidth: isSelected ? 1.5 : 0.5)
                    )
                if block.isTarget {
                    Text("🗝️").font(.system(size: 9))
                }
            }
        }
        .buttonStyle(.plain)
        .offset(x: x, y: y)
    }
    
    private func loadLevel(_ lvl: Int) {
        moves = 0
        isWon = false
        selectedBlockId = nil
        
        switch lvl {
        case 1:
            // Easy Level
            blocks = [
                Block(id: 1, r: 2, c: 1, length: 2, isHorizontal: true, isTarget: true), // Target Red
                Block(id: 2, r: 1, c: 3, length: 3, isHorizontal: false, isTarget: false), // Vertical obstacle
                Block(id: 3, r: 4, c: 1, length: 2, isHorizontal: true, isTarget: false),
                Block(id: 4, r: 0, c: 0, length: 2, isHorizontal: false, isTarget: false),
                Block(id: 5, r: 0, c: 2, length: 2, isHorizontal: true, isTarget: false)
            ]
        case 2:
            // Medium Level
            blocks = [
                Block(id: 1, r: 2, c: 0, length: 2, isHorizontal: true, isTarget: true),
                Block(id: 2, r: 0, c: 2, length: 3, isHorizontal: false, isTarget: false),
                Block(id: 3, r: 1, c: 3, length: 2, isHorizontal: true, isTarget: false),
                Block(id: 4, r: 2, c: 4, length: 2, isHorizontal: false, isTarget: false),
                Block(id: 5, r: 3, c: 1, length: 2, isHorizontal: false, isTarget: false),
                Block(id: 6, r: 4, c: 2, length: 2, isHorizontal: true, isTarget: false)
            ]
        default:
            // Hard Level
            blocks = [
                Block(id: 1, r: 2, c: 1, length: 2, isHorizontal: true, isTarget: true),
                Block(id: 2, r: 1, c: 3, length: 3, isHorizontal: false, isTarget: false),
                Block(id: 3, r: 0, c: 4, length: 2, isHorizontal: false, isTarget: false),
                Block(id: 4, r: 4, c: 3, length: 2, isHorizontal: true, isTarget: false),
                Block(id: 5, r: 3, c: 0, length: 2, isHorizontal: false, isTarget: false),
                Block(id: 6, r: 5, c: 1, length: 3, isHorizontal: true, isTarget: false)
            ]
        }
        haptic.play(.click)
    }
    
    private func slideBlock(_ block: Block, delta: Int) {
        guard let idx = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        
        let newR = block.isHorizontal ? block.r : block.r + delta
        let newC = block.isHorizontal ? block.c + delta : block.c
        
        // Bounds check
        if block.isHorizontal {
            if newC < 0 || newC + block.length > 6 { return }
        } else {
            if newR < 0 || newR + block.length > 6 { return }
        }
        
        // Collision check with other blocks
        for other in blocks where other.id != block.id {
            for step in 0..<block.length {
                let cellR = block.isHorizontal ? newR : newR + step
                let cellC = block.isHorizontal ? newC + step : newC
                
                for otherStep in 0..<other.length {
                    let otherCellR = other.isHorizontal ? other.r : other.r + otherStep
                    let otherCellC = other.isHorizontal ? other.c + otherStep : other.c
                    if cellR == otherCellR && cellC == otherCellC {
                        haptic.play(.warning)
                        return
                    }
                }
            }
        }
        
        // Move successful
        blocks[idx].r = newR
        blocks[idx].c = newC
        moves += 1
        haptic.play(.click)
        
        // Check win condition (Target block reaches col 4 where col 4+2=6 reaches exit)
        if blocks[idx].isTarget && blocks[idx].r == 2 && blocks[idx].c == 4 {
            isWon = true
            haptic.play(.victory)
            _ = scoreManager.recordScore(moves, for: "slidingblocks")
        }
    }
}
