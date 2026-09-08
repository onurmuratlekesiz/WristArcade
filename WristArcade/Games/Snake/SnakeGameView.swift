import SwiftUI

public struct SnakeGameView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    enum Direction {
        case up, right, down, left
        
        func turnedRight() -> Direction {
            switch self {
            case .up: return .right
            case .right: return .down
            case .down: return .left
            case .left: return .up
            }
        }
        
        func turnedLeft() -> Direction {
            switch self {
            case .up: return .left
            case .left: return .down
            case .down: return .right
            case .right: return .up
            }
        }
    }
    
    struct GridPoint: Equatable {
        let x: Int
        let y: Int
    }
    
    private let gridWidth = 14
    private let gridHeight = 15
    
    @State private var snake: [GridPoint] = [GridPoint(x: 7, y: 7), GridPoint(x: 7, y: 8), GridPoint(x: 7, y: 9)]
    @State private var direction: Direction = .up
    @State private var nextDirection: Direction = .up
    @State private var food: GridPoint = GridPoint(x: 5, y: 4)
    
    @State private var score: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewRecord: Bool = false
    
    @State private var crownAccumulator: Double = 0.0
    @State private var crownValue: Double = 0.0
    
    var body: some View {
        GeometryReader { geo in
            let cellWidth = geo.size.width / CGFloat(gridWidth)
            let cellHeight = geo.size.height / CGFloat(gridHeight)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPlaying {
                    // Game Grid
                    Canvas { context, size in
                        // Draw Food
                        let foodRect = CGRect(
                            x: CGFloat(food.x) * cellWidth + 1,
                            y: CGFloat(food.y) * cellHeight + 1,
                            width: cellWidth - 2,
                            height: cellHeight - 2
                        )
                        context.fill(Path(ellipseIn: foodRect), with: .color(.red))
                        
                        // Draw Snake
                        for (index, segment) in snake.enumerated() {
                            let segRect = CGRect(
                                x: CGFloat(segment.x) * cellWidth + 1,
                                y: CGFloat(segment.y) * cellHeight + 1,
                                width: cellWidth - 2,
                                height: cellHeight - 2
                            )
                            let color = index == 0 ? Color.green : Color.green.opacity(0.7)
                            context.fill(Path(roundedRect: segRect, cornerRadius: 2), with: .color(color))
                        }
                    }
                    
                    // Score overlay at top
                    VStack {
                        HStack {
                            Text("\(score)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("\(scoreManager.getHighScore(for: "snake"))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 2)
                        Spacer()
                    }
                } else if isGameOver {
                    VStack(spacing: 6) {
                        Text(isNewRecord ? "NEW RECORD!" : "GAME OVER")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(isNewRecord ? .yellow : .red)
                        
                        Text("Apples: \(score)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("Best: \(scoreManager.getHighScore(for: "snake"))")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                        Button(action: startNewGame) {
                            Text("RETRY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 26))
                            .foregroundColor(.green)
                        
                        Text("CROWN SNAKE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Rotate Crown to turn or swipe")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        
                        Button(action: startNewGame) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 26)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .focusable(true)
            .digitalCrownRotation(
                $crownValue,
                from: -1000.0,
                through: 1000.0,
                by: 1.0,
                sensitivity: .high,
                isContinuous: true,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { newValue in
                let delta = newValue - crownAccumulator
                if delta > 3.0 {
                    nextDirection = direction.turnedRight()
                    crownAccumulator = newValue
                    HapticManager.shared.play(.crownTick)
                } else if delta < -3.0 {
                    nextDirection = direction.turnedLeft()
                    crownAccumulator = newValue
                    HapticManager.shared.play(.crownTick)
                }
            }
            // Swipe gesture support as alternative control
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { gesture in
                        let h = gesture.translation.width
                        let v = gesture.translation.height
                        if abs(h) > abs(v) {
                            if h > 0 && direction != .left { nextDirection = .right }
                            else if h < 0 && direction != .right { nextDirection = .left }
                        } else {
                            if v > 0 && direction != .up { nextDirection = .down }
                            else if v < 0 && direction != .down { nextDirection = .up }
                        }
                    }
            )
            .onReceive(Timer.publish(every: 0.16, on: .main, in: .common).autoconnect()) { _ in
                guard isPlaying else { return }
                gameTick()
            }
        }
    }
    
    private func startNewGame() {
        snake = [GridPoint(x: 7, y: 7), GridPoint(x: 7, y: 8), GridPoint(x: 7, y: 9)]
        direction = .up
        nextDirection = .up
        score = 0
        isGameOver = false
        isNewRecord = false
        spawnFood()
        isPlaying = true
        HapticManager.shared.play(.tap)
    }
    
    private func spawnFood() {
        var available: [GridPoint] = []
        for x in 0..<gridWidth {
            for y in 0..<gridHeight {
                let p = GridPoint(x: x, y: y)
                if !snake.contains(p) {
                    available.append(p)
                }
            }
        }
        if let randomPoint = available.randomElement() {
            food = randomPoint
        }
    }
    
    private func gameTick() {
        direction = nextDirection
        let head = snake[0]
        var newHead = head
        
        switch direction {
        case .up: newHead = GridPoint(x: head.x, y: head.y - 1)
        case .down: newHead = GridPoint(x: head.x, y: head.y + 1)
        case .left: newHead = GridPoint(x: head.x - 1, y: head.y)
        case .right: newHead = GridPoint(x: head.x + 1, y: head.y)
        }
        
        // Check wall collision
        if newHead.x < 0 || newHead.x >= gridWidth || newHead.y < 0 || newHead.y >= gridHeight {
            triggerGameOver()
            return
        }
        
        // Check self collision
        if snake.contains(newHead) {
            triggerGameOver()
            return
        }
        
        snake.insert(newHead, at: 0)
        
        // Check food collision
        if newHead == food {
            score += 1
            HapticManager.shared.play(.score)
            spawnFood()
        } else {
            snake.removeLast()
        }
    }
    
    private func triggerGameOver() {
        isPlaying = false
        isGameOver = true
        isNewRecord = scoreManager.recordScore(score, for: "snake")
        HapticManager.shared.play(.gameOver)
    }
}
