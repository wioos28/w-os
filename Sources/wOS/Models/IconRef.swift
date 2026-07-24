// IconRef.swift
// Ported from src/theme/Icon.js. The original used @expo/vector-icons with a
// { lib, name } descriptor (Ionicons / MaterialCommunityIcons / FontAwesome5).
// Native iOS has no such library — SF Symbols is the true native equivalent,
// so every icon descriptor now just carries a single SF Symbol name.
import SwiftUI

struct IconRef: Hashable, Codable {
    var symbol: String

    /// Renders exactly like the old <Icon lib=... name=... size=... color=... />
    @ViewBuilder
    func view(size: CGFloat = 20, color: Color = .white) -> some View {
        Image(systemName: symbol)
            .font(.system(size: size))
            .foregroundColor(color)
    }
}
