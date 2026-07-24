// WindowInstance+WOS.swift
// SwiftUI computed properties for WindowInstance from WOSCore.
import SwiftUI
import WOSCore

extension WindowInstance {
    var color: Color { Color(hex: colorHex) }
    var icon: IconRef { IconRef(symbol: iconSymbol) }
}
