import SwiftUI

public struct PistiGameView: View {
    struct PlayingCard: Identifiable, Equatable {
        let id = UUID()
        let suit: String // ♠, ♥, ♦, ♣
        let rank: Int // 1 (A), 2-10, 11 (J), 12 (Q), 13 (K)
        
        var rankString: String {
            switch rank {
            case 1: return "A"
            case 11: return "J"
            case 12: return "Q"
            case 13: return "K"
            default: return "\(rank)"
            }
        }
        
        var isRed: Bool {
            suit == "♥" || suit == "♦"
        }
    }
    
    @State private var deck: [PlayingCard] = []
    @State private var playerHand: [PlayingCard] = []
    @State private var aiHand: [PlayingCard] = []
    @State private var tablePile: [PlayingCard] = []
    
    @State private var playerScore: Int = 0
    @State private var aiScore: Int = 0
    @State private var playerPistiCount: Int = 0
    @State private var aiPistiCount: Int = 0
    
    @State private var roundMessage: String = "Kartını seç ve ortaya at!"
    @State private var isGameOver: Bool = false
    @State private var isPlayerTurn: Bool = true
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                // Score Board Header
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("SEN: \(playerScore)p")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.cyan)
                        if playerPistiCount > 0 {
                            Text("🔥 \(playerPistiCount) Pişti")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("BOT: \(aiScore)p")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.red)
                        if aiPistiCount > 0 {
                            Text("🔥 \(aiPistiCount) Pişti")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal, 6)
                
                // Status message
                Text(roundMessage)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 22)
                
                // Table Pile (Center)
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.2))
                        .frame(height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green.opacity(0.4), lineWidth: 1)
                        )
                    
                    if tablePile.isEmpty {
                        Text("Yer Boş")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    } else {
                        HStack(spacing: -12) {
                            ForEach(Array(tablePile.suffix(4).enumerated()), id: \.element.id) { index, card in
                                cardBadge(card)
                                    .rotationEffect(.degrees(Double(index * 4 - 6)))
                            }
                        }
                    }
                }
                .padding(.horizontal, 6)
                
                // Player Hand
                VStack(spacing: 2) {
                    Text("Senin Kartların (\(playerHand.count))")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        ForEach(playerHand) { card in
                            Button(action: {
                                playPlayerCard(card)
                            }) {
                                cardBadge(card, isInteractive: true)
                            }
                            .buttonStyle(.plain)
                            .disabled(!isPlayerTurn || isGameOver)
                        }
                    }
                }
                .padding(.top, 2)
                
                if isGameOver {
                    Button("YENİDEN OYNA") {
                        startNewGame()
                    }
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.yellow)
                    .clipShape(Capsule())
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 2)
        }
        .navigationTitle("Pişti")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startNewGame()
        }
    }
    
    @ViewBuilder
    private func cardBadge(_ card: PlayingCard, isInteractive: Bool = false) -> some View {
        VStack(spacing: 1) {
            Text(card.rankString)
                .font(.system(size: 11, weight: .black, design: .rounded))
            Text(card.suit)
                .font(.system(size: 10))
        }
        .frame(width: 26, height: 38)
        .background(Color.white)
        .foregroundColor(card.isRed ? .red : .black)
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.3), radius: isInteractive ? 2 : 1, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isInteractive ? Color.cyan : Color.gray.opacity(0.4), lineWidth: isInteractive ? 1.5 : 0.5)
        )
    }
    
    private func startNewGame() {
        var newDeck: [PlayingCard] = []
        let suits = ["♠", "♥", "♦", "♣"]
        for s in suits {
            for r in 1...13 {
                newDeck.append(PlayingCard(suit: s, rank: r))
            }
        }
        newDeck.shuffle()
        
        // Initial 4 table cards
        tablePile = Array(newDeck.prefix(4))
        newDeck.removeFirst(4)
        
        deck = newDeck
        playerScore = 0
        aiScore = 0
        playerPistiCount = 0
        aiPistiCount = 0
        isGameOver = false
        isPlayerTurn = true
        roundMessage = "Kartını seç ve masaya at!"
        
        dealHands()
        haptic.play(.click)
    }
    
    private func dealHands() {
        guard deck.count >= 8 else {
            endGame()
            return
        }
        
        playerHand = Array(deck.prefix(4))
        deck.removeFirst(4)
        aiHand = Array(deck.prefix(4))
        deck.removeFirst(4)
    }
    
    private func playPlayerCard(_ card: PlayingCard) {
        guard isPlayerTurn, let idx = playerHand.firstIndex(of: card) else { return }
        playerHand.remove(at: idx)
        haptic.play(.click)
        
        let captured = evaluatePlay(card: card, isPlayer: true)
        
        if playerHand.isEmpty && aiHand.isEmpty {
            if !deck.isEmpty {
                dealHands()
            } else {
                endGame()
                return
            }
        }
        
        isPlayerTurn = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            playAITurn()
        }
    }
    
    private func playAITurn() {
        guard !aiHand.isEmpty else { return }
        
        // AI Logic:
        // 1. If can match top card, play it!
        // 2. If no match and table has >= 3 cards and has Jack, play Jack!
        // 3. Otherwise play lowest/safest card (avoid throwing Jack on empty or matchable)
        var cardToPlay = aiHand[0]
        if let top = tablePile.last {
            if let matching = aiHand.first(where: { $0.rank == top.rank }) {
                cardToPlay = matching
            } else if tablePile.count >= 3, let jack = aiHand.first(where: { $0.rank == 11 }) {
                cardToPlay = jack
            } else {
                // Play non-jack
                let nonJacks = aiHand.filter { $0.rank != 11 }
                if let safe = nonJacks.randomElement() {
                    cardToPlay = safe
                }
            }
        }
        
        if let idx = aiHand.firstIndex(of: cardToPlay) {
            aiHand.remove(at: idx)
        }
        
        _ = evaluatePlay(card: cardToPlay, isPlayer: false)
        
        if playerHand.isEmpty && aiHand.isEmpty {
            if !deck.isEmpty {
                dealHands()
            } else {
                endGame()
                return
            }
        }
        
        isPlayerTurn = true
    }
    
    private func evaluatePlay(card: PlayingCard, isPlayer: Bool) -> Bool {
        if let top = tablePile.last {
            // Check Match or Jack
            if card.rank == top.rank || card.rank == 11 {
                // Pisti Check: Table had exactly 1 card and matched by rank!
                if tablePile.count == 1 && card.rank == top.rank {
                    let pts = card.rank == 11 ? 20 : 10
                    if isPlayer {
                        playerScore += pts
                        playerPistiCount += 1
                        roundMessage = "💥 PİŞTİ YAPTIN! (+\(pts) Puan)"
                        haptic.play(.victory)
                    } else {
                        aiScore += pts
                        aiPistiCount += 1
                        roundMessage = "🤖 Rakip Pişti Yaptı! (+\(pts))"
                        haptic.play(.warning)
                    }
                } else {
                    // Regular capture
                    let capturedCount = tablePile.count + 1
                    let pts = capturedCount
                    if isPlayer {
                        playerScore += pts
                        roundMessage = "👏 \(capturedCount) kart topladın!"
                        haptic.play(.click)
                    } else {
                        aiScore += pts
                        roundMessage = "🤖 Rakip \(capturedCount) kart topladı."
                    }
                }
                tablePile.removeAll()
                return true
            }
        }
        
        tablePile.append(card)
        return false
    }
    
    private func endGame() {
        isGameOver = true
        if playerScore > aiScore {
            roundMessage = "🏆 KAZANDIN! (\(playerScore) - \(aiScore))"
            haptic.play(.victory)
        } else if aiScore > playerScore {
            roundMessage = "OYUN BİTTİ (\(playerScore) - \(aiScore))"
            haptic.play(.warning)
        } else {
            roundMessage = "BERABERE! (\(playerScore) - \(aiScore))"
        }
        _ = scoreManager.recordScore(playerScore, for: "pisti")
    }
}
