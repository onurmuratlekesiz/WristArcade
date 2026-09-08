import SwiftUI

public struct BullseyeArcheryGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var arrowsLeft: Int = 5
    @State private var totalScore: Int = 0
    @State private var windX: Double = 1.5 // meters/sec (-3.0 to 3.0)
    @State private var windY: Double = -0.5
    @State private var aimX: CGFloat = 0
    @State private var aimY: CGFloat = 0
    @State private var isDrawingBow: Bool = false
    @State private var drawTension: Double = 0.0
    @State private var lastHitPoint: CGPoint? = nil
    @State private var lastHitScore: Int = 0
    @State private var isGameOver: Bool = false
    @State private var showingInfo: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "bullseyearchery" })!
    
    private let drawTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                // Header Bar
                HStack {
                    Button(action: {
                        HapticManager.shared.play(.tap)
                        showingInfo = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(i18n.isTurkish ? "HEDEF OKÇULUK" : "BULLSEYE ARCHERY")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.orange)
                    
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
                
                // HUD: Score, Arrows & Wind
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(i18n.isTurkish ? "OK: \(arrowsLeft)/5" : "ARROWS: \(arrowsLeft)/5")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                        Text(i18n.isTurkish ? "PUAN: \(totalScore)" : "SCORE: \(totalScore)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    // Wind indicator
                    HStack(spacing: 3) {
                        Image(systemName: "wind")
                            .font(.system(size: 11))
                            .foregroundColor(.cyan)
                        Text("\(String(format: "%.1f", abs(windX)))m/s")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.cyan)
                        Image(systemName: windX >= 0 ? "arrow.right" : "arrow.left")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
                }
                .padding(.horizontal, 6)
                
                // Archery Target Area
                ZStack {
                    // Outer White Rings (1-2 pts)
                    Circle().fill(Color.white).frame(width: 100, height: 100)
                    Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1).frame(width: 80, height: 80)
                    
                    // Black Rings (3-4 pts)
                    Circle().fill(Color.black).frame(width: 70, height: 70)
                    
                    // Blue Rings (5-6 pts)
                    Circle().fill(Color.blue).frame(width: 50, height: 50)
                    
                    // Red Rings (7-8 pts)
                    Circle().fill(Color.red).frame(width: 32, height: 32)
                    
                    // Bullseye Gold (9-10 pts)
                    Circle().fill(Color.yellow).frame(width: 16, height: 16)
                    Circle().fill(Color.orange).frame(width: 6, height: 6)
                    
                    // Last Hit Marker
                    if let hit = lastHitPoint {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                            .position(hit)
                    }
                    
                    // Aiming Reticle (moves when dragging / drawing)
                    if isDrawingBow {
                        Image(systemName: "scope")
                            .font(.system(size: 22))
                            .foregroundColor(.red)
                            .offset(x: aimX, y: aimY)
                    }
                    
                    // Touch & Drag Gesture
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { val in
                                    guard !isGameOver, arrowsLeft > 0 else { return }
                                    if !isDrawingBow {
                                        isDrawingBow = true
                                        drawTension = 0
                                        HapticManager.shared.play(.tap)
                                    }
                                    aimX = val.translation.width * 0.4
                                    aimY = val.translation.height * 0.4
                                }
                                .onEnded { _ in
                                    guard isDrawingBow else { return }
                                    isDrawingBow = false
                                    looseArrow()
                                }
                        )
                }
                .frame(width: 106, height: 106)
                
                // Tension Bar & Hit Result
                if isDrawingBow {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.3)).frame(height: 6)
                            Capsule().fill(Color.orange).frame(width: geo.size.width * CGFloat(drawTension), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 14)
                } else if lastHitScore > 0 {
                    Text(lastHitScore == 10 ? (i18n.isTurkish ? "TAM İSABET! (BULLSEYE 10P)" : "PERFECT BULLSEYE! (10 PTS)") : "+\(lastHitScore) \(i18n.isTurkish ? "PUAN" : "PTS")")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(lastHitScore >= 8 ? .yellow : .white)
                }
                
                if isGameOver {
                    VStack(spacing: 3) {
                        Text(i18n.isTurkish ? "OYUN BİTTİ!" : "ROUND COMPLETE!")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.orange)
                        Button(action: resetGame) {
                            Text(i18n.isTurkish ? "YENİ TUR" : "NEW ROUND")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 26)
                                .background(Color.orange)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 4)
        }
        .onReceive(drawTimer) { _ in
            if isDrawingBow && drawTension < 1.0 {
                drawTension = min(1.0, drawTension + 0.08)
            }
        }
        .sheet(isPresented: $showingInfo) {
            GameTutorialSheetView(game: gameInfo)
        }
    }
    
    private func looseArrow() {
        guard arrowsLeft > 0 else { return }
        arrowsLeft -= 1
        HapticManager.shared.play(.tap)
        
        // Wind offset physics
        let windDriftX = CGFloat(windX * 8.0)
        let windDriftY = CGFloat(windY * 6.0)
        
        // Final landing point relative to center (53, 53)
        let center = CGPoint(x: 53, y: 53)
        let finalX = center.x + aimX + windDriftX
        let finalY = center.y + aimY + windDriftY
        lastHitPoint = CGPoint(x: finalX, y: finalY)
        
        let dx = finalX - center.x
        let dy = finalY - center.y
        let dist = sqrt(dx * dx + dy * dy)
        
        var points = 0
        if dist <= 4 { points = 10 }
        else if dist <= 12 { points = 9 }
        else if dist <= 22 { points = 7 }
        else if dist <= 33 { points = 5 }
        else if dist <= 44 { points = 3 }
        else if dist <= 50 { points = 1 }
        else { points = 0 }
        
        lastHitScore = points
        totalScore += points
        
        if points >= 9 {
            HapticManager.shared.play(.success)
        } else if points > 0 {
            HapticManager.shared.play(.tap)
        } else {
            HapticManager.shared.play(.failure)
        }
        
        // Shift wind for next arrow
        windX = Double.random(in: -2.8...2.8)
        windY = Double.random(in: -1.5...1.5)
        
        if arrowsLeft == 0 {
            isGameOver = true
            if totalScore > scoreManager.highScore(for: "bullseyearchery") {
                scoreManager.saveHighScore(totalScore, for: "bullseyearchery")
            }
        }
    }
    
    private func resetGame() {
        arrowsLeft = 5
        totalScore = 0
        lastHitPoint = nil
        lastHitScore = 0
        isGameOver = false
        windX = Double.random(in: -2.5...2.5)
        windY = Double.random(in: -1.0...1.0)
    }
}
