import SwiftUI

public struct PaddleGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    // Paddle state (controlled via Crown)
    @State private var crownRotation: Double = 0.0
    @State private var paddleX: CGFloat = 0.0
    
    // Ball state
    @State private var ballPosition: CGPoint = CGPoint(x: 80, y: 70)
    @State private var ballVelocity: CGPoint = CGPoint(x: 2.2, y: -2.8)
    
    // Game loop & score
    @State private var score: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    
    private let paddleWidth: CGFloat = 46.0
    private let paddleHeight: CGFloat = 8.0
    private let ballRadius: CGFloat = 6.0
    
    public var body: some View {
        GeometryReader { geo in
            let fieldWidth = geo.size.width
            let fieldHeight = geo.size.height
            let maxPaddleX = (fieldWidth / 2) - (paddleWidth / 2)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Subtle boundary border
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1.5)
                    .padding(2)
                
                if isPlaying {
                    // Score HUD
                    VStack {
                        HStack {
                            Text("SCORE")
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(.gray)
                            Text("\(score)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "paddle"))")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 4)
                        Spacer()
                    }
                    
                    // Ball
                    Circle()
                        .fill(Color.white)
                        .frame(width: ballRadius * 2, height: ballRadius * 2)
                        .position(ballPosition)
                        .shadow(color: .cyan.opacity(0.8), radius: 4)
                    
                    // Paddle at bottom
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cyan)
                        .frame(width: paddleWidth, height: paddleHeight)
                        .position(x: (fieldWidth / 2) + paddleX, y: fieldHeight - 12)
                        .shadow(color: .cyan, radius: 5)
                    
                } else if isGameOver {
                    // Game Over Screen
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "GAME OVER")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("Best: \(scoreManager.getHighScore(for: "paddle"))")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.gray)
                        
                        Button(action: startNewGame) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text("PLAY AGAIN")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.cyan)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                } else {
                    // Start Screen
                    VStack(spacing: 8) {
                        Image(systemName: "circle.grid.cross.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.cyan)
                        
                        Text("CROWN PADDLE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Turn Digital Crown to steer paddle")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.cyan)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .focusable(true)
            .digitalCrownRotation(
                $crownRotation,
                from: -Double(maxPaddleX),
                through: Double(maxPaddleX),
                by: 3.5,
                sensitivity: .high,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownRotation) { newRotation in
                paddleX = CGFloat(newRotation)
            }
            .onReceive(Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                updateGame(fieldWidth: fieldWidth, fieldHeight: fieldHeight)
            }
        }
    }
    
    private func startNewGame() {
        score = 0
        isGameOver = false
        isNewRecord = false
        ballPosition = CGPoint(x: 90, y: 50)
        ballVelocity = CGPoint(x: 2.2, y: 2.5)
        crownRotation = 0
        paddleX = 0
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func updateGame(fieldWidth: CGFloat, fieldHeight: CGFloat) {
        var newX = ballPosition.x + ballVelocity.x
        var newY = ballPosition.y + ballVelocity.y
        var vx = ballVelocity.x
        var vy = ballVelocity.y
        
        // Wall collisions (Left & Right)
        if newX - ballRadius <= 2 {
            newX = ballRadius + 2
            vx = abs(vx)
            HapticManager.shared.play(.bounce)
        } else if newX + ballRadius >= fieldWidth - 2 {
            newX = fieldWidth - 2 - ballRadius
            vx = -abs(vx)
            HapticManager.shared.play(.bounce)
        }
        
        // Top wall collision
        if newY - ballRadius <= 2 {
            newY = ballRadius + 2
            vy = abs(vy)
            HapticManager.shared.play(.bounce)
        }
        
        // Paddle collision (Bottom)
        let paddleCenter = (fieldWidth / 2) + paddleX
        let paddleTop = fieldHeight - 12 - (paddleHeight / 2)
        
        if newY + ballRadius >= paddleTop && newY - ballRadius <= paddleTop + 4 {
            if newX >= paddleCenter - (paddleWidth / 2) && newX <= paddleCenter + (paddleWidth / 2) {
                // Hit paddle!
                newY = paddleTop - ballRadius
                vy = -abs(vy) * 1.03 // Slightly accelerate
                
                // Add spin depending on where it hit on the paddle
                let hitOffset = (newX - paddleCenter) / (paddleWidth / 2)
                vx = hitOffset * 3.2
                
                score += 1
                HapticManager.shared.play(.score)
            }
        }
        
        // Bottom Miss -> Game Over
        if newY - ballRadius > fieldHeight {
            isPlaying = false
            isGameOver = true
            isNewRecord = scoreManager.recordScore(score, for: "paddle")
            HapticManager.shared.play(.gameOver)
            return
        }
        
        ballPosition = CGPoint(x: newX, y: newY)
        ballVelocity = CGPoint(x: vx, y: vy)
    }
}
