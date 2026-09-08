import SwiftUI

public struct DeepSeaReelGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    enum FishState {
        case idle
        case waitingBite
        case hooked
        case caught
        case snapped
        case escaped
    }
    
    @State private var state: FishState = .idle
    @State private var crownRotation: Double = 0
    @State private var previousCrown: Double = 0
    @State private var distanceLeft: Double = 40.0 // meters
    @State private var tension: Double = 50.0 // 0 to 100
    @State private var fishWeight: Double = 0
    @State private var fishName: String = ""
    @State private var totalScore: Int = 0
    @State private var statusMessage: String = ""
    @State private var showingInfo: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "deepreel" })!
    
    // Timer for fish struggle and tension decay
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                // Header Bar
                HStack {
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        showingInfo = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.cyan)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(i18n.isTurkish ? "DERİN OLTA" : "DEEP SEA REEL")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.cyan)
                    
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
                
                // Score & Best
                HStack {
                    Text(i18n.isTurkish ? "PUAN: \(totalScore)" : "SCORE: \(totalScore)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.yellow)
                    Spacer()
                    Text(i18n.isTurkish ? "REKOR: \(scoreManager.highScore(for: "deepreel"))" : "BEST: \(scoreManager.highScore(for: "deepreel"))")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 6)
                
                // Visual Ocean / Fishing Scene
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color(red: 0.05, green: 0.15, blue: 0.35)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 70)
                    
                    if state == .idle {
                        VStack(spacing: 2) {
                            Image(systemName: "figure.fishing")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text(i18n.isTurkish ? "Oltayı denize fırlatın" : "Cast line to fish")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else if state == .waitingBite {
                        VStack(spacing: 2) {
                            ProgressView()
                                .tint(.cyan)
                            Text(i18n.isTurkish ? "Balık bekleniyor..." : "Waiting for bite...")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.cyan)
                        }
                    } else if state == .hooked {
                        VStack(spacing: 2) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                Text(i18n.isTurkish ? "VURDU! CROWN ÇEVİR" : "HOOKED! REEL CROWN")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(.yellow)
                            }
                            
                            // Distance and Depth
                            Text("\(Int(distanceLeft))m \(i18n.isTurkish ? "Kaldı" : "Left")")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(.white)
                            
                            // Tension Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.4))
                                        .frame(height: 8)
                                    
                                    // Sweet spot indicator (40% - 75%)
                                    Rectangle()
                                        .fill(Color.green.opacity(0.4))
                                        .frame(width: geo.size.width * 0.35, height: 8)
                                        .offset(x: geo.size.width * 0.4)
                                    
                                    // Current tension marker
                                    Capsule()
                                        .fill(tensionColor)
                                        .frame(width: max(4, geo.size.width * CGFloat(tension / 100.0)), height: 8)
                                }
                            }
                            .frame(height: 8)
                            .padding(.horizontal, 10)
                        }
                    } else if state == .caught {
                        VStack(spacing: 2) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                            Text("\(fishName) (\(String(format: "%.1f", fishWeight)) kg!)")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.green)
                        }
                    } else {
                        VStack(spacing: 2) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            Text(statusMessage)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Action Buttons
                if state == .idle || state == .caught || state == .snapped || state == .escaped {
                    Button(action: castLine) {
                        HStack {
                            Image(systemName: "arrow.up.forward.circle.fill")
                            Text(i18n.isTurkish ? "OLTA FIRLAT" : "CAST LINE")
                                .font(.system(size: 11, weight: .black))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.cyan)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                } else if state == .hooked {
                    // Quick tap reel backup button
                    Button(action: {
                        crownRotation += 15
                        manualReelStep()
                    }) {
                        Text(i18n.isTurkish ? "CROWN ÇEVİR VEYA DOKUN" : "REEL CROWN / TAP")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 24)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
        .focusable()
        .digitalCrownRotation($crownRotation, from: -10000, through: 10000, by: 1.0, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
        .onChange(of: crownRotation) { _ in
            if state == .hooked {
                let delta = abs(crownRotation - previousCrown)
                previousCrown = crownRotation
                if delta > 0.5 {
                    manualReelStep()
                }
            }
        }
        .onReceive(timer) { _ in
            updatePhysics()
        }
        .sheet(isPresented: $showingInfo) {
            GameTutorialSheetView(game: gameInfo)
        }
    }
    
    private var tensionColor: Color {
        if tension < 25 { return .blue }
        if tension > 85 { return .red }
        if tension >= 40 && tension <= 75 { return .green }
        return .yellow
    }
    
    private func castLine() {
        HapticManager.shared.play(.tap)
        state = .waitingBite
        statusMessage = ""
        
        let biteDelay = Double.random(in: 1.5...3.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + biteDelay) {
            guard state == .waitingBite else { return }
            
            HapticManager.shared.play(.success)
            state = .hooked
            distanceLeft = Double.random(in: 30...60)
            tension = 50.0
            
            let species = [
                ("Tuna", 35.0, 150),
                ("Marlin", 65.0, 300),
                ("Swordfish", 45.0, 220),
                ("Salmon", 12.0, 80),
                ("Great Shark", 95.0, 500)
            ]
            let pick = species.randomElement()!
            fishName = pick.0
            fishWeight = pick.1 + Double.random(in: -3...10)
        }
    }
    
    private func manualReelStep() {
        guard state == .hooked else { return }
        HapticManager.shared.play(.tap)
        distanceLeft -= 1.8
        tension += 4.5
        
        if distanceLeft <= 0 {
            catchFish()
        }
    }
    
    private func updatePhysics() {
        guard state == .hooked else { return }
        
        // Fish pulls back tension and distance
        let struggle = Double.random(in: 0.8...3.0)
        tension -= 2.0 // Decay without reeling
        
        if Double.random(in: 0...1) > 0.6 {
            tension += struggle * 1.5
        }
        
        // Check line snap or escape
        if tension >= 98 {
            state = .snapped
            statusMessage = i18n.isTurkish ? "Misina koptu! (Aşırı Gerilim)" : "Line snapped! (Tension high)"
            HapticManager.shared.play(.failure)
        } else if tension <= 5 {
            state = .escaped
            statusMessage = i18n.isTurkish ? "Balık kurtuldu! (Gevşek Misina)" : "Fish escaped! (Line slack)"
            HapticManager.shared.play(.failure)
        }
    }
    
    private func catchFish() {
        state = .caught
        HapticManager.shared.play(.success)
        let gainedScore = Int(fishWeight * 10)
        totalScore += gainedScore
        
        if totalScore > scoreManager.highScore(for: "deepreel") {
            scoreManager.saveHighScore(totalScore, for: "deepreel")
        }
    }
}
