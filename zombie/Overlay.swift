//
//  ContentView.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//

import SwiftUI

struct DeadScreenView: View{
    @Environment(AppState.self) private var appState
    private var color = Color.red
    
    var body: some View{
        Text(appState.overlayText)
            .font(.system(size: 120))
            .foregroundStyle(color)
            .shadow(color: color, radius: 10)
    }
}

struct GlowingBorderView: View {
    var relativeBatteryLifeLeft: Double = 1
    var color = Color.red
    
    /// Calculates the diagonal radius for the radial gradient based on view dimensions.
    /// - Parameters:
    ///   - width: The view width
    ///   - height: The view height
    /// - Returns: Half the diagonal length, which ensures the gradient covers the entire view from center
    private func baseRadius(width: CGFloat, height: CGFloat) -> CGFloat {
        return sqrt(width * width + height * height) / 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            let radius = baseRadius(width: geometry.size.width, height: geometry.size.height)
            
            Rectangle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            color
                        ]),
                        center: .center,
                        // old version for 16'inch screen: startRadius: 900.0 * relativeBatteryLifeLeft
                        startRadius: radius * relativeBatteryLifeLeft,
                        // old version for 16'inch screen: endRadius: 900 + 450 * relativeBatteryLifeLeft
                        endRadius: radius + (radius * 0.5) * relativeBatteryLifeLeft
                    )
                )
                .allowsHitTesting(false)
        }
    }
}

struct ZombieView: View {
    @Environment(AppState.self) private var appState
    
    @State private var shadowOpacity: Double = 0.0
    
    /* value between 0.0 ... 1.0, 1 means dead  */
    var relativeBatteryLifeLeft: Double {
        // calc 100%
        let batteryLevel = appState.isDemoMode ? appState.demoBatteryLevel : appState.batteryLevel
        let delta = appState.lowThreshold - appState.minThreshold
        var level = batteryLevel - appState.minThreshold
        
        if(delta < 1){ return 0.0 }
        
        // minimum value is 0
        level = level < 0 ? 0 : level
        
        return Double(level)/Double(delta)
    }
    
    var body: some View {
        ZStack{
            GlowingBorderView(relativeBatteryLifeLeft: relativeBatteryLifeLeft)
            if(relativeBatteryLifeLeft <= 0){
                DeadScreenView()
            }
        }
        .opacity(shadowOpacity)
        .onAppear{
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                self.shadowOpacity = 0.8
            }
        }
    }
}
