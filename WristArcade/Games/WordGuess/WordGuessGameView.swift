import SwiftUI

public struct WordGuessGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct GuessRow {
        var letters: [Character]
        var states: [LetterState]
    }
    
    enum LetterState {
        case empty, notInWord, wrongSpot, correctSpot
        
        var color: Color {
            switch self {
            case .empty: return Color.white.opacity(0.1)
            case .notInWord: return Color.gray.opacity(0.4)
            case .wrongSpot: return Color.yellow
            case .correctSpot: return Color.green
            }
        }
    }
    
    private let wordList = ["STAR", "GAME", "TIME", "PLAY", "GOLD", "FIRE", "WIND", "MOON", "LION", "BEAR", "COOL", "HERO"]
    @State private var secretWord: String = "STAR"
    @State private var rows: [GuessRow] = []
    @State private var currentRow: Int = 0
    @State private var currentGuess: String = ""
    
    @State private var isPlaying: Bool = false
    @State private var isVictory: Bool = false
    @State private var isGameOver: Bool = false
    
    private let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 3) {
                        // 4 Rows of 4 Tiles
                        VStack(spacing: 3) {
                            ForEach(0..<4, id: \.self) { r in
                                HStack(spacing: 4) {
                                    ForEach(0..<4, id: \.self) { c in
                                        let char = (r < rows.count && c < rows[r].letters.count) ? String(rows[r].letters[c]) : (r == currentRow && c < currentGuess.count ? String(Array(currentGuess)[c]) : "")
                                        let state = (r < rows.count) ? rows[r].states[c] : .empty
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(state.color)
                                                .frame(width: 28, height: 28)
                                            
                                            Text(char)
                                                .font(.system(size: 13, weight: .black, design: .rounded))
                                                .foregroundColor(state == .wrongSpot || state == .correctSpot ? .black : .white)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mini keyboard / letter picker
                        VStack(spacing: 2) {
                            HStack(spacing: 2) {
                                ForEach(Array("ABCDEFGHIJ"), id: \.self) { ch in
                                    keyBtn(ch)
                                }
                            }
                            HStack(spacing: 2) {
                                ForEach(Array("KLMNOPQRST"), id: \.self) { ch in
                                    keyBtn(ch)
                                }
                            }
                            HStack(spacing: 2) {
                                ForEach(Array("UVWXYZ"), id: \.self) { ch in
                                    keyBtn(ch)
                                }
                                Button(action: deleteChar) {
                                    Image(systemName: "delete.left.fill")
                                        .font(.system(size: 9))
                                        .frame(width: 22, height: 18)
                                        .background(Color.red.opacity(0.6))
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: submitGuess) {
                                    Text("GO")
                                        .font(.system(size: 9, weight: .bold))
                                        .frame(width: 24, height: 18)
                                        .background(Color.green)
                                        .foregroundColor(.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                }
                                .buttonStyle(.plain)
                                .disabled(currentGuess.count != 4)
                            }
                        }
                        .padding(.top, 2)
                    }
                } else if isVictory || isGameOver {
                    VStack(spacing: 6) {
                        Text(isVictory ? "WORD CRACKED!" : "OUT OF GUESSES!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isVictory ? .green : .red)
                        
                        Text("Word was: \(secretWord)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("PLAY AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "character.book.closed.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.green)
                        
                        Text("WORD GUESS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Deduce the hidden 4-letter word in 4 guesses")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func keyBtn(_ ch: Character) -> some View {
        Button(action: {
            if currentGuess.count < 4 {
                currentGuess.append(ch)
                HapticManager.shared.play(.tap)
            }
        }) {
            Text(String(ch))
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 14, height: 18)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .buttonStyle(.plain)
    }
    
    private func deleteChar() {
        if !currentGuess.isEmpty {
            currentGuess.removeLast()
            HapticManager.shared.play(.tap)
        }
    }
    
    private func startNewGame() {
        secretWord = wordList.randomElement()!
        rows = []
        currentRow = 0
        currentGuess = ""
        isVictory = false
        isGameOver = false
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func submitGuess() {
        guard currentGuess.count == 4 else { return }
        
        let guessChars = Array(currentGuess)
        let secretChars = Array(secretWord)
        var states: [LetterState] = Array(repeating: .notInWord, count: 4)
        
        for i in 0..<4 {
            if guessChars[i] == secretChars[i] {
                states[i] = .correctSpot
            } else if secretChars.contains(guessChars[i]) {
                states[i] = .wrongSpot
            }
        }
        
        rows.append(GuessRow(letters: guessChars, states: states))
        
        if currentGuess == secretWord {
            isPlaying = false
            isVictory = true
            _ = scoreManager.recordScore(1, for: "wordguess")
            HapticManager.shared.play(.victory)
        } else if rows.count >= 4 {
            isPlaying = false
            isGameOver = true
            HapticManager.shared.play(.gameOver)
        } else {
            currentRow += 1
            currentGuess = ""
            HapticManager.shared.play(.bounce)
        }
    }
}
