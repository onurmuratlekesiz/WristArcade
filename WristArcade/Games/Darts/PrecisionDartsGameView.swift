import SwiftUI

public struct PrecisionDartsGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var soundManager = SoundManager.shared
    
    // Crown aiming angle in degrees
    @State private var aimAngle: Double = 0.0
    // Throw power 0..100
    @State private var power: Double = 50.0
    @State private var powerIncreasing: Bool = true
    @State private var timer: Timer?
    
    @State private var dartsLeft: Int = 3
    @State private var roundScore: Int = 0
    @State private var lastHitText: String = "Aim & Throw!"
    @State private var isGameOver: Bool = false
    @State private var thrownHits: [CGPoint] = []
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack {
                HStack(spacing: 3) {
                    ForEach(0..<dartsLeft, id: \.self) { _ in
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                Text("Score: \(roundScore)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 8)
            
            // Dartboard Vector Canvas
            ZStack {
                // Outer ring
                Circle()
                    .fill(Color.black)
                    .frame(width: 90, height: 90)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                
                // Double ring
                Circle()
                    .stroke(Color.green, lineWidth: 5)
                    .frame(width: 80, height: 80)
                
                // Single zone
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 70, height: 70)
                
                // Triple ring
                Circle()
                    .stroke(Color.red, lineWidth: 5)
                    .frame(width: 50, height: 50)
                
                // Outer bull
                Circle()
                    .fill(Color.green)
                    .frame(width: 22, height: 22)
                
                // Inner bullseye
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                
                // Aim pointer line
                Path { path in
                    let rad = aimAngle * .pi / 180.0
                    let center = CGPoint(x: 45, y: 45)
                    let end = CGPoint(x: 45 + cos(rad) * 44, y: 45 + sin(rad) * 44)
                    path.move(to: center)
                    path.addLine(to: end)
                }
                .stroke(Color.cyan.opacity(0.8), style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                .frame(width: 90, height: 90)
                
                // Thrown darts markers
                ForEach(0..<thrownHits.count, id: \.self) { idx in
                    let pt = thrownHits[idx]
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 5, height: 5)
                        .position(pt)
                }
            }
            .frame(width: 90, height: 90)
            .focusable()
            .digitalCrownRotation($aimAngle, from: -180.0, through: 180.0, by: 4.0, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
            
            // Power meter bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(powerColor())
                        .frame(width: geo.size.width * CGFloat(power / 100.0), height: 6)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 16)
            
            Text(lastHitText)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.cyan)
                .lineLimit(1)
            
            if !isGameOver {
                Button(action: throwDart) {
                    Text("THROW")
                        .font(.system(size: 11, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .handGestureShortcut(.primaryAction) // watchOS 10/11 Double Tap gesture
            } else {
                Button(action: startNewGame) {
                    Text("Play Again")
                        .font(.system(size: 11, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .handGestureShortcut(.primaryAction)
            }
        }
        .padding(4)
        .onAppear(perform: startNewGame)
        .onDisappear { timer?.invalidate() }
    }
    
    private func powerColor() -> Color {
        if power > 80 { return .red }
        if power > 50 { return .green }
        return .yellow
    }
    
    private func throwDart() {
        guard dartsLeft > 0, !isGameOver else { return }
        
        dartsLeft -= 1
        soundManager.play(.laser)
        HapticManager.shared.play(.tap)
        
        // Calculate hit point based on angle and power deviation
        let rad = aimAngle * .pi / 180.0
        let dist = 45.0 * (power / 100.0)
        let hitX = 45.0 + cos(rad) * dist + Double.random(in: -3...3)
        let hitY = 45.0 + sin(rad) * dist + Double.random(in: -3...3)
        let hitPoint = CGPoint(x: hitX, y: hitY)
        thrownHits.append(hitPoint)
        
        // Calculate points based on radius from center (45, 45)
        let dx = hitX - 45.0
        let dy = hitY - 45.0
        let r = sqrt(dx * dx + dy * dy)
        
        var points = 0
        if r <= 5.0 {
            points = 50
            lastHitText = "BULLSEYE! 🎯 (+50)"
            soundManager.play(.victory)
            HapticManager.shared.play(.victory)
        } else if r <= 11.0 {
            points = 25
            lastHitText = "Outer Bull (+25)"
            soundManager.play(.point)
            HapticManager.shared.play(.score)
        } else if r >= 23.0 && r <= 27.0 {
            points = 60
            lastHitText = "TRIPLE RING! 🔥 (+60)"
            soundManager.play(.point)
            HapticManager.shared.play(.score)
        } else if r >= 38.0 && r <= 42.0 {
            points = 40
            lastHitText = "Double Ring (+40)"
            soundManager.play(.point)
        } else if r < 45.0 {
            points = 20
            lastHitText = "Single Hit (+20)"
            soundManager.play(.point)
        } else {
            points = 0
            lastHitText = "Missed board! (0)"
            soundManager.play(.gameOver)
        }
        
        roundScore += points
        
        if dartsLeft <= 0 {
            isGameOver = true
            timer?.invalidate()
            scoreManager.saveHighScore(roundScore, for: "darts")
            scoreManager.addXP(roundScore)
            lastHitText = "Round Total: \(roundScore) pts!"
        }
    }
    
    private func startNewGame() {
        dartsLeft = 3
        roundScore = 0
        isGameOver = false
        thrownHits = []
        lastHitText = "Aim with Crown & Throw!"
        aimAngle = 0.0
        power = 50.0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            if powerIncreasing {
                power += 3.0
                if power >= 98.0 { powerIncreasing = false }
            } else {
                power -= 3.0
                if power <= 10.0 { powerIncreasing = true }
            }
        }
    }
}
