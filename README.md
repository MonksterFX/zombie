# Zombie - Battery Monitor For The Last Mile

A macOS menu bar app that monitors your battery level and provides visual warnings to prevent unexpected shutdowns.

## Overview

Zombie watches your battery level and displays a visual indication when it drops below a threshold. The app provides an additional layer of warning that helps prevent the sudden shutdowns that can occur on macOS when the battery is critically low.

### Why Zombie?

Living on the edge with your battery on macOS can be risky. You start a meeting or get into the flow and forget about the low battery warning.

On Windows, you get warned a second time, seconds before the device shuts down due to low battery. On macOS, this second warning doesn't exist - it just shuts down. Zombie fills this gap.

## Features

- **Visual Overlay Warning**: Displays a border around all connected screens when battery is low
- **Progressive Indication**: The border grows thicker as battery level decreases
- **Multi-Monitor Support**: Automatically adapts when monitors are connected or disconnected
- **Menu Bar Integration**: Quick access to app controls and settings
- **Power State Monitoring**: Tracks battery charging status and power events
- **Customizable Thresholds**: Configure when warnings should appear

## How It Works

Zombie creates a simple overlay that draws a border around all connected screens. The border grows progressively thicker the lower your battery gets, providing a clear visual reminder to plug in your device. The overlay automatically adapts when monitors are connected or disconnected.

## Installation

### Requirements

- macOS 12.0 or later
- Xcode 14.0 or later (for building from source)

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/zombie.git
   cd zombie
   ```

2. Open the project in Xcode:
   ```bash
   open zombie.xcodeproj
   ```

3. Build and run the project (⌘+R)

## Usage

1. Launch the Zombie app
2. The app icon will appear in your menu bar
3. Click the menu bar icon to access settings and controls
4. When your battery drops below the threshold, a visual border will appear around your screens
5. The border will grow as the battery level decreases
6. Plug in your device to dismiss the warning

## Configuration

Access the menu bar icon to:
- Adjust battery warning thresholds
- Configure overlay appearance
- Enable/disable the monitoring
- Quit the application

## Disclaimer

I'm not a Swift/SwiftUI/Apple professional. This is a working prototype that has (let's phrase it like this) room to improve :)

Feel free to help out and contribute!

## Contributing

Contributions are welcome! Feel free to:
- Report bugs and issues
- Suggest new features
- Submit pull requests
- Improve documentation

## License

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
