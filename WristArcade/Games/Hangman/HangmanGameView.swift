import SwiftUI
import WatchKit

public struct HangmanGameView: View {
    private let enWords = ["WATCH", "APPLE", "ARCADE", "CROWN", "PULSE", "LASER", "CYBER", "NEON", "ROBOT", "QUEST", "POWER", "GHOST"]
    private let trWords = ["SAAT", "ELMA", "OYUN", "TEKER", "NABIZ", "LAZER", "SİBER", "NEON", "ROBOT", "GÖREV", "GÜÇ", "HAYALET"]
    
    @State private var targetWord: String = ""
    @State private var guessedLetters: Set<Character> = []
    @State private var mistakes: Int = 0
    private let maxMistakes = 6
    
    @State private var gameOver: Bool = false
    @State private var playerWon: Bool = false
    @State private var score: Int = 0
    
    private let keyboardRow1 = "ABCDEFG"
    private let keyboardRow2 = "HIJKLMN"
    private let keyboardRow3 = "OPQRSTU"
    private let keyboardRow4 = "VWXYZ"
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                // Header & Mistakes Remaining
                HStack {
                    Text("HANGMAN")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    HStack(spacing: 3) {
                        ForEach(0..<maxMistakes, id: \.self) { i in
                            Circle()
                                .fill(i < mistakes ? Color.red : Color.green.opacity(0.8))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(.horizontal, 8)
                
                // Neon Gallows Canvas
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .frame(height: 55)
                    
                    Canvas { ctx, size in
                        let strokeStyle = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        
                        // Base gallows pole
                        var base = Path()
                        base.move(to: CGPoint(x: size.width * 0.2, y: size.height * 0.85))
                        base.addLine(to: CGPoint(x: size.width * 0.45, y: size.height * 0.85))
                        base.move(to: CGPoint(x: size.width * 0.32, y: size.height * 0.85))
                        base.addLine(to: CGPoint(x: size.width * 0.32, y: size.height * 0.15))
                        base.addLine(to: CGPoint(x: size.width * 0.65, y: size.height * 0.15))
                        base.addLine(to: CGPoint(x: size.width * 0.65, y: size.height * 0.3))
                        ctx.stroke(base, with: .color(.gray), style: strokeStyle)
                        
                        let cx = size.width * 0.65
                        let topY = size.height * 0.3
                        
                        // 1. Head
                        if mistakes >= 1 {
                            let head = Path(ellipseIn: CGRect(x: cx - 6, y: topY, width: 12, height: 12))
                            ctx.stroke(head, with: .color(.orange), style: strokeStyle)
                        }
                        // 2. Body
                        if mistakes >= 2 {
                            var body = Path()
                            body.move(to: CGPoint(x: cx, y: topY + 12))
                            body.addLine(to: CGPoint(x: cx, y: topY + 24))
                            ctx.stroke(body, with: .color(.cyan), style: strokeStyle)
                        }
                        // 3. Left Arm
                        if mistakes >= 3 {
                            var lArm = Path()
                            lArm.move(to: CGPoint(x: cx, y: topY + 15))
                            lArm.addLine(to: CGPoint(x: cx - 8, y: topY + 20))
                            ctx.stroke(lArm, with: .color(.cyan), style: strokeStyle)
                        }
                        // 4. Right Arm
                        if mistakes >= 4 {
                            var rArm = Path()
                            rArm.move(to: CGPoint(x: cx, y: topY + 15))
                            rArm.addLine(to: CGPoint(x: cx + 8, y: topY + 20))
                            ctx.stroke(rArm, with: .color(.cyan), style: strokeStyle)
                        }
                        // 5. Left Leg
                        if mistakes >= 5 {
                            var lLeg = Path()
                            lLeg.move(to: CGPoint(x: cx, y: topY + 24))
                            lLeg.addLine(to: CGPoint(x: cx - 6, y: topY + 34))
                            ctx.stroke(lLeg, with: .color(.pink), style: strokeStyle)
                        }
                        // 6. Right Leg
                        if mistakes >= 6 {
                            var rLeg = Path()
                            rLeg.move(to: CGPoint(x: cx, y: topY + 24))
                            rLeg.addLine(to: CGPoint(x: cx + 6, y: topY + 34))
                            ctx.stroke(rLeg, with: .color(.pink), style: strokeStyle)
                        }
                    }
                    .frame(height: 55)
                }
                .padding(.horizontal, 8)
                
                // Word Display Slots
                HStack(spacing: 5) {
                    ForEach(Array(targetWord.enumerated()), id: \.offset) { _, char in
                        VStack(spacing: 2) {
                            Text(guessedLetters.contains(char) || gameOver ? String(char) : " ")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(guessedLetters.contains(char) ? .green : (gameOver ? .red : .white))
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 14, height: 2)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                // Game Over Overlay / Next Word
                if gameOver {
                    VStack(spacing: 4) {
                        Text(playerWon ? "SOLVED! +100" : "GAME OVER")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(playerWon ? .green : .red)
                        
                        Button(action: startNewGame) {
                            Text("NEXT WORD")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    // Touch Alphabet Keyboard
                    VStack(spacing: 3) {
                        keyboardRow(letters: keyboardRow1)
                        keyboardRow(letters: keyboardRow2)
                        keyboardRow(letters: keyboardRow3)
                        keyboardRow(letters: keyboardRow4)
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.bottom, 12)
        }
        .onAppear {
            startNewGame()
        }
    }
    
    private func keyboardRow(letters: String) -> some View {
        HStack(spacing: 3) {
            ForEach(Array(letters), id: \.self) { char in
                let isGuessed = guessedLetters.contains(char)
                let isInWord = targetWord.contains(char)
                
                Button(action: {
                    guessLetter(char)
                }) {
                    Text(String(char))
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 18, height: 20)
                        .background(
                            isGuessed
                                ? (isInWord ? Color.green.opacity(0.3) : Color.red.opacity(0.2))
                                : Color.white.opacity(0.15)
                        )
                        .foregroundColor(
                            isGuessed
                                ? (isInWord ? .green : .red.opacity(0.5))
                                : .white
                        )
                        .cornerRadius(3)
                }
                .buttonStyle(.plain)
                .disabled(isGuessed || gameOver)
            }
        }
    }
    
    private func guessLetter(_ char: Character) {
        guard !guessedLetters.contains(char) && !gameOver else { return }
        guessedLetters.insert(char)
        
        if targetWord.contains(char) {
            WKInterfaceDevice.current().play(.click)
            let won = targetWord.allSatisfy { guessedLetters.contains($0) }
            if won {
                playerWon = true
                gameOver = true
                score += 100
                WKInterfaceDevice.current().play(.success)
                _ = ScoreManager.shared.recordScore(score, for: "hangman")
                _ = XPManager.shared.addXP(50, reason: "Hangman Win")
            }
        } else {
            mistakes += 1
            WKInterfaceDevice.current().play(.failure)
            if mistakes >= maxMistakes {
                playerWon = false
                gameOver = true
            }
        }
    }
    
    private func startNewGame() {
        let isTurkish = LocalizationManager.shared.isTurkish
        let bank = isTurkish ? trWords : enWords
        targetWord = bank.randomElement() ?? "ARCADE"
        guessedLetters.removeAll()
        mistakes = 0
        gameOver = false
        playerWon = false
    }
}
