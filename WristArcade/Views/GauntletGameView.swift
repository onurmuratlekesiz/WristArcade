import SwiftUI
import WatchKit

public struct GauntletGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    enum GauntletStep {
        case intro
        case roundIntro(Int, String, String)
        case miniGame(Int)
        case victory
        case defeat
    }
    
    @State private var currentStep: GauntletStep = .intro
    @State private var roundIndex: Int = 0
    @State private var lives: Int = 3
    @State private var roundTimer: Double = 10.0
    @State private var score: Int = 0
    
    // Micro-game states
    // Round 0: Fast Math
    @State private var mathA: Int = 3
    @State private var mathB: Int = 4
    @State private var mathAns: Int = 7
    @State private var mathOptions: [Int] = [7, 8, 6]
    
    // Round 1: Reflex Tap
    @State private var reflexColor: Color = .red
    @State private var reflexReady: Bool = false
    
    // Round 2: Tap the Dot
    @State private var dotPos: CGPoint = CGPoint(x: 80, y: 100)
    @State private var dotsHit: Int = 0
    private let targetDots = 3
    
    // Round 3: Safe Cracker Dial (Quick align)
    @State private var dialAngle: Double = 0.0
    @State private var targetAngle: Double = 90.0
    
    // Round 4: Rapid Chomp / Final Sprint
    @State private var tapsCount: Int = 0
    private let requiredTaps = 12
    
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 4) {
                // Top HUD
                HStack {
                    Text("GAUNTLET")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.yellow)
                    Spacer()
                    // Lives
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            Text(i < lives ? "❤️" : "🖤")
                                .font(.system(size: 10))
                        }
                    }
                }
                .padding(.horizontal, 6)
                
                // Timer Bar
                if case .miniGame = currentStep {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 3)
                            Rectangle()
                                .fill(roundTimer > 3 ? Color.green : Color.red)
                                .frame(width: max(0, geo.size.width * CGFloat(roundTimer / 8.0)), height: 3)
                        }
                    }
                    .frame(height: 3)
                }
                
                Spacer()
                
                // Step Content
                switch currentStep {
                case .intro:
                    VStack(spacing: 6) {
                        Text("⚡ ARCADE GAUNTLET")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.yellow)
                        Text("5 Rapid Micro-Games\nSurvive with 3 Lives!")
                            .font(.system(size: 10))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button(action: startGauntlet) {
                            Text("START MARATHON")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    
                case .roundIntro(let num, let title, let prompt):
                    VStack(spacing: 6) {
                        Text("STAGE \(num + 1) / 5")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.cyan)
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(prompt)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    
                case .miniGame(let idx):
                    switch idx {
                    case 0:
                        // Micro Math
                        VStack(spacing: 6) {
                            Text("\(mathA) + \(mathB) = ?")
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            HStack(spacing: 6) {
                                ForEach(mathOptions, id: \.self) { opt in
                                    Button(action: {
                                        if opt == mathAns {
                                            passRound()
                                        } else {
                                            failRound()
                                        }
                                    }) {
                                        Text("\(opt)")
                                            .font(.system(size: 13, weight: .bold))
                                            .frame(width: 36, height: 28)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                    case 1:
                        // Reflex Green Flash
                        Button(action: {
                            if reflexReady {
                                passRound()
                            } else {
                                failRound()
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(reflexColor)
                                    .frame(width: 120, height: 80)
                                Text(reflexReady ? "TAP NOW!" : "WAIT...")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.black)
                            }
                        }
                        .buttonStyle(.plain)
                        
                    case 2:
                        // Whack the Dots
                        ZStack {
                            Text("Hit \(targetDots - dotsHit) more!")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(maxHeight: .infinity, alignment: .top)
                            
                            Button(action: {
                                dotsHit += 1
                                WKInterfaceDevice.current().play(.click)
                                if dotsHit >= targetDots {
                                    passRound()
                                } else {
                                    dotPos = CGPoint(x: CGFloat.random(in: 25...135), y: CGFloat.random(in: 30...110))
                                }
                            }) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 30, height: 30)
                                    .shadow(color: .red, radius: 4)
                            }
                            .buttonStyle(.plain)
                            .position(dotPos)
                        }
                        .frame(height: 120)
                        
                    case 3:
                        // Dial Alignment
                        VStack(spacing: 6) {
                            Text("Rotate dial to target!")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                                    .frame(width: 60, height: 60)
                                
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 4, height: 24)
                                    .offset(y: -18)
                                    .rotationEffect(.degrees(targetAngle))
                                
                                Rectangle()
                                    .fill(Color.cyan)
                                    .frame(width: 4, height: 24)
                                    .offset(y: -18)
                                    .rotationEffect(.degrees(dialAngle))
                            }
                            
                            Button(action: {
                                dialAngle = (dialAngle + 30).truncatingRemainder(dividingBy: 360)
                                WKInterfaceDevice.current().play(.click)
                                if abs(dialAngle - targetAngle) < 15 {
                                    passRound()
                                }
                            }) {
                                Text("TURN DIAL")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.cyan)
                                    .foregroundColor(.black)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                        
                    default:
                        // Rapid Taps
                        VStack(spacing: 4) {
                            Text("TAP AS FAST AS YOU CAN!")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.orange)
                            
                            Text("\(tapsCount) / \(requiredTaps)")
                                .font(.system(size: 15, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                tapsCount += 1
                                WKInterfaceDevice.current().play(.click)
                                if tapsCount >= requiredTaps {
                                    passRound()
                                }
                            }) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text("TAP")
                                            .font(.system(size: 11, weight: .black))
                                            .foregroundColor(.black)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                case .victory:
                    VStack(spacing: 6) {
                        Text("👑 GAUNTLET CLEARED!")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.yellow)
                        Text("+250 XP BONUS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.green)
                        
                        Button(action: { dismiss() }) {
                            Text("CLAIM REWARD")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    
                case .defeat:
                    VStack(spacing: 6) {
                        Text("💀 GAUNTLET FAILED")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.red)
                        Text("Stage \(roundIndex + 1) eliminated you")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Button(action: startGauntlet) {
                            Text("TRY AGAIN")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.orange)
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding(6)
        }
        .onReceive(timer) { _ in
            guard case .miniGame = currentStep else { return }
            roundTimer -= 0.1
            if roundTimer <= 0 {
                failRound()
            }
        }
    }
    
    private func startGauntlet() {
        lives = 3
        roundIndex = 0
        score = 0
        loadRound(0)
    }
    
    private func loadRound(_ idx: Int) {
        roundIndex = idx
        roundTimer = 7.0
        
        let titles = [
            ("SPEED MATH", "Solve instantly!"),
            ("REFLEX FLASH", "Tap on GREEN!"),
            ("WHACK TARGETS", "Hit all red dots!"),
            ("LOCK ALIGN", "Turn dial to match!"),
            ("TURBO TAP", "12 Rapid Taps!")
        ]
        
        let (title, prompt) = titles[idx]
        currentStep = .roundIntro(idx, title, prompt)
        
        // Prepare microgame setup
        switch idx {
        case 0:
            mathA = Int.random(in: 2...6)
            mathB = Int.random(in: 2...6)
            mathAns = mathA + mathB
            mathOptions = [mathAns, mathAns + 1, mathAns - 1].shuffled()
        case 1:
            reflexColor = .red
            reflexReady = false
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.5...3.0)) {
                if case .miniGame(1) = currentStep {
                    reflexColor = .green
                    reflexReady = true
                    WKInterfaceDevice.current().play(.directionUp)
                }
            }
        case 2:
            dotsHit = 0
            dotPos = CGPoint(x: 80, y: 70)
        case 3:
            dialAngle = 0.0
            targetAngle = Double([90, 180, 270].randomElement() ?? 90)
        default:
            tapsCount = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            currentStep = .miniGame(idx)
        }
    }
    
    private func passRound() {
        WKInterfaceDevice.current().play(.success)
        score += 50
        if roundIndex >= 4 {
            currentStep = .victory
            _ = ScoreManager.shared.recordScore(score + 250, for: "gauntlet")
            _ = XPManager.shared.addXP(250, reason: "Arcade Gauntlet Cleared")
        } else {
            loadRound(roundIndex + 1)
        }
    }
    
    private func failRound() {
        WKInterfaceDevice.current().play(.failure)
        lives -= 1
        if lives <= 0 {
            currentStep = .defeat
        } else {
            loadRound(roundIndex)
        }
    }
}
