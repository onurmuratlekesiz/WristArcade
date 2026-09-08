import SwiftUI

public struct BlackjackGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    struct Card: Identifiable {
        let id = UUID()
        let rank: String
        let suit: String
        let value: Int
        
        var isRed: Bool {
            return suit == "♥" || suit == "♦"
        }
    }
    
    @State private var deck: [Card] = []
    @State private var playerHand: [Card] = []
    @State private var dealerHand: [Card] = []
    
    @State private var isPlaying: Bool = false
    @State private var isPlayerTurn: Bool = true
    @State private var outcomeText: String = ""
    @State private var outcomeColor: Color = .white
    @State private var winStreak: Int = 0
    @State private var showRoundResult: Bool = false
    
    // Credit & Betting System
    @State private var credits: Int = 100
    @State private var betAmount: Int = 10
    @State private var activeBet: Int = 10
    @State private var isDoubleActive: Bool = false
    
    private var canDoubleDown: Bool {
        return isPlayerTurn && playerHand.count == 2 && credits >= activeBet && !isDoubleActive
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 3) {
                        // Header HUD: Chips, Bet, and High Score
                        HStack {
                            HStack(spacing: 2) {
                                Text("🪙")
                                    .font(.system(size: 9))
                                Text("\(credits)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.yellow)
                            }
                            Spacer()
                            HStack(spacing: 2) {
                                Text("BET:")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("\(activeBet)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(isDoubleActive ? .orange : .teal)
                            }
                            Spacer()
                            HStack(spacing: 2) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.yellow)
                                Text("\(scoreManager.getHighScore(for: "blackjack"))")
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 6)
                        
                        // Dealer Area
                        VStack(spacing: 1) {
                            HStack {
                                Text("DEALER")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(isPlayerTurn ? "?" : "\(handTotal(dealerHand))")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            
                            HStack(spacing: 3) {
                                ForEach(Array(dealerHand.enumerated()), id: \.element.id) { index, card in
                                    if index == 1 && isPlayerTurn {
                                        cardBackView()
                                    } else {
                                        cardFrontView(card: card)
                                    }
                                }
                            }
                        }
                        
                        // Center Pot & Double Indicator
                        HStack {
                            Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
                            if isDoubleActive {
                                Text("2X DOUBLE")
                                    .font(.system(size: 7, weight: .heavy))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.orange.opacity(0.3))
                                    .foregroundColor(.orange)
                                    .clipShape(Capsule())
                            } else {
                                Text("POT: \(activeBet * 2) 🪙")
                                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                            Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
                        }
                        .padding(.vertical, 1)
                        
                        // Player Area
                        VStack(spacing: 1) {
                            HStack {
                                Text("YOUR HAND")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(handTotal(playerHand))")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.teal)
                            }
                            .padding(.horizontal, 8)
                            
                            HStack(spacing: 3) {
                                ForEach(playerHand) { card in
                                    cardFrontView(card: card)
                                }
                            }
                        }
                        
                        // Actions or Round Outcome
                        if showRoundResult {
                            VStack(spacing: 3) {
                                Text(outcomeText)
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundColor(outcomeColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                if credits <= 0 {
                                    Button(action: reloadChips) {
                                        Text("RELOAD 100 🪙")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 3)
                                            .background(Color.yellow)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Button(action: dealNewHand) {
                                        Text("NEXT (BET \(min(betAmount, credits)) 🪙)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 3)
                                            .background(Color.teal)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 1)
                        } else if isPlayerTurn {
                            HStack(spacing: 4) {
                                Button(action: hit) {
                                    Text("HIT")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 24)
                                        .background(Color.teal)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: stand) {
                                    Text("STAND")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 24)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                
                                if canDoubleDown {
                                    Button(action: doubleDown) {
                                        Text("2X DBL")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 24)
                                            .background(Color.orange)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 6)
                            .padding(.top, 2)
                        }
                    }
                } else {
                    // Start Screen with Starting Credits & Rules
                    VStack(spacing: 5) {
                        Image(systemName: "suit.club.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.teal)
                        
                        Text("CLASSIC 21")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 3) {
                            Text("Starting Bank:")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                            Text("100 🪙")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                        }
                        
                        Text("2X Double Down • Dealer 17+ • 3:2 BJ")
                            .font(.system(size: 8))
                            .foregroundColor(.gray.opacity(0.8))
                        
                        Button(action: startNewGame) {
                            Text("DEAL (10 🪙)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 90, height: 26)
                                .background(Color.teal)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 2)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func cardFrontView(card: Card) -> some View {
        VStack(spacing: 1) {
            Text(card.rank)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(card.isRed ? .red : .black)
            Text(card.suit)
                .font(.system(size: 10))
                .foregroundColor(card.isRed ? .red : .black)
        }
        .frame(width: 26, height: 35)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func cardBackView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.teal.opacity(0.8))
                .frame(width: 26, height: 35)
            Image(systemName: "lock.fill")
                .font(.system(size: 9))
                .foregroundColor(.black)
        }
    }
    
    private func startNewGame() {
        winStreak = 0
        credits = 100
        betAmount = 10
        isPlaying = true
        dealNewHand()
    }
    
    private func reloadChips() {
        credits = 100
        betAmount = 10
        dealNewHand()
    }
    
    private func dealNewHand() {
        if credits <= 0 {
            credits = 100
            betAmount = 10
        }
        
        let bet = min(betAmount, credits)
        credits -= bet
        activeBet = bet
        isDoubleActive = false
        
        buildDeck()
        SoundManager.shared.play(.cardDeal)
        HapticManager.shared.play(.tap)
        
        playerHand = [drawCard(), drawCard()]
        dealerHand = [drawCard(), drawCard()]
        isPlayerTurn = true
        showRoundResult = false
        outcomeText = ""
        
        // Instant natural 21 check
        if handTotal(playerHand) == 21 {
            evaluateNatural21()
        }
    }
    
    private func buildDeck() {
        let ranks = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]
        let suits = ["♠", "♥", "♦", "♣"]
        var newDeck: [Card] = []
        for s in suits {
            for r in ranks {
                let v: Int
                if r == "A" { v = 11 }
                else if ["J","Q","K"].contains(r) { v = 10 }
                else { v = Int(r) ?? 10 }
                newDeck.append(Card(rank: r, suit: s, value: v))
            }
        }
        deck = newDeck.shuffled()
    }
    
    private func drawCard() -> Card {
        if deck.isEmpty { buildDeck() }
        return deck.removeFirst()
    }
    
    private func handTotal(_ hand: [Card]) -> Int {
        var total = hand.reduce(0) { $0 + $1.value }
        var aces = hand.filter { $0.rank == "A" }.count
        while total > 21 && aces > 0 {
            total -= 10
            aces -= 1
        }
        return total
    }
    
    private func hit() {
        playerHand.append(drawCard())
        SoundManager.shared.play(.cardDeal)
        HapticManager.shared.play(.tap)
        
        let total = handTotal(playerHand)
        if total > 21 {
            // Bust
            isPlayerTurn = false
            showRoundResult = true
            outcomeText = "BUST! -\(activeBet) 🪙"
            outcomeColor = .red
            winStreak = 0
            SoundManager.shared.play(.gameOver)
            HapticManager.shared.play(.gameOver)
        } else if total == 21 {
            stand()
        }
    }
    
    private func doubleDown() {
        guard canDoubleDown else { return }
        credits -= activeBet
        activeBet *= 2
        isDoubleActive = true
        
        // Double down deals exactly one card and then stands
        playerHand.append(drawCard())
        SoundManager.shared.play(.cardDeal)
        HapticManager.shared.play(.tap)
        
        let total = handTotal(playerHand)
        if total > 21 {
            isPlayerTurn = false
            showRoundResult = true
            outcomeText = "BUST! -\(activeBet) 🪙"
            outcomeColor = .red
            winStreak = 0
            SoundManager.shared.play(.gameOver)
            HapticManager.shared.play(.gameOver)
        } else {
            stand()
        }
    }
    
    private func stand() {
        isPlayerTurn = false
        
        // Dealer logic: draw until 17+
        while handTotal(dealerHand) < 17 {
            dealerHand.append(drawCard())
            SoundManager.shared.play(.cardDeal)
        }
        
        evaluateWinner()
    }
    
    private func evaluateNatural21() {
        isPlayerTurn = false
        showRoundResult = true
        let d = handTotal(dealerHand)
        if d == 21 {
            // Push
            credits += activeBet
            outcomeText = "PUSH! (BOTH 21)"
            outcomeColor = .yellow
            HapticManager.shared.play(.bounce)
        } else {
            // Blackjack pays 3:2
            let winAmount = Int(Double(activeBet) * 2.5)
            credits += winAmount
            outcomeText = "BLACKJACK! +\(winAmount) 🪙"
            outcomeColor = .green
            winStreak += 1
            _ = scoreManager.recordScore(credits, for: "blackjack")
            SoundManager.shared.play(.victory)
            HapticManager.shared.play(.victory)
        }
    }
    
    private func evaluateWinner() {
        let p = handTotal(playerHand)
        let d = handTotal(dealerHand)
        
        showRoundResult = true
        if d > 21 {
            let winAmount = activeBet * 2
            credits += winAmount
            outcomeText = "DEALER BUST! +\(winAmount) 🪙"
            outcomeColor = .green
            winStreak += 1
            _ = scoreManager.recordScore(credits, for: "blackjack")
            SoundManager.shared.play(.victory)
            HapticManager.shared.play(.victory)
        } else if p > d {
            let winAmount = activeBet * 2
            credits += winAmount
            outcomeText = "YOU WIN! +\(winAmount) 🪙"
            outcomeColor = .green
            winStreak += 1
            _ = scoreManager.recordScore(credits, for: "blackjack")
            SoundManager.shared.play(.victory)
            HapticManager.shared.play(.victory)
        } else if p < d {
            outcomeText = "DEALER WINS -\(activeBet) 🪙"
            outcomeColor = .red
            winStreak = 0
            SoundManager.shared.play(.gameOver)
            HapticManager.shared.play(.gameOver)
        } else {
            credits += activeBet
            outcomeText = "PUSH! 🪙 RETURNED"
            outcomeColor = .yellow
            HapticManager.shared.play(.bounce)
        }
    }
}
