import SwiftUI

public struct BaccaratGameView: View {
    @State private var bankroll: Int = 100
    @State private var betAmount: Int = 10
    @State private var selectedBet: BetTarget = .player
    
    @State private var playerCards: [Int] = []
    @State private var bankerCards: [Int] = []
    @State private var roundResult: String = "Bahsinizi seçip DAĞIT'a dokunun"
    @State private var isPlaying: Bool = false
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    enum BetTarget: String, CaseIterable, Identifiable {
        case player = "Oyuncu"
        case tie = "Berabere"
        case banker = "Kasa"
        
        var id: String { rawValue }
        var multiplier: Double {
            switch self {
            case .player: return 2.0
            case .banker: return 1.95
            case .tie: return 8.0
            }
        }
    }
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                // Bankroll & Bet
                HStack {
                    Text("Bakiye: $\(bankroll)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                    Spacer()
                    Text("Bahis: $\(betAmount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 4)
                
                // Cards Table (Player vs Banker)
                HStack(spacing: 8) {
                    VStack {
                        Text("OYUNCU (\(baccaratTotal(playerCards)))")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.cyan)
                        cardsView(playerCards)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("KASA (\(baccaratTotal(bankerCards)))")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.orange)
                        cardsView(bankerCards)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(4)
                .background(Color.white.opacity(0.06))
                .cornerRadius(8)
                
                // Result text
                Text(roundResult)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(height: 22)
                
                // Bet Target Segmented Picker
                Picker("Bahis", selection: $selectedBet) {
                    ForEach(BetTarget.allCases) { b in
                        Text(b.rawValue).tag(b)
                    }
                }
                .pickerStyle(.segmented)
                .frame(height: 24)
                .disabled(isPlaying)
                
                // Deal button
                Button(action: dealBaccarat) {
                    Text(bankroll < betAmount ? "YENİDEN DOLDUR" : "KART DAĞIT ($\(betAmount))")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(Color.cyan)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Baccarat Mini")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func cardsView(_ cards: [Int]) -> some View {
        HStack(spacing: 2) {
            if cards.isEmpty {
                Text("🂠 🂠")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            } else {
                ForEach(0..<cards.count, id: \.self) { idx in
                    Text("\(cards[idx])")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .frame(width: 18, height: 26)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(3)
                }
            }
        }
    }
    
    private func baccaratTotal(_ cards: [Int]) -> Int {
        let sum = cards.reduce(0) { total, val in
            let point = val >= 10 ? 0 : val
            return total + point
        }
        return sum % 10
    }
    
    private func dealBaccarat() {
        if bankroll < betAmount {
            bankroll = 100
            roundResult = "Kasa yenilendi! ($100)"
            return
        }
        
        bankroll -= betAmount
        haptic.play(.click)
        
        // Deal 2 cards each (1-13)
        var pCards = [Int.random(in: 1...13), Int.random(in: 1...13)]
        var bCards = [Int.random(in: 1...13), Int.random(in: 1...13)]
        
        var pTotal = baccaratTotal(pCards)
        var bTotal = baccaratTotal(bCards)
        
        // Natural check (8 or 9)
        if pTotal < 8 && bTotal < 8 {
            // Player draws on 0-5
            if pTotal <= 5 {
                pCards.append(Int.random(in: 1...13))
                pTotal = baccaratTotal(pCards)
            }
            // Banker draws if <= 5
            if bTotal <= 5 {
                bCards.append(Int.random(in: 1...13))
                bTotal = baccaratTotal(bCards)
            }
        }
        
        playerCards = pCards
        bankerCards = bCards
        
        if pTotal > bTotal {
            if selectedBet == .player {
                let win = Int(Double(betAmount) * selectedBet.multiplier)
                bankroll += win
                roundResult = "Oyuncu kazandı! +$\(win) 🏆"
                haptic.play(.victory)
            } else {
                roundResult = "Oyuncu kazandı! Kaybettiniz."
                haptic.play(.warning)
            }
        } else if bTotal > pTotal {
            if selectedBet == .banker {
                let win = Int(Double(betAmount) * selectedBet.multiplier)
                bankroll += win
                roundResult = "Kasa kazandı! +$\(win) 🏆"
                haptic.play(.victory)
            } else {
                roundResult = "Kasa kazandı! Kaybettiniz."
                haptic.play(.warning)
            }
        } else {
            if selectedBet == .tie {
                let win = Int(Double(betAmount) * selectedBet.multiplier)
                bankroll += win
                roundResult = "Berabere! +$\(win) 💎"
                haptic.play(.victory)
            } else {
                bankroll += betAmount // Push on tie
                roundResult = "Berabere! Bahis iade edildi."
            }
        }
        
        _ = scoreManager.recordScore(bankroll, for: "baccarat")
    }
}
