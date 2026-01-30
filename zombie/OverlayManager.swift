//
//  OverlayManager.swift
//  zombie
//
//  Created by Max Mönch on 21.10.25.
//
import AppKit
import SwiftUI

/// Manages overlay windows across multiple screens
final class OverlayManager {
    static let shared = OverlayManager()
    
    private init() {
        setupScreenChangeNotifications()
    }

    /// Dictionary mapping screen identifiers to their overlay windows
    private var windows: [String: NSWindow] = [:]

    /// Ensures overlays are displayed on all connected screens
    func ensureOverlay(appState: AppState) {
        let screens = NSScreen.screens
        guard !screens.isEmpty else { return }

        NSLog("Ensuring overlays on \(screens.count) screen(s)")

        // Create overlays for all screens
        for screen in screens {
            let screenID = self.screenIdentifier(for: screen)
            
            if self.windows[screenID] == nil {
                NSLog("Creating overlay for screen: \(screenID)")
                self.windows[screenID] = self.createOverlay(for: screen, appState: appState)
            }

            if let window = self.windows[screenID] {
                window.alphaValue = 1
                window.orderFront(nil)
                NSLog("Showing overlay on screen: \(screenID) at frame: \(window.frame)")
            }
        }
        
        // Store reference to first window for compatibility
        appState.controledWindow = windows.values.first
        
        // Clean up windows for disconnected screens
        cleanupDisconnectedScreens()
    }

    /// Removes overlays from all screens
    func removeOverlay(appState: AppState) {
        for (_, window) in self.windows {
            window.orderOut(nil)
        }
        self.windows.removeAll()
        appState.controledWindow = nil
    }

    /// Creates an overlay window for a specific screen
    private func createOverlay(for screen: NSScreen, appState: AppState) -> NSWindow {
        // Use full frame for proper screen coverage
        let screenFrame = screen.frame

        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .statusBar
        window.ignoresMouseEvents = true
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]

        // Explicitly set the window frame to match the screen
        window.setFrame(screenFrame, display: true)

        let borderView = ZombieView().environment(appState)
        window.contentView = NSHostingView(rootView: borderView)

        return window
    }
    
    /// Generates a unique identifier for a screen
    private func screenIdentifier(for screen: NSScreen) -> String {
        // Use screen's device description for unique identification
        if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
            return "screen_\(screenNumber)"
        }
        // Fallback to frame as identifier
        return "screen_\(screen.frame.origin.x)_\(screen.frame.origin.y)"
    }
    
    /// Removes windows for screens that are no longer connected
    private func cleanupDisconnectedScreens() {
        let currentScreenIDs = Set(NSScreen.screens.map { self.screenIdentifier(for: $0) })
        let windowScreenIDs = Set(self.windows.keys)
        
        let disconnectedScreenIDs = windowScreenIDs.subtracting(currentScreenIDs)
        
        if !disconnectedScreenIDs.isEmpty {
            NSLog("Cleaning up \(disconnectedScreenIDs.count) disconnected screen(s)")
        }
        
        for screenID in disconnectedScreenIDs {
            if let window = self.windows[screenID] {
                window.orderOut(nil)
                NSLog("Hidden overlay window for disconnected screen: \(screenID)")
            }
            self.windows.removeValue(forKey: screenID)
            NSLog("Removed overlay for disconnected screen: \(screenID)")
        }
    }
    
    /// Sets up notifications to respond to screen configuration changes
    private func setupScreenChangeNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            NSLog("Screen configuration changed")
            self?.handleScreenConfigurationChange()
        }
    }
    
    /// Handles screen configuration changes (monitors connected/disconnected)
    private func handleScreenConfigurationChange() {
        // If we have active overlays, refresh them for the new screen configuration
        if !self.windows.isEmpty {
            NSLog("Handling screen configuration change with \(self.windows.count) active window(s)")
            
            let appState = AppState.shared
            let screenCountBefore = self.windows.count
            
            // Clean up disconnected screens first
            cleanupDisconnectedScreens()
            
            let screenCountAfter = self.windows.count
            if screenCountAfter < screenCountBefore {
                NSLog("Cleaned up \(screenCountBefore - screenCountAfter) window(s)")
            }
            
            // Ensure overlays exist on all current screens (including newly connected ones)
            ensureOverlay(appState: appState)
            
            NSLog("Screen configuration update complete. Now have \(self.windows.count) window(s)")
        }
    }
}
