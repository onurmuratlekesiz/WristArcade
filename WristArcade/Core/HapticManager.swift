import WatchKit
import Foundation

/// Provides standardized haptic feedback across all games using Apple Watch Taptic Engine.
public enum GameHapticType {
    case tap
    case crownTick
    case bounce
    case score
    case combo
    case victory
    case gameOver
    case error
    case warning
}

public final class HapticManager {
    public static let shared = HapticManager()
    
    private init() {}
    
    /// Trigger a specific game haptic feedback if enabled in user preferences
    public func play(_ type: GameHapticType) {
        guard UserDefaults.standard.bool(forKey: "haptics_enabled") != false else { return }
        
        let device = WKInterfaceDevice.current()
        switch type {
        case .tap:
            device.play(.click)
        case .crownTick:
            device.play(.directionUp)
        case .bounce:
            device.play(.click)
        case .score:
            device.play(.directionDown)
        case .combo:
            device.play(.success)
        case .victory:
            device.play(.success)
        case .gameOver:
            device.play(.failure)
        case .error:
            device.play(.retry)
        case .warning:
            device.play(.notification)
        }
    }
}
