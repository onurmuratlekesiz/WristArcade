//
//  MotionManager.swift
//  WristArcade
//
//  Created for WristArcade 60 Games Diamond Edition.
//  Zero-overhead, battery-friendly CoreMotion gyroscope and accelerometer tilt manager.
//

import Foundation
import CoreMotion
import Combine

public final class MotionManager: ObservableObject {
    public static let shared = MotionManager()
    
    private let motionManager = CMMotionManager()
    
    @Published public var roll: Double = 0.0     // X-axis tilt (-1.0 to 1.0)
    @Published public var pitch: Double = 0.0    // Y-axis tilt (-1.0 to 1.0)
    @Published public var isActive: Bool = false
    @Published public var sensitivity: Double = 1.0 // 0.5x to 2.0x
    
    private init() {
        sensitivity = UserDefaults.standard.double(forKey: "wristarcade_motion_sensitivity")
        if sensitivity == 0.0 {
            sensitivity = 1.0
        }
    }
    
    /// Starts motion updates with the specified interval. Safe for battery (only active while in game).
    public func startTiltUpdates(updateInterval: TimeInterval = 0.02) {
        guard motionManager.isDeviceMotionAvailable, !isActive else { return }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.showsDeviceMovementDisplay = false
        
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }
            
            let rawRoll = motion.attitude.roll
            let rawPitch = motion.attitude.pitch
            
            let normalizedRoll = max(-1.0, min(1.0, (rawRoll / 0.8) * self.sensitivity))
            let normalizedPitch = max(-1.0, min(1.0, (rawPitch / 0.8) * self.sensitivity))
            
            DispatchQueue.main.async {
                self.roll = normalizedRoll
                self.pitch = normalizedPitch
            }
        }
        
        isActive = true
    }
    
    /// Stops motion updates immediately to conserve battery.
    public func stopTiltUpdates() {
        guard isActive else { return }
        motionManager.stopDeviceMotionUpdates()
        roll = 0.0
        pitch = 0.0
        isActive = false
    }
    
    public func setSensitivity(_ value: Double) {
        sensitivity = value
        UserDefaults.standard.set(value, forKey: "wristarcade_motion_sensitivity")
    }
}
