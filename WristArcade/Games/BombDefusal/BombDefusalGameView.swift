//
//  BombDefusalGameView.swift
//  WristArcade
//
//  Created for WristArcade 60 Games Diamond Edition.
//  High-tension logic deduction bomb defusal game.
//

import SwiftUI

public struct BombDefusalGameView: View {
    @State private var serial: String = "WX-4927"
    @State private var wires: [WireItem] = []
    @State private var timeLeft: Double = 45.0
    @State private var correctWireIndex: Int = 1
    @State private var ruleHint: String = ""
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    @State private var isExploded: Bool = false
    @State private var isDefused: Bool = false
    
    @State private var timer: Timer?
    
    struct WireItem: Identifiable {
        let id: Int
        let color: Color
        let name: String
        var isCut: Bool = false
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 4) {
                // Header: Serial & Timer
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("SERIAL")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                        Text(serial)
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    Spacer()
                    // Digital Countdown LED
                    Text(String(format: "%04.1f", max(0, timeLeft)))
                        .font(.system(size: 16, weight: .heavy, design: .monospaced))
                        .foregroundColor(timeLeft < 10 ? .red : .green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(white: 0.12))
                        .cornerRadius(4)
                }
                .padding(.horizontal, 8)
                
                // Rule Hint Pill
                Text(ruleHint)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.08)))
                
                Spacer()
                
                // 4 Interactive Wires
                VStack(spacing: 8) {
                    ForEach(wires) { wire in
                        Button(action: {
                            cutWire(wire.id)
                        }) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 8, height: 8)
                                
                                if wire.isCut {
                                    HStack(spacing: 6) {
                                        Rectangle()
                                            .fill(wire.color)
                                            .frame(height: 5)
                                        Image(systemName: "scissors")
                                            .font(.system(size: 9))
                                            .foregroundColor(.white)
                                        Rectangle()
                                            .fill(wire.color)
                                            .frame(height: 5)
                                    }
                                } else {
                                    Rectangle()
                                        .fill(wire.color)
                                        .frame(height: 5)
                                        .shadow(color: wire.color.opacity(0.8), radius: 2)
                                }
                                
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 8, height: 8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .background(Color(white: 0.15))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(wire.isCut || isGameOver)
                    }
                }
                .padding(.horizontal, 10)
                
                Spacer()
            }
            .padding(.top, 4)
            
            // Overlays: Exploded or Defused
            if isExploded {
                VStack(spacing: 6) {
                    Text("💥 DETONATED!")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                    Text("Wrong Wire Cut!")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                    Button(action: startNewBomb) {
                        Text("TRY AGAIN")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.red))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.95)))
            } else if isDefused {
                VStack(spacing: 6) {
                    Text("✅ DEFUSED!")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.green)
                    Text("Bomb Safe! +150 XP")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.yellow)
                    Button(action: nextLevel) {
                        Text("NEXT BOMB")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.green))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.95)))
            }
        }
        .onAppear {
            startNewBomb()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startNewBomb() {
        timer?.invalidate()
        isExploded = false
        isDefused = false
        isGameOver = false
        timeLeft = 45.0
        
        let prefixLetters = ["WX", "RK", "TR", "BL", "CZ", "NP"]
        let randomLetter = prefixLetters.randomElement() ?? "WX"
        let randomDigits = Int.random(in: 1000...9999)
        serial = "\(randomLetter)-\(randomDigits)"
        
        let colorPalette: [(Color, String)] = [
            (.red, "Red"),
            (.blue, "Blue"),
            (.yellow, "Yellow"),
            (.green, "Green")
        ]
        
        var generatedWires: [WireItem] = []
        for i in 0..<4 {
            let sample = colorPalette.randomElement()!
            generatedWires.append(WireItem(id: i, color: sample.0, name: sample.1))
        }
        wires = generatedWires
        
        let lastDigit = randomDigits % 10
        let hasRed = wires.contains { $0.name == "Red" }
        let blueCount = wires.filter { $0.name == "Blue" }.count
        
        if lastDigit % 2 != 0 && hasRed {
            ruleHint = "Serial odd & has RED -> Cut Wire 2"
            correctWireIndex = 1
        } else if blueCount > 1 {
            ruleHint = "Multiple BLUE wires -> Cut Wire 4"
            correctWireIndex = 3
        } else if wires[0].name == "Green" {
            ruleHint = "Starts with GREEN -> Cut Wire 1"
            correctWireIndex = 0
        } else {
            ruleHint = "Standard protocol -> Cut Wire 3"
            correctWireIndex = 2
        }
        
        HapticManager.shared.play(.start)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeLeft > 0.1 {
                timeLeft -= 0.1
                if Int(timeLeft * 10) % 10 == 0 && timeLeft <= 5 {
                    SoundManager.shared.play(.click)
                    HapticManager.shared.play(.click)
                }
            } else {
                detonate()
            }
        }
    }
    
    private func cutWire(_ id: Int) {
        guard !isGameOver else { return }
        
        if let idx = wires.firstIndex(where: { $0.id == id }) {
            wires[idx].isCut = true
        }
        
        if id == correctWireIndex {
            // Defused!
            timer?.invalidate()
            isDefused = true
            isGameOver = true
            score += 1
            ScoreManager.shared.recordScore(score, for: "bombdefusal")
            ScoreManager.shared.addXP(150)
            HapticManager.shared.play(.victory)
            SoundManager.shared.play(.victory)
        } else {
            detonate()
        }
    }
    
    private func detonate() {
        timer?.invalidate()
        isExploded = true
        isGameOver = true
        HapticManager.shared.play(.error)
        SoundManager.shared.play(.laser)
    }
    
    private func nextLevel() {
        startNewBomb()
    }
}
