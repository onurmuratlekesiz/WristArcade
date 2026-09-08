import SwiftUI

public struct LuckyRouletteGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var chips: Int = 100
    @State private var selectedBetType: BetType = .red
    @State private var selectedNumber: Int = 7
    @State private var currentBet: Int = 10
    @State private var wheelAngle: Double = 0
    @State private var isSpinning: Bool = false
    @State private var winningNumber: Int? = nil
    @State private var resultMessage: String = ""
    @State private var showingInfo: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "luckyroulette" })!
    
    enum BetType: String, CaseIterable {
        case red = "RED"
        case black = "BLACK"
        case even = "EVEN"
        case odd = "ODD"
        case number = "#7"
    }
    
    // Standard European Roulette layout numbers
    private let redNumbers: Set<Int> = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
    
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
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(i18n.isTurkish ? "ŞANSLI RULET" : "LUCKY ROULETTE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.red)
                    
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
                
                // Stats Bar (Bank & High Score)
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(i18n.isTurkish ? "KASA" : "BANK")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.gray)
                        Text("$\(chips)")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.yellow)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(i18n.isTurkish ? "REKOR" : "BEST")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.gray)
                        Text("$\(scoreManager.highScore(for: "luckyroulette"))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.cyan)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.4))
                .cornerRadius(8)
                
                // Roulette Wheel / Ball Target Area
                ZStack {
                    Circle()
                        .strokeBorder(
                            AngularGradient(
                                gradient: Gradient(colors: [.red, .black, .red, .black, .green, .red, .black, .red]),
                                center: .center
                            ),
                            lineWidth: 10
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(wheelAngle))
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: 58, height: 58)
                    
                    if let winNum = winningNumber {
                        VStack(spacing: 0) {
                            Text("\(winNum)")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(colorForNumber(winNum))
                            Text(winNum == 0 ? "ZERO" : (redNumbers.contains(winNum) ? "RED" : "BLK"))
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.gray)
                        }
                    } else {
                        Image(systemName: "circle.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(isSpinning ? .yellow : .red)
                            .rotationEffect(.degrees(wheelAngle * 2))
                    }
                }
                .frame(height: 84)
                
                // Result Banner
                if !resultMessage.isEmpty {
                    Text(resultMessage)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(resultMessage.contains("+") ? .green : .orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
                
                // Bet Type Selector
                VStack(spacing: 4) {
                    Text(i18n.isTurkish ? "BAHİS TÜRÜ ($10):" : "BET TYPE ($10):")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 3) {
                        ForEach(BetType.allCases, id: \.self) { bType in
                            Button(action: {
                                guard !isSpinning else { return }
                                HapticManager.shared.play(.tap)
                                selectedBetType = bType
                            }) {
                                Text(bType.rawValue)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(selectedBetType == bType ? .white : .gray)
                                    .frame(maxWidth: .infinity, minHeight: 22)
                                    .background(selectedBetType == bType ? betButtonColor(bType) : Color.white.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .disabled(isSpinning)
                        }
                    }
                }
                
                // Spin Action Button
                Button(action: spinWheel) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11))
                        Text(isSpinning ? (i18n.isTurkish ? "DÖNÜYOR..." : "SPINNING...") : (i18n.isTurkish ? "ÇARK ÇEVİR ($10)" : "SPIN WHEEL ($10)"))
                            .font(.system(size: 11, weight: .black))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 32)
                    .background(isSpinning || chips < 10 ? Color.gray.opacity(0.4) : Color.red)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(isSpinning || chips < 10)
                
                if chips < 10 && !isSpinning {
                    Button(action: {
                        HapticManager.shared.play(.success)
                        chips = 100
                        resultMessage = i18n.isTurkish ? "+$100 Fiş Eklendi!" : "+$100 Bank Reload!"
                    }) {
                        Text(i18n.isTurkish ? "KASAYI YENİLE ($100)" : "RELOAD BANK ($100)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 4)
        }
        .sheet(isPresented: $showingInfo) {
            GameTutorialSheetView(game: gameInfo)
        }
    }
    
    private func betButtonColor(_ type: BetType) -> Color {
        switch type {
        case .red: return .red
        case .black: return .black
        case .even: return .blue
        case .odd: return .purple
        case .number: return .orange
        }
    }
    
    private func colorForNumber(_ n: Int) -> Color {
        if n == 0 { return .green }
        return redNumbers.contains(n) ? .red : .white
    }
    
    private func spinWheel() {
        guard chips >= currentBet, !isSpinning else { return }
        
        HapticManager.shared.play(.tap)
        chips -= currentBet
        isSpinning = true
        resultMessage = ""
        
        let spinRounds = Double.random(in: 4...7) * 360
        let extraAngle = Double.random(in: 0...359)
        let targetAngle = wheelAngle + spinRounds + extraAngle
        
        withAnimation(.easeOut(duration: 2.2)) {
            wheelAngle = targetAngle
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            isSpinning = false
            let landed = Int.random(in: 0...36)
            winningNumber = landed
            
            var won = false
            var payout = 0
            
            switch selectedBetType {
            case .red:
                if redNumbers.contains(landed) { won = true; payout = currentBet * 2 }
            case .black:
                if landed != 0 && !redNumbers.contains(landed) { won = true; payout = currentBet * 2 }
            case .even:
                if landed != 0 && landed % 2 == 0 { won = true; payout = currentBet * 2 }
            case .odd:
                if landed % 2 == 1 { won = true; payout = currentBet * 2 }
            case .number:
                if landed == selectedNumber { won = true; payout = currentBet * 36 }
            }
            
            if won {
                chips += payout
                HapticManager.shared.play(.success)
                resultMessage = i18n.isTurkish ? "KAZANDIN! +$\(payout)" : "YOU WON! +$\(payout)"
                if chips > scoreManager.highScore(for: "luckyroulette") {
                    scoreManager.saveHighScore(chips, for: "luckyroulette")
                }
            } else {
                HapticManager.shared.play(.failure)
                resultMessage = i18n.isTurkish ? "KAYBETTİN (-$10)" : "LOST (-$10)"
            }
        }
    }
}
