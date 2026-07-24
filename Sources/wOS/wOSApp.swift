// wOSApp.swift
// Ported from App.js — the root of the whole simulated OS.
import SwiftUI

@main
struct wOSApp: App {
    @StateObject private var systemState = SystemState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(systemState)
                .preferredColorScheme(.dark)
        }
    }
}
