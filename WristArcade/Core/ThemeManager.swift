import SwiftUI

/// Available display themes for WristArcade
public enum ArcadeTheme: String, CaseIterable, Identifiable {
    case cyberpunk = "cyberpunk"
    case gameboy = "gameboy"
    case amber = "amber"
    case oled = "oled"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .cyberpunk: return "Cyberpunk Neon"
        case .gameboy: return "GameBoy DMG '89"
        case .amber: return "Amber CRT '82"
        case .oled: return "OLED Stealth Black"
        }
    }
    
    public var backgroundColor: Color {
        switch self {
        case .cyberpunk: return Color(red: 0.05, green: 0.05, blue: 0.12)
        case .gameboy: return Color(red: 0.60, green: 0.74, blue: 0.35)
        case .amber: return Color(red: 0.08, green: 0.04, blue: 0.01)
        case .oled: return Color.black
        }
    }
    
    public var primaryAccent: Color {
        switch self {
        case .cyberpunk: return Color.cyan
        case .gameboy: return Color(red: 0.06, green: 0.22, blue: 0.06)
        case .amber: return Color(red: 1.00, green: 0.69, blue: 0.00)
        case .oled: return Color.white
        }
    }
    
    public var secondaryAccent: Color {
        switch self {
        case .cyberpunk: return Color(red: 1.0, green: 0.18, blue: 0.58)
        case .gameboy: return Color(red: 0.19, green: 0.38, blue: 0.19)
        case .amber: return Color(red: 0.85, green: 0.50, blue: 0.00)
        case .oled: return Color(white: 0.6)
        }
    }
    
    public var cardBackground: Color {
        switch self {
        case .cyberpunk: return Color.white.opacity(0.08)
        case .gameboy: return Color(red: 0.55, green: 0.68, blue: 0.32)
        case .amber: return Color(red: 0.18, green: 0.10, blue: 0.02)
        case .oled: return Color(white: 0.12)
        }
    }

    public var accentColor: Color {
        primaryAccent
    }
}

/// Manages active visual theme persistence
public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @Published public var currentTheme: ArcadeTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "arcade_theme")
        }
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: "arcade_theme") ?? "cyberpunk"
        self.currentTheme = ArcadeTheme(rawValue: saved) ?? .cyberpunk
    }
}
