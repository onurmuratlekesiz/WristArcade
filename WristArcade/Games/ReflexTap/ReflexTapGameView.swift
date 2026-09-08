import SwiftUI

public struct ReflexTapGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    enum PlayState {
        case idle
        case waiting
        case ready
        case result(Int)
        case early
    }
    
    @State private var gameState: PlayState = .idle
    @State private var startTime: Date = Date()
    @State private var waitTask: Task<Void, Never>? = nil
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundColor()
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    // Header
                    HStack {
                        Text("REFLEX")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "crown.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                        let best = scoreManager.getHighScore(for: "reflextap")
                        Text(best > 0 ? "\(best)ms" : "--")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    // Main status content
                    switch gameState {
                    case .idle:
                        VStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.yellow)
                            Text("REFLEX TEST")
                                .font(.system(size: 13, weight: .bold))
                            Text("Tap when screen turns Green")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                            Text("TAP TO BEGIN")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                                .padding(.top, 4)
                        }
                    case .waiting:
                        VStack(spacing: 4) {
                            Text("WAIT FOR GREEN...")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.white)
                            Text("Don't tap yet!")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    case .ready:
                        VStack(spacing: 4) {
                            Text("TAP NOW!")
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(.black)
                        }
                    case .result(let ms):
                        VStack(spacing: 4) {
                            Text("\(ms) ms")
                                .font(.system(size: 24, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white)
                            Text(rankString(for: ms))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("Tap to try again")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                    case .early:
                        VStack(spacing: 4) {
                            Text("TOO EARLY!")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(.white)
                            Text("Wait for green before tapping.")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.8))
                            Text("Tap to retry")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.yellow)
                                .padding(.top, 4)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 6)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                handleTap()
            }
        }
    }
    
    private func backgroundColor() -> Color {
        switch gameState {
        case .idle: return Color.black
        case .waiting: return Color.red.opacity(0.85)
        case .ready: return Color.green
        case .result: return Color.black
        case .early: return Color.orange.opacity(0.9)
        }
    }
    
    private func handleTap() {
        switch gameState {
        case .idle, .result, .early:
            startTest()
        case .waiting:
            // False start!
            waitTask?.cancel()
            gameState = .early
            HapticManager.shared.play(.error)
        case .ready:
            let elapsed = Date().timeIntervalSince(startTime)
            let ms = Int(elapsed * 1000)
            gameState = .result(ms)
            _ = scoreManager.recordScore(ms, for: "reflextap")
            HapticManager.shared.play(.victory)
        }
    }
    
    private func startTest() {
        gameState = .waiting
        HapticManager.shared.play(.tap)
        
        let randomDelay = Double.random(in: 1.5...3.8)
        waitTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000_000))
            if !Task.isCancelled {
                startTime = Date()
                gameState = .ready
                HapticManager.shared.play(.tap)
            }
        }
    }
    
    private func rankString(for ms: Int) -> String {
        if ms < 200 { return "⚡ GODLIKE SPEED!" }
        if ms < 260 { return "🚀 LIGHTNING FAST!" }
        if ms < 330 { return "👍 GREAT REFLEXES" }
        if ms < 420 { return "🐢 AVERAGE" }
        return "🦥 SLOWPOKE"
    }
}
