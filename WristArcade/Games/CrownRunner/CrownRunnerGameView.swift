import SwiftUI

public struct CrownRunnerGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct Obstacle: Identifiable {
        let id: Int
        var x: CGFloat
        var width: CGFloat
        var height: CGFloat
    }
    
    @State private var playerY: CGFloat = 0.0
    @State private var playerVy: CGFloat = 0.0
    @State private var isGrounded: Bool = true
    
    @State private var obstacles: [Obstacle] = []
    @State private var score: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    @State private var tickCounter: Int = 0
    
    @State private var crownDummy: Double = 0.0
    
    var body: some View {
        GeometryReader { geo in
            let fieldW = geo.size.width
            let fieldH = geo.size.height
            let groundY = fieldH - 24
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    // Ground line
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: fieldW, height: 2)
                        .position(x: fieldW / 2, y: groundY)
                    
                    // Obstacles
                    ForEach(obstacles) { obs in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.red)
                            .frame(width: obs.width, height: obs.height)
                            .position(x: obs.x, y: groundY - (obs.height / 2))
                    }
                    
                    // Runner character
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.orange)
                            .frame(width: 14, height: 18)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 4, height: 4)
                            .offset(x: 3, y: -4)
                    }
                    .position(x: 35, y: groundY - 9 - playerY)
                    
                    // Score HUD
                    VStack {
                        HStack {
                            Text("DIST: \(score)m")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "crownrunner"))m")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 2)
                        Spacer()
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "COLLISION!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Distance: \(score)m")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: { startNewGame(fieldW: fieldW) }) {
                            Text("RUN AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 26))
                            .foregroundColor(.orange)
                        
                        Text("CROWN RUNNER")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Turn Crown or tap screen to jump over obstacles")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: { startNewGame(fieldW: fieldW) }) {
                            Text("RUN")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                jump()
            }
            .focusable(true)
            .digitalCrownRotation(
                $crownDummy,
                from: -1000.0,
                through: 1000.0,
                by: 1.0,
                sensitivity: .high,
                isContinuous: true,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownDummy) { _ in
                jump()
            }
            .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                tick(fieldW: fieldW)
            }
        }
    }
    
    private func startNewGame(fieldW: CGFloat) {
        score = 0
        obstacles = []
        playerY = 0
        playerVy = 0
        isGrounded = true
        isGameOver = false
        isNewRecord = false
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func jump() {
        guard isPlaying, isGrounded else { return }
        playerVy = 7.5
        isGrounded = false
        HapticManager.shared.play(.tap)
    }
    
    private func tick(fieldW: CGFloat) {
        score += 1
        tickCounter += 1
        
        // Physics
        playerY += playerVy
        playerVy -= 0.55 // Gravity
        if playerY <= 0 {
            playerY = 0
            playerVy = 0
            isGrounded = true
        }
        
        // Spawn obstacle
        if tickCounter % 40 == 0 {
            obstacles.append(Obstacle(id: tickCounter, x: fieldW + 20, width: 12, height: CGFloat.random(in: 14...22)))
        }
        
        // Move obstacles
        var nextObs: [Obstacle] = []
        let playerBox = CGRect(x: 35 - 7, y: playerY, width: 14, height: 18)
        
        for var obs in obstacles {
            obs.x -= 3.2
            
            // Collision test
            let obsBox = CGRect(x: obs.x - (obs.width / 2), y: 0, width: obs.width, height: obs.height)
            if playerBox.intersects(obsBox) {
                // Crash!
                isPlaying = false
                isGameOver = true
                isNewRecord = scoreManager.recordScore(score, for: "crownrunner")
                HapticManager.shared.play(.gameOver)
                return
            }
            
            if obs.x > -20 {
                nextObs.append(obs)
            }
        }
        self.obstacles = nextObs
    }
}
