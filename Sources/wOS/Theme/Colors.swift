// Colors.swift
// Central color helpers, ported from the hex color strings used throughout
// the original React Native StyleSheet objects (App.js, DesktopScreen.js, ...).
import SwiftUI

extension Color {
    /// Build a Color from a hex string like "#3b82f6" or "3b82f6".
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }

    // Palette matching the JS StyleSheet colors used across the app.
    static let wosBackground = Color(hex: "0a0a0a")
    static let wosPanel = Color(hex: "111111")
    static let wosPanelAlt = Color(hex: "1a1a1a")
    static let wosBorder = Color(hex: "2a2a2a")
    static let wosAccent = Color(hex: "3b82f6")
    static let wosDanger = Color(hex: "ef4444")
    static let wosSuccess = Color(hex: "10b981")
    static let wosWarning = Color(hex: "f59e0b")
    static let wosMuted = Color(hex: "888888")
}
