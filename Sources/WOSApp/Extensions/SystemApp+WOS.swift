// SystemApp+WOS.swift
// SwiftUI computed properties for SystemApp from WOSCore.
import SwiftUI
import WOSCore

extension SystemApp {
    var color: Color { Color(hex: colorHex) }
    var icon: IconRef { IconRef(symbol: iconSymbol) }
}
