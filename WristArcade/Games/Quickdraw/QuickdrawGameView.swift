import SwiftUI

public struct QuickdrawGameView: View {
    @State private var duelPhase: DuelState = .ready
    @State private var reactionTimeMs: Int = 0
    @State private var bestReactionMs: Int = 0
    @State private var startTime: Date? = nil
    @State private var timer: Timer? = nil
    
    enum DuelState {
        case ready, waiting, drawNow, shotSuccess, falseStart
    }
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Kovboy Düellosu")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
                Spacer()
                if bestReactionMs > 0 {
                    Text("En İyi: \(bestReactionMs)ms")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal, 8)
            
            // Standoff Silhouette Box
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColorForPhase)
                
                VStack(spacing: 4) {
                    Text(banditIcon)
                        .font(.system(size: 34))
                    
                    Text(statusTitle)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)
                    
                    if duelPhase == .shotSuccess {
                        Text("\(reactionTimeMs) ms")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                }
            }
            .frame(height: 120)
            .onTapGesture {
                handleTap()
            }
            
            if duelPhase == .ready || duelPhase == .shotSuccess || duelPhase == .falseStart {
                Button(action: startDuel) {
                    Text("DÜELLOYA BAŞLA 🤠")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
            } else {
                Text("Ekrana dokunmak için hazır ol...")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Quickdraw")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var bgColorForPhase: Color {
        switch duelPhase {
        case .ready: return Color.white.opacity(0.08)
        case .waiting: return Color.red.opacity(0.3)
        case .drawNow: return Color.yellow.opacity(0.85)
        case .shotSuccess: return Color.green.opacity(0.5)
        case .falseStart: return Color.red.opacity(0.7)
        }
    }
    
    private var banditIcon: String {
        switch duelPhase {
        case .ready: return "🤠"
        case .waiting: return "👤"
        case .drawNow: return "💥"
        case .shotSuccess: return "💀"
        case .falseStart: return "❌"
        }
    }
    
    private var statusTitle: String {
        switch duelPhase {
        case .ready: return "BAŞLAMAK İÇİN BAS"
        case .waiting: return "BEKLE..."
        case .drawNow: return "ÇEK! 💥"
        case .shotSuccess: return "HAYDUT VURULDU!"
        case .falseStart: return "ERKEN ATEŞ! ❌"
        }
    }
    
    private func startDuel() {
        duelPhase = .waiting
        haptic.play(.click)
        
        let delay = Double.random(in: 1.8...4.0)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            duelPhase = .drawNow
            startTime = Date()
            haptic.play(.victory)
        }
    }
    
    private func handleTap() {
        if duelPhase == .waiting {
            // False start!
            timer?.invalidate()
            duelPhase = .falseStart
            haptic.play(.warning)
            return
        }
        
        if duelPhase == .drawNow, let st = startTime {
            let elapsed = Int(Date().timeIntervalSince(st) * 1000)
            reactionTimeMs = elapsed
            duelPhase = .shotSuccess
            haptic.play(.victory)
            
            if bestReactionMs == 0 || elapsed < bestReactionMs {
                bestReactionMs = elapsed
            }
            
            // Lower time is better
            _ = scoreManager.recordScore(elapsed, for: "quickdraw")
        }
    }
}
