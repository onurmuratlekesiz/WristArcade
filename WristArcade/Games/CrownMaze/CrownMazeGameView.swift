import SwiftUI

public struct CrownMazeGameView: View {
    @State private var crownAngle: Double = 0.0
    @State private var currentRing: Int = 3 // 3 = outer, 2 = mid, 1 = inner, 0 = goal!
    @State private var marbleAngle: Double = 0.0
    
    // Slot angles for each ring
    @State private var ringSlotAngles: [Double] = [0, 90, 210, 315]
    @State private var score: Int = 0
    @State private var level: Int = 1
    @State private var isGoalReached: Bool = false
    
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
                Text("Skor: \(score)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 8)
            
            // Concentric Maze Rings
            ZStack {
                // Ring 3 (Outer)
                Circle()
                    .stroke(currentRing == 3 ? Color.cyan : Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(crownAngle))
                
                // Ring 2 (Middle)
                Circle()
                    .stroke(currentRing == 2 ? Color.cyan : Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 85, height: 85)
                    .rotationEffect(.degrees(crownAngle * 1.5))
                
                // Ring 1 (Inner)
                Circle()
                    .stroke(currentRing == 1 ? Color.cyan : Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(crownAngle * 2))
                
                // Goal Portal
                Circle()
                    .fill(Color.yellow.opacity(0.8))
                    .frame(width: 18, height: 18)
                    .overlay(
                        Text("★")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                    )
                
                // Neon Marble
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .shadow(color: .green, radius: 4)
                    .offset(x: marbleRadius(for: currentRing))
            }
            .frame(width: 130, height: 130)
            .focusable()
            .digitalCrownRotation($crownAngle, from: -3600, through: 3600, by: 15, sensitivity: .medium, isContinuous: true)
            .onChange(of: crownAngle) { _ in
                checkMarbleDrop()
            }
            
            Text(isGoalReached ? "🎉 MERKEZE ULAŞTIN!" : "Crown ile halkaları döndür")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(isGoalReached ? .green : .gray)
            
            if isGoalReached {
                Button("SONRAKİ SEVİYE") {
                    nextLevel()
                }
                .font(.system(size: 10, weight: .heavy))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.yellow)
                .clipShape(Capsule())
            }
        }
        .navigationTitle("Crown Maze")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func marbleRadius(for ring: Int) -> CGFloat {
        switch ring {
        case 3: return 60
        case 2: return 42
        case 1: return 25
        default: return 0
        }
    }
    
    private func checkMarbleDrop() {
        guard !isGoalReached else { return }
        
        // Normalize angle 0..360
        let norm = (Int(abs(crownAngle)) % 360)
        let slot = Int(ringSlotAngles[currentRing])
        let diff = abs(norm - slot)
        
        if diff < 15 || diff > 345 {
            // Drop to next ring
            currentRing -= 1
            haptic.play(.click)
            score += 25
            
            if currentRing <= 0 {
                isGoalReached = true
                score += 100
                haptic.play(.victory)
                _ = scoreManager.recordScore(score, for: "crownmaze")
            }
        }
    }
    
    private func nextLevel() {
        level += 1
        currentRing = 3
        isGoalReached = false
        ringSlotAngles = [0, Double.random(in: 40...320), Double.random(in: 40...320), Double.random(in: 40...320)]
        haptic.play(.tap)
    }
}
