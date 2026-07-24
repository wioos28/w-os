// SystemApp.swift
// System app model — uses hex strings for colors (no SwiftUI dependency).
import Foundation

struct SystemApp: Identifiable, Hashable {
    let id: String
    let title: String
    let iconSymbol: String
    let colorHex: String
}
