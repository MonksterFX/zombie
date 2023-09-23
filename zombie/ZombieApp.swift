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
    @StateObject var appState = AppState.shared
    
    let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
        checkBatteryStatus()
    }
    
    
    init(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    var body: some Scene {
        /*WindowGroup{
            Text("Zombie Timer V.1").onAppear{isMenuPresented.toggle()}
        }*/
        MenuBarExtra("UtilityApp", systemImage: appState.controledWindow == nil ? "hammer" : "minus.plus.batteryblock.exclamationmark.fill") {
            AppMenu().environmentObject(appState)
            Overlay().environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $appState.autoload)
    }
}

