// RealApp.swift
// Real third-party app model — pure data, no SwiftUI dependency.
import Foundation

struct RealApp: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let category: String
    let colorHex: String
    let iconSymbol: String
    let url: String
    let scheme: String?
    let desc: String
}
