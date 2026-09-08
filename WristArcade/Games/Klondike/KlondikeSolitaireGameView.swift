import SwiftUI

public struct KlondikeSolitaireGameView: View {
    struct SolitaireCard: Identifiable, Equatable {
        let id = UUID()
        let suit: String // ♠, ♥, ♦, ♣
        let rank: Int // 1 (A) ... 13 (K)
        var isFaceUp: Bool = false
        
        var isRed: Bool { suit == "♥" || suit == "♦" }
        
        var rankString: String {
            switch rank {
            case 1: return "A"
            case 11: return "J"
            case 12: return "Q"
            case 13: return "K"
            default: return "\(rank)"
            }
        }
    }
    
    @State private var stock: [SolitaireCard] = []
    @State private var waste: [SolitaireCard] = []
    @State private var foundations: [[SolitaireCard]] = [[], [], [], []] // 4 suits
    @State private var columns: [[SolitaireCard]] = [[], [], [], [], [], [], []] // 7 columns
    
    @State private var moves: Int = 0
    @State private var score: Int = 0
    @State private var isWon: Bool = false
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                // Header (Score & Moves)
                HStack {
                    Text("Puan: \(score)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                    Spacer()
                    Text("Hamle: \(moves)")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 6)
                
                // Top Row: Stock + Waste + Foundations (4)
                HStack(spacing: 3) {
                    // Stock & Waste
                    HStack(spacing: 2) {
                        Button(action: drawFromStock) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(stock.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                                    .frame(width: 20, height: 28)
                                Text(stock.isEmpty ? "↺" : "🂠")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        if let topWaste = waste.last {
                            Button(action: { moveWasteToBestTarget() }) {
                                miniCardBadge(topWaste)
                            }
                            .buttonStyle(.plain)
                        } else {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                .frame(width: 20, height: 28)
                        }
                    }
                    
                    Spacer()
                    
                    // 4 Foundation Slots
                    HStack(spacing: 2) {
                        ForEach(0..<4, id: \.self) { fIdx in
                            let fCards = foundations[fIdx]
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                                    .frame(width: 20, height: 28)
                                if let topF = fCards.last {
                                    miniCardBadge(topF)
                                } else {
                                    Text(["♠", "♥", "♦", "♣"][fIdx])
                                        .font(.system(size: 9))
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
                
                Divider().background(Color.gray.opacity(0.3))
                
                // 7 Tableau Columns
                HStack(alignment: .top, spacing: 2) {
                    ForEach(0..<7, id: \.self) { cIdx in
                        let colCards = columns[cIdx]
                        VStack(spacing: -14) {
                            if colCards.isEmpty {
                                Button(action: { moveKingToEmptyColumn(cIdx) }) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        .frame(width: 20, height: 28)
                                        .overlay(Text("K").font(.system(size: 8)).foregroundColor(.gray.opacity(0.4)))
                                }
                                .buttonStyle(.plain)
                            } else {
                                ForEach(Array(colCards.enumerated()), id: \.element.id) { cardIdx, card in
                                    if card.isFaceUp {
                                        Button(action: {
                                            if cardIdx == colCards.count - 1 {
                                                moveTableauCardToBestTarget(colIdx: cIdx)
                                            }
                                        }) {
                                            miniCardBadge(card)
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.blue.opacity(0.8))
                                            .frame(width: 20, height: 26)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.top, 2)
                
                if isWon {
                    VStack(spacing: 2) {
                        Text("🎉 TEBRİKLER! KAZANDIN!")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.yellow)
                        Button("TEKRAR OYNA") {
                            initGame()
                        }
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                }
            }
        }
        .navigationTitle("Klondike Solitaire")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            initGame()
        }
    }
    
    @ViewBuilder
    private func miniCardBadge(_ card: SolitaireCard) -> some View {
        VStack(spacing: 0) {
            Text(card.rankString)
                .font(.system(size: 8, weight: .black, design: .rounded))
            Text(card.suit)
                .font(.system(size: 7))
        }
        .frame(width: 20, height: 28)
        .background(Color.white)
        .foregroundColor(card.isRed ? .red : .black)
        .cornerRadius(3)
        .shadow(color: .black.opacity(0.4), radius: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
        )
    }
    
    private func initGame() {
        var newDeck: [SolitaireCard] = []
        let suits = ["♠", "♥", "♦", "♣"]
        for s in suits {
            for r in 1...13 {
                newDeck.append(SolitaireCard(suit: s, rank: r))
            }
        }
        newDeck.shuffle()
        
        var newCols: [[SolitaireCard]] = Array(repeating: [], count: 7)
        for i in 0..<7 {
            for j in 0...i {
                var c = newDeck.removeFirst()
                if j == i { c.isFaceUp = true }
                newCols[i].append(c)
            }
        }
        
        columns = newCols
        stock = newDeck
        waste = []
        foundations = [[], [], [], []]
        moves = 0
        score = 0
        isWon = false
        haptic.play(.click)
    }
    
    private func drawFromStock() {
        haptic.play(.click)
        moves += 1
        if stock.isEmpty {
            stock = waste.reversed().map {
                var c = $0
                c.isFaceUp = false
                return c
            }
            waste.removeAll()
        } else {
            var c = stock.removeLast()
            c.isFaceUp = true
            waste.append(c)
        }
    }
    
    private func moveWasteToBestTarget() {
        guard let card = waste.last else { return }
        
        // 1. Try Foundation
        for fIdx in 0..<4 {
            let f = foundations[fIdx]
            if f.isEmpty && card.rank == 1 {
                foundations[fIdx].append(waste.removeLast())
                score += 15
                moves += 1
                haptic.play(.victory)
                checkWinCondition()
                return
            } else if let topF = f.last, topF.suit == card.suit, topF.rank == card.rank - 1 {
                foundations[fIdx].append(waste.removeLast())
                score += 15
                moves += 1
                haptic.play(.click)
                checkWinCondition()
                return
            }
        }
        
        // 2. Try Tableau
        for cIdx in 0..<7 {
            if let topC = columns[cIdx].last, topC.isFaceUp {
                if topC.isRed != card.isRed && topC.rank == card.rank + 1 {
                    columns[cIdx].append(waste.removeLast())
                    score += 5
                    moves += 1
                    haptic.play(.click)
                    return
                }
            }
        }
        
        haptic.play(.warning)
    }
    
    private func moveTableauCardToBestTarget(colIdx: Int) {
        guard let card = columns[colIdx].last, card.isFaceUp else { return }
        
        // Try Foundation
        for fIdx in 0..<4 {
            let f = foundations[fIdx]
            if f.isEmpty && card.rank == 1 {
                foundations[fIdx].append(columns[colIdx].removeLast())
                revealTopIfNeeded(colIdx: colIdx)
                score += 15
                moves += 1
                haptic.play(.victory)
                checkWinCondition()
                return
            } else if let topF = f.last, topF.suit == card.suit, topF.rank == card.rank - 1 {
                foundations[fIdx].append(columns[colIdx].removeLast())
                revealTopIfNeeded(colIdx: colIdx)
                score += 15
                moves += 1
                haptic.play(.click)
                checkWinCondition()
                return
            }
        }
        
        // Try other Tableau columns
        for destIdx in 0..<7 where destIdx != colIdx {
            if let topDest = columns[destIdx].last, topDest.isFaceUp {
                if topDest.isRed != card.isRed && topDest.rank == card.rank + 1 {
                    columns[destIdx].append(columns[colIdx].removeLast())
                    revealTopIfNeeded(colIdx: colIdx)
                    score += 5
                    moves += 1
                    haptic.play(.click)
                    return
                }
            }
        }
        
        haptic.play(.warning)
    }
    
    private func moveKingToEmptyColumn(_ colIdx: Int) {
        guard columns[colIdx].isEmpty else { return }
        
        // Check waste
        if let topWaste = waste.last, topWaste.rank == 13 {
            columns[colIdx].append(waste.removeLast())
            score += 5
            moves += 1
            haptic.play(.click)
            return
        }
        
        // Check tableau bottoms
        for c in 0..<7 where c != colIdx {
            if let top = columns[c].last, top.rank == 13, columns[c].count > 1 {
                columns[colIdx].append(columns[c].removeLast())
                revealTopIfNeeded(colIdx: c)
                score += 5
                moves += 1
                haptic.play(.click)
                return
            }
        }
    }
    
    private func revealTopIfNeeded(colIdx: Int) {
        if !columns[colIdx].isEmpty && !columns[colIdx].last!.isFaceUp {
            columns[colIdx][columns[colIdx].count - 1].isFaceUp = true
            score += 10
        }
    }
    
    private func checkWinCondition() {
        let totalInFoundations = foundations.reduce(0) { $0 + $1.count }
        if totalInFoundations == 52 {
            isWon = true
            score += 200
            haptic.play(.victory)
            _ = scoreManager.recordScore(score, for: "klondikesolitaire")
        }
    }
}
