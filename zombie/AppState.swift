//
//  AppState.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//

import SwiftUI

@Observable class AppState {
    /* window state */
    var isDemoMode: Bool = false {
        didSet { updateOverlayState() }
    }
    var isOn: Bool = false {
        didSet { updateOverlayState() }
    }
    var isMuted: Bool = false {
        didSet { updateOverlayState() }
    }
    
    /* Add mute function */
    private var mutedAt: Date? = nil
    
    /* Settings */
    var minThreshold: Int = 1
    var lowThreshold: Int = 10
    {
        didSet {
            isOn = batteryLevel <= lowThreshold
        }
    }
    var demoBatteryLevel: Int = 100 {
        didSet {
            isOn = demoBatteryLevel < lowThreshold
        }
    }
    
    // var ignoreFocusMode: Bool = false
    
    /* Overlay */
    var controledWindow: NSWindow? = nil
    var autoload: Bool = true // TODO: what does this do?
    
    /* Power Infos - Managed by PowerEventMonitor */
    var batteryLevel: Int = 100
    var isCharging: Bool = false
    var powerSource: String = "Unknown"
    
    static let shared = AppState()
    
    private init() {}
    
    func triggerAutoload(){
        self.autoload = true
    }
    
    func updateBatteryLevel(level: Int){
        batteryLevel = level
        
        if(isCharging){
            isOn = false
            return
        }
        
        if(level <= lowThreshold){
            isOn = true
        }
        
        self.updateOverlayState()
    }
    
    func mute(){
        isMuted = true
        mutedAt = Date()
        scheduleUnmute(after: 10)
    }
    
    func unmute(){
        isMuted = false
        mutedAt = nil
    }

    private func updateOverlayState() {
        Task { @MainActor in
            if isMuted {
                OverlayManager.shared.removeOverlay(appState: self)
            } else if (isDemoMode && (demoBatteryLevel <= lowThreshold)) {
                OverlayManager.shared.ensureOverlay(appState: self)
            } else if isOn {
                OverlayManager.shared.ensureOverlay(appState: self)
            } else {
                OverlayManager.shared.removeOverlay(appState: self)
            }
        }
    }
    
    private func scheduleUnmute(after seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 1) { [weak self] in
            guard let self = self else { return }

            // Only unmute if still muted and duration has passed
            if let mutedAt = self.mutedAt,
               Date().timeIntervalSince(mutedAt) >= seconds {
                self.unmute()
                print("Unmuted automatically after \(seconds) seconds.")
            }
        }
    }
}
