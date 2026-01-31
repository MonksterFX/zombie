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
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text("Zombie").font(.largeTitle)
                Spacer()
                Text("\(appState.estimatedMinutesRemainingAsFormated)")
                Text("\(appState.batteryLevel)%")
            }
            Text("Battery monitor for the last mile!").font(.subheadline)

            // MARK: Mute
            Button(action: {
                if appState.isMuted {
                    appState.unmute()
                } else {
                    appState.mute()
                }
            }) {
                HStack {
                    Image(
                        systemName: appState.isMuted
                        ? "speaker.wave.2.fill" : "speaker.slash.fill"
                    )
                    Text(appState.isMuted ? "Unmute" : "Mute for 10 Minutes")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(appState.isMuted ? .gray : .accentColor)
            .opacity(appState.isMuted ? 1.0 : 0.8)

            Text("Options")
                .font(.title2)

            HStack {
                Text("Warning Threshold").fontWeight(.bold)
                Spacer()
                Text("\(appState.lowThreshold)%")
            }
            Text("When to activate zombie mode").font(.subheadline)

            Slider(
                value: Binding(
                    get: { Double(appState.lowThreshold) },
                    set: { appState.lowThreshold = Int($0) }
                ),
                in: 1...30,
                step: 1
            )

            HStack {
                Text("Dead Threshold").fontWeight(.bold)

                Spacer()
                Text("\(appState.minThreshold)%")
            }
            Text("When to show the dead screen").font(.subheadline)

            Slider(
                value: Binding(
                    get: { Double(appState.minThreshold) },
                    set: { appState.minThreshold = Int($0) }
                ),
                in: 1...30,
                step: 1
            )

            HStack {
                Text("Overlay Text").fontWeight(.bold)
            }
            Text("Text shown when battery is critically low").font(.subheadline)

            TextField(
                "Enter text",
                text: Binding(
                    get: { appState.overlayText },
                    set: { appState.overlayText = $0 }
                )
            )
            .textFieldStyle(.roundedBorder)

            // MARK: - Advanced Settings
            DisclosureGroup(
                "Advanced Settings",
                isExpanded: Binding(
                    get: { appState.advancedSettings },
                    set: { newValue in
                        appState.advancedSettings = newValue
                    }
                )
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    // MARK: - Demo Mode
                    Text(
                        "Demo mode lets you test the app without having to wait for the battery to drain."
                    )
                    .font(.subheadline)

                    Toggle(
                        isOn: Binding(
                            get: { appState.isDemoMode },
                            set: { newValue in
                                appState.isDemoMode = newValue
                            }
                        )
                    ) {
                        Text("Demo Mode")
                    }

                    if appState.isDemoMode {
                        Group {
                            HStack {
                                Text("Demo Battery Level")
                                Spacer()
                                Text("\(appState.demoBatteryLevel)%")
                            }
                            .padding(.top, 5)

                            Slider(
                                value: Binding(
                                    get: { Double(appState.demoBatteryLevel) },
                                    set: { appState.demoBatteryLevel = Int($0) }
                                ),
                                in: 1...100,
                                step: 1
                            )
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                if let url = URL(string: "https://github.com/MonksterFX/zombie")
                {
                    Spacer()
                    Link("Zombie - Github", destination: url)
                    Spacer()
                }
            }

            Divider()

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("Quit Zombie")
                }
            }
        }
        .frame(width: 350)
    }
}

struct AppMenu_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AppMenu().environment(AppState.shared)
        }
        .padding(16)
    }
}
