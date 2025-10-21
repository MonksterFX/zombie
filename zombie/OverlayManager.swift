//
//  OverlayManager.swift
//  zombie
//
//  Created by Max Mönch on 21.10.25.
//
import AppKit
import SwiftUI

final class OverlayManager {
    static let shared = OverlayManager()
    private init() {}

    private var window: NSWindow?

    func ensureOverlay(appState: AppState) {
        guard NSScreen.main != nil else { return }

        if window == nil {
            createOverlay(appState: appState)
        }

        window?.alphaValue = 1
        window?.makeKeyAndOrderFront(nil)
        appState.controledWindow = window
    }

    func removeOverlay(appState: AppState) {
        window?.orderOut(nil)
        appState.controledWindow = nil
        window = nil
    }

    private func createOverlay(appState: AppState) {
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero

        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let borderView = ZombieView().environment(appState)
        window.contentView = NSHostingView(rootView: borderView)

        self.window = window
    }
}
