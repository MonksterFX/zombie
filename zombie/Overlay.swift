//
//  ContentView.swift
//  zombie
//
//  Created by Max Mönch on 22.09.23.
//

import SwiftUI

struct DeadScreenView: View{
    private var color = Color.red
    
    var body: some View{
        Text("Dead")
            .font(.system(size: 120))
            .foregroundStyle(color)
            .shadow(color: color, radius: 10)
    }
}

struct GlowingBorderView: View {
    private var color = Color.red
    
    var body: some View {
        Rectangle()
            .fill(
                  RadialGradient(
                      gradient: Gradient(colors: [
                        .clear,
                        color
                      ]),
                      center: .center,
                      startRadius: 0, // TODO: calculate based on battery status
                      endRadius: 900 // TODO: calculate depending on screen size
                  )
              )
            .allowsHitTesting(false)
    }
}

struct ZombieView: View {
    @State private var shadowOpacity: Double = 0.0
    @State var isDead: Bool = false
    
    var body: some View {
        ZStack{
            GlowingBorderView()
            DeadScreenView()
        }
        .opacity(shadowOpacity)
        .onAppear{
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                self.shadowOpacity = 0.8
            }
        }
    }
}

struct Overlay: View {
    @EnvironmentObject var state: AppState
    @State private var window: NSWindow? = nil
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Beta Version").onChange(of: state.isOn){ value in
                if(value){
                    enableGreenBorder()
                }else{
                    disableGreenBorder()
                }
            }.onAppear{enableGreenBorder()}
        }
        .padding(8)
    }
    
    private func enableGreenBorder() {
        // Get the main screen
        
        if NSScreen.main != nil && window == nil {
            // Get the screen's frame
            let screenFrame = screenFrameWithoutMenuBar()

            // Create an NSWindow to draw the border
            let window = NSWindow(
                contentRect: screenFrame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )

            // Configure the window to be transparent and always on top
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            window.setIsVisible(true)
            
            // Enable click trough
            window.ignoresMouseEvents = true
            
            // Create a border view
            let borderView = ZombieView()

            // Add the border view to the window's content view
            window.contentView = NSHostingView(rootView: borderView)
            
            // Make the window visible on all desktops/spaces
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            // Show the window
            window.makeKeyAndOrderFront(nil)
            
            self.window = window
            state.controledWindow = window
        }
        
        if(window != nil){
            window?.setIsVisible(true)
        }
    }

    private func disableGreenBorder() {
        if let currentWindow = window {
            currentWindow.setIsVisible(false)
        }
    }
    
    func screenFrameWithoutMenuBar() -> CGRect {
        let screenFrame = NSScreen.main?.frame ?? CGRect.zero
        
        // Check if there's a visible menu bar on macOS
        if let visibleFrame = NSScreen.main?.visibleFrame {
            let menuBarHeight = screenFrame.height - visibleFrame.height
            return CGRect(x: screenFrame.origin.x, y: screenFrame.origin.y + menuBarHeight, width: screenFrame.width, height: screenFrame.height - menuBarHeight)
        }
        
        return screenFrame
    }
}

struct Overlay_Previews: PreviewProvider {
    static var previews: some View {
        Overlay()
    }
}
