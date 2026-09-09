#if os(watchOS)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif
import Foundation
import SwiftUI

#if !os(watchOS)
public enum CrownSensitivity {
    case low, medium, high
}

public class WKInterfaceDevice {
    public static func current() -> WKInterfaceDevice { WKInterfaceDevice() }
    public enum WKHapticType {
        case click, directionUp, directionDown, success, failure, retry, start, notification
    }
    public func play(_ type: WKHapticType) {
        #if canImport(UIKit)
        switch type {
        case .click:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .directionUp, .directionDown, .start:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .failure, .retry:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .notification:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        #endif
    }
}

#if !os(watchOS)
public struct DigitalCrownIOSModifier<V: BinaryFloatingPoint>: ViewModifier {
    @Binding var binding: V
    let from: V
    let through: V
    let by: V
    let isContinuous: Bool
    
    @State private var lastDragX: CGFloat = 0
    
    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        let deltaX = value.translation.width - lastDragX
                        lastDragX = value.translation.width
                        
                        let stepFactor = max(0.5, Double(by == 0 ? 1 : by))
                        let range = abs(Double(through) - Double(from))
                        let step: Double
                        if !isContinuous && range > 0.01 && range <= 10.0 {
                            step = (Double(deltaX) / 35.0) * Double(by == 0 ? 1 : by)
                        } else if !isContinuous && range > 500.0 {
                            step = Double(deltaX) * 2.0
                        } else {
                            step = Double(deltaX) * stepFactor * 0.8
                        }
                        
                        var newValue = Double(binding) + step
                        if !isContinuous {
                            let minVal = min(Double(from), Double(through))
                            let maxVal = max(Double(from), Double(through))
                            newValue = max(minVal, min(maxVal, newValue))
                        }
                        binding = V(newValue)
                    }
                    .onEnded { _ in
                        lastDragX = 0
                    }
            )
    }
}

extension View {
    @ViewBuilder
    public func digitalCrownRotation<V: BinaryFloatingPoint>(
        _ binding: Binding<V>,
        from: V = 0,
        through: V = 1,
        by: V = 1,
        sensitivity: CrownSensitivity = .medium,
        isContinuous: Bool = false,
        isHapticFeedbackEnabled: Bool = false
    ) -> some View {
        self.modifier(DigitalCrownIOSModifier(
            binding: binding,
            from: from,
            through: through,
            by: by,
            isContinuous: isContinuous
        ))
    }
}
#endif

/// Provides standardized haptic feedback across all games using Apple Watch Taptic Engine and iOS Taptic Engine.
public enum GameHapticType {
    case tap
    case click
    case crownTick
    case bounce
    case score
    case combo
    case victory
    case gameOver
    case error
    case warning
    case failure
    case success
    case directionUp
    case start
    case impact
}

public final class HapticManager: ObservableObject {
    public static let shared = HapticManager()
    
    private init() {}
    
    /// Trigger a specific game haptic feedback if enabled in user preferences
    public func play(_ type: GameHapticType) {
        guard UserDefaults.standard.bool(forKey: "haptics_enabled") != false else { return }
        
        let device = WKInterfaceDevice.current()
        switch type {
        case .tap, .click, .impact:
            device.play(.click)
        case .crownTick, .directionUp:
            device.play(.directionUp)
        case .bounce:
            device.play(.click)
        case .score:
            device.play(.directionDown)
        case .combo:
            device.play(.success)
        case .victory, .success:
            device.play(.success)
        case .gameOver, .failure:
            device.play(.failure)
        case .error:
            device.play(.retry)
        case .warning:
            device.play(.notification)
        case .start:
            device.play(.start)
        }
    }

    public func playClick() {
        play(.click)
    }

    public func playSuccess() {
        play(.success)
    }

    public func playImpact() {
        play(.click)
    }

    public func playVictory() {
        play(.victory)
    }

    public func playFailure() {
        play(.failure)
    }
}
