import SwiftUI

struct SingleDie: Identifiable {
    let id: Int
    var value: Int
    var isHeld: Bool
}

public struct LuckyDiceGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var dice: [SingleDie] = [
        SingleDie(id: 0, value: 1, isHeld: false),
        SingleDie(id: 1, value: 2, isHeld: false),
        SingleDie(id: 2, value: 3, isHeld: false)
    ]
    @State private var rollsLeft: Int = 2
    @State private var totalScore: Int = 0
    @State private var lastComboText: String = ""
    @State private var isRolling: Bool = false
    @State private var showingInfo: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "luckydice" })!
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                // Header Bar
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
                    
                    Text(i18n.isTurkish ? "ŞANSLI ZARLAR" : "LUCKY DICE")
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
                
                // Score & Rolls Bar
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(i18n.isTurkish ? "ATIŞ HAKKI" : "ROLLS")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(rollsLeft) / 2")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(i18n.isTurkish ? "TOPLAM SKOR" : "SCORE")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(totalScore)")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 8)
                
                // 3 Dice Row
                HStack(spacing: 8) {
                    ForEach(0..<3) { idx in
                        let die = dice[idx]
                        Button(action: {
                            toggleHold(index: idx)
                        }) {
                            VStack(spacing: 2) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(die.isHeld ? Color.yellow : Color.white)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: die.isHeld ? .yellow.opacity(0.6) : .black.opacity(0.3), radius: 3)
                                    
                                    diePipsView(for: die.value, isHeld: die.isHeld)
                                }
                                .scaleEffect(isRolling && !die.isHeld ? 0.88 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isRolling)
                                
                                Text(die.isHeld ? (i18n.isTurkish ? "KİLİTLİ" : "HELD") : (i18n.isTurkish ? "DOKUN" : "TAP"))
                                    .font(.system(size: 7, weight: .heavy))
                                    .foregroundColor(die.isHeld ? .yellow : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
                
                // Combo message
                if !lastComboText.isEmpty {
                    Text(lastComboText)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())
                }
                
                // Action Buttons
                Button(action: {
                    rollDice()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "die.face.5.fill")
                            .font(.system(size: 11))
                        Text(rollsLeft > 0 ? (i18n.isTurkish ? "ZAR AT" : "ROLL DICE") : (i18n.isTurkish ? "YENİ EL" : "NEW ROUND"))
                            .font(.system(size: 11, weight: .black))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 4)
            }
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoSheet(game: gameInfo)
        }
    }
    
    private func toggleHold(index: Int) {
        if rollsLeft == 2 { return } // Must roll once before holding
        dice[index].isHeld.toggle()
        HapticManager.shared.play(.tap)
    }
    
    private func rollDice() {
        if rollsLeft == 0 {
            // Reset for new round
            for i in 0..<3 {
                dice[i].isHeld = false
            }
            rollsLeft = 2
            lastComboText = ""
        }
        
        isRolling = true
        HapticManager.shared.play(.click)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            for i in 0..<3 {
                if !dice[i].isHeld {
                    dice[i].value = Int.random(in: 1...6)
                }
            }
            rollsLeft -= 1
            isRolling = false
            
            if rollsLeft == 0 {
                evaluateRound()
            }
        }
    }
    
    private func evaluateRound() {
        let vals = dice.map { $0.value }.sorted()
        var roundPoints = 0
        var combo = ""
        
        if vals[0] == vals[1] && vals[1] == vals[2] {
            // 3 of a kind!
            roundPoints = vals[0] * 10 + 100
            combo = i18n.isTurkish ? "ÜÇLÜ ZAR! +\(roundPoints)" : "TRIPLES JACKPOT! +\(roundPoints)"
            HapticManager.shared.play(.success)
        } else if (vals[0] + 1 == vals[1]) && (vals[1] + 1 == vals[2]) {
            // Straight!
            roundPoints = 60
            combo = i18n.isTurkish ? "DÜZ KENT! +60" : "STRAIGHT RUN! +60"
            HapticManager.shared.play(.success)
        } else if vals[0] == vals[1] || vals[1] == vals[2] {
            // Pair
            let pairVal = (vals[0] == vals[1]) ? vals[0] : vals[1]
            roundPoints = pairVal * 4 + 20
            combo = i18n.isTurkish ? "ÇİFT ZAR! +\(roundPoints)" : "LUCKY PAIR! +\(roundPoints)"
            HapticManager.shared.play(.click)
        } else {
            roundPoints = vals.reduce(0, +)
            combo = i18n.isTurkish ? "TOPLAM: +\(roundPoints)" : "HIGH SUM: +\(roundPoints)"
            HapticManager.shared.play(.tap)
        }
        
        totalScore += roundPoints
        lastComboText = combo
        scoreManager.recordScore(totalScore, for: "luckydice")
    }
    
    @ViewBuilder
    private func diePipsView(for val: Int, isHeld: Bool) -> some View {
        Text("\(val)")
            .font(.system(size: 22, weight: .black, design: .rounded))
            .foregroundColor(isHeld ? .black : .blue)
    }
}
