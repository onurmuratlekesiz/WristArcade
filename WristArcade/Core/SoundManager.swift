import Foundation
import WatchKit
import AVFoundation

/// Retro 8-bit sound effects types for WristArcade games
public enum GameSoundType {
    case tap
    case click
    case flip
    case point
    case victory
    case gameOver
    case gameover
    case laser
    case explosion
    case powerup
    case cardDeal
}

/// Provides 8-bit retro sound effects for watchOS with user toggle and volume settings.
public final class SoundManager: ObservableObject {
    public static let shared = SoundManager()
    
    @Published public var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "sound_enabled")
        }
    }
    
    private init() {
        if UserDefaults.standard.object(forKey: "sound_enabled") == nil {
            self.isSoundEnabled = true
        } else {
            self.isSoundEnabled = UserDefaults.standard.bool(forKey: "sound_enabled")
        }
    }
    
    /// Plays an arcade sound effect
    public func play(_ sound: GameSoundType) {
        guard isSoundEnabled else { return }
        
        // Use WKInterfaceDevice audio cues as primary ultra-low-latency watch sound
        let device = WKInterfaceDevice.current()
        switch sound {
        case .tap, .click, .flip, .cardDeal:
            device.play(.click)
        case .point:
            device.play(.directionUp)
        case .victory, .powerup:
            device.play(.success)
        case .gameOver, .gameover:
            device.play(.failure)
        case .laser:
            device.play(.directionDown)
        case .explosion:
            device.play(.retry)
        }
    }
}
