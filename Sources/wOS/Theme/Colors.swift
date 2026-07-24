// Colors.swift
// Modern color system with gradients, glass effects, and semantic colors.
import SwiftUI

extension Color {
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

    // MARK: - Core Palette
    static let wosBackground = Color(hex: "0a0a0a")
    static let wosSurface = Color(hex: "111111")
    static let wosPanel = Color(hex: "141414")
    static let wosPanelAlt = Color(hex: "1a1a1a")
    static let wosBorder = Color(hex: "2a2a2a")
    static let wosBorderLight = Color(hex: "3a3a3a")

    // MARK: - Accent Colors
    static let wosAccent = Color(hex: "3b82f6")
    static let wosAccentLight = Color(hex: "60a5fa")
    static let wosAccentDark = Color(hex: "2563eb")

    // MARK: - Semantic Colors
    static let wosDanger = Color(hex: "ef4444")
    static let wosDangerLight = Color(hex: "f87171")
    static let wosSuccess = Color(hex: "10b981")
    static let wosSuccessLight = Color(hex: "34d399")
    static let wosWarning = Color(hex: "f59e0b")
    static let wosWarningLight = Color(hex: "fbbf24")
    static let wosInfo = Color(hex: "06b6d4")
    static let wosInfoLight = Color(hex: "22d3ee")

    // MARK: - Text Colors
    static let wosTextPrimary = Color.white
    static let wosTextSecondary = Color(hex: "a1a1aa")
    static let wosTextMuted = Color(hex: "71717a")
    static let wosTextDisabled = Color(hex: "52525b")

    // MARK: - Gradients
    static let wosAccentGradient = LinearGradient(
        colors: [Color.wosAccent, Color.wosAccentDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let wosDangerGradient = LinearGradient(
        colors: [Color.wosDanger, Color.wosDangerLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let wosSuccessGradient = LinearGradient(
        colors: [Color.wosSuccess, Color.wosSuccessLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let wosSurfaceGradient = LinearGradient(
        colors: [Color.wosPanel, Color.wosPanelAlt],
        startPoint: .top,
        endPoint: .bottom
    )

    static let wosGlassGradient = LinearGradient(
        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Background Gradients
    static let wosBootGradient = LinearGradient(
        colors: [Color(hex: "0a0a0f"), Color(hex: "1a1a2e"), Color(hex: "0a0a0f")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let wosDarkGradient = LinearGradient(
        colors: [Color(hex: "0a0a0a"), Color(hex: "111111")],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - View Extensions

extension View {
    func wosGlassBackground() -> some View {
        self.background(.ultraThinMaterial)
    }

    func wosCardStyle() -> some View {
        self
            .padding(14)
            .background(Color.wosPanel)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wosBorder))
    }

    func wosButtonStyle(ghost: Bool = false) -> some View {
        self
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(ghost ? .wosAccent : .white)
            .padding(.vertical, 9)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(ghost ? Color.wosPanelAlt : Color.wosAccent)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(ghost ? Color.wosBorder : .clear))
            .cornerRadius(10)
    }
}
