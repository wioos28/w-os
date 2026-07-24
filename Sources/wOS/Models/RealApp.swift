// RealApp.swift
// Ported 1:1 from src/data/realApps.js (REAL_APPS / REAL_APP_CATEGORIES).
// W OS cannot truly "install" Google/Spotify/Facebook/TikTok on the phone —
// only iOS itself can install real apps via the App Store. Tapping one of
// these genuinely opens the real thing: first the app's own URL scheme
// (opens the real native app if already installed), then falls back to the
// real https website. Nothing here is simulated.
import SwiftUI

struct RealApp: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let category: String
    let colorHex: String
    let iconSymbol: String
    let url: String
    let scheme: String?
    let desc: String

    var color: Color { Color(hex: colorHex) }
    var icon: IconRef { IconRef(symbol: iconSymbol) }
}
