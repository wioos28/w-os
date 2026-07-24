// WOSColor.swift
// Pure Foundation hex color parser — no SwiftUI dependency.
import Foundation

/// Lightweight color representation for the core layer.
/// Resolves to actual SwiftUI Color in the UI layer via extension.
struct WOSColor: Hashable, Codable {
    let hex: String

    var red: Double {
        var rgb: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&rgb)
        return Double((rgb & 0xFF0000) >> 16) / 255.0
    }

    var green: Double {
        var rgb: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&rgb)
        return Double((rgb & 0x00FF00) >> 8) / 255.0
    }

    var blue: Double {
        var rgb: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&rgb)
        return Double(rgb & 0x0000FF) / 255.0
    }

    private var sanitizedHex: String {
        hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
    }

    init(_ hex: String) {
        self.hex = hex
    }
}
