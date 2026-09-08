import SwiftUI

struct WarCard: Equatable {
    let suit: String
    let value: Int
    
    var displayValue: String {
        switch value {
        case 14: return "A"
        case 13: return "K"
        case 12: return "Q"
        case 11: return "J"
        case 10: return "10"
        default: return "\(value)"
        }
    }
    
    var isRed: Bool {
        suit == "♥" || suit == "♦"
    }
}

public struct CardWarGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var playerCard: WarCard? = nil
    @State private var dealerCard: WarCard? = nil
    @State private var resultMessage: String = ""
    @State private var score: Int = 0
    @State private var winStreak: Int = 0
    @State private var isWarRound: Bool = false
    @State private var showingInfo: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "cardwar" })!
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                // Header
                HStack {
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        showingInfo = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(i18n.isTurkish ? "KART SAVAŞI" : "CARD WAR")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)
                
                // Score & Win Streak Bar
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(i18n.isTurkish ? "SERİ" : "STREAK")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        HStack(spacing: 2) {
                            Text("\(winStreak)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            if winStreak > 1 {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if !resultMessage.isEmpty {
                        Text(resultMessage)
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(isWarRound ? .yellow : .white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isWarRound ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(i18n.t("high_score").uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(scoreManager.getHighScore(for: "cardwar"))")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 6)
                
                // Arena: Dealer vs Player Cards
                HStack(spacing: 12) {
                    // Dealer Card
                    VStack(spacing: 2) {
                        Text(i18n.isTurkish ? "KRUPİYE" : "DEALER")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.gray)
                        
                        cardView(dealerCard)
                    }
                    
                    Text("VS")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.gray)
                    
                    // Player Card
                    VStack(spacing: 2) {
                        Text(i18n.isTurkish ? "SEN" : "YOU")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.orange)
                        
                        cardView(playerCard)
                    }
                }
                .padding(.vertical, 2)
                
                // Action Button
                Button(action: {
                    playBattle()
                }) {
                    Text(isWarRound ? (i18n.isTurkish ? "⚔️ SAVAŞ! (WAR)" : "⚔️ WAR STRIKE!") : (i18n.isTurkish ? "KART ÇEK (BATTLE)" : "DRAW CARD"))
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 26)
                        .background(isWarRound ? Color.yellow : Color.orange)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .padding(.top, 2)
            }
            .padding(.bottom, 6)
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoSheet(game: gameInfo)
        }
    }
    
    @ViewBuilder
    private func cardView(_ card: WarCard?) -> some View {
        if let card = card {
            VStack(spacing: 1) {
                Text(card.displayValue)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(card.isRed ? .red : .white)
                Text(card.suit)
                    .font(.system(size: 14))
                    .foregroundColor(card.isRed ? .red : .white)
            }
            .frame(width: 44, height: 56)
            .background(Color.white.opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .cornerRadius(6)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    .background(Color.white.opacity(0.04))
                Image(systemName: "suit.spade.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.2))
            }
            .frame(width: 44, height: 56)
            .cornerRadius(6)
        }
    }
    
    private func randomCard() -> WarCard {
        let suits = ["♠", "♥", "♦", "♣"]
        let suit = suits.randomElement()!
        let value = Int.random(in: 2...14)
        return WarCard(suit: suit, value: value)
    }
    
    private func playBattle() {
        let p = randomCard()
        let d = randomCard()
        playerCard = p
        dealerCard = d
        
        if p.value > d.value {
            // Player won
            let gain = isWarRound ? 30 : 10
            score += gain
            winStreak += 1
            isWarRound = false
            resultMessage = i18n.isTurkish ? "KAZANDIN! (+\(gain))" : "YOU WIN! (+\(gain))"
            _ = scoreManager.recordScore(score, for: "cardwar")
            HapticManager.shared.play(.victory)
        } else if d.value > p.value {
            // Dealer won
            winStreak = 0
            isWarRound = false
            resultMessage = i18n.isTurkish ? "KAYBETTİN" : "DEALER WON"
            HapticManager.shared.play(.failure)
        } else {
            // Tie -> WAR!
            isWarRound = true
            resultMessage = i18n.isTurkish ? "⚔️ SAVAŞ! (BERABERE)" : "⚔️ TIE! WAR BEGINS"
            HapticManager.shared.play(.warning)
        }
    }
}
