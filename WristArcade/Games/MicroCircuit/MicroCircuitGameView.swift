//
//  MicroCircuitGameView.swift
//  WristArcade
//
//  Created for WristArcade 60 Games Diamond Edition.
//  Top-down retro micro racer with Digital Crown & CoreMotion wrist tilt steering.
//

import SwiftUI

public struct MicroCircuitGameView: View {
    @StateObject private var motion = MotionManager.shared
    @State private var crownRotation: Double = 0.0
    @State private var carAngle: Double = 0.0 // heading in radians
    @State private var carX: Double = 90.0
    @State private var carY: Double = 140.0
    @State private var speed: Double = 0.0
    @State private var isAccelerating: Bool = false
    @State private var currentLap: Int = 1
    @State private var lapTime: Double = 0.0
    @State private var bestLap: Double = 0.0
    @State private var checkpointsCrossed: Set<Int> = []
    @State private var isGameOver: Bool = false
    @State private var lapNotification: String? = nil
    
    @State private var timer: Timer?
    @State private var useTilt: Bool = true
    
    // Oval track dimensions
    private let trackCenterX: Double = 95.0
    private let trackCenterY: Double = 105.0
    private let outerRadiusX: Double = 75.0
    private let outerRadiusY: Double = 55.0
    private let innerRadiusX: Double = 35.0
    private let innerRadiusY: Double = 25.0
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Track Canvas
                Canvas { context, size in
                    // Asphalt Background
                    let outerRect = CGRect(x: trackCenterX - outerRadiusX, y: trackCenterY - outerRadiusY, width: outerRadiusX * 2, height: outerRadiusY * 2)
                    let innerRect = CGRect(x: trackCenterX - innerRadiusX, y: trackCenterY - innerRadiusY, width: innerRadiusX * 2, height: innerRadiusY * 2)
                    
                    context.fill(Path(ellipseIn: outerRect), with: .color(Color(white: 0.15)))
                    context.stroke(Path(ellipseIn: outerRect), with: .color(Color.orange.opacity(0.8)), lineWidth: 3)
                    
                    // Infield Grass
                    context.fill(Path(ellipseIn: innerRect), with: .color(Color(red: 0.05, green: 0.15, blue: 0.08)))
                    context.stroke(Path(ellipseIn: innerRect), with: .color(Color.white.opacity(0.5)), lineWidth: 2)
                    
                    // Start / Finish Line
                    let finishLine = Path { p in
                        p.move(to: CGPoint(x: trackCenterX, y: trackCenterY + innerRadiusY))
                        p.addLine(to: CGPoint(x: trackCenterX, y: trackCenterY + outerRadiusY))
                    }
                    context.stroke(finishLine, with: .color(.yellow), style: StrokeStyle(lineWidth: 3, dash: [4, 4]))
                }
                
                // Player Car
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orange)
                        .frame(width: 14, height: 8)
                        .overlay(
                            Rectangle()
                                .fill(Color.cyan)
                                .frame(width: 4, height: 6)
                                .offset(x: 2),
                            alignment: .center
                        )
                }
                .rotationEffect(.radians(carAngle))
                .position(x: carX, y: carY)
                .shadow(color: .orange.opacity(0.8), radius: 4)
                
                // HUD Header
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("LAP \(currentLap)/3")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                            Text(String(format: "%.2fs", lapTime))
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("BEST")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            Text(bestLap > 0 ? String(format: "%.2fs", bestLap) : "--.--")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    
                    if let note = lapNotification {
                        Text(note)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.black.opacity(0.85)))
                            .transition(.scale)
                    }
                    
                    Spacer()
                    
                    // Gas / Accel Controls
                    HStack(spacing: 12) {
                        Button(action: {
                            useTilt.toggle()
                            HapticManager.shared.play(.click)
                        }) {
                            Image(systemName: useTilt ? "gyroscope" : "crown.fill")
                                .font(.system(size: 11))
                                .foregroundColor(useTilt ? .green : .cyan)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(Color.white.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                        
                        // Accel Trigger
                        Text("GAS")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(isAccelerating ? Color.green : Color.orange)
                            .cornerRadius(16)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !isAccelerating {
                                            isAccelerating = true
                                            HapticManager.shared.play(.directionUp)
                                            SoundManager.shared.play(.click)
                                        }
                                    }
                                    .onEnded { _ in
                                        isAccelerating = false
                                    }
                            )
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                }
                
                // Game Over Overlay
                if isGameOver {
                    VStack(spacing: 6) {
                        Text("RACE COMPLETE!")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                        Text("Best: \(String(format: "%.2fs", bestLap))")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Button(action: restartRace) {
                            Text("DRIVE AGAIN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.orange))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.92)))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange, lineWidth: 1))
                }
            }
            .focusable()
            .digitalCrownRotation($crownRotation, from: -Double.infinity, through: Double.infinity, by: 1.0, sensitivity: .high, isContinuous: true, isHapticFeedbackEnabled: false)
            .onAppear {
                bestLap = Double(ScoreManager.shared.getHighScore(for: "microcircuit")) / 100.0
                startSimulation()
                motion.startTiltUpdates()
            }
            .onDisappear {
                stopSimulation()
                motion.stopTiltUpdates()
            }
        }
    }
    
    private func startSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            updatePhysics()
        }
    }
    
    private func stopSimulation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updatePhysics() {
        guard !isGameOver else { return }
        
        // Steering: combine Crown rotation and CoreMotion tilt
        if useTilt {
            let tiltSteer = motion.roll * 0.12
            carAngle += tiltSteer
        }
        
        // Crown input changes car angle
        let deltaCrown = crownRotation * 0.08
        if abs(deltaCrown) > 0.001 {
            carAngle += deltaCrown
            crownRotation = 0.0
        }
        
        // Acceleration & Friction
        if isAccelerating {
            speed = min(3.8, speed + 0.15)
        } else {
            speed = max(0.0, speed - 0.06)
        }
        
        // Move car forward along heading
        let nextX = carX + cos(carAngle) * speed
        let nextY = carY + sin(carAngle) * speed
        
        // Check if car is on track (between inner and outer ellipse)
        let dx = nextX - trackCenterX
        let dy = nextY - trackCenterY
        let outerDist = (dx * dx) / (outerRadiusX * outerRadiusX) + (dy * dy) / (outerRadiusY * outerRadiusY)
        let innerDist = (dx * dx) / (innerRadiusX * innerRadiusX) + (dy * dy) / (innerRadiusY * innerRadiusY)
        
        if outerDist > 1.05 || innerDist < 0.95 {
            // Off track grass penalty!
            speed = max(0.8, speed * 0.7)
            HapticManager.shared.play(.click)
        }
        
        carX = nextX
        carY = nextY
        
        // Lap Timer
        if speed > 0.1 {
            lapTime += 0.03
        }
        
        // Checkpoints detection around the oval
        if nextX > trackCenterX + 25 && nextY < trackCenterY {
            checkpointsCrossed.insert(1)
        } else if nextX < trackCenterX - 25 && nextY < trackCenterY {
            checkpointsCrossed.insert(2)
        } else if nextX < trackCenterX - 25 && nextY > trackCenterY {
            checkpointsCrossed.insert(3)
        }
        
        // Finish line crossed (bottom center moving counter-clockwise)
        if checkpointsCrossed.count >= 3 && abs(nextX - trackCenterX) < 12 && nextY > trackCenterY + 15 {
            checkpointsCrossed.removeAll()
            
            // New Lap Complete
            HapticManager.shared.play(.success)
            SoundManager.shared.play(.point)
            
            if bestLap == 0.0 || lapTime < bestLap {
                bestLap = lapTime
                ScoreManager.shared.saveHighScore(Int(bestLap * 100), for: "microcircuit")
                lapNotification = "⚡ NEW BEST!"
            } else {
                lapNotification = "LAP \(currentLap) DONE"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                lapNotification = nil
            }
            
            if currentLap >= 3 {
                isGameOver = true
                SoundManager.shared.play(.victory)
                ScoreManager.shared.addXP(150)
            } else {
                currentLap += 1
                lapTime = 0.0
            }
        }
    }
    
    private func restartRace() {
        carX = trackCenterX
        carY = trackCenterY + (innerRadiusY + outerRadiusY) / 2
        carAngle = 0.0
        speed = 0.0
        currentLap = 1
        lapTime = 0.0
        checkpointsCrossed.removeAll()
        isGameOver = false
        lapNotification = nil
        HapticManager.shared.play(.start)
    }
}
