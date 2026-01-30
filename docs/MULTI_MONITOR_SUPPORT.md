# Multi-Monitor Support

## Overview
The zombie battery monitor app now supports multiple monitors. The visual warning overlay will appear on all connected displays when the battery level drops below the configured threshold.

## Changes Made

### OverlayManager.swift
The `OverlayManager` class has been completely refactored to support multiple displays:

1. **Multiple Window Management**: Instead of managing a single window, the manager now maintains a dictionary of windows keyed by screen identifiers.

2. **Screen Identification**: Each screen is uniquely identified using the NSScreenNumber from its device description, with a fallback to frame-based identification.

3. **Dynamic Screen Detection**: The manager automatically detects when monitors are connected or disconnected through `NSApplication.didChangeScreenParametersNotification`.

4. **Automatic Cleanup**: When a monitor is disconnected, its overlay window is automatically removed and cleaned up.

## Key Features

- **All Screens Coverage**: When battery warning is triggered, overlays appear on all connected monitors simultaneously
- **Hot-plug Support**: Connect or disconnect monitors while the app is running - overlays will automatically adapt
- **Screen-specific Windows**: Each monitor gets its own overlay window, properly positioned and sized for that display
- **Automatic Synchronization**: All overlays show the same battery warning level and update in sync

## Technical Details

### Screen Change Notifications
The manager listens for `NSApplication.didChangeScreenParametersNotification` to detect:
- New monitors being connected
- Monitors being disconnected
- Display arrangement changes

### Window Management Strategy
- Windows are created lazily when overlays are needed
- Each window is assigned to a specific NSScreen instance
- Windows maintain the same properties: borderless, floating level, ignores mouse events
- All windows share the same ZombieView content but render independently

## Testing
The implementation has been compiled and builds successfully without warnings or errors.

To test:
1. Run the app with multiple monitors connected
2. Set a high battery threshold to trigger the warning
3. Verify overlays appear on all screens
4. Connect/disconnect a monitor and verify the overlays adapt accordingly

## Compatibility
- Requires macOS 14.6 or later
- Works with any number of connected displays
- Supports both built-in and external displays
- Compatible with different display arrangements (mirror, extended desktop)
