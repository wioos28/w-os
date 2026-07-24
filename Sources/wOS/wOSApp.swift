// wOSApp.swift
// Root of W OS - forces landscape orientation for desktop experience.
import SwiftUI

@main
struct wOSApp: App {
    @StateObject private var systemState = SystemState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(systemState)
                .preferredColorScheme(.dark)
                .ignoresSafeArea()
        }
    }
}
