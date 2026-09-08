import SwiftUI

public struct MathBlitzGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    @State private var equationText: String = "7 + 8 = 15"
    @State private var isEquationCorrect: Bool = true
    @State private var score: Int = 0
    @State private var timerProgress: CGFloat = 1.0
    
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 8) {
                        // Header
                        HStack {
                            Text("STREAK: \(score)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "mathblitz"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        
                        // Timer bar
                        GeometryReader { barGeo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 3)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(timerProgress > 0.3 ? Color.blue : Color.red)
                                    .frame(width: barGeo.size.width * timerProgress, height: 3)
                            }
                        }
                        .frame(height: 3)
                        .padding(.horizontal, 10)
                        
                        // Equation Display
                        Text(equationText)
                            .font(.system(size: 20, weight: .heavy, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                        
                        // TRUE / FALSE Buttons
                        HStack(spacing: 8) {
                            Button(action: { answer(true) }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark")
                                    Text("TRUE")
                                }
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                                .background(Color.green)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { answer(false) }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "xmark")
                                    Text("FALSE")
                                }
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                                .background(Color.red)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 8)
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "WRONG!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Streak: \(score)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("RETRY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "plus.forwardslash.minus")
                            .font(.system(size: 26))
                            .foregroundColor(.blue)
                        
                        Text("MATH BLITZ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Is the math correct? You have 3 seconds per round!")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                timerProgress -= 0.018
                if timerProgress <= 0 {
                    triggerGameOver()
                }
            }
        }
    }
    
    private func startNewGame() {
        score = 0
        isGameOver = false
        isNewRecord = false
        isPlaying = true
        generateEquation()
        HapticManager.shared.play(.tap)
    }
    
    private func generateEquation() {
        timerProgress = 1.0
        let a = Int.random(in: 2...12)
        let b = Int.random(in: 2...12)
        let isAdd = Bool.random()
        let realResult = isAdd ? (a + b) : (a * b)
        
        let shouldBeCorrect = Bool.random()
        let shownResult = shouldBeCorrect ? realResult : realResult + [-2, -1, 1, 2].randomElement()!
        
        self.isEquationCorrect = (realResult == shownResult)
        let op = isAdd ? "+" : "×"
        self.equationText = "\(a) \(op) \(b) = \(shownResult)"
    }
    
    private func answer(_ userGuess: Bool) {
        if userGuess == isEquationCorrect {
            score += 1
            HapticManager.shared.play(.score)
            generateEquation()
        } else {
            triggerGameOver()
        }
    }
    
    private func triggerGameOver() {
        isPlaying = false
        isGameOver = true
        isNewRecord = scoreManager.recordScore(score, for: "mathblitz")
        HapticManager.shared.play(.gameOver)
    }
}
