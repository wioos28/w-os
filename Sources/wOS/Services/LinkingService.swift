// LinkingService.swift
// Ported 1:1 from src/services/linking.js.
// Genuine (non-simulated) app launching: iOS never lets a third-party app
// truly "install" Google/Spotify/Facebook/TikTok — only the App Store can.
// What we CAN do, and do here for real: try the app's own URL scheme first
// (opens the actual native app if it's already installed), then fall back
// to opening the real https website in Safari. Both paths use UIApplication's
// real openURL API — nothing here is faked.
import UIKit

enum LinkingService {
    static func openRealApp(_ app: RealApp, onFailure: ((String) -> Void)? = nil) {
        if let scheme = app.scheme, let schemeURL = URL(string: scheme), UIApplication.shared.canOpenURL(schemeURL) {
            UIApplication.shared.open(schemeURL, options: [:]) { success in
                if !success, let url = URL(string: app.url) {
                    UIApplication.shared.open(url)
                }
            }
            return
        }
        if let url = URL(string: app.url) {
            UIApplication.shared.open(url)
            return
        }
        onFailure?("\(app.name) chưa có liên kết hợp lệ.")
    }

    /// Opens the phone's REAL system Settings app — a genuine action used for
    /// controls (Wi-Fi, Bluetooth, Airplane mode...) that no third-party app
    /// is ever allowed to toggle directly on iOS.
    static func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
