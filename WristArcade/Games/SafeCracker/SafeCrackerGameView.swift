import SwiftUI

public struct SafeCrackerGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    @State private var dialValue: Double = 0.0
    @State private var targets: [Int] = []
    @State private var currentTargetIndex: Int = 0
    @State private var timeLeft: Int = 30
    
    @State private var isPlaying: Bool = false
    @State private var isVictory: Bool = false
    @State private var isGameOver: Bool = false
    @State private var safesCracked: Int = 0
    
    public var body: some View {
        GeometryReader { geo in
            let currentNumber = (Int(dialValue) % 100 + 100) % 100
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 6) {
                        // Header HUD
                        HStack {
                            Text("TIME: \(timeLeft)s")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(timeLeft <= 8 ? .red : .yellow)
                            Spacer()
                            HStack(spacing: 4) {
                                ForEach(0..<3, id: \.self) { i in
                                    Image(systemName: i < currentTargetIndex ? "lock.open.fill" : "lock.fill")
                                        .font(.system(size: 9))
                                        .foregroundColor(i < currentTargetIndex ? .green : .gray)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        
                        // Safe Dial Graphic
                        ZStack {
                            // Dial Outer Ring
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 6)
                                .frame(width: 120, height: 120)
                            
                            // Indicator line at top
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 3, height: 12)
                                .offset(y: -54)
                            
                            // Center Number Display
                            VStack(spacing: 0) {
                                Text("\(currentNumber)")
                                    .font(.system(size: 34, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                Text("DIAL")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Text("Rotate Crown to feel combination")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                } else if isVictory || isGameOver {
                    VStack(spacing: 6) {
                        Text(isVictory ? "SAFE CRACKED!" : "TIME UP!")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(isVictory ? .yellow : .red)
                        
                        Text("Total Safes: \(safesCracked)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("NEXT VAULT")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow)
                        
                        Text("SAFE CRACKER")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Turn Digital Crown to feel dial clicks and open the 3 locks")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: startNewGame) {
                            Text("CRACK")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .focusable(true)
            .digitalCrownRotation(
                $dialValue,
                from: -1000.0,
                through: 1000.0,
                by: 1.0,
                sensitivity: .high,
                isContinuous: true,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: dialValue) { newValue in
                guard isPlaying else { return }
                checkDial(val: (Int(newValue) % 100 + 100) % 100)
            }
            .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                if timeLeft > 0 {
                    timeLeft -= 1
                } else {
                    isPlaying = false
                    isGameOver = true
                    HapticManager.shared.play(.gameOver)
                }
            }
        }
    }
    
    private func startNewGame() {
        targets = [
            Int.random(in: 10...35),
            Int.random(in: 40...65),
            Int.random(in: 70...95)
        ]
        currentTargetIndex = 0
        timeLeft = 30
        dialValue = 0.0
        isVictory = false
        isGameOver = false
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func checkDial(val: Int) {
        guard currentTargetIndex < targets.count else { return }
        let target = targets[currentTargetIndex]
        
        let diff = abs(val - target)
        if diff <= 1 {
            // Unlocked this digit!
            currentTargetIndex += 1
            HapticManager.shared.play(.score)
            
            if currentTargetIndex == 3 {
                // Whole safe unlocked!
                safesCracked += 1
                isPlaying = false
                isVictory = true
                _ = scoreManager.recordScore(safesCracked, for: "safecracker")
                HapticManager.shared.play(.victory)
            }
        } else if diff <= 4 {
            HapticManager.shared.play(.crownTick)
        }
    }
}
