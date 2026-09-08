import SwiftUI

public struct WhackDotGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    @State private var activeHole: Int? = nil
    @State private var score: Int = 0
    @State private var timeLeft: Int = 25
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width, geo.size.height) - 16
            let holeSize = (boardSize - 16) / 3
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 4) {
                        // Header
                        HStack {
                            Text("SCORE: \(score)")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(.red)
                            Spacer()
                            Text("⏳ \(timeLeft)s")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(timeLeft <= 5 ? .red : .yellow)
                        }
                        .padding(.horizontal, 10)
                        
                        // 3x3 Grid
                        VStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { r in
                                HStack(spacing: 6) {
                                    ForEach(0..<3, id: \.self) { c in
                                        let idx = r * 3 + c
                                        let isTarget = (activeHole == idx)
                                        
                                        Button(action: {
                                            whack(idx: idx)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white.opacity(0.1))
                                                    .frame(width: holeSize, height: holeSize)
                                                
                                                if isTarget {
                                                    Circle()
                                                        .fill(Color.red)
                                                        .frame(width: holeSize - 8, height: holeSize - 8)
                                                        .shadow(color: .red, radius: 6)
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(4)
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "TIME UP!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Whacks: \(score)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("WHACK AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "circle.grid.3x3.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.red)
                        
                        Text("WHACK-A-DOT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Tap glowing red dots as fast as you can")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                if timeLeft > 0 {
                    timeLeft -= 1
                } else {
                    isPlaying = false
                    isGameOver = true
                    isNewRecord = scoreManager.recordScore(score, for: "whackmole")
                    HapticManager.shared.play(.gameOver)
                }
            }
            .onReceive(Timer.publish(every: 0.75, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                activeHole = Int.random(in: 0..<9)
            }
        }
    }
    
    private func startNewGame() {
        score = 0
        timeLeft = 25
        isGameOver = false
        isNewRecord = false
        isPlaying = true
        activeHole = Int.random(in: 0..<9)
        HapticManager.shared.play(.tap)
    }
    
    private func whack(idx: Int) {
        if idx == activeHole {
            score += 1
            activeHole = nil
            HapticManager.shared.play(.score)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if isPlaying { activeHole = Int.random(in: 0..<9) }
            }
        } else {
            HapticManager.shared.play(.error)
        }
    }
}
