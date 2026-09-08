import SwiftUI

public struct WordMasterGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var soundManager = SoundManager.shared
    
    // 6 rows x 5 letters
    @State private var guesses: [String] = []
    @State private var currentGuess: String = ""
    @State private var targetWord: String = "WATCH"
    @State private var isGameOver: Bool = false
    @State private var hasWon: Bool = false
    @State private var statusMessage: String = "Guess 5-letter word"
    
    // Word banks
    private let wordsEn = ["WATCH", "APPLE", "CROWN", "PULSE", "TIMER", "SMART", "HEART", "GAMES", "PIXEL", "POWER", "RETRO", "SHINE", "TRACK", "SPACE", "FOCUS"]
    private let wordsTr = ["SAATİ", "ELMAY", "KORON", "NABIZ", "SAYAC", "AKILL", "KALBİ", "OYUNU", "PİKSL", "GUCUK", "RETRO", "ISIKT", "KAYIT", "UZAYI", "ODAKL"]
    
    private let keyboardRowsEn = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["↵", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
    ]
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                // 6 Guess Rows
                VStack(spacing: 3) {
                    ForEach(0..<6, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(0..<5, id: \.self) { col in
                                tileView(row: row, col: col)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
                
                Text(statusMessage)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(hasWon ? .green : (isGameOver ? .red : .gray))
                    .lineLimit(1)
                
                // Virtual Keyboard
                if !isGameOver {
                    VStack(spacing: 3) {
                        ForEach(0..<keyboardRowsEn.count, id: \.self) { r in
                            HStack(spacing: 2) {
                                ForEach(keyboardRowsEn[r], id: \.self) { key in
                                    Button(action: {
                                        handleKey(key)
                                    }) {
                                        Text(key)
                                            .font(.system(size: key == "↵" || key == "⌫" ? 9 : 10, weight: .bold))
                                            .frame(width: key == "↵" || key == "⌫" ? 22 : 15, height: 22)
                                            .background(keyBackground(key))
                                            .foregroundColor(.white)
                                            .cornerRadius(3)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.top, 2)
                } else {
                    Button(action: startNewGame) {
                        Text("Next Word")
                            .font(.system(size: 12, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(6)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear(perform: startNewGame)
    }
    
    @ViewBuilder
    private func tileView(row: Int, col: Int) -> some View {
        let (letter, bg) = letterAndColor(row: row, col: col)
        
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(bg)
                .frame(width: 24, height: 24)
            
            Text(letter)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private func letterAndColor(row: Int, col: Int) -> (String, Color) {
        if row < guesses.count {
            let guess = guesses[row]
            guard col < guess.count else { return ("", Color.white.opacity(0.1)) }
            let charIndex = guess.index(guess.startIndex, offsetBy: col)
            let letter = String(guess[charIndex])
            
            let targetIndex = targetWord.index(targetWord.startIndex, offsetBy: col)
            let targetChar = String(targetWord[targetIndex])
            
            if letter == targetChar {
                return (letter, Color.green)
            } else if targetWord.contains(letter) {
                return (letter, Color.yellow.opacity(0.85))
            } else {
                return (letter, Color.gray.opacity(0.35))
            }
        } else if row == guesses.count {
            guard col < currentGuess.count else { return ("", Color.white.opacity(0.1)) }
            let charIndex = currentGuess.index(currentGuess.startIndex, offsetBy: col)
            return (String(currentGuess[charIndex]), Color.white.opacity(0.2))
        } else {
            return ("", Color.white.opacity(0.08))
        }
    }
    
    private func keyBackground(_ key: String) -> Color {
        // If key was guessed
        for guess in guesses {
            for (idx, char) in guess.enumerated() {
                if String(char) == key {
                    let targetChar = String(targetWord[targetWord.index(targetWord.startIndex, offsetBy: idx)])
                    if String(char) == targetChar { return Color.green }
                    else if targetWord.contains(key) { return Color.yellow.opacity(0.8) }
                    else { return Color.gray.opacity(0.3) }
                }
            }
        }
        return Color.white.opacity(0.15)
    }
    
    private func handleKey(_ key: String) {
        soundManager.play(.tap)
        HapticManager.shared.play(.tap)
        
        if key == "⌫" {
            if !currentGuess.isEmpty { currentGuess.removeLast() }
        } else if key == "↵" {
            submitGuess()
        } else {
            if currentGuess.count < 5 {
                currentGuess.append(key)
            }
        }
    }
    
    private func submitGuess() {
        guard currentGuess.count == 5 else {
            statusMessage = "Must be 5 letters!"
            return
        }
        
        guesses.append(currentGuess)
        
        if currentGuess == targetWord {
            hasWon = true
            isGameOver = true
            soundManager.play(.victory)
            HapticManager.shared.play(.victory)
            let score = (7 - guesses.count) * 200
            scoreManager.saveHighScore(score, for: "word5")
            scoreManager.addXP(150)
            statusMessage = "SOLVED! 🏆 \(targetWord)"
        } else if guesses.count >= 6 {
            isGameOver = true
            soundManager.play(.gameOver)
            HapticManager.shared.play(.gameOver)
            statusMessage = "Word was: \(targetWord)"
        } else {
            currentGuess = ""
            statusMessage = "Try \(guesses.count + 1) / 6"
        }
    }
    
    private func startNewGame() {
        guesses = []
        currentGuess = ""
        isGameOver = false
        hasWon = false
        statusMessage = "Guess 5-letter word"
        
        let isTr = LocalizationManager.shared.currentLanguage == "tr"
        let pool = isTr ? wordsTr : wordsEn
        targetWord = pool.randomElement() ?? "WATCH"
    }
}
