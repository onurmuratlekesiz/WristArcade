import SwiftUI

public struct BrickCrusherGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct Brick: Identifiable {
        let id: Int
        var rect: CGRect
        var color: Color
        var isDestroyed: Bool
    }
    
    // Paddle state (Crown)
    @State private var crownRotation: Double = 0.0
    @State private var paddleX: CGFloat = 0.0
    
    // Ball state
    @State private var ballPosition: CGPoint = CGPoint(x: 90, y: 110)
    @State private var ballVelocity: CGPoint = CGPoint(x: 2.0, y: -2.2)
    
    // Bricks
    @State private var bricks: [Brick] = []
    
    // Game loop & score
    @State private var score: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isVictory: Bool = false
    @State private var isNewRecord: Bool = false
    
    private let paddleWidth: CGFloat = 40.0
    private let paddleHeight: CGFloat = 7.0
    private let ballRadius: CGFloat = 5.0
    
    var body: some View {
        GeometryReader { geo in
            let fieldWidth = geo.size.width
            let fieldHeight = geo.size.height
            let maxPaddleX = (fieldWidth / 2) - (paddleWidth / 2)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    // Draw Bricks
                    ForEach(bricks) { brick in
                        if !brick.isDestroyed {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(brick.color)
                                .frame(width: brick.rect.width, height: brick.rect.height)
                                .position(x: brick.rect.midX, y: brick.rect.midY)
                        }
                    }
                    
                    // Ball
                    Circle()
                        .fill(Color.white)
                        .frame(width: ballRadius * 2, height: ballRadius * 2)
                        .position(ballPosition)
                        .shadow(color: .pink.opacity(0.8), radius: 3)
                    
                    // Paddle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.pink)
                        .frame(width: paddleWidth, height: paddleHeight)
                        .position(x: (fieldWidth / 2) + paddleX, y: fieldHeight - 12)
                        .shadow(color: .pink, radius: 4)
                    
                    // Score HUD
                    VStack {
                        HStack {
                            Text("\(score)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.pink)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "brickcrusher"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 2)
                        Spacer()
                    }
                } else if isGameOver || isVictory {
                    VStack(spacing: 6) {
                        Text(isVictory ? "STAGE CLEARED!" : (isNewRecord ? "NEW RECORD!" : "GAME OVER"))
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isVictory ? .green : (isNewRecord ? .yellow : .red))
                        
                        Text("Score: \(score)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: { startNewGame(fieldWidth: fieldWidth) }) {
                            Text(isVictory ? "NEXT ROUND" : "RETRY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.pink)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "square.split.bottomrightquarter.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.pink)
                        
                        Text("BRICK CRUSHER")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Turn Digital Crown to smash bricks")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        
                        Button(action: { startNewGame(fieldWidth: fieldWidth) }) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.pink)
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
    
    private func startNewGame(fieldWidth: CGFloat) {
        score = 0
        isGameOver = false
        isVictory = false
        isNewRecord = false
        ballPosition = CGPoint(x: fieldWidth / 2, y: 100)
        ballVelocity = CGPoint(x: 2.0, y: -2.4)
        crownRotation = 0
        paddleX = 0
        
        setupBricks(fieldWidth: fieldWidth)
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func setupBricks(fieldWidth: CGFloat) {
        let cols = 6
        let rows = 4
        let spacing: CGFloat = 3
        let totalSpacing = spacing * CGFloat(cols + 1)
        let brickW = (fieldWidth - totalSpacing) / CGFloat(cols)
        let brickH: CGFloat = 10
        let startY: CGFloat = 26
        
        let colors: [Color] = [.red, .orange, .cyan, .green]
        var list: [Brick] = []
        var id = 0
        
        for r in 0..<rows {
            for c in 0..<cols {
                let x = spacing + CGFloat(c) * (brickW + spacing)
                let y = startY + CGFloat(r) * (brickH + spacing)
                let rect = CGRect(x: x, y: y, width: brickW, height: brickH)
                list.append(Brick(id: id, rect: rect, color: colors[r], isDestroyed: false))
                id += 1
            }
        }
        self.bricks = list
    }
    
    private func updateGame(fieldWidth: CGFloat, fieldHeight: CGFloat) {
        var newX = ballPosition.x + ballVelocity.x
        var newY = ballPosition.y + ballVelocity.y
        var vx = ballVelocity.x
        var vy = ballVelocity.y
        
        // Walls
        if newX - ballRadius <= 2 {
            newX = ballRadius + 2
            vx = abs(vx)
            HapticManager.shared.play(.bounce)
        } else if newX + ballRadius >= fieldWidth - 2 {
            newX = fieldWidth - 2 - ballRadius
            vx = -abs(vx)
            HapticManager.shared.play(.bounce)
        }
        if newY - ballRadius <= 16 {
            newY = ballRadius + 16
            vy = abs(vy)
            HapticManager.shared.play(.bounce)
        }
        
        // Paddle Hit
        let paddleCenter = (fieldWidth / 2) + paddleX
        let paddleTop = fieldHeight - 12 - (paddleHeight / 2)
        if newY + ballRadius >= paddleTop && newY - ballRadius <= paddleTop + 4 {
            if newX >= paddleCenter - (paddleWidth / 2) && newX <= paddleCenter + (paddleWidth / 2) {
                newY = paddleTop - ballRadius
                vy = -abs(vy)
                let offset = (newX - paddleCenter) / (paddleWidth / 2)
                vx = offset * 3.0
                HapticManager.shared.play(.bounce)
            }
        }
        
        // Brick collisions
        let ballRect = CGRect(x: newX - ballRadius, y: newY - ballRadius, width: ballRadius * 2, height: ballRadius * 2)
        for i in 0..<bricks.count {
            if !bricks[i].isDestroyed && bricks[i].rect.intersects(ballRect) {
                bricks[i].isDestroyed = true
                score += 10
                vy = -vy
                HapticManager.shared.play(.score)
                break
            }
        }
        
        // Check Victory
        if bricks.allSatisfy({ $0.isDestroyed }) {
            isPlaying = false
            isVictory = true
            isNewRecord = scoreManager.recordScore(score, for: "brickcrusher")
            HapticManager.shared.play(.victory)
            return
        }
        
        // Miss bottom -> Game Over
        if newY - ballRadius > fieldHeight {
            isPlaying = false
            isGameOver = true
            isNewRecord = scoreManager.recordScore(score, for: "brickcrusher")
            HapticManager.shared.play(.gameOver)
            return
        }
        
        ballPosition = CGPoint(x: newX, y: newY)
        ballVelocity = CGPoint(x: vx, y: vy)
    }
}
