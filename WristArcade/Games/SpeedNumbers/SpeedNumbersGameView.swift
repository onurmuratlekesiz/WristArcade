import SwiftUI

struct NumberTile: Identifiable {
    let id: Int
    let value: Int
    var isTapped: Bool = false
    var isWrongFlash: Bool = false
}

public struct SpeedNumbersGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var i18n = LocalizationManager.shared
    
    @State private var tiles: [NumberTile] = []
    @State private var currentTarget: Int = 1
    @State private var startTime: Date? = nil
    @State private var elapsedTime: Double = 0.0
    @State private var timerActive: Bool = false
    @State private var isFinished: Bool = false
    @State private var finalTime: Double = 0.0
    @State private var showingInfo: Bool = false
    
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let gameInfo = ArcadeCatalog.allGames.first(where: { $0.id == "speednumbers" })!
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                // Header
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
                    
                    Text(i18n.isTurkish ? "HIZLI 1-9" : "SPEED 1-9")
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
                
                // Status Bar (Next Target / Stopwatch / Record)
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(i18n.isTurkish ? "SIRADAKİ" : "NEXT")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        Text(isFinished ? "✓" : "\(currentTarget)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.cyan)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Text(i18n.t("time").uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        Text(String(format: "%.2fs", isFinished ? finalTime : elapsedTime))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(isFinished ? .green : .white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(i18n.t("best").uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                        let bestMs = scoreManager.getHighScore(for: "speednumbers")
                        Text(bestMs > 0 ? String(format: "%.2fs", Double(bestMs) / 1000.0) : "--")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 6)
                
                if isFinished {
                    // Win state
                    VStack(spacing: 4) {
                        Text(i18n.t("you_win"))
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.green)
                        Text(String(format: "%.2f saniye!", finalTime))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        
                        Button(action: {
                            restartGame()
                        }) {
                            Text(i18n.t("tap_to_restart"))
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 26)
                                .background(Color.cyan)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.top, 2)
                    }
                    .padding(.vertical, 8)
                } else {
                    // 3x3 Shuffled Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                        ForEach(0..<tiles.count, id: \.self) { idx in
                            let tile = tiles[idx]
                            Button(action: {
                                handleTap(index: idx)
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(tile.isTapped ? Color.green.opacity(0.15) : (tile.isWrongFlash ? Color.red.opacity(0.3) : Color.white.opacity(0.1)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(tile.isTapped ? Color.green.opacity(0.4) : (tile.isWrongFlash ? Color.red : Color.cyan.opacity(0.2)), lineWidth: 1)
                                        )
                                    
                                    if tile.isTapped {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.green)
                                    } else {
                                        Text("\(tile.value)")
                                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                                            .foregroundColor(tile.isWrongFlash ? .red : .white)
                                    }
                                }
                                .frame(height: 38)
                            }
                            .buttonStyle(.plain)
                            .disabled(tile.isTapped)
                        }
                    }
                    .padding(.horizontal, 6)
                }
            }
            .padding(.bottom, 6)
        }
        .onAppear {
            restartGame()
        }
        .onReceive(timer) { _ in
            if timerActive, let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
        .sheet(isPresented: $showingInfo) {
            GameInfoSheet(game: gameInfo)
        }
    }
    
    private func restartGame() {
        let nums = Array(1...9).shuffled()
        tiles = nums.enumerated().map { NumberTile(id: $0.offset, value: $0.element) }
        currentTarget = 1
        startTime = nil
        elapsedTime = 0.0
        timerActive = false
        isFinished = false
        finalTime = 0.0
        HapticManager.shared.play(.tap)
    }
    
    private func handleTap(index: Int) {
        guard !isFinished else { return }
        
        // Start timer on first tap
        if !timerActive {
            startTime = Date()
            timerActive = true
        }
        
        let tappedVal = tiles[index].value
        if tappedVal == currentTarget {
            // Correct tap!
            tiles[index].isTapped = true
            HapticManager.shared.play(.click)
            
            if currentTarget == 9 {
                // Completed 1 to 9!
                timerActive = false
                isFinished = true
                finalTime = elapsedTime
                let ms = Int(finalTime * 1000)
                _ = scoreManager.recordScore(ms, for: "speednumbers")
                HapticManager.shared.play(.victory)
            } else {
                currentTarget += 1
            }
        } else {
            // Wrong tap! Penalty
            tiles[index].isWrongFlash = true
            elapsedTime += 0.5 // 0.5s penalty
            HapticManager.shared.play(.failure)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if index < tiles.count {
                    tiles[index].isWrongFlash = false
                }
            }
        }
    }
}
