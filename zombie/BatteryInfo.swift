//
//  BatteryInfo.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//

import Foundation
import IOKit.ps

func checkBatteryStatus() {
    // Get the power source information
    if let powerSourceInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
       let powerSourcesList = IOPSCopyPowerSourcesList(powerSourceInfo)?.takeRetainedValue() as? [CFTypeRef]
    {
        for powerSource in powerSourcesList {
            if let powerSourceInfo = IOPSGetPowerSourceDescription(powerSourceInfo, powerSource)?.takeUnretainedValue() as? [String: Any] {
                // Extract battery information
/*
                if let isCharging = powerSourceInfo[kIOPSPowerSourceStateKey] as? String {
                    if isCharging == kIOPSACPowerValue {
                        print("The Mac is currently plugged in.")
                    } else {
                        print("The Mac is running on battery.")
                    }
                }
  */
                if let batteryPercentage = powerSourceInfo[kIOPSCurrentCapacityKey] as? Int,
                   let maxCapacity = powerSourceInfo[kIOPSMaxCapacityKey] as? Int {
                    let percentage = Double(batteryPercentage) / Double(maxCapacity) * 100.0
                    AppState.shared.updateBattery(Double(batteryPercentage) / Double(maxCapacity))
                    
                    if(AppState.shared.controledWindow == nil){
                        AppState.shared.triggerAutoload()
                    }
                }
            }
        }
    }
}




