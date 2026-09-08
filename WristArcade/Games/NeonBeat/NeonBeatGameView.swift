import SwiftUI

public struct NeonBeatGameView: View {
    @State private var score: Int = 0
    @State private var combo: Int = 0
    @State private var lives: Int = 3
    @State private var isGameOver: Bool = false
    
    struct BeatNote: Identifiable {
        let id = UUID()
        var lane: Int // 0 = left, 1 = right
        var y: CGFloat
    }
    
    @State private var notes: [BeatNote] = []
    @State private var timer: Timer? = nil
    
    @StateObject private var haptic = HapticManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Skor: \(score)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
                Spacer()
                if combo > 1 {
                    Text("\(combo)x KOMBO! 🔥")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.yellow)
                }
                Spacer()
                Text(String(repeating: "❤️", count: lives))
                    .font(.system(size: 8))
            }
            .padding(.horizontal, 6)
            
            // 2-Lane Highway Viewport
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    
                    // Dividing Center Line
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1)
                    
                    // Hit Target Bar near bottom (y: 85)
                    Rectangle()
                        .fill(Color.cyan.opacity(0.35))
                        .frame(height: 6)
                        .position(x: geo.size.width / 2, y: 85)
                    
                    // Notes
                    ForEach(notes) { note in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(note.lane == 0 ? Color.cyan : Color.pink)
                            .frame(width: 44, height: 12)
                            .position(x: note.lane == 0 ? geo.size.width * 0.28 : geo.size.width * 0.72, y: note.y)
                    }
                    
                    if isGameOver {
                        VStack(spacing: 4) {
                            Text("RİTİM BİTTİ!")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(.red)
                            Text("Toplam Skor: \(score)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                            Button("TEKRAR DENE") { restartGame() }
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .frame(height: 105)
            
            // 2 Tap Buttons (Left / Right)
            HStack(spacing: 6) {
                Button(action: { tapLane(0) }) {
                    Text("SOL")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(Color.cyan)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isGameOver)
                
                Button(action: { tapLane(1) }) {
                    Text("SAĞ")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(Color.pink)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isGameOver)
            }
            .padding(.horizontal, 6)
        }
        .navigationTitle("Neon Beat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startGame() }
        .onDisappear { timer?.invalidate() }
    }
    
    private func startGame() {
        score = 0
        combo = 0
        lives = 3
        isGameOver = false
        notes = []
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { _ in
            guard !isGameOver else { return }
            
            // Spawn note
            if Double.random(in: 0...1) < 0.12 {
                let lane = Int.random(in: 0...1)
                notes.append(BeatNote(lane: lane, y: 0))
            }
            
            // Move notes down
            for i in notes.indices {
                notes[i].y += 3.5
            }
            
            // Missed notes (passed y: 100)
            if let missed = notes.first(where: { $0.y > 100 }) {
                notes.removeAll { $0.id == missed.id }
                combo = 0
                lives -= 1
                haptic.play(.warning)
                if lives <= 0 {
                    gameOver()
                }
            }
        }
    }
    
    private func tapLane(_ lane: Int) {
        guard !isGameOver else { return }
        
        // Check if there is a note in this lane near y: 85 (tolerance: 65 to 100)
        if let hitIndex = notes.firstIndex(where: { $0.lane == lane && $0.y >= 65 && $0.y <= 100 }) {
            notes.remove(at: hitIndex)
            combo += 1
            let pts = 10 * max(1, combo)
            score += pts
            haptic.play(.tap)
        } else {
            // Bad tap
            combo = 0
            haptic.play(.click)
        }
    }
    
    private func gameOver() {
        isGameOver = true
        timer?.invalidate()
        haptic.play(.victory)
        _ = scoreManager.recordScore(score, for: "neonbeat")
    }
    
    private func restartGame() {
        startGame()
    }
}
