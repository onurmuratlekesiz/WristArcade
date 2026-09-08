import SwiftUI

public struct ColorMemoryGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    enum ColorButton: Int, CaseIterable {
        case green = 0
        case red = 1
        case yellow = 2
        case blue = 3
        
        var baseColor: Color {
            switch self {
            case .green: return Color.green
            case .red: return Color.red
            case .yellow: return Color.yellow
            case .blue: return Color.blue
            }
        }
    }
    
    @State private var sequence: [ColorButton] = []
    @State private var userStep: Int = 0
    @State private var activeFlashing: ColorButton? = nil
    
    @State private var isShowingSequence: Bool = false
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    @State private var round: Int = 0
    
    public var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) - 16
            let btnSize = (size - 8) / 2
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    VStack(spacing: 4) {
                        // Header
                        HStack {
                            Text("ROUND \(round)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.purple)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "colormemory"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        
                        // 2x2 Buttons
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                colorPadButton(.green, size: btnSize)
                                colorPadButton(.red, size: btnSize)
                            }
                            HStack(spacing: 6) {
                                colorPadButton(.yellow, size: btnSize)
                                colorPadButton(.blue, size: btnSize)
                            }
                        }
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "WRONG ORDER!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Rounds: \(round)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: startNewGame) {
                            Text("RETRY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.purple)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 26))
                            .foregroundColor(.purple)
                        
                        Text("COLOR SEQUENCE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Remember & repeat the light pattern")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.purple)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func colorPadButton(_ button: ColorButton, size: CGFloat) -> some View {
        let isLit = activeFlashing == button
        Button(action: {
            handleUserTap(button)
        }) {
            RoundedRectangle(cornerRadius: 12)
                .fill(button.baseColor.opacity(isLit ? 1.0 : 0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(isLit ? 0.9 : 0.15), lineWidth: 2)
                )
                .frame(width: size, height: size)
                .shadow(color: isLit ? button.baseColor : .clear, radius: 8)
        }
        .buttonStyle(.plain)
        .disabled(isShowingSequence)
    }
    
    private func startNewGame() {
        sequence = []
        round = 0
        userStep = 0
        isGameOver = false
        isNewRecord = false
        isPlaying = true
        addNewStep()
    }
    
    private func addNewStep() {
        round += 1
        let nextColor = ColorButton.allCases.randomElement()!
        sequence.append(nextColor)
        userStep = 0
        playSequence()
    }
    
    private func playSequence() {
        isShowingSequence = true
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            for color in sequence {
                activeFlashing = color
                HapticManager.shared.play(.tap)
                try? await Task.sleep(nanoseconds: 400_000_000)
                activeFlashing = nil
                try? await Task.sleep(nanoseconds: 180_000_000)
            }
            isShowingSequence = false
        }
    }
    
    private func handleUserTap(_ tapped: ColorButton) {
        guard !isShowingSequence else { return }
        
        activeFlashing = tapped
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if activeFlashing == tapped { activeFlashing = nil }
        }
        
        if tapped == sequence[userStep] {
            HapticManager.shared.play(.tap)
            userStep += 1
            if userStep == sequence.count {
                // Completed round
                HapticManager.shared.play(.score)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    addNewStep()
                }
            }
        } else {
            // Failed
            isPlaying = false
            isGameOver = true
            isNewRecord = scoreManager.recordScore(round - 1, for: "colormemory")
            HapticManager.shared.play(.gameOver)
        }
    }
}
