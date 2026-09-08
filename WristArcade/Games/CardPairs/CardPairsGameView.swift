import SwiftUI

public struct CardPairsGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct MemoryCard: Identifiable {
        let id: Int
        let symbol: String
        let color: Color
        var isFaceUp: Bool = false
        var isMatched: Bool = false
    }
    
    @State private var cards: [MemoryCard] = []
    @State private var selectedIndices: [Int] = []
    @State private var moves: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isVictory: Bool = false
    @State private var isBusy: Bool = false
    
    private let symbols = ["♠", "♥", "♦", "♣", "⭐", "⚡"]
    private let colors: [Color] = [.white, .red, .orange, .cyan, .yellow, .purple]
    
    public var body: some View {
        GeometryReader { geo in
            let boardWidth = geo.size.width - 12
            let cardW = (boardWidth - 12) / 3
            let cardH = cardW * 1.15
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 3) {
                        // Header
                        HStack {
                            Text("MOVES: \(moves)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.indigo)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            let best = scoreManager.getHighScore(for: "cardpairs")
                            Text(best > 0 ? "\(best)" : "--")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        
                        // 3x4 Grid (4 rows of 3)
                        VStack(spacing: 4) {
                            ForEach(0..<4, id: \.self) { r in
                                HStack(spacing: 4) {
                                    ForEach(0..<3, id: \.self) { c in
                                        let idx = r * 3 + c
                                        let card = cards[idx]
                                        
                                        Button(action: {
                                            cardTapped(at: idx)
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(card.isMatched ? Color.green.opacity(0.2) : (card.isFaceUp ? Color.white : Color.indigo.opacity(0.6)))
                                                    .frame(width: cardW, height: cardH)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(card.isMatched ? Color.green : Color.white.opacity(0.3), lineWidth: 1)
                                                    )
                                                
                                                if card.isFaceUp || card.isMatched {
                                                    Text(card.symbol)
                                                        .font(.system(size: 18, weight: .bold))
                                                        .foregroundColor(card.color)
                                                } else {
                                                    Image(systemName: "questionmark")
                                                        .font(.system(size: 11, weight: .bold))
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(card.isMatched || card.isFaceUp || isBusy)
                                    }
                                }
                            }
                        }
                        .padding(4)
                    }
                } else if isVictory {
                    VStack(spacing: 6) {
                        Text("ALL PAIRS FOUND!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.green)
                        
                        Text("Completed in \(moves) moves")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("PLAY AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.indigo)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "square.stack.3d.down.right.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.indigo)
                        
                        Text("CARD PAIRS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Flip and match all 6 card pairs in fewest moves")
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.indigo)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func startNewGame() {
        var deck: [MemoryCard] = []
        var id = 0
        for i in 0..<6 {
            deck.append(MemoryCard(id: id, symbol: symbols[i], color: colors[i]))
            id += 1
            deck.append(MemoryCard(id: id, symbol: symbols[i], color: colors[i]))
            id += 1
        }
        self.cards = deck.shuffled()
        self.selectedIndices = []
        self.moves = 0
        self.isVictory = false
        self.isBusy = false
        self.isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func cardTapped(at index: Int) {
        guard !isBusy, !cards[index].isFaceUp, !cards[index].isMatched else { return }
        
        cards[index].isFaceUp = true
        selectedIndices.append(index)
        HapticManager.shared.play(.tap)
        
        if selectedIndices.count == 2 {
            moves += 1
            let first = selectedIndices[0]
            let second = selectedIndices[1]
            
            if cards[first].symbol == cards[second].symbol {
                // Match!
                cards[first].isMatched = true
                cards[second].isMatched = true
                selectedIndices = []
                HapticManager.shared.play(.score)
                
                // Check if all matched
                if cards.allSatisfy({ $0.isMatched }) {
                    isVictory = true
                    isPlaying = false
                    _ = scoreManager.recordScore(moves, for: "cardpairs")
                    HapticManager.shared.play(.victory)
                }
            } else {
                // No match, flip back after short delay
                isBusy = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    cards[first].isFaceUp = false
                    cards[second].isFaceUp = false
                    selectedIndices = []
                    isBusy = false
                }
            }
        }
    }
}
