// ContentView.swift
// Ported from App.js's render: switches between Boot/Setup/Lock/Desktop and
// overlays StatusBarWOS + ControlCenter/NotificationCenter/Search/Multitask.
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var systemState: SystemState

    var body: some View {
        ZStack {
            Group {
                switch systemState.screen {
                case .boot:
                    BootView()
                case .setup:
                    SetupView()
                case .lock:
                    LockView()
                case .desktop:
                    DesktopView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.4), value: systemState.screen)

            if systemState.screen == .desktop {
                StatusBarWOS(
                    onControlCenter: { systemState.showControlCenter = true },
                    onNotifications: { systemState.showNotifications = true },
                    onSearch: { systemState.showSearch = true },
                    onMultitask: { systemState.showMultitask = true }
                )
            }

            if systemState.showControlCenter {
                ControlCenterView(onClose: { systemState.showControlCenter = false })
                    .transition(.move(edge: .bottom))
                    .zIndex(20000)
            }
            if systemState.showNotifications {
                NotificationCenterView(onClose: { systemState.showNotifications = false })
                    .transition(.move(edge: .top))
                    .zIndex(20000)
            }
            if systemState.showSearch {
                SearchView(onClose: { systemState.showSearch = false })
                    .transition(.opacity)
                    .zIndex(20000)
            }
            if systemState.showMultitask {
                MultitaskView(onClose: { systemState.showMultitask = false })
                    .transition(.opacity)
                    .zIndex(20000)
            }
        }
        .onAppear { systemState.boot() }
    }
}
