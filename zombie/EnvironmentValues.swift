//
//  EnviromentBinding.swift
//  zombie
//
//  Created by Max Mönch on 18.10.25.
//
import SwiftUI

extension EnvironmentValues {
    func binding<T>(_ keyPath: WritableKeyPath<AppState, T>) -> Binding<T> {
        Binding(
            get: { self[AppState.self][keyPath: keyPath] },
            set: { self[AppState.self][keyPath: keyPath] = $0 }
        )
    }
}
