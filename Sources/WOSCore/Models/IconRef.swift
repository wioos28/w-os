// IconRef.swift
// Icon descriptor — carries only the SF Symbol name.
// SwiftUI rendering is provided by an extension in the UI layer.
import Foundation

struct IconRef: Hashable, Codable {
    var symbol: String
}
