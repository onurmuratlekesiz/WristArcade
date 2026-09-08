import SwiftUI

struct TrafficCar: Identifiable {
    let id: UUID = UUID()
    var lane: Int // 0: Left, 1: Center, 2: Right
    var yPos: CGFloat // 0 (top) to 130 (bottom)
    var isNitro: Bool
}

public struct HighwayRacerGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var playerLane: Int = 1 // Center lane start
    @State private var crownValue: Double = 0
    @State private var traffic: [TrafficCar] = []
    @State private var distanceTraveled: Int = 0
    @State private var nitroUnits: Int = 0
    @State private var isNitroActive: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isPlaying: Bool = false
    @State private var showingInfo: Bool = false
    
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "highwayracer" })!
    
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
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
                
                Text(i18n.isTurkish ? "OTOYOL YARIŞÇISI" : "HIGHWAY RACER")
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
            
            // HUD: Distance & Nitro
            HStack {
                Text("\(distanceTraveled)m")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white)
                
                Spacer()
                
                if nitroUnits > 0 {
                    Button(action: activateNitro) {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 9))
                            Text("NITRO x\(nitroUnits)")
                                .font(.system(size: 9, weight: .black))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isNitroActive ? Color.cyan : Color.yellow)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            
            // Highway 3-Lane Road Track
            ZStack {
                // Dark Asphalt Track
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isNitroActive ? Color.cyan : Color.yellow.opacity(0.4), lineWidth: 2)
                    )
                
                // Lane dividers
                HStack {
                    Spacer()
                    DashedLine()
                        .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                    Spacer()
                    DashedLine()
                        .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                    Spacer()
                }
                
                // Traffic & Items
                ForEach(traffic) { item in
                    GeometryReader { geo in
                        let laneWidth = geo.size.width / 3.0
                        let x = CGFloat(item.lane) * laneWidth + laneWidth / 2.0
                        
                        Group {
                            if item.isNitro {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.yellow)
                            } else {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.red)
                                    .frame(width: laneWidth * 0.55, height: 26)
                                    .overlay(
                                        VStack {
                                            Circle().fill(Color.yellow).frame(width: 4, height: 4)
                                            Spacer()
                                            Circle().fill(Color.red).frame(width: 4, height: 4)
                                        }
                                        .padding(2)
                                    )
                            }
                        }
                        .position(x: x, y: item.yPos)
                    }
                }
                
                // Player Car
                GeometryReader { geo in
                    let laneWidth = geo.size.width / 3.0
                    let x = CGFloat(playerLane) * laneWidth + laneWidth / 2.0
                    let y = geo.size.height - 20
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isNitroActive ? Color.cyan : Color.yellow)
                        .frame(width: laneWidth * 0.6, height: 28)
                        .overlay(
                            VStack {
                                Circle().fill(Color.white).frame(width: 4, height: 4)
                                Spacer()
                                Rectangle().fill(Color.black.opacity(0.6)).frame(height: 6)
                                Spacer()
                                Circle().fill(Color.red).frame(width: 4, height: 4)
                            }
                            .padding(2)
                        )
                        .position(x: x, y: y)
                        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: playerLane)
                }
                
                // Left / Right Touch Overlay Controls
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            shiftLane(left: true)
                        }
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            shiftLane(left: false)
                        }
                }
                
                // Game Over Overlay
                if isGameOver {
                    VStack(spacing: 4) {
                        Text(i18n.isTurkish ? "KAZA YAPTIN!" : "CRASHED!")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.red)
                        Text(i18n.isTurkish ? "Mesafe: \(distanceTraveled)m" : "Distance: \(distanceTraveled)m")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                        Button(action: startGame) {
                            Text(i18n.isTurkish ? "TEKRAR OYNA" : "PLAY AGAIN")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.8))
                } else if !isPlaying {
                    Button(action: startGame) {
                        Text(i18n.isTurkish ? "BAŞLA" : "START DRIVE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.yellow)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 120)
        }
        .padding(.horizontal, 4)
        .focusable()
        .digitalCrownRotation($crownValue, from: -100, through: 100, by: 1.0, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
        .onChange(of: crownValue) { val in
            if val > 3 && playerLane < 2 {
                playerLane += 1
                crownValue = 0
                HapticManager.shared.play(.tap)
            } else if val < -3 && playerLane > 0 {
                playerLane -= 1
                crownValue = 0
                HapticManager.shared.play(.tap)
            }
        }
        .onReceive(timer) { _ in
            gameLoop()
        }
        .sheet(isPresented: $showingInfo) {
            GameTutorialSheetView(game: gameInfo)
        }
    }
    
    private func shiftLane(left: Bool) {
        guard isPlaying, !isGameOver else { return }
        HapticManager.shared.play(.tap)
        if left && playerLane > 0 {
            playerLane -= 1
        } else if !left && playerLane < 2 {
            playerLane += 1
        }
    }
    
    private func startGame() {
        isPlaying = true
        isGameOver = false
        distanceTraveled = 0
        nitroUnits = 0
        isNitroActive = false
        traffic = []
        playerLane = 1
        crownValue = 0
    }
    
    private func activateNitro() {
        guard nitroUnits > 0, !isNitroActive else { return }
        HapticManager.shared.play(.success)
        nitroUnits -= 1
        isNitroActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isNitroActive = false
        }
    }
    
    private func gameLoop() {
        guard isPlaying, !isGameOver else { return }
        
        let speed: CGFloat = isNitroActive ? 8.0 : 4.0
        distanceTraveled += isNitroActive ? 3 : 1
        
        // Spawn traffic
        if Int.random(in: 0...100) < 6 {
            let freeLane = Int.random(in: 0...2)
            let isNitroBonus = Int.random(in: 0...10) == 0
            traffic.append(TrafficCar(lane: freeLane, yPos: -20, isNitro: isNitroBonus))
        }
        
        // Move traffic down
        for i in traffic.indices {
            traffic[i].yPos += speed
        }
        
        // Check collisions & item pickups
        var indicesToRemove: [Int] = []
        for (idx, item) in traffic.enumerated() {
            if item.yPos >= 90 && item.yPos <= 120 && item.lane == playerLane {
                if item.isNitro {
                    HapticManager.shared.play(.tap)
                    nitroUnits = min(3, nitroUnits + 1)
                    indicesToRemove.append(idx)
                } else if !isNitroActive {
                    // Collision!
                    HapticManager.shared.play(.failure)
                    isGameOver = true
                    if distanceTraveled > scoreManager.highScore(for: "highwayracer") {
                        scoreManager.saveHighScore(distanceTraveled, for: "highwayracer")
                    }
                    return
                }
            } else if item.yPos > 140 {
                indicesToRemove.append(idx)
            }
        }
        
        for idx in indicesToRemove.reversed() {
            if idx < traffic.count {
                traffic.remove(at: idx)
            }
        }
    }
}

struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
