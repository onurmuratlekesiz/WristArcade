import SwiftUI
#if os(watchOS)
import WatchKit
#endif

public struct AirHockeyGameView: View {
    @State private var crownAccumulator: Float = 0.0
    @State private var playerX: CGFloat = 80
    @State private var botX: CGFloat = 80
    @State private var puckX: CGFloat = 80
    @State private var puckY: CGFloat = 110
    @State private var puckVx: CGFloat = 2.0
    @State private var puckVy: CGFloat = 3.0
    
    @State private var playerScore: Int = 0
    @State private var botScore: Int = 0
    @State private var isPlaying: Bool = true
    @State private var gameOver: Bool = false
    @State private var winnerText: String = ""
    
    private let targetScore = 5
    private let fieldWidth: CGFloat = 160
    private let fieldHeight: CGFloat = 210
    private let paddleRadius: CGFloat = 14
    private let puckRadius: CGFloat = 8
    
    @State private var timer = Timer.publish(every: 0.033, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / fieldWidth
            let scaleY = geo.size.height / fieldHeight
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Neon Air Hockey Rink
                VStack(spacing: 0) {
                    // Top Goal (Bot)
                    Rectangle()
                        .fill(Color.red.opacity(0.4))
                        .frame(width: 60 * scaleX, height: 6 * scaleY)
                    
                    Spacer()
                    
                    // Center Rink Line & Circle
                    ZStack {
                        Rectangle()
                            .fill(Color.cyan.opacity(0.3))
                            .frame(height: 2)
                        Circle()
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                            .frame(width: 44 * scaleX, height: 44 * scaleX)
                    }
                    
                    Spacer()
                    
                    // Bottom Goal (Player)
                    Rectangle()
                        .fill(Color.green.opacity(0.4))
                        .frame(width: 60 * scaleX, height: 6 * scaleY)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
                )
                
                // Bot Paddle (Top)
                Circle()
                    .fill(
                        RadialGradient(colors: [.red, .red.opacity(0.6)], center: .center, startRadius: 2, endRadius: paddleRadius * scaleX)
                    )
                    .frame(width: paddleRadius * 2 * scaleX, height: paddleRadius * 2 * scaleX)
                    .position(x: botX * scaleX, y: 24 * scaleY)
                
                // Player Paddle (Bottom)
                Circle()
                    .fill(
                        RadialGradient(colors: [.cyan, .blue], center: .center, startRadius: 2, endRadius: paddleRadius * scaleX)
                    )
                    .frame(width: paddleRadius * 2 * scaleX, height: paddleRadius * 2 * scaleX)
                    .position(x: playerX * scaleX, y: (fieldHeight - 24) * scaleY)
                
                // Puck
                Circle()
                    .fill(Color.yellow)
                    .frame(width: puckRadius * 2 * scaleX, height: puckRadius * 2 * scaleX)
                    .shadow(color: .yellow, radius: 4)
                    .position(x: puckX * scaleX, y: puckY * scaleY)
                
                // Score Overlay
                HStack {
                    Text("\(botScore)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                    Spacer()
                    Text("AIR HOCKEY")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                    Text("\(playerScore)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 10)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // Game Over Overlay
                if gameOver {
                    ZStack {
                        Color.black.opacity(0.85).ignoresSafeArea()
                        VStack(spacing: 8) {
                            Text(winnerText)
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(playerScore >= targetScore ? .green : .red)
                            
                            Text("\(playerScore) - \(botScore)")
                                .font(.system(size: 20, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Button(action: resetGame) {
                                Text("REPLAY")
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.cyan)
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
                    .onChanged { val in
                        let newX = val.location.x / scaleX
                        playerX = max(paddleRadius + 4, min(fieldWidth - paddleRadius - 4, newX))
                    }
            )
            .focusable(true)
            .digitalCrownRotation(
                $crownAccumulator,
                from: -1000,
                through: 1000,
                by: 1.0,
                sensitivity: .medium,
                isContinuous: true,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownAccumulator) { newVal in
                let step = CGFloat(newVal) * 2.0
                crownAccumulator = 0
                playerX = max(paddleRadius + 4, min(fieldWidth - paddleRadius - 4, playerX + step))
            }
            .onReceive(timer) { _ in
                guard isPlaying && !gameOver else { return }
                updatePhysics()
            }
        }
    }
    
    private func updatePhysics() {
        // Move Puck
        puckX += puckVx
        puckY += puckVy
        
        // Wall Bounces (Left & Right)
        if puckX <= puckRadius + 2 {
            puckX = puckRadius + 2
            puckVx = -puckVx
            WKInterfaceDevice.current().play(.click)
        } else if puckX >= fieldWidth - puckRadius - 2 {
            puckX = fieldWidth - puckRadius - 2
            puckVx = -puckVx
            WKInterfaceDevice.current().play(.click)
        }
        
        // Bot AI Tracking Puck
        let botTarget = puckX
        if botX < botTarget - 3 {
            botX += min(2.4, botTarget - botX)
        } else if botX > botTarget + 3 {
            botX -= min(2.4, botX - botTarget)
        }
        botX = max(paddleRadius + 4, min(fieldWidth - paddleRadius - 4, botX))
        
        // Player Paddle Collision (Bottom)
        let distPlayer = hypot(puckX - playerX, puckY - (fieldHeight - 24))
        if distPlayer < (paddleRadius + puckRadius) && puckVy > 0 {
            puckVy = -abs(puckVy) * 1.05
            puckVx = (puckX - playerX) * 0.3
            WKInterfaceDevice.current().play(.directionUp)
        }
        
        // Bot Paddle Collision (Top)
        let distBot = hypot(puckX - botX, puckY - 24)
        if distBot < (paddleRadius + puckRadius) && puckVy < 0 {
            puckVy = abs(puckVy) * 1.05
            puckVx = (puckX - botX) * 0.3
            WKInterfaceDevice.current().play(.directionDown)
        }
        
        // Clamp speed
        puckVx = max(-6, min(6, puckVx))
        puckVy = max(-7, min(7, puckVy))
        
        // Goal Check
        let goalLeft = (fieldWidth - 60) / 2
        let goalRight = (fieldWidth + 60) / 2
        
        // Top Goal (Player scores!)
        if puckY <= puckRadius {
            if puckX >= goalLeft && puckX <= goalRight {
                playerScore += 1
                WKInterfaceDevice.current().play(.success)
                if playerScore >= targetScore {
                    endGame(playerWon: true)
                } else {
                    resetPuck(servingToPlayer: false)
                }
            } else {
                puckY = puckRadius
                puckVy = -puckVy
            }
        }
        
        // Bottom Goal (Bot scores!)
        if puckY >= fieldHeight - puckRadius {
            if puckX >= goalLeft && puckX <= goalRight {
                botScore += 1
                WKInterfaceDevice.current().play(.failure)
                if botScore >= targetScore {
                    endGame(playerWon: false)
                } else {
                    resetPuck(servingToPlayer: true)
                }
            } else {
                puckY = fieldHeight - puckRadius
                puckVy = -puckVy
            }
        }
    }
    
    private func resetPuck(servingToPlayer: Bool) {
        puckX = fieldWidth / 2
        puckY = fieldHeight / 2
        puckVx = CGFloat.random(in: -1.5...1.5)
        puckVy = servingToPlayer ? 2.5 : -2.5
    }
    
    private func endGame(playerWon: Bool) {
        gameOver = true
        isPlaying = false
        winnerText = playerWon ? "VICTORY!" : "DEFEAT"
        if playerWon {
            _ = ScoreManager.shared.recordScore(playerScore * 100, for: "airhockey")
            _ = XPManager.shared.addXP(60, reason: "Air Hockey Win")
        }
    }
    
    private func resetGame() {
        playerScore = 0
        botScore = 0
        gameOver = false
        isPlaying = true
        resetPuck(servingToPlayer: false)
    }
}
