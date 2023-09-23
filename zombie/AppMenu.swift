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
        VStack(){
            Text("Battery@\(appState.battery * 100)%")
            Toggle(isOn: $appState.isOn){
                Text("Test")
            }
            Toggle(isOn: $appState.ignoreFocusMode){
                Text("Ignore Focus Mode")
            }
            Text("Quit")
        }

    }
}
