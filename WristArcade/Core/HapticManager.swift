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
        self
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
