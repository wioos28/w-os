// RealApp+WOS.swift
// SwiftUI computed properties for RealApp from WOSCore.
import SwiftUI
import WOSCore

extension RealApp {
    var color: Color { Color(hex: colorHex) }
    var icon: IconRef { IconRef(symbol: iconSymbol) }
}
