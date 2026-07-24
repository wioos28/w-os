// LinkingService.swift
// In-app linking service - opens web content within W OS browser, not externally.
import SwiftUI
import WOSCore

enum LinkingService {
    static func openRealApp(_ app: RealApp, shellState: WOSShellState? = nil) {
        if let state = shellState {
            state.openApp("browser")
        }
    }

    static func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    static func openInSafari(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
