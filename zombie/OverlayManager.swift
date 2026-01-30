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

        if self.window == nil {
            self.window = self.createOverlay(appState: appState)
        }

        self.window?.alphaValue = 1
        self.window?.makeKeyAndOrderFront(nil) // FIXME: Remove if redundant
        appState.controledWindow = window
    }

    func removeOverlay(appState: AppState) {
        self.window?.orderOut(nil)
        self.window = nil
        appState.controledWindow = nil
    }

    private func createOverlay(appState: AppState) -> NSWindow {
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero

        let _window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        _window.isOpaque = false
        _window.backgroundColor = .clear
        _window.level = .floating
        _window.ignoresMouseEvents = true
        _window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]

        let borderView = ZombieView().environment(appState)
        _window.contentView = NSHostingView(rootView: borderView)

        return _window
    }
}
