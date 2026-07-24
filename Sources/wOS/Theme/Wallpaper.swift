// Wallpaper.swift
// Dynamic wallpaper system with time-of-day transitions and blur controls.
import SwiftUI
import UIKit

struct WallpaperOption: Identifiable, Hashable {
    let id: String
    let label: String
    let baseColor: Color
    let assetName: String
    let timeOfDay: TimeOfDay?

    enum TimeOfDay: String, CaseIterable {
        case morning, afternoon, evening, night
    }

    init(id: String, label: String, baseColor: Color, assetName: String, timeOfDay: TimeOfDay? = nil) {
        self.id = id
        self.label = label
        self.baseColor = baseColor
        self.assetName = assetName
        self.timeOfDay = timeOfDay
    }
}

enum WallpaperCatalog {
    static let all: [WallpaperOption] = [
        WallpaperOption(id: "default", label: "Tối",      baseColor: Color(hex: "0a0a0a"), assetName: "Wallpaper_default"),
        WallpaperOption(id: "blue",    label: "Xanh",      baseColor: Color(hex: "0f172a"), assetName: "Wallpaper_blue"),
        WallpaperOption(id: "purple",  label: "Tím",       baseColor: Color(hex: "1e1b4b"), assetName: "Wallpaper_purple"),
        WallpaperOption(id: "red",     label: "Đỏ",        baseColor: Color(hex: "1a0505"), assetName: "Wallpaper_red"),
        WallpaperOption(id: "green",   label: "Xanh lá",   baseColor: Color(hex: "051a0a"), assetName: "Wallpaper_green"),
        WallpaperOption(id: "dynamic", label: "Động",      baseColor: Color(hex: "111827"), assetName: "Wallpaper_default", timeOfDay: .morning),
    ]

    static func option(for id: String) -> WallpaperOption {
        all.first(where: { $0.id == id }) ?? all[0]
    }

    static func dynamicWallpaper(for date: Date = Date()) -> WallpaperOption {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<12:  return WallpaperOption(id: "dynamic_morning", label: "Sáng", baseColor: Color(hex: "0f172a"), assetName: "Wallpaper_blue")
        case 12..<17: return WallpaperOption(id: "dynamic_afternoon", label: "Chiều", baseColor: Color(hex: "1e1b4b"), assetName: "Wallpaper_purple")
        case 17..<20: return WallpaperOption(id: "dynamic_evening", label: "Tối", baseColor: Color(hex: "1a0505"), assetName: "Wallpaper_red")
        default:      return WallpaperOption(id: "dynamic_night", label: "Đêm", baseColor: Color(hex: "051a0a"), assetName: "Wallpaper_green")
        }
    }
}

struct WallpaperBackground: View {
    var wallpaperId: String
    var dim: Double = 0.35
    @State private var isTransitioning = false

    private var option: WallpaperOption {
        if wallpaperId == "dynamic" {
            return WallpaperCatalog.dynamicWallpaper()
        }
        return WallpaperCatalog.option(for: wallpaperId)
    }

    var body: some View {
        let opt = option
        ZStack {
            if UIImage(named: opt.assetName) != nil {
                Image(opt.assetName)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else {
                opt.baseColor
                    .transition(.opacity)
            }
            Color.black.opacity(dim)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: wallpaperId)
        .saturation(wallpaperId == "dynamic" ? dynamicSaturation : 1.0)
    }

    private var dynamicSaturation: Double {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return 1.2
        case 12..<17: return 1.0
        case 17..<20: return 0.8
        default: return 0.6
        }
    }
}
