// Wallpaper.swift
// Wallpaper catalog. Adds real bundled background images (Assets.xcassets)
// on top of the original app's flat color choices (SetupScreen.js /
// SettingsScreen.js "wpColors": default/blue/purple/red/green).
import SwiftUI
import UIKit

struct WallpaperOption: Identifiable, Hashable {
    let id: String          // key stored in SystemState.wallpaper
    let label: String       // Vietnamese label, matches original screens
    let baseColor: Color    // fallback flat color (matches old wpColors)
    let assetName: String   // Assets.xcassets image set name
}

enum WallpaperCatalog {
    static let all: [WallpaperOption] = [
        WallpaperOption(id: "default", label: "Tối",      baseColor: Color(hex: "0a0a0a"), assetName: "Wallpaper_default"),
        WallpaperOption(id: "blue",    label: "Xanh",      baseColor: Color(hex: "0f172a"), assetName: "Wallpaper_blue"),
        WallpaperOption(id: "purple",  label: "Tím",       baseColor: Color(hex: "1e1b4b"), assetName: "Wallpaper_purple"),
        WallpaperOption(id: "red",     label: "Đỏ",        baseColor: Color(hex: "1a0505"), assetName: "Wallpaper_red"),
        WallpaperOption(id: "green",   label: "Xanh lá",   baseColor: Color(hex: "051a0a"), assetName: "Wallpaper_green"),
    ]

    static func option(for id: String) -> WallpaperOption {
        all.first(where: { $0.id == id }) ?? all[0]
    }
}

/// Renders the current wallpaper as a full-bleed background.
/// Falls back to a plain color fill if the asset image can't be found,
/// so the OS never crashes or shows a blank screen because of a missing asset.
struct WallpaperBackground: View {
    var wallpaperId: String
    var dim: Double = 0.35 // darken overlay so foreground UI stays legible

    var body: some View {
        let option = WallpaperCatalog.option(for: wallpaperId)
        ZStack {
            if UIImage(named: option.assetName) != nil {
                Image(option.assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                option.baseColor
            }
            Color.black.opacity(dim)
        }
        .ignoresSafeArea()
    }
}
