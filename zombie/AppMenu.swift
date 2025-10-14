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
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading){
            Text("Zombie").font(.largeTitle)
            Text("Battery monitor for the last mile!").font(.subheadline)
            
            Text("Battery@\(appState.battery * 100)%")

            Text("Min Threshold")
            Slider(value: $appState.lowThreshold) {newValue in
                print(newValue)
            }
            
            Text("Dead Threshold")
            Slider(value: $appState.minThreshold) {newValue in
                print(newValue)
            }
            
            Toggle(isOn: $appState.isOn){
                Text("Demo Mode")
            }
            
            Toggle(isOn: $appState.ignoreFocusMode){
                Text("Ignore Focus Mode")
            }
        }
    }
}

struct AppMenu_Previews: PreviewProvider {
    static var previews: some View {
        AppMenu()
    }
}


