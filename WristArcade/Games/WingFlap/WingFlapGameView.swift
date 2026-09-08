import SwiftUI

public struct WingFlapGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct Pipe: Identifiable {
        let id: Int
        var x: CGFloat
        let gapY: CGFloat
        var passed: Bool = false
    }
    
    @State private var birdY: CGFloat = 110.0
    @State private var birdVy: CGFloat = 0.0
    
    @State private var pipes: [Pipe] = []
    @State private var score: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    @State private var pipeCounter: Int = 0
    
    private let pipeGap: CGFloat = 58.0
    private let pipeWidth: CGFloat = 18.0
    
    var body: some View {
        GeometryReader { geo in
            let fieldW = geo.size.width
            let fieldH = geo.size.height
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    // Pipes
                    ForEach(pipes) { p in
                        // Top pipe
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: pipeWidth, height: p.gapY - (pipeGap / 2))
                            .position(x: p.x, y: (p.gapY - (pipeGap / 2)) / 2)
                        
                        // Bottom pipe
                        let botHeight = fieldH - (p.gapY + (pipeGap / 2))
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: pipeWidth, height: botHeight)
                            .position(x: p.x, y: (p.gapY + (pipeGap / 2)) + (botHeight / 2))
                    }
                    
                    // Bird (Custom neon circle with wing)
                    ZStack {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 14, height: 14)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 4, height: 4)
                            .offset(x: 3, y: -2)
                    }
                    .position(x: 40, y: birdY)
                    .shadow(color: .yellow, radius: 4)
                    
                    // Score HUD
                    VStack {
                        HStack {
                            Text("\(score)")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.green)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "wingflap"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 2)
                        Spacer()
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "GAME OVER")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: { startNewGame(fieldH: fieldH) }) {
                            Text("FLAP AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .handGestureShortcut(.primaryAction)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "bird.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.green)
                        
                        Text("WING FLAP")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Tap screen or Double Tap fingers to flap wings")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: { startNewGame(fieldH: fieldH) }) {
                            Text("FLY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .handGestureShortcut(.primaryAction)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                flap()
            }
            .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                tick(fieldW: fieldW, fieldH: fieldH)
            }
        }
    }
    
    private func startNewGame(fieldH: CGFloat) {
        score = 0
        pipes = []
        birdY = fieldH / 2
        birdVy = 0
        isGameOver = false
        isNewRecord = false
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func flap() {
        guard isPlaying else { return }
        birdVy = -4.8
        HapticManager.shared.play(.tap)
    }
    
    private func tick(fieldW: CGFloat, fieldH: CGFloat) {
        birdY += birdVy
        birdVy += 0.32 // Gravity
        
        // Floor / ceiling collision
        if birdY <= 7 || birdY >= fieldH - 7 {
            triggerGameOver()
            return
        }
        
        // Spawn pipes
        pipeCounter += 1
        if pipeCounter % 45 == 0 {
            let gapY = CGFloat.random(in: 45...(fieldH - 45))
            pipes.append(Pipe(id: pipeCounter, x: fieldW + 20, gapY: gapY))
        }
        
        // Move & collide
        var nextPipes: [Pipe] = []
        let birdBox = CGRect(x: 40 - 6, y: birdY - 6, width: 12, height: 12)
        
        for var p in pipes {
            p.x -= 2.2
            
            // Collision with top & bottom pipe
            let topBox = CGRect(x: p.x - (pipeWidth / 2), y: 0, width: pipeWidth, height: p.gapY - (pipeGap / 2))
            let botBox = CGRect(x: p.x - (pipeWidth / 2), y: p.gapY + (pipeGap / 2), width: pipeWidth, height: fieldH)
            
            if birdBox.intersects(topBox) || birdBox.intersects(botBox) {
                triggerGameOver()
                return
            }
            
            // Score check
            if !p.passed && p.x < 40 {
                p.passed = true
                score += 1
                HapticManager.shared.play(.score)
            }
            
            if p.x > -20 {
                nextPipes.append(p)
            }
        }
        self.pipes = nextPipes
    }
    
    private func triggerGameOver() {
        isPlaying = false
        isGameOver = true
        isNewRecord = scoreManager.recordScore(score, for: "wingflap")
        HapticManager.shared.play(.gameOver)
    }
}
