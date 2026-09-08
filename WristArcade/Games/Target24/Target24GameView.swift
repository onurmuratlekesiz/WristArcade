//
//  Target24GameView.swift
//  WristArcade
//
//  Created for WristArcade 60 Games Diamond Edition.
//  Classic 24 Solver mathematical target card puzzle.
//

import SwiftUI

public struct Target24GameView: View {
    @State private var numbers: [Int] = [3, 8, 4, 6]
    @State private var usedNumbers: [Bool] = [false, false, false, false]
    @State private var expression: [String] = []
    @State private var evaluatedResult: Double? = nil
    @State private var score: Int = 0
    @State private var isSolved: Bool = false
    @State private var errorMessage: String? = nil
    
    private let presetDecks: [[Int]] = [
        [3, 8, 4, 6],
        [1, 3, 4, 6],
        [2, 3, 4, 5],
        [2, 2, 7, 7],
        [1, 5, 5, 5],
        [4, 4, 4, 6],
        [2, 4, 6, 8],
        [3, 3, 8, 8]
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 4) {
                // Header
                HStack {
                    Text("GOAL: 24")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                    Spacer()
                    Text("SOLVED: \(score)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 10)
                
                // Expression Display
                HStack {
                    Text(expression.isEmpty ? "Tap numbers & operators" : expression.joined(separator: " "))
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundColor(expression.isEmpty ? .gray : .white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .background(Color(white: 0.12))
                .cornerRadius(6)
                .padding(.horizontal, 8)
                
                // 4 Number Tiles
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { idx in
                        Button(action: {
                            appendNumber(idx)
                        }) {
                            Text("\(numbers[idx])")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(usedNumbers[idx] ? .gray : .black)
                                .frame(width: 36, height: 32)
                                .background(usedNumbers[idx] ? Color(white: 0.25) : Color.yellow)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(usedNumbers[idx] || isSolved)
                    }
                }
                
                // 4 Operator Buttons
                HStack(spacing: 8) {
                    ForEach(["+", "-", "×", "÷"], id: \.self) { op in
                        Button(action: {
                            appendOperator(op)
                        }) {
                            Text(op)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 26)
                                .background(Color.purple.opacity(0.8))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(isSolved)
                    }
                }
                
                // Action Controls: Clear, Backspace, Submit
                HStack(spacing: 6) {
                    Button(action: clearExpression) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 26)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: evaluate) {
                        Text("CHECK = 24")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 26)
                            .background(Color.green)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .disabled(isSolved || expression.count < 3)
                }
                .padding(.horizontal, 8)
            }
            .padding(.top, 2)
            
            // Solved Celebration Overlay
            if isSolved {
                VStack(spacing: 6) {
                    Text("🎉 24 SOLVED!")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                    Text("+150 XP")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                    Button(action: nextPuzzle) {
                        Text("NEXT PUZZLE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.yellow))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.95)))
            }
        }
        .onAppear {
            nextPuzzle()
        }
    }
    
    private func appendNumber(_ idx: Int) {
        guard !usedNumbers[idx] else { return }
        usedNumbers[idx] = true
        expression.append("\(numbers[idx])")
        HapticManager.shared.play(.click)
        SoundManager.shared.play(.click)
    }
    
    private func appendOperator(_ op: String) {
        guard !expression.isEmpty else { return }
        let last = expression.last!
        if last != "+" && last != "-" && last != "×" && last != "÷" {
            expression.append(op)
            HapticManager.shared.play(.click)
            SoundManager.shared.play(.click)
        }
    }
    
    private func clearExpression() {
        expression.removeAll()
        usedNumbers = [false, false, false, false]
        HapticManager.shared.play(.click)
    }
    
    private func evaluate() {
        // Sequential left-to-right evaluation for simple arcade watch play
        guard expression.count >= 3 else { return }
        
        var currentVal: Double = 0.0
        var currentOp: String = "+"
        
        for token in expression {
            if token == "+" || token == "-" || token == "×" || token == "÷" {
                currentOp = token
            } else if let num = Double(token) {
                switch currentOp {
                case "+": currentVal += num
                case "-": currentVal -= num
                case "×": currentVal *= num
                case "÷":
                    if num != 0 {
                        currentVal /= num
                    }
                default: break
                }
            }
        }
        
        if abs(currentVal - 24.0) < 0.001 && usedNumbers.allSatisfy({ $0 }) {
            isSolved = true
            score += 1
            ScoreManager.shared.recordScore(score, for: "target24")
            ScoreManager.shared.addXP(150)
            HapticManager.shared.play(.victory)
            SoundManager.shared.play(.victory)
        } else {
            HapticManager.shared.play(.error)
            SoundManager.shared.play(.gameover)
        }
    }
    
    private func nextPuzzle() {
        isSolved = false
        clearExpression()
        numbers = presetDecks.randomElement() ?? [3, 8, 4, 6]
        numbers.shuffle()
    }
}
