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
            monitor.powerSourceChanged()
        }, Unmanaged.passUnretained(self).toOpaque()).takeRetainedValue()

        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)

        // Initial state
        powerSourceChanged()
    }

    deinit {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }

    private func powerSourceChanged() {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let info = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: Any]
        else { return }

        let powerSourceState = info[kIOPSPowerSourceStateKey] as? String ?? "Unknown"
        let isCharging = info[kIOPSIsChargingKey] as? Bool ?? false
        let capacity = info[kIOPSCurrentCapacityKey] as? Int ?? 0
        
        debugPrint(capacity, powerSourceState, isCharging)

        // Update AppState on main thread (important for SwiftUI)
        DispatchQueue.main.async {
            self.appState.powerSource = powerSourceState
            self.appState.isCharging = isCharging
            self.appState.updateBatteryLevel(level: capacity)
        }
    }
}





