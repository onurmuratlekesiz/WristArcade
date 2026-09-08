import SwiftUI

public struct MicroSolitaireGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct Card: Identifiable, Equatable {
        let id = UUID()
        let rank: String
        let suit: String
        let value: Int
        var isRemoved: Bool = false
        
        var isRed: Bool {
            return suit == "♥" || suit == "♦"
        }
    }
    
    @State private var tableau: [Card] = [] // 9 cards (3x3)
    @State private var stock: [Card] = []
    @State private var wasteCard: Card? = nil
    
    @State private var cardsCleared: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isVictory: Bool = false
    @State private var isGameOver: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 4) {
                        // Header
                        HStack {
                            Text("CLEARED: \(cardsCleared)/9")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "microsolitaire"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        
                        // Tableau: 3 columns x 3 rows
                        VStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { r in
                                HStack(spacing: 4) {
                                    ForEach(0..<3, id: \.self) { c in
                                        let idx = r * 3 + c
                                        if idx < tableau.count {
                                            let card = tableau[idx]
                                            Button(action: {
                                                tapTableauCard(at: idx)
                                            }) {
                                                if card.isRemoved {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                                        .frame(width: 26, height: 36)
                                                } else {
                                                    cardView(card: card)
                                                }
                                            }
                                            .buttonStyle(.plain)
                                            .disabled(card.isRemoved)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.15))
                        
                        // Bottom Area: Waste Card & Stock Pile
                        HStack(spacing: 12) {
                            // Stock pile
                            Button(action: drawFromStock) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.cyan.opacity(0.7))
                                        .frame(width: 30, height: 40)
                                    Text("\(stock.count)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(stock.isEmpty)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                            
                            // Waste card
                            if let waste = wasteCard {
                                cardView(card: waste)
                                    .scaleEffect(1.08)
                            }
                        }
                        .padding(.top, 2)
                    }
                } else if isVictory || isGameOver {
                    VStack(spacing: 6) {
                        Text(isVictory ? "TABLE CLEARED!" : "OUT OF MOVES!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isVictory ? .green : .red)
                        
                        Text("Cleared: \(cardsCleared) cards")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("PLAY AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.cyan)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "suit.spade.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.cyan)
                        
                        Text("MICRO SOLITAIRE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Tap cards that are ±1 rank from waste card to clear")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: startNewGame) {
                            Text("DEAL")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.cyan)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func cardView(card: Card) -> some View {
        VStack(spacing: 1) {
            Text(card.rank)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(card.isRed ? .red : .black)
            Text(card.suit)
                .font(.system(size: 11))
                .foregroundColor(card.isRed ? .red : .black)
        }
        .frame(width: 26, height: 36)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: .white.opacity(0.1), radius: 2)
    }
    
    private func startNewGame() {
        let ranks = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
        let suits = ["♠", "♥", "♦", "♣"]
        var fullDeck: [Card] = []
        for s in suits {
            for (idx, r) in ranks.enumerated() {
                fullDeck.append(Card(rank: r, suit: s, value: idx + 1))
            }
        }
        fullDeck.shuffle()
        
        self.tableau = Array(fullDeck.prefix(9))
        self.wasteCard = fullDeck[9]
        self.stock = Array(fullDeck.dropFirst(10))
        self.cardsCleared = 0
        self.isVictory = false
        self.isGameOver = false
        self.isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func tapTableauCard(at index: Int) {
        guard let waste = wasteCard else { return }
        let card = tableau[index]
        guard !card.isRemoved else { return }
        
        // Match +1 or -1 (with King - Ace wrapping)
        let diff = abs(card.value - waste.value)
        let isMatch = (diff == 1) || (card.value == 1 && waste.value == 13) || (card.value == 13 && waste.value == 1)
        
        if isMatch {
            tableau[index].isRemoved = true
            wasteCard = card
            cardsCleared += 1
            HapticManager.shared.play(.score)
            
            if cardsCleared == 9 {
                isPlaying = false
                isVictory = true
                _ = scoreManager.recordScore(9, for: "microsolitaire")
                HapticManager.shared.play(.victory)
            }
        } else {
            HapticManager.shared.play(.error)
        }
    }
    
    private func drawFromStock() {
        guard !stock.isEmpty else { return }
        wasteCard = stock.removeFirst()
        HapticManager.shared.play(.tap)
    }
}
