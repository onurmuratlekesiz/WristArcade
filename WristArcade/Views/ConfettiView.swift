import SwiftUI

struct ConfettiPiece: Identifiable {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var rotation: Double
    var speedY: CGFloat
    var speedX: CGFloat
}

public struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    @State private var timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    @State private var opacity: Double = 1.0
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { p in
                    Rectangle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size * 0.6)
                        .rotationEffect(.degrees(p.rotation))
                        .position(x: p.x, y: p.y)
                }
            }
            .opacity(opacity)
            .onAppear {
                spawnConfetti(in: geo.size)
            }
            .onReceive(timer) { _ in
                updatePhysics(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func spawnConfetti(in size: CGSize) {
        let colors: [Color] = [.yellow, .orange, .cyan, .green, .pink, .purple]
        var newPieces: [ConfettiPiece] = []
        for _ in 0..<35 {
            let p = ConfettiPiece(
                x: CGFloat.random(in: 10...size.width - 10),
                y: CGFloat.random(in: -20...10),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...8),
                rotation: Double.random(in: 0...360),
                speedY: CGFloat.random(in: 2...5),
                speedX: CGFloat.random(in: -1.5...1.5)
            )
            newPieces.append(p)
        }
        pieces = newPieces
        
        // Fade out after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 0
            }
        }
    }
    
    private func updatePhysics(in size: CGSize) {
        for i in pieces.indices {
            pieces[i].y += pieces[i].speedY
            pieces[i].x += pieces[i].speedX
            pieces[i].rotation += 6.0
        }
    }
}
