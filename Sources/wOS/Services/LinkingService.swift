// LinkingService.swift
// In-app linking service - opens web content within W OS browser, not externally.
import SwiftUI

enum LinkingService {
    /// Opens app URL within W OS browser window instead of external app
    static func openRealApp(_ app: RealApp, systemState: SystemState? = nil) {
        // Always open in W OS internal browser
        if let state = systemState {
            state.openApp("browser")
            // Could pass URL to browser here if needed
        }
        // Fallback: open in Safari only if explicitly requested
    }

    /// Opens URL in Safari (only for system settings)
    static func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    /// Opens a URL in Safari (used sparingly)
    static func openInSafari(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
