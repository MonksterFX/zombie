//
//  PowerEventMonitor.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//
import Foundation
import IOKit.ps

class PowerEventMonitor {
    private var runLoopSource: CFRunLoopSource?
    private var appState: AppState

    init(appState: AppState) {
        self.appState = appState

        // Register for power source change notifications
        runLoopSource = IOPSNotificationCreateRunLoopSource({ context in
            let monitor = Unmanaged<PowerEventMonitor>.fromOpaque(context!).takeUnretainedValue()
            NSLog("⚡️ Power source change notification received")
            monitor.powerSourceChanged()
        }, Unmanaged.passUnretained(self).toOpaque()).takeRetainedValue()

        // Ensure we add the source to the main run loop for instant UI updates
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)

        // Initial state
        powerSourceChanged()
    }

    deinit {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
    }

    /// Handles power source changes and updates app state
    private func powerSourceChanged() {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let info = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: Any]
        else { return }

        let powerSourceState = info[kIOPSPowerSourceStateKey] as? String ?? "Unknown"
        let powerSourceType = info[kIOPSTypeKey] as? String ?? "Unknown"
        let isCharging = info[kIOPSIsChargingKey] as? Bool ?? false
        let capacity = info[kIOPSCurrentCapacityKey] as? Int ?? 0
        
        // Check if we're on AC power (more reliable than just checking isCharging)
        let isOnACPower = (powerSourceState == kIOPSACPowerValue) || 
                          (powerSourceType == kIOPSInternalBatteryType && isCharging)
        
        NSLog("🔋 Power state: \(powerSourceState), Type: \(powerSourceType), Charging: \(isCharging), AC Power: \(isOnACPower), Battery: \(capacity)%")

        // Update AppState on main thread (important for SwiftUI)
        DispatchQueue.main.async {
            self.appState.powerSource = powerSourceState
            self.appState.isCharging = isOnACPower
            self.appState.updateBatteryLevel(level: capacity)
        }
    }
}





