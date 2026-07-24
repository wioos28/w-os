// wOSApp.swift
// Root of W OS - forces landscape orientation for desktop experience.
import SwiftUI
import WOSCore

@main
struct wOSApp: App {
    @StateObject private var shellState = WOSShellState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shellState)
                .preferredColorScheme(.dark)
                .ignoresSafeArea()
        }
    }
}
