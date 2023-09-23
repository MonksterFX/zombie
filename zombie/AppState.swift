//
//  AppState.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isOn: Bool = false
    @Published var ignoreFocusMode: Bool = false
    @Published var treshhold: Double = 0.05
    @Published var battery: Double = 0.5
    @Published var controledWindow: NSWindow? = nil
    @Published var autoload: Bool = true
    
    static let shared = AppState()
    
    private init() {}
    
    func triggerAutoload(){
        self.autoload = true
    }
    
    func updateBattery(_ newValue: Double){
        self.isOn = newValue > self.treshhold
        self.battery = newValue
    }
}
