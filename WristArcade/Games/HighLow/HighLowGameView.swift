import SwiftUI

public struct HighLowGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct Card {
        let rank: String
        let suit: String
        let value: Int
        
        var isRed: Bool {
            return suit == "♥" || suit == "♦"
        }
    }
    
    @State private var currentCard: Card = Card(rank: "7", suit: "♦", value: 7)
    @State private var streak: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 6) {
                        // Header
                        HStack {
                            Text("STREAK: \(streak)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "highlow"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        
                        // Center Card
                        VStack(spacing: 2) {
                            Text(currentCard.rank)
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(currentCard.isRed ? .red : .black)
                            Text(currentCard.suit)
                                .font(.system(size: 28))
                                .foregroundColor(currentCard.isRed ? .red : .black)
                        }
                        .frame(width: 80, height: 110)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .white.opacity(0.2), radius: 6)
                        
                        // Higher / Lower Guess Buttons
                        HStack(spacing: 8) {
                            Button(action: { guess(isHigher: true) }) {
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.up")
                                    Text("HIGHER")
                                }
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 28)
                                .background(Color.green)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { guess(isHigher: false) }) {
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.down")
                                    Text("LOWER")
                                }
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 28)
                                .background(Color.red)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 8)
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "WRONG GUESS!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Streak: \(streak)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("RETRY")
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
                        Image(systemName: "suit.heart.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.red)
                        
                        Text("HIGH-LOW")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Guess if the next card will be Higher or Lower")
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
        }
    }
    
    private func startNewGame() {
        streak = 0
        isGameOver = false
        isNewRecord = false
        currentCard = randomCard()
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func randomCard() -> Card {
        let ranks = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]
        let suits = ["♠", "♥", "♦", "♣"]
        let r = ranks.randomElement()!
        let s = suits.randomElement()!
        let v: Int
        if r == "A" { v = 14 }
        else if r == "K" { v = 13 }
        else if r == "Q" { v = 12 }
        else if r == "J" { v = 11 }
        else { v = Int(r) ?? 7 }
        return Card(rank: r, suit: s, value: v)
    }
    
    private func guess(isHigher: Bool) {
        var next = randomCard()
        while next.value == currentCard.value {
            next = randomCard() // Avoid exact equal ties for snappy gameplay
        }
        
        let correct = isHigher ? (next.value > currentCard.value) : (next.value < currentCard.value)
        currentCard = next
        
        if correct {
            streak += 1
            HapticManager.shared.play(.score)
        } else {
            isPlaying = false
            isGameOver = true
            isNewRecord = scoreManager.recordScore(streak, for: "highlow")
            HapticManager.shared.play(.gameOver)
        }
    }
}
