import SwiftUI
import WatchKit

public struct LunarLanderGameView: View {
    @State private var crownAccumulator: Float = 0.0
    
    @State private var shipX: CGFloat = 80
    @State private var shipY: CGFloat = 25
    @State private var vx: CGFloat = 0.4
    @State private var vy: CGFloat = 0.0
    @State private var fuel: CGFloat = 100.0
    @State private var isThrusting: Bool = false
    
    @State private var status: String = "DESCENDING"
    @State private var gameOver: Bool = false
    @State private var hasLanded: Bool = false
    @State private var score: Int = 0
    
    private let gravity: CGFloat = 0.08
    private let thrustPower: CGFloat = 0.22
    private let maxSafeLandingSpeed: CGFloat = 1.6
    private let padX: CGFloat = 55
    private let padWidth: CGFloat = 50
    private let groundY: CGFloat = 175
    
    @State private var timer = Timer.publish(every: 0.033, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / 160
            let scaleY = geo.size.height / 210
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Starry Night Sky
                Canvas { ctx, size in
                    let stars = [
                        CGPoint(x: 20, y: 15), CGPoint(x: 75, y: 40), CGPoint(x: 130, y: 20),
                        CGPoint(x: 45, y: 90), CGPoint(x: 110, y: 120), CGPoint(x: 145, y: 80)
                    ]
                    for s in stars {
                        ctx.fill(Path(ellipseIn: CGRect(x: s.x * scaleX, y: s.y * scaleY, width: 2, height: 2)), with: .color(.white.opacity(0.7)))
                    }
                }
                
                // Moon Terrain & Landing Pad
                Canvas { ctx, size in
                    var terrain = Path()
                    terrain.move(to: CGPoint(x: 0, y: groundY * scaleY))
                    terrain.addLine(to: CGPoint(x: padX * scaleX, y: groundY * scaleY))
                    terrain.addLine(to: CGPoint(x: (padX + padWidth) * scaleX, y: groundY * scaleY))
                    terrain.addLine(to: CGPoint(x: 160 * scaleX, y: groundY * scaleY))
                    terrain.addLine(to: CGPoint(x: 160 * scaleX, y: size.height))
                    terrain.addLine(to: CGPoint(x: 0, y: size.height))
                    terrain.closeSubpath()
                    ctx.fill(terrain, with: .color(Color(white: 0.2)))
                    
                    // Neon Landing Pad
                    var pad = Path()
                    pad.move(to: CGPoint(x: padX * scaleX, y: groundY * scaleY))
                    pad.addLine(to: CGPoint(x: (padX + padWidth) * scaleX, y: groundY * scaleY))
                    ctx.stroke(pad, with: .color(.green), style: StrokeStyle(lineWidth: 3))
                }
                
                // Lunar Module (Lander)
                ZStack {
                    // Flame when thrusting
                    if isThrusting && fuel > 0 {
                        Path { p in
                            p.move(to: CGPoint(x: -3, y: 8))
                            p.addLine(to: CGPoint(x: 3, y: 8))
                            p.addLine(to: CGPoint(x: 0, y: 16))
                            p.closeSubpath()
                        }
                        .fill(Color.orange)
                    }
                    
                    // Module Body
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 12 * scaleX, height: 12 * scaleX)
                    
                    // Landing Legs
                    Path { p in
                        p.move(to: CGPoint(x: -6, y: 4))
                        p.addLine(to: CGPoint(x: -8, y: 8))
                        p.move(to: CGPoint(x: 6, y: 4))
                        p.addLine(to: CGPoint(x: 8, y: 8))
                    }
                    .stroke(Color.white, lineWidth: 1.5)
                }
                .position(x: shipX * scaleX, y: shipY * scaleY)
                
                // HUD: Fuel & Vertical Speed
                VStack(spacing: 2) {
                    HStack {
                        Text("FUEL: \(Int(fuel))%")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(fuel > 20 ? .cyan : .red)
                        Spacer()
                        Text("V-SPD: \(String(format: "%.1f", vy))")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(abs(vy) <= maxSafeLandingSpeed ? .green : .red)
                    }
                    .padding(.horizontal, 8)
                    Spacer()
                }
                .padding(.top, 4)
                
                // Game Over Overlay
                if gameOver {
                    ZStack {
                        Color.black.opacity(0.85).ignoresSafeArea()
                        VStack(spacing: 8) {
                            Text(status)
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(hasLanded ? .green : .red)
                            
                            if hasLanded {
                                Text("SCORE: \(score)")
                                    .font(.system(size: 16, weight: .black, design: .monospaced))
                                    .foregroundColor(.yellow)
                            }
                            
                            Button(action: resetMission) {
                                Text("RETRY")
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(hasLanded ? Color.green : Color.orange)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        applyThrust()
                    }
                    .onEnded { _ in
                        isThrusting = false
                    }
            )
            .focusable(true)
            .digitalCrownRotation(
                $crownAccumulator,
                from: -1000,
                through: 1000,
                by: 1.0,
                sensitivity: .high,
                isContinuous: true,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownAccumulator) { _, newVal in
                if newVal > 0 {
                    applyThrust()
                } else if newVal < 0 {
                    // Slight steer
                    shipX = max(10, min(150, shipX + CGFloat(newVal) * 2))
                }
                crownAccumulator = 0
            }
            .onReceive(timer) { _ in
                guard !gameOver else { return }
                updateFlight()
            }
        }
    }
    
    private func applyThrust() {
        guard fuel > 0 else { return }
        isThrusting = true
        vy -= thrustPower
        fuel = max(0, fuel - 0.75)
        WKInterfaceDevice.current().play(.click)
    }
    
    private func updateFlight() {
        // Apply Gravity
        vy += gravity
        
        // Move Ship
        shipX += vx
        shipY += vy
        
        // Screen bounds bounce (Left/Right)
        if shipX <= 8 {
            shipX = 8
            vx = -vx * 0.5
        } else if shipX >= 152 {
            shipX = 152
            vx = -vx * 0.5
        }
        
        // Touchdown / Collision with Ground
        if shipY >= groundY - 6 {
            shipY = groundY - 6
            gameOver = true
            isThrusting = false
            
            let onPad = shipX >= padX && shipX <= (padX + padWidth)
            let safeSpeed = abs(vy) <= maxSafeLandingSpeed
            
            if onPad && safeSpeed {
                hasLanded = true
                status = "TOUCHDOWN! 🚀"
                score = 500 + Int(fuel * 10)
                WKInterfaceDevice.current().play(.success)
                _ = ScoreManager.shared.recordScore(score, for: "lunarlander")
                _ = XPManager.shared.addXP(80, reason: "Lunar Lander Safe Landing")
            } else {
                hasLanded = false
                status = !onPad ? "OFF TARGET CRASH!" : "HARD CRASH!"
                WKInterfaceDevice.current().play(.failure)
            }
        }
    }
    
    private func resetMission() {
        shipX = CGFloat.random(in: 30...130)
        shipY = 25
        vx = CGFloat.random(in: -0.3...0.3)
        vy = 0.0
        fuel = 100.0
        isThrusting = false
        gameOver = false
        hasLanded = false
        status = "DESCENDING"
    }
}
