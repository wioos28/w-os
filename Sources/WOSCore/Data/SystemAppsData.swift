// SystemAppsData.swift
// Dynamic system app catalog — loads from GitHub (apps.json), falls back to
// built-in defaults when offline. No SwiftUI dependency.
import Foundation

enum SystemAppsData {
    // MARK: - Static defaults (used when catalog hasn't loaded yet)
    static let settings   = SystemApp(id: "settings",   title: "Cài đặt",   iconSymbol: "gearshape.fill",           colorHex: "5b5f66")
    static let browser    = SystemApp(id: "browser",    title: "Browser",   iconSymbol: "globe",                     colorHex: "3b82f6")
    static let appstore   = SystemApp(id: "appstore",   title: "Thư viện",  iconSymbol: "bag.fill",                  colorHex: "10b981")
    static let terminal   = SystemApp(id: "terminal",   title: "Terminal",  iconSymbol: "terminal.fill",             colorHex: "27272a")
    static let files      = SystemApp(id: "files",      title: "Tệp",       iconSymbol: "folder.fill",               colorHex: "f59e0b")
    static let calculator = SystemApp(id: "calculator", title: "Máy tính",  iconSymbol: "plusminus.circle.fill",     colorHex: "f97316")
    static let notes      = SystemApp(id: "notes",      title: "Ghi chú",   iconSymbol: "note.text",                 colorHex: "eab308")
    static let weather    = SystemApp(id: "weather",    title: "Thời tiết", iconSymbol: "cloud.sun.fill",            colorHex: "06b6d4")
    static let music      = SystemApp(id: "music",      title: "Nhạc",      iconSymbol: "music.note",                colorHex: "ec4899")
    static let calendar   = SystemApp(id: "calendar",   title: "Lịch",      iconSymbol: "calendar",                  colorHex: "6366f1")
    static let update     = SystemApp(id: "update",     title: "Cập nhật",  iconSymbol: "arrow.triangle.2.circlepath", colorHex: "0ea5e9")

    // Default list (before catalog loads)
    static let defaultList: [SystemApp] = [settings, browser, appstore, terminal, files, calculator, notes, weather, music, calendar, update]
    static let defaultDockIds: [String] = ["settings", "browser", "appstore", "terminal", "files"]

    // MARK: - Dynamic catalog (updated by AppCatalogService)
    static var dynamicList: [SystemApp] = defaultList
    static var dynamicDockIds: [String] = defaultDockIds
    static var catalogVersion: String = ""
    static var catalogLoaded: Bool = false

    // MARK: - Public API

    static var list: [SystemApp] {
        catalogLoaded ? dynamicList : defaultList
    }

    static var dockAppIds: [String] {
        catalogLoaded ? dynamicDockIds : defaultDockIds
    }

    static func find(_ id: String) -> SystemApp? {
        list.first(where: { $0.id == id })
    }

    // MARK: - Update from catalog

    static func updateFromCatalog(_ catalog: AppCatalog) {
        dynamicList = catalog.apps.filter { $0.enabled }.map { entry in
            SystemApp(
                id: entry.id,
                title: entry.title,
                iconSymbol: entry.icon,
                colorHex: entry.color
            )
        }
        dynamicDockIds = catalog.apps.filter { $0.dock && $0.enabled }.map(\.id)
        catalogVersion = catalog.version
        catalogLoaded = true

        print("[SystemAppsData] Loaded \(dynamicList.count) apps from catalog v\(catalogVersion)")
    }

    static func resetToDefaults() {
        dynamicList = defaultList
        dynamicDockIds = defaultDockIds
        catalogVersion = ""
        catalogLoaded = false
    }
}
