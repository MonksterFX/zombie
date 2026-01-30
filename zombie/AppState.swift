//
//  AppState.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//

import SwiftUI

// MARK: - UserDefaults Keys
private extension AppState {
    /// UserDefaults keys for persistent settings
    enum Keys {
        static let lowThreshold = "zombie.lowThreshold"
        static let minThreshold = "zombie.minThreshold"
    }
}

@Observable class AppState {
    /* window state */
    // private(set) var isDemoMode: Bool = false {
    var isDemoMode: Bool = false {
        didSet {
            self.updateBatteryLevel(level: self.batteryLevel)
        }
    }
    
    private(set) var isOn: Bool = false {
        didSet { self.updateOverlayState() }
    }
    
    private(set) var isMuted: Bool = false {
        didSet { self.updateOverlayState() }
    }
    
    /* Add mute function */
    private var mutedAt: Date? = nil
    
    /* Settings */
    var minThreshold: Int = 1 {
        didSet {
            UserDefaults.standard.set(minThreshold, forKey: Keys.minThreshold)
        }
    }
    
    var lowThreshold: Int = 10 {
        didSet {
            UserDefaults.standard.set(lowThreshold, forKey: Keys.lowThreshold)
            self.isOn = self.batteryLevel <= self.lowThreshold
        }
    }
    
    var demoBatteryLevel: Int = 100 {
        didSet {
            self.isOn = self.demoBatteryLevel < self.lowThreshold
        }
    }
    
    /* Overlay */
    var controledWindow: NSWindow? = nil
    
    /* Power Infos - Managed by PowerEventMonitor */
    var batteryLevel: Int = 100
    
    var isCharging: Bool = false {
        didSet {
            // Reset sample history when switching charging state
            // batterySamples.removeAll()
        }
    }
    
    var powerSource: String = "Unknown"
    
    // MARK-: Estimate Minutes Remaining
    private let maxSamples = 20
    private var batterySamples: [(time: Date, level: Int)] = []

    var estimatedMinutesRemainingAsFormated: String = "-"
    var estimatedMinutesRemaining: Double? = nil

    // EMA smoothing factor: 0.1 = slow change, 0.5 = fast change.
    private let emaAlpha = 0.35

    // Max allowed gap between samples to be considered valid (minutes)
    private let maxSampleGapMinutes: Double = 8
    
    static let shared = AppState()
    
    private init() {
        // Load persisted settings from UserDefaults
        self.lowThreshold = UserDefaults.standard.object(forKey: Keys.lowThreshold) as? Int ?? 10
        self.minThreshold = UserDefaults.standard.object(forKey: Keys.minThreshold) as? Int ?? 1
        
        // Update overlay state based on loaded settings
        self.updateOverlayState()
    }
    
    func updateBatteryLevel(level: Int){
        self.batteryLevel = level
        NSLog("Battery level changed to \(level)")
        
        let now = Date()
        
        // Store sample
        self.batterySamples.append((time: now, level: level))
        
        if self.batterySamples.count > maxSamples {
            self.batterySamples.removeFirst()
        }
        
        // Update estimation
        self.estimatedMinutesRemaining = self.estimateBatteryLifeEMA()
        self.estimatedMinutesRemainingAsFormated = self.formattedRemainingTime()
        
        // TODO: move to state maschine
        // always disable is on when charging
        if (self.isCharging){
            self.isOn = false
        }else if (level <= self.lowThreshold){
            self.isOn = true
        }else{
            self.isOn = false
        }
        
        self.updateOverlayState()
    }
    
    func formattedRemainingTime() -> String {
        guard let minutes = estimatedMinutesRemaining else { return "—" }
        let total = Int(minutes.rounded())
        
        if total < 60 { return "\(total) min" }
        
        let hours = total / 60
        let mins = total % 60
        return mins == 0 ? "\(hours)h" : "\(hours)h \(mins)m"
    }
    
    private func estimateBatteryLifeEMA() -> Double? {
        guard !self.isCharging else { return nil }
        guard self.batterySamples.count >= 2 else { return nil }
        
        var emaDrainRate: Double? = nil
        
        for i in 1..<self.batterySamples.count {
            let prev = self.batterySamples[i - 1]
            let curr = self.batterySamples[i]
            
            // Ignore long gaps (sleep, hibernation, etc.)
            let minutes = curr.time.timeIntervalSince(prev.time) / 60.0
            if minutes > self.maxSampleGapMinutes { continue }
            
            let levelDelta = prev.level - curr.level
            
            // Ignore charging or non-drops
            if levelDelta <= 0 { continue }
            
            let drainRatePerMinute = Double(levelDelta) / minutes
            
            // EMA update
            if let ema = emaDrainRate {
                emaDrainRate = self.emaAlpha * drainRatePerMinute + (1 - self.emaAlpha) * ema
            } else {
                // Initialize EMA with first observed rate
                emaDrainRate = drainRatePerMinute
            }
        }
        
        guard let rate = emaDrainRate, rate > 0 else { return nil }
        
        NSLog("Current drain rate \(rate)")
        
        return Double(self.batteryLevel) / rate
    }
    
    
    func mute(){
        self.isMuted = true
        self.mutedAt = Date()
        
        // TODO: make it 10 mins
        self.scheduleUnmute(after: 10)
        NSLog("Muted")
    }
    
    func unmute(){
        self.isMuted = false
        self.mutedAt = nil
        NSLog("Unmuted")
    }

    private func updateOverlayState() {
        DispatchQueue.main.async {
            // Operation of main
            if self.isMuted {
                OverlayManager.shared.removeOverlay(appState: self)
            } else if (self.isDemoMode && (self.demoBatteryLevel <= self.lowThreshold)) {
                OverlayManager.shared.ensureOverlay(appState: self)
            } else if self.isOn {
                OverlayManager.shared.ensureOverlay(appState: self)
            } else {
                OverlayManager.shared.removeOverlay(appState: self)
            }
        }
    }
    
    private func scheduleUnmute(after seconds: TimeInterval) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + seconds + 1) { [weak self] in
            guard let self = self else { return }

            // Only unmute if still muted and duration has passed
            if let mutedAt = self.mutedAt,
               Date().timeIntervalSince(mutedAt) >= seconds {
                NSLog("Unmute automatically triggered after \(seconds) seconds.")
                self.unmute()
            }
        }
    }
}
