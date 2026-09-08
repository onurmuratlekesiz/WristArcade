import SwiftUI

public struct SubDiveGameView: View {
    @State private var subDepth: Double = 60.0 // 0 to 120 px
    @State private var oxygen: Double = 100.0
    @State private var depthMeters: Int = 0
    @State private var isGameOver: Bool = false
    
    struct Obstacle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var isOxygen: Bool
    }
    
    @State private var obstacles: [Obstacle] = []
    @State private var timer: Timer? = nil
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Derinlik: \(depthMeters)m")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
                Spacer()
                Text("O2: \(Int(oxygen))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(oxygen > 30 ? .green : .red)
            }
            .padding(.horizontal, 8)
            
            // Oceanic Trench Viewport
            GeometryReader { geo in
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.05, green: 0.15, blue: 0.3), Color(red: 0.01, green: 0.03, blue: 0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .cornerRadius(10)
                    
                    // Obstacles & Bubbles
                    ForEach(obstacles) { obs in
                        Text(obs.isOxygen ? "🫧" : "💣")
                            .font(.system(size: 14))
                            .position(x: obs.x, y: obs.y)
                    }
                    
                    // Mini Submarine
                    Text("🛥️")
                        .font(.system(size: 16))
                        .position(x: 35, y: CGFloat(subDepth))
                    
                    if isGameOver {
                        VStack(spacing: 4) {
                            Text("DALIS BİTTİ!")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(.red)
                            Text("\(depthMeters) metreye daldın")
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                            Button("TEKRAR DIVE") { restartGame() }
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(Color.cyan)
                                .foregroundColor(.black)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .frame(height: 120)
            .focusable()
            .digitalCrownRotation($subDepth, from: 15, through: 105, by: 4, sensitivity: .high, isContinuous: false)
            
            Text("Crown çevirerek derinliği ayarla")
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
        .navigationTitle("Submarine Dive")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startGame() }
        .onDisappear { timer?.invalidate() }
    }
    
    private func startGame() {
        subDepth = 60.0
        oxygen = 100.0
        depthMeters = 0
        isGameOver = false
        obstacles = []
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            guard !isGameOver else { return }
            
            depthMeters += 1
            oxygen -= 0.15
            if oxygen <= 0 {
                gameOver()
                return
            }
            
            // Spawn obstacles
            if Double.random(in: 0...1) < 0.15 {
                let isO2 = Double.random(in: 0...1) < 0.35
                obstacles.append(Obstacle(x: 150, y: CGFloat.random(in: 20...100), isOxygen: isO2))
            }
            
            // Move obstacles left
            for i in obstacles.indices {
                obstacles[i].x -= 4
            }
            
            // Check collision with submarine at x: 35, y: subDepth
            let subY = CGFloat(subDepth)
            for obs in obstacles {
                let dist = hypot(obs.x - 35, obs.y - subY)
                if dist < 14 {
                    if obs.isOxygen {
                        oxygen = min(100, oxygen + 25)
                        haptic.play(.click)
                        obstacles.removeAll { $0.id == obs.id }
                    } else {
                        gameOver()
                        return
                    }
                }
            }
            
            // Clean up offscreen
            obstacles.removeAll { $0.x < -20 }
        }
    }
    
    private func gameOver() {
        isGameOver = true
        timer?.invalidate()
        haptic.play(.warning)
        _ = scoreManager.recordScore(depthMeters, for: "subdive")
    }
    
    private func restartGame() {
        startGame()
    }
}
