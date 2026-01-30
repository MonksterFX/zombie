//
//  zombieApp.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//

import SwiftUI
import MenuBarExtraAccess
import UserNotifications

@main
struct ZombieApp: App {
    @State var appState = AppState.shared
    private var monitor: PowerEventMonitor?
    
    init(){
        self.monitor = PowerEventMonitor(appState: appState)
        
        // Ensure overlay is created at startup (if needed)
        let capturedState = self.appState
        Task { @MainActor in
            OverlayManager.shared.ensureOverlay(appState: capturedState)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Successfully requested notifications")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    
    var body: some Scene {
        MenuBarExtra("UtilityApp", systemImage: self.appState.controledWindow == nil ? "bolt.badge.checkmark.fill" : "bolt.trianglebadge.exclamationmark.fill") {
            VStack{
                AppMenu().environment(self.appState)
            }
            .padding(16)
        }
        .menuBarExtraStyle(.window)
    }
}

