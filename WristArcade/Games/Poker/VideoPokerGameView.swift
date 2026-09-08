import SwiftUI

struct PokerCard: Identifiable, Equatable {
    let id = UUID()
    let suit: String // ♠, ♥, ♦, ♣
    let value: Int   // 2 to 14 (11=J, 12=Q, 13=K, 14=A)
    var isHeld: Bool = false
    
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

public struct VideoPokerGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var deck: [PokerCard] = []
    @State private var hand: [PokerCard] = []
    @State private var isDrawingPhase: Bool = false
    @State private var handResult: String = ""
    @State private var score: Int = 0
    @State private var roundWon: Bool = false
    @State private var showingInfo: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "videopoker" })!
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                // Header
                HStack {
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        showingInfo = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.yellow)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(i18n.isTurkish ? "VİDEO POKER" : "VIDEO POKER")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.yellow)
                    
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
                
                // Score & Result Bar
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(i18n.t("score").uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(score)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if !handResult.isEmpty {
                        Text(handResult)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(roundWon ? .yellow : .gray)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(roundWon ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(i18n.t("high_score").uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(scoreManager.getHighScore(for: "videopoker"))")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 6)
                
                // 5 Cards Display
                HStack(spacing: 3) {
                    ForEach(0..<hand.count, id: \.self) { idx in
                        let card = hand[idx]
                        Button(action: {
                            if !isDrawingPhase {
                                hand[idx].isHeld.toggle()
                                HapticManager.shared.play(.tap)
                            }
                        }) {
                            VStack(spacing: 1) {
                                // Hold indicator
                                Text(card.isHeld ? (i18n.isTurkish ? "TUT" : "HELD") : " ")
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundColor(card.isHeld ? .black : .clear)
                                    .frame(maxWidth: .infinity)
                                    .background(card.isHeld ? Color.yellow : Color.clear)
                                    .cornerRadius(2)
                                
                                Text(card.displayValue)
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundColor(card.isRed ? .red : .white)
                                
                                Text(card.suit)
                                    .font(.system(size: 12))
                                    .foregroundColor(card.isRed ? .red : .white)
                            }
                            .frame(width: 29, height: 48)
                            .background(card.isHeld ? Color.yellow.opacity(0.15) : Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(card.isHeld ? Color.yellow : Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(isDrawingPhase)
                    }
                }
                .padding(.vertical, 4)
                
                // Action Button (DEAL / DRAW)
                Button(action: {
                    if isDrawingPhase {
                        dealHand()
                    } else {
                        drawCards()
                    }
                }) {
                    Text(isDrawingPhase ? (i18n.isTurkish ? "YENİ EL (DEAL)" : "NEW DEAL") : (i18n.isTurkish ? "KART DEĞİŞTİR (DRAW)" : "DRAW CARDS"))
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 26)
                        .background(isDrawingPhase ? Color.cyan : Color.yellow)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 6)
                
                // Paytable summary
                Text(i18n.isTurkish ? "Vale Çifti veya Üstü Puan Kazandırır" : "Jacks or Better pays out")
                    .font(.system(size: 7))
                    .foregroundColor(.gray)
                    .padding(.top, 1)
            }
            .padding(.bottom, 6)
        }
        .onAppear {
            dealHand()
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoSheet(game: gameInfo)
        }
    }
    
    private func resetDeck() {
        let suits = ["♠", "♥", "♦", "♣"]
        var newDeck: [PokerCard] = []
        for s in suits {
            for v in 2...14 {
                newDeck.append(PokerCard(suit: s, value: v))
            }
        }
        deck = newDeck.shuffled()
    }
    
    private func dealHand() {
        resetDeck()
        hand = Array(deck.prefix(5))
        deck.removeFirst(5)
        isDrawingPhase = false
        handResult = ""
        roundWon = false
        HapticManager.shared.play(.tap)
    }
    
    private func drawCards() {
        for i in 0..<hand.count {
            if !hand[i].isHeld && !deck.isEmpty {
                hand[i] = deck.removeFirst()
            }
        }
        isDrawingPhase = true
        evaluateHand()
    }
    
    private func evaluateHand() {
        let values = hand.map { $0.value }.sorted()
        let suits = hand.map { $0.suit }
        
        let isFlush = Set(suits).count == 1
        
        var isStraight = false
        if Set(values).count == 5 {
            if values[4] - values[0] == 4 {
                isStraight = true
            } else if values == [2, 3, 4, 5, 14] { // Ace-low straight
                isStraight = true
            }
        }
        
        var counts: [Int: Int] = [:]
        for v in values {
            counts[v, default: 0] += 1
        }
        let freq = counts.values.sorted(by: >)
        
        var payout = 0
        var name = ""
        
        if isFlush && isStraight && values.contains(14) && values.contains(13) {
            name = "ROYAL FLUSH!"
            payout = 800
        } else if isFlush && isStraight {
            name = "STRAIGHT FLUSH!"
            payout = 250
        } else if freq == [4, 1] {
            name = "4 OF A KIND!"
            payout = 100
        } else if freq == [3, 2] {
            name = "FULL HOUSE"
            payout = 40
        } else if isFlush {
            name = "FLUSH"
            payout = 30
        } else if isStraight {
            name = "STRAIGHT"
            payout = 20
        } else if freq == [3, 1, 1] {
            name = "3 OF A KIND"
            payout = 15
        } else if freq == [2, 2, 1] {
            name = "TWO PAIR"
            payout = 10
        } else if freq == [2, 1, 1, 1] {
            let pairVal = counts.first(where: { $0.value == 2 })?.key ?? 0
            if pairVal >= 11 { // Jacks or better
                name = i18n.isTurkish ? "VALE ÇİFTİ+" : "JACKS OR BETTER"
                payout = 5
            } else {
                name = i18n.isTurkish ? "DÜŞÜK ÇİFT" : "LOW PAIR"
                payout = 0
            }
        } else {
            name = i18n.isTurkish ? "YÜKSEK KART" : "HIGH CARD"
            payout = 0
        }
        
        handResult = name
        if payout > 0 {
            score += payout
            roundWon = true
            _ = scoreManager.recordScore(score, for: "videopoker")
            HapticManager.shared.play(.victory)
        } else {
            roundWon = false
            HapticManager.shared.play(.failure)
        }
    }
}
