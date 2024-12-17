//
//  Counter_SwiftUIApp.swift
//  Counter-SwiftUI
//
//  Created by Fachri Febrian on 17/12/2024.
//

import ComposableArchitecture
import SwiftUI

@main
struct Counter_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
              store: Store(initialState: Counter.State()) {
                Counter()
              }
            )
        }
    }
}