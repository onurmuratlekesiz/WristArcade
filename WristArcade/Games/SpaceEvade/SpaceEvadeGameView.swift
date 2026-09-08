import SwiftUI

public struct SpaceEvadeGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct Hazard: Identifiable {
        let id: Int
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var isStar: Bool
    }
    
    @State private var crownRotation: Double = 0.0
    @State private var shipX: CGFloat = 0.0
    
    @State private var hazards: [Hazard] = []
    @State private var score: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    @State private var hazardCounter: Int = 0
    
    private let shipWidth: CGFloat = 20.0
    private let shipHeight: CGFloat = 16.0
    
    public var body: some View {
        GeometryReader { geo in
            let fieldW = geo.size.width
            let fieldH = geo.size.height
            let maxShipX = (fieldW / 2) - (shipWidth / 2)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    // Falling hazards & stars
                    ForEach(hazards) { h in
                        if h.isStar {
                            Image(systemName: "star.fill")
                                .font(.system(size: h.size))
                                .foregroundColor(.yellow)
                                .position(x: h.x, y: h.y)
                        } else {
                            Circle()
                                .fill(Color.red.opacity(0.85))
                                .frame(width: h.size, height: h.size)
                                .position(x: h.x, y: h.y)
                                .shadow(color: .red, radius: 3)
                        }
                    }
                    
                    // Spaceship
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.mint)
                        .rotationEffect(.degrees(-90))
                        .position(x: (fieldW / 2) + shipX, y: fieldH - 16)
                        .shadow(color: .mint, radius: 4)
                    
                    // Score HUD
                    VStack {
                        HStack {
                            Text("\(score)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.mint)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "spaceevade"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 2)
                        Spacer()
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "SHIP DESTROYED!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: { startNewGame(fieldW: fieldW) }) {
                            Text("RETRY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.mint)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 26))
                            .foregroundColor(.mint)
                        
                        Text("SPACE EVADE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Turn Crown to dodge meteors and collect stars")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: { startNewGame(fieldW: fieldW) }) {
                            Text("LAUNCH")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.mint)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .focusable(true)
            .digitalCrownRotation(
                $crownRotation,
                from: -Double(maxShipX),
                through: Double(maxShipX),
                by: 3.5,
                sensitivity: .high,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownRotation) { newRotation in
                shipX = CGFloat(newRotation)
            }
            .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                tick(fieldW: fieldW, fieldH: fieldH)
            }
        }
    }
    
    private func startNewGame(fieldW: CGFloat) {
        score = 0
        hazards = []
        crownRotation = 0
        shipX = 0
        isGameOver = false
        isNewRecord = false
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func tick(fieldW: CGFloat, fieldH: CGFloat) {
        // Spawn hazard every ~20 ticks
        hazardCounter += 1
        if hazardCounter % 16 == 0 {
            let isStar = Double.random(in: 0...1) < 0.25
            let x = CGFloat.random(in: 12...(fieldW - 12))
            hazards.append(Hazard(id: hazardCounter, x: x, y: -10, size: isStar ? 12 : 10, isStar: isStar))
        }
        
        let shipCenter = CGPoint(x: (fieldW / 2) + shipX, y: fieldH - 16)
        var nextHazards: [Hazard] = []
        
        for var h in hazards {
            h.y += 2.8
            
            // Collision with ship
            let dist = hypot(h.x - shipCenter.x, h.y - shipCenter.y)
            if dist < 14 {
                if h.isStar {
                    score += 5
                    HapticManager.shared.play(.score)
                    continue
                } else {
                    // Crash!
                    isPlaying = false
                    isGameOver = true
                    isNewRecord = scoreManager.recordScore(score, for: "spaceevade")
                    HapticManager.shared.play(.gameOver)
                    return
                }
            }
            
            if h.y < fieldH + 10 {
                nextHazards.append(h)
            } else if !h.isStar {
                score += 1
            }
        }
        self.hazards = nextHazards
    }
}
