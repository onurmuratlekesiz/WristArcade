//
//  TableTennisGameView.swift
//  WristArcade
//
//  Created for WristArcade 60 Games Diamond Edition.
//  Digital Crown retro Air Table Tennis against an adaptive bot.
//

import SwiftUI

public struct TableTennisGameView: View {
    @State private var crownRotation: Double = 0.0
    @State private var playerPaddleX: Double = 95.0
    @State private var botPaddleX: Double = 95.0
    @State private var ballX: Double = 95.0
    @State private var ballY: Double = 100.0
    @State private var ballVX: Double = 1.6
    @State private var ballVY: Double = 2.4
    
    @State private var playerScore: Int = 0
    @State private var botScore: Int = 0
    @State private var isGameOver: Bool = false
    @State private var isPlayerWinner: Bool = false
    
    @State private var timer: Timer?
    
    private let paddleWidth: Double = 36.0
    private let paddleHeight: Double = 6.0
    private let screenWidth: Double = 190.0
    private let screenHeight: Double = 210.0
    private let winningScore: Int = 5
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Table Surface
                Color(red: 0.05, green: 0.25, blue: 0.18).ignoresSafeArea()
                
                // Court Markings Canvas
                Canvas { context, size in
                    // Center Net
                    let netPath = Path { p in
                        p.move(to: CGPoint(x: 10, y: size.height / 2))
                        p.addLine(to: CGPoint(x: size.width - 10, y: size.height / 2))
                    }
                    context.stroke(netPath, with: .color(.white.opacity(0.8)), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                    
                    // Center Line
                    let centerLine = Path { p in
                        p.move(to: CGPoint(x: size.width / 2, y: 15))
                        p.addLine(to: CGPoint(x: size.width / 2, y: size.height - 15))
                    }
                    context.stroke(centerLine, with: .color(.white.opacity(0.3)), lineWidth: 1)
                }
                
                // Bot Paddle (Top)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.red)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: botPaddleX, y: 22)
                
                // Player Paddle (Bottom)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.cyan)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: playerPaddleX, y: screenHeight - 24)
                    .shadow(color: .cyan.opacity(0.8), radius: 4)
                
                // Tennis Ball
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
                    .position(x: ballX, y: ballY)
                    .shadow(color: .yellow, radius: 3)
                
                // Score Header
                VStack {
                    HStack {
                        Text("YOU \(playerScore)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                        Spacer()
                        Text("BOT \(botScore)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 2)
                    Spacer()
                }
                
                // Game Over Overlay
                if isGameOver {
                    VStack(spacing: 6) {
                        Text(isPlayerWinner ? "🏆 VICTORY!" : "DEFEAT")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(isPlayerWinner ? .yellow : .red)
                        Text("\(playerScore) - \(botScore)")
                            .font(.system(size: 13, weight: .heavy, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: resetGame) {
                            Text("PLAY AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.cyan))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.92)))
                }
            }
            .focusable()
            .digitalCrownRotation($crownRotation, from: -Double.infinity, through: Double.infinity, by: 1.0, sensitivity: .high, isContinuous: true, isHapticFeedbackEnabled: false)
            .onChange(of: crownRotation) { newVal in
                let targetX = playerPaddleX + newVal * 2.0
                playerPaddleX = max(paddleWidth / 2 + 6, min(screenWidth - paddleWidth / 2 - 6, targetX))
                crownRotation = 0.0
            }
            .onAppear {
                startGame()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private func startGame() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { _ in
            updatePhysics()
        }
    }
    
    private func updatePhysics() {
        guard !isGameOver else { return }
        
        // Move Ball
        ballX += ballVX
        ballY += ballVY
        
        // Left / Right Walls
        if ballX < 12 {
            ballX = 12
            ballVX = -ballVX
            HapticManager.shared.play(.click)
            SoundManager.shared.play(.click)
        } else if ballX > screenWidth - 12 {
            ballX = screenWidth - 12
            ballVX = -ballVX
            HapticManager.shared.play(.click)
            SoundManager.shared.play(.click)
        }
        
        // Bot AI: tracks ball with subtle delay
        let botSpeed = 2.1
        if botPaddleX < ballX - 4 {
            botPaddleX = min(screenWidth - paddleWidth / 2 - 6, botPaddleX + botSpeed)
        } else if botPaddleX > ballX + 4 {
            botPaddleX = max(paddleWidth / 2 + 6, botPaddleX - botSpeed)
        }
        
        // Bot Paddle Hit (Top)
        if ballY <= 26 && ballY >= 18 {
            if abs(ballX - botPaddleX) <= paddleWidth / 2 + 4 {
                ballVY = abs(ballVY) * 1.04
                let hitOffset = (ballX - botPaddleX) / (paddleWidth / 2)
                ballVX = hitOffset * 2.8
                HapticManager.shared.play(.click)
                SoundManager.shared.play(.click)
            }
        }
        
        // Player Paddle Hit (Bottom)
        if ballY >= screenHeight - 28 && ballY <= screenHeight - 20 {
            if abs(ballX - playerPaddleX) <= paddleWidth / 2 + 4 {
                ballVY = -abs(ballVY) * 1.04
                let hitOffset = (ballX - playerPaddleX) / (paddleWidth / 2)
                ballVX = hitOffset * 3.2
                HapticManager.shared.play(.directionUp)
                SoundManager.shared.play(.point)
            }
        }
        
        // Score Conditions
        if ballY < 8 {
            // Player point!
            playerScore += 1
            HapticManager.shared.play(.success)
            SoundManager.shared.play(.point)
            checkMatchEnd()
            serveBall(toPlayer: false)
        } else if ballY > screenHeight - 6 {
            // Bot point!
            botScore += 1
            HapticManager.shared.play(.error)
            SoundManager.shared.play(.gameover)
            checkMatchEnd()
            serveBall(toPlayer: true)
        }
    }
    
    private func serveBall(toPlayer: Bool) {
        ballX = screenWidth / 2
        ballY = screenHeight / 2
        ballVX = Double.random(in: -1.5...1.5)
        ballVY = toPlayer ? 2.4 : -2.4
    }
    
    private func checkMatchEnd() {
        if playerScore >= winningScore {
            isGameOver = true
            isPlayerWinner = true
            ScoreManager.shared.recordScore(playerScore, for: "tabletennis")
            ScoreManager.shared.addXP(150)
            HapticManager.shared.play(.victory)
            SoundManager.shared.play(.victory)
        } else if botScore >= winningScore {
            isGameOver = true
            isPlayerWinner = false
            HapticManager.shared.play(.error)
        }
    }
    
    private func resetGame() {
        playerScore = 0
        botScore = 0
        isGameOver = false
        serveBall(toPlayer: true)
    }
}
