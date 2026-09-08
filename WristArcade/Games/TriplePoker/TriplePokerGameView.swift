import SwiftUI

public struct TriplePokerGameView: View {
    @State private var chips: Int = 100
    @State private var ante: Int = 10
    
    @State private var playerCards: [Int] = []
    @State private var dealerCards: [Int] = []
    @State private var dealerRevealed: Bool = false
    @State private var message: String = "ANTE koy ve DAĞIT'a bas"
    @State private var inHand: Bool = false
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                HStack {
                    Text("Fiş: $\(chips)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                    Spacer()
                    Text("Ante: $\(ante)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 4)
                
                // Dealer Hand
                VStack(spacing: 2) {
                    Text("DAĞITICI (3 KART)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { idx in
                            if idx < dealerCards.count {
                                Text(dealerRevealed ? "\(dealerCards[idx])" : "🂠")
                                    .font(.system(size: 11, weight: .bold))
                                    .frame(width: 22, height: 30)
                                    .background(dealerRevealed ? Color.white : Color.blue.opacity(0.3))
                                    .foregroundColor(dealerRevealed ? .black : .white)
                                    .cornerRadius(4)
                            } else {
                                Text("🂠")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // Player Hand
                VStack(spacing: 2) {
                    Text("SENİN ELİN")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.cyan)
                    HStack(spacing: 3) {
                        ForEach(0..<playerCards.count, id: \.self) { idx in
                            Text("\(playerCards[idx])")
                                .font(.system(size: 11, weight: .bold))
                                .frame(width: 22, height: 30)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Text(message)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .frame(height: 20)
                
                if !inHand {
                    Button(action: startHand) {
                        Text(chips < ante ? "YENİDEN DOLDUR" : "DAĞIT ($\(ante))")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                            .background(Color.cyan)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 4)
                } else {
                    HStack(spacing: 6) {
                        Button("PAS GEÇ") { fold() }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 26)
                            .background(Color.red.opacity(0.4))
                            .clipShape(Capsule())
                        
                        Button("OYNA ($\(ante))") { playCall() }
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 26)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Three Card Poker")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func startHand() {
        if chips < ante {
            chips = 100
            message = "Kasa yenilendi! ($100)"
            return
        }
        chips -= ante
        haptic.play(.click)
        
        playerCards = [Int.random(in: 2...14), Int.random(in: 2...14), Int.random(in: 2...14)].sorted()
        dealerCards = [Int.random(in: 2...14), Int.random(in: 2...14), Int.random(in: 2...14)].sorted()
        dealerRevealed = false
        inHand = true
        message = "Oyna veya Pas geç"
    }
    
    private func fold() {
        inHand = false
        dealerRevealed = true
        message = "Pas geçildi. Ante kaybedildi."
        haptic.play(.click)
    }
    
    private func playCall() {
        guard chips >= ante else {
            fold()
            return
        }
        chips -= ante
        inHand = false
        dealerRevealed = true
        
        let pScore = evaluate3Card(playerCards)
        let dScore = evaluate3Card(dealerCards)
        
        if pScore > dScore {
            let win = ante * 4
            chips += win
            message = "Kazandın! +$\(win) 🏆"
            haptic.play(.victory)
        } else if dScore > pScore {
            message = "Dağıtıcı kazandı!"
            haptic.play(.warning)
        } else {
            chips += ante * 2
            message = "Berabere! İade edildi."
        }
        
        _ = scoreManager.recordScore(chips, for: "triplepoker")
    }
    
    private func evaluate3Card(_ cards: [Int]) -> Int {
        // 3 of a kind
        if cards[0] == cards[1] && cards[1] == cards[2] {
            return 500 + cards[0]
        }
        // Straight
        if cards[0] + 1 == cards[1] && cards[1] + 1 == cards[2] {
            return 400 + cards[2]
        }
        // Pair
        if cards[0] == cards[1] || cards[1] == cards[2] {
            return 200 + (cards[1])
        }
        // High card
        return cards.max() ?? 0
    }
}
