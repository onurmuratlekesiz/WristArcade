import SwiftUI

struct AlienInvader: Identifiable {
    let id: Int
    var x: Double
    var y: Double
    var isAlive: Bool
    var type: Int
}

struct LaserBeam: Identifiable {
    let id: UUID = UUID()
    var x: Double
    var y: Double
}

public struct GalaxyDefenderGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var crownRotation: Double = 80.0
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    @State private var wave: Int = 1
    @State private var showingInfo: Bool = false
    
    @State private var aliens: [AlienInvader] = []
    @State private var lasers: [LaserBeam] = []
    @State private var ufoX: Double = -30.0
    @State private var ufoActive: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "galaxydefender" })!
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack {
                Button(action: {
                    HapticManager.shared.play(.tap)
                    showingInfo = true
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.mint)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("WAVE \(wave)")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Text("\(score)")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(.mint)
                
                Button(action: {
                    HapticManager.shared.play(.tap)
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 6)
            
            // Battle Arena
            GeometryReader { geo in
                ZStack {
                    // Dark Starfield
                    Color.black.cornerRadius(8)
                    
                    // UFO Mothership
                    if ufoActive {
                        Text("🛸")
                            .font(.system(size: 16))
                            .position(x: ufoX, y: 14)
                    }
                    
                    // Aliens Grid
                    ForEach(aliens) { alien in
                        if alien.isAlive {
                            Text(alien.type == 0 ? "👾" : "👾")
                                .font(.system(size: 12))
                                .position(x: alien.x, y: alien.y)
                        }
                    }
                    
                    // Lasers
                    ForEach(lasers) { laser in
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: 2, height: 6)
                            .position(x: laser.x, y: laser.y)
                    }
                    
                    // Player Cannon (steered by Crown)
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.mint)
                            .frame(width: 4, height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.mint)
                            .frame(width: 20, height: 8)
                    }
                    .position(x: min(max(crownRotation, 15), geo.size.width - 15), y: geo.size.height - 10)
                    
                    // Game Over Screen
                    if isGameOver {
                        VStack(spacing: 4) {
                            Text(i18n.isTurkish ? "ÜS DÜŞTÜ!" : "BASE DESTROYED")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.red)
                            Text("\(score) PTS")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Button(action: {
                                restartGame()
                            }) {
                                Text(i18n.isTurkish ? "YENİDEN DENE" : "RETRY")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.mint)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(8)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isGameOver {
                        fireLaser(cannonX: min(max(crownRotation, 15), geo.size.width - 15), geoHeight: geo.size.height)
                    }
                }
                .onAppear {
                    spawnWave()
                }
                .onReceive(timer) { _ in
                    if !isGameOver {
                        updateGame(geoWidth: geo.size.width, geoHeight: geo.size.height)
                    }
                }
            }
            .focusable()
            .digitalCrownRotation($crownRotation, from: 10, through: 160, by: 4, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoSheet(game: gameInfo)
        }
    }
    
    private func spawnWave() {
        aliens.removeAll()
        lasers.removeAll()
        var idCounter = 0
        for row in 0..<3 {
            for col in 0..<5 {
                aliens.append(AlienInvader(
                    id: idCounter,
                    x: Double(28 + col * 26),
                    y: Double(28 + row * 20),
                    isAlive: true,
                    type: row % 2
                ))
                idCounter += 1
            }
        }
    }
    
    private func fireLaser(cannonX: Double, geoHeight: Double) {
        lasers.append(LaserBeam(x: cannonX, y: geoHeight - 16))
        HapticManager.shared.play(.click)
    }
    
    private func updateGame(geoWidth: Double, geoHeight: Double) {
        // Move Lasers
        for i in (0..<lasers.count).reversed() {
            lasers[i].y -= 6
            if lasers[i].y < 0 {
                lasers.remove(at: i)
                continue
            }
            
            // Collision with aliens
            let lx = lasers[i].x
            let ly = lasers[i].y
            for aIdx in 0..<aliens.count {
                if aliens[aIdx].isAlive {
                    let ax = aliens[aIdx].x
                    let ay = aliens[aIdx].y
                    if abs(lx - ax) < 12 && abs(ly - ay) < 10 {
                        aliens[aIdx].isAlive = false
                        lasers.remove(at: i)
                        score += 20
                        HapticManager.shared.play(.tap)
                        break
                    }
                }
            }
        }
        
        // UFO Movement
        if ufoActive {
            ufoX += 2.5
            if ufoX > geoWidth + 30 {
                ufoActive = false
            }
        } else if Int.random(in: 1...120) == 1 {
            ufoActive = true
            ufoX = -20
        }
        
        // Check Wave Clear
        if aliens.allSatisfy({ !$0.isAlive }) {
            wave += 1
            score += 100
            HapticManager.shared.play(.success)
            spawnWave()
        }
        
        // Descend aliens
        if Int.random(in: 1...30) == 1 {
            for i in 0..<aliens.count {
                if aliens[i].isAlive {
                    aliens[i].y += 3
                    if aliens[i].y >= geoHeight - 20 {
                        isGameOver = true
                        HapticManager.shared.play(.warning)
                        scoreManager.recordScore(score, for: "galaxydefender")
                    }
                }
            }
        }
    }
    
    private func restartGame() {
        score = 0
        wave = 1
        isGameOver = false
        crownRotation = 80.0
        spawnWave()
    }
}
