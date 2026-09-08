import SwiftUI

public enum DuelMode: String, CaseIterable, Identifiable {
    case reflex = "reflex"
    case tictactoe = "tictactoe"
    case cardwar = "cardwar"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .reflex: return "⚡ Reflex Duel"
        case .tictactoe: return "❌⭕ Tic-Tac-Toe 2P"
        case .cardwar: return "🃏 Card Duel 2P"
        }
    }
}

public struct WristDuelView: View {
    @State private var selectedMode: DuelMode = .reflex
    private let haptic = HapticManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // Reflex Duel State
    @State private var p1Score: Int = 0
    @State private var p2Score: Int = 0
    @State private var reflexState: ReflexPhase = .ready
    @State private var roundWinner: String? = nil
    @State private var matchWinner: String? = nil
    @State private var waitTimer: Timer? = nil
    
    enum ReflexPhase {
        case ready, waiting, tapNow, roundOver
    }
    
    // TicTacToe 2P State
    @State private var board: [String] = Array(repeating: "", count: 9)
    @State private var currentPlayer: String = "X"
    @State private var tttWinner: String? = nil
    
    // Card Duel State
    @State private var p1Card: Int = 0
    @State private var p2Card: Int = 0
    @State private var cardRoundWinner: String? = nil
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            // Mode Selector
            HStack(spacing: 4) {
                ForEach(DuelMode.allCases) { mode in
                    Button(action: { selectedMode = mode }) {
                        Text(mode == .reflex ? "⚡ Reflex" : (mode == .tictactoe ? "⭕ TicTac" : "🃏 Cards"))
                            .font(.system(size: 9, weight: selectedMode == mode ? .bold : .regular))
                            .foregroundColor(selectedMode == mode ? .black : .white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .background(selectedMode == mode ? Color.orange : Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            
            switch selectedMode {
            case .reflex:
                reflexDuelView
            case .tictactoe:
                tictactoeDuelView
            case .cardwar:
                cardDuelView
            }
        }
        .navigationTitle("⚔️ Wrist Duel 2P")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 1. Reflex Duel
    private var reflexDuelView: some View {
        GeometryReader { geo in
            VStack(spacing: 2) {
                // Top Player 1 (Inverted 180 deg for opposite player)
                Button(action: { handleReflexTap(player: 1) }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(reflexColor(player: 1))
                        VStack(spacing: 2) {
                            Text("OYUNCU 1 (P1)")
                                .font(.system(size: 11, weight: .bold))
                            Text("\(p1Score) / 3")
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                            if reflexState == .tapNow {
                                Text("BAS! ⚡")
                                    .font(.system(size: 14, weight: .heavy))
                            }
                        }
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(180))
                    }
                }
                .buttonStyle(.plain)
                .frame(height: (geo.size.height - 30) / 2)
                
                // Center Status / Control Bar
                HStack {
                    if let winner = matchWinner {
                        Text("\(winner) KAZANDI! 👑")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.yellow)
                    } else if reflexState == .ready {
                        Button("BAŞLA") { startReflexRound() }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.cyan)
                    } else if reflexState == .waiting {
                        Text("BEKLE...")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                    } else if reflexState == .tapNow {
                        Text("ŞİMDİ! ⚡")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.green)
                    } else if reflexState == .roundOver {
                        Button("SONRAKİ EL") { startReflexRound() }
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                }
                .frame(height: 24)
                
                // Bottom Player 2
                Button(action: { handleReflexTap(player: 2) }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(reflexColor(player: 2))
                        VStack(spacing: 2) {
                            if reflexState == .tapNow {
                                Text("BAS! ⚡")
                                    .font(.system(size: 14, weight: .heavy))
                            }
                            Text("\(p2Score) / 3")
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                            Text("OYUNCU 2 (P2)")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .frame(height: (geo.size.height - 30) / 2)
            }
        }
    }
    
    private func reflexColor(player: Int) -> Color {
        if reflexState == .tapNow {
            return Color.green.opacity(0.85)
        }
        if reflexState == .waiting {
            return Color.red.opacity(0.4)
        }
        return Color.white.opacity(0.12)
    }
    
    private func startReflexRound() {
        if p1Score >= 3 || p2Score >= 3 {
            p1Score = 0
            p2Score = 0
            matchWinner = nil
        }
        reflexState = .waiting
        haptic.play(.click)
        
        let randomDelay = Double.random(in: 1.5...3.5)
        waitTimer?.invalidate()
        waitTimer = Timer.scheduledTimer(withTimeInterval: randomDelay, repeats: false) { _ in
            reflexState = .tapNow
            haptic.play(.warning)
        }
    }
    
    private func handleReflexTap(player: Int) {
        if reflexState == .waiting {
            // False start! Opponent gets the point
            waitTimer?.invalidate()
            reflexState = .roundOver
            if player == 1 {
                p2Score += 1
                roundWinner = "P1 Hatalı Başladı! P2 Puanı Aldı"
            } else {
                p1Score += 1
                roundWinner = "P2 Hatalı Başladı! P1 Puanı Aldı"
            }
            checkDuelWin()
            return
        }
        
        if reflexState == .tapNow {
            waitTimer?.invalidate()
            reflexState = .roundOver
            if player == 1 {
                p1Score += 1
            } else {
                p2Score += 1
            }
            haptic.play(.victory)
            checkDuelWin()
        }
    }
    
    private func checkDuelWin() {
        if p1Score >= 3 {
            matchWinner = "P1"
            XPManager.shared.addXP(50, reason: "Reflex Duel Win")
        } else if p2Score >= 3 {
            matchWinner = "P2"
            XPManager.shared.addXP(50, reason: "Reflex Duel Win")
        }
    }
    
    // MARK: - 2. Tic-Tac-Toe 2P
    private var tictactoeDuelView: some View {
        VStack(spacing: 4) {
            HStack {
                Text(tttWinner == nil ? "Sıra: \(currentPlayer)" : tttWinner!)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(currentPlayer == "X" ? .cyan : .pink)
                Spacer()
                Button("Yenile") { resetTTT() }
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                ForEach(0..<9, id: \.self) { idx in
                    Button(action: { makeMove(idx) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 38)
                            Text(board[idx])
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(board[idx] == "X" ? .cyan : .pink)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(board[idx] != "" || tttWinner != nil)
                }
            }
            .padding(4)
        }
    }
    
    private func makeMove(_ idx: Int) {
        guard board[idx] == "" && tttWinner == nil else { return }
        board[idx] = currentPlayer
        haptic.play(.click)
        
        if checkTTTWin(for: currentPlayer) {
            tttWinner = "\(currentPlayer) KAZANDI! 🏆"
            haptic.play(.victory)
            XPManager.shared.addXP(50, reason: "Tic-Tac-Toe 2P Win")
        } else if !board.contains("") {
            tttWinner = "BERABERE! 🤝"
        } else {
            currentPlayer = currentPlayer == "X" ? "O" : "X"
        }
    }
    
    private func checkTTTWin(for p: String) -> Bool {
        let lines = [
            [0,1,2],[3,4,5],[6,7,8],
            [0,3,6],[1,4,7],[2,5,8],
            [0,4,8],[2,4,6]
        ]
        return lines.contains { $0.allSatisfy { board[$0] == p } }
    }
    
    private func resetTTT() {
        board = Array(repeating: "", count: 9)
        currentPlayer = "X"
        tttWinner = nil
    }
    
    // MARK: - 3. Card Duel 2P
    private var cardDuelView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                VStack {
                    Text("P1 KARTI")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.cyan)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 54, height: 72)
                        Text(p1Card > 0 ? "\(p1Card)" : "🂠")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                
                VStack {
                    Text("P2 KARTI")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.pink)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 54, height: 72)
                        Text(p2Card > 0 ? "\(p2Card)" : "🂠")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                    }
                }
            }
            
            if let winner = cardRoundWinner {
                Text(winner)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.yellow)
            }
            
            Button(action: drawDuelCards) {
                Text("KART ÇEK")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background(Color.cyan.opacity(0.3))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
        }
    }
    
    private func drawDuelCards() {
        p1Card = Int.random(in: 1...13)
        p2Card = Int.random(in: 1...13)
        haptic.play(.click)
        
        if p1Card > p2Card {
            cardRoundWinner = "P1 Eli Kazandı! (+10 XP)"
            XPManager.shared.addXP(10, reason: "Card Duel Hand")
        } else if p2Card > p1Card {
            cardRoundWinner = "P2 Eli Kazandı! (+10 XP)"
            XPManager.shared.addXP(10, reason: "Card Duel Hand")
        } else {
            cardRoundWinner = "SAVAŞ! Eşit Kartlar ⚔️"
        }
    }
}
