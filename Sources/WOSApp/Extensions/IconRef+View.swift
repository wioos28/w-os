// IconRef+View.swift
// SwiftUI rendering extension for IconRef from WOSCore.
import SwiftUI
import WOSCore

extension IconRef {
    @ViewBuilder
    func view(size: CGFloat = 20, color: Color = .white) -> some View {
        Image(systemName: symbol)
            .font(.system(size: size))
            .foregroundColor(color)
    }
}
