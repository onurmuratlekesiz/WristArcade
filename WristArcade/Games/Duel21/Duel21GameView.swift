//
//  Duel21GameView.swift
//  WristArcade
//
//  Created for WristArcade 60 Games Diamond Edition.
//  Pass-and-play 2-Player Heads-Up Blackjack on a single Apple Watch.
//

import SwiftUI

public struct Duel21GameView: View {
    @State private var deck: [Card] = []
    @State private var p1Cards: [Card] = []
    @State private var p2Cards: [Card] = []
    
    @State private var currentTurn: Int = 1 // 1: Player 1, 2: Pass Screen, 3: Player 2, 4: Showdown
    @State private var p1Score: Int = 0
    @State private var p2Score: Int = 0
    @State private var resultMessage: String = ""
    @State private var winnerColor: Color = .yellow
    
    struct Card: Identifiable {
        let id = UUID()
        let rank: String
        let value: Int
        let suit: String
        let isRed: Bool
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.15, blue: 0.12).ignoresSafeArea()
            
            VStack(spacing: 4) {
                if currentTurn == 1 {
                    // Player 1 Active Turn
                    playerTurnView(player: 1, cards: p1Cards, score: p1Score)
                } else if currentTurn == 2 {
                    // Pass Watch Interstitial
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                        Text("PASS WATCH")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Hand watch to Player 2")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            currentTurn = 3
                            HapticManager.shared.play(.start)
                        }) {
                            Text("PLAYER 2 START")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.yellow))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                } else if currentTurn == 3 {
                    // Player 2 Active Turn
                    playerTurnView(player: 2, cards: p2Cards, score: p2Score)
                } else {
                    // Final Showdown
                    showdownView
                }
            }
            .padding(.horizontal, 6)
        }
        .onAppear {
            startMatch()
        }
    }
    
    @ViewBuilder
    private func playerTurnView(player: Int, cards: [Card], score: Int) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text("PLAYER \(player)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(player == 1 ? .cyan : .orange)
                Spacer()
                Text("TOTAL: \(score)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(score > 21 ? .red : .white)
            }
            .padding(.horizontal, 6)
            
            // Cards Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(cards) { card in
                        VStack(spacing: 1) {
                            Text(card.rank)
                                .font(.system(size: 11, weight: .bold))
                            Text(card.suit)
                                .font(.system(size: 9))
                        }
                        .foregroundColor(card.isRed ? .red : .black)
                        .frame(width: 26, height: 38)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.white))
                    }
                }
                .padding(.vertical, 4)
            }
            
            Spacer()
            
            if score > 21 {
                Text("BUST! (OVER 21)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.red)
                Button(action: endCurrentPlayerTurn) {
                    Text("CONTINUE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.yellow))
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 8) {
                    Button(action: hitCard) {
                        Text("HIT")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.green))
                    }
                    .buttonStyle(.plain)
                    .handGestureShortcut(.primaryAction)
                    
                    Button(action: endCurrentPlayerTurn) {
                        Text("STAND")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.red.opacity(0.8)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, 4)
    }
    
    private var showdownView: some View {
        VStack(spacing: 6) {
            Text(resultMessage)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(winnerColor)
            
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("P1: \(p1Score)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                    Text(p1Score > 21 ? "BUST" : "\(p1Cards.count) cards")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                
                Text("VS")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.yellow)
                
                VStack(spacing: 2) {
                    Text("P2: \(p2Score)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                    Text(p2Score > 21 ? "BUST" : "\(p2Cards.count) cards")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.08)))
            
            Button(action: startMatch) {
                Text("PLAY AGAIN")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.yellow))
            }
            .buttonStyle(.plain)
        }
    }
    
    private func startMatch() {
        var newDeck: [Card] = []
        let ranks = [("A", 11), ("2", 2), ("3", 3), ("4", 4), ("5", 5), ("6", 6), ("7", 7), ("8", 8), ("9", 9), ("10", 10), ("J", 10), ("Q", 10), ("K", 10)]
        let suits = [("♠", false), ("♣", false), ("♥", true), ("♦", true)]
        
        for rank in ranks {
            for suit in suits {
                newDeck.append(Card(rank: rank.0, value: rank.1, suit: suit.0, isRed: suit.1))
            }
        }
        newDeck.shuffle()
        deck = newDeck
        
        p1Cards = [deck.removeFirst(), deck.removeFirst()]
        p2Cards = [deck.removeFirst(), deck.removeFirst()]
        p1Score = calculateScore(p1Cards)
        p2Score = calculateScore(p2Cards)
        currentTurn = 1
        HapticManager.shared.play(.start)
    }
    
    private func hitCard() {
        guard !deck.isEmpty else { return }
        let newCard = deck.removeFirst()
        
        if currentTurn == 1 {
            p1Cards.append(newCard)
            p1Score = calculateScore(p1Cards)
            HapticManager.shared.play(.click)
            SoundManager.shared.play(.flip)
            if p1Score >= 21 {
                // Auto stand or bust
            }
        } else if currentTurn == 3 {
            p2Cards.append(newCard)
            p2Score = calculateScore(p2Cards)
            HapticManager.shared.play(.click)
            SoundManager.shared.play(.flip)
        }
    }
    
    private func endCurrentPlayerTurn() {
        HapticManager.shared.play(.click)
        if currentTurn == 1 {
            currentTurn = 2 // Transition to pass watch screen
        } else if currentTurn == 3 {
            evaluateShowdown()
        }
    }
    
    private func evaluateShowdown() {
        currentTurn = 4
        
        let p1Valid = p1Score <= 21
        let p2Valid = p2Score <= 21
        
        if !p1Valid && !p2Valid {
            resultMessage = "🤝 DOUBLE BUST!"
            winnerColor = .gray
        } else if p1Valid && !p2Valid {
            resultMessage = "👑 PLAYER 1 WINS!"
            winnerColor = .cyan
            ScoreManager.shared.addXP(150)
            HapticManager.shared.play(.victory)
            SoundManager.shared.play(.victory)
        } else if !p1Valid && p2Valid {
            resultMessage = "👑 PLAYER 2 WINS!"
            winnerColor = .orange
            ScoreManager.shared.addXP(150)
            HapticManager.shared.play(.victory)
            SoundManager.shared.play(.victory)
        } else if p1Score > p2Score {
            resultMessage = "👑 PLAYER 1 WINS!"
            winnerColor = .cyan
            ScoreManager.shared.addXP(150)
            HapticManager.shared.play(.victory)
            SoundManager.shared.play(.victory)
        } else if p2Score > p1Score {
            resultMessage = "👑 PLAYER 2 WINS!"
            winnerColor = .orange
            ScoreManager.shared.addXP(150)
            HapticManager.shared.play(.victory)
            SoundManager.shared.play(.victory)
        } else {
            resultMessage = "🤝 IT'S A PUSH (TIE)!"
            winnerColor = .yellow
        }
        
        ScoreManager.shared.recordScore(max(p1Score, p2Score), for: "duel21")
    }
    
    private func calculateScore(_ cards: [Card]) -> Int {
        var total = cards.reduce(0) { $0 + $1.value }
        var aces = cards.filter { $0.rank == "A" }.count
        while total > 21 && aces > 0 {
            total -= 10
            aces -= 1
        }
        return total
    }
}
