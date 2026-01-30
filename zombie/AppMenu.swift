//
//  AppMenu.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//  inspiration by https://blog.schurigeln.com/menu-bar-apps-swift-ui/
//

import Foundation
import SwiftUI

struct AppMenu: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .top){
                Text("Zombie").font(.largeTitle)
                Spacer()
                Text("\(appState.estimatedMinutesRemainingAsFormated)")
                Text("\(appState.batteryLevel)%")
            }
            Text("Battery monitor for the last mile!").font(.subheadline)

            HStack(){
                Text("Warning Threshold").fontWeight(.bold)
                Spacer()
                Text("\(appState.lowThreshold)%")
            }
            Text("When to show the dead screen").font(.subheadline)
            
            Slider(value: Binding(
                get: { Double(appState.lowThreshold) },
                set: { appState.lowThreshold = Int($0) }
            ), in: 1...30, step: 1)
            
            HStack{
                Text("Dead Threshold").fontWeight(.bold)
            
                Spacer()
                Text("\(appState.minThreshold)%")
            }
            Text("When to show the dead screen").font(.subheadline)
            
            Slider(value: Binding(
                get: { Double(appState.minThreshold) },
                set: { appState.minThreshold = Int($0) }
            ), in: 1...30, step: 1)
            

            // MARK: Mute
            Toggle(isOn:  Binding(
                get: { appState.isMuted },
                set: { $0 ? appState.mute() : appState.unmute() }
           )){
                Text("Mute for 10 minutes")
            }
            
            // MARK: - Demo Mode
            Toggle(isOn:
                    Binding(
                        get: { appState.isDemoMode },
                       set: { appState.isDemoMode = $0 }
                   )){
                Text("Demo Mode")
            }
            
            if(appState.isDemoMode){
                HStack{
                    Text("Demo Battery Level")
                    Spacer()
                    Text("\(appState.demoBatteryLevel)%")
                }
                Slider(value: Binding(
                    get: { Double(appState.demoBatteryLevel) },
                    set: { appState.demoBatteryLevel = Int($0) }
                ), in: 1...100, step: 1)
                
            }
            
            HStack{
                if let url = URL(string: "https://github.com/MonksterFX/zombie") {
                    Spacer()
                    Link("Zombie - Github", destination: url)
                    Spacer()
                }
            }
        }
    }
}

struct AppMenu_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            AppMenu().environment(AppState.shared)
        }
        .padding(16)
    }
}


