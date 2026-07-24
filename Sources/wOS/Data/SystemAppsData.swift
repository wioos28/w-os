// SystemAppsData.swift
// Ported 1:1 from src/data/systemApps.js
import SwiftUI

enum SystemAppsData {
    static let settings   = SystemApp(id: "settings",   title: "Cài đặt",   icon: IconRef(symbol: "gearshape.fill"),           color: Color(hex: "5b5f66"))
    static let browser    = SystemApp(id: "browser",    title: "Browser",   icon: IconRef(symbol: "globe"),                     color: Color(hex: "3b82f6"))
    static let appstore   = SystemApp(id: "appstore",   title: "Thư viện",  icon: IconRef(symbol: "bag.fill"),                  color: Color(hex: "10b981"))
    static let terminal   = SystemApp(id: "terminal",   title: "Terminal",  icon: IconRef(symbol: "terminal.fill"),             color: Color(hex: "27272a"))
    static let files      = SystemApp(id: "files",      title: "Tệp",       icon: IconRef(symbol: "folder.fill"),               color: Color(hex: "f59e0b"))
    static let calculator = SystemApp(id: "calculator", title: "Máy tính",  icon: IconRef(symbol: "plusminus.circle.fill"),     color: Color(hex: "f97316"))
    static let notes      = SystemApp(id: "notes",      title: "Ghi chú",   icon: IconRef(symbol: "note.text"),                 color: Color(hex: "eab308"))
    static let weather    = SystemApp(id: "weather",    title: "Thời tiết", icon: IconRef(symbol: "cloud.sun.fill"),            color: Color(hex: "06b6d4"))
    static let music      = SystemApp(id: "music",      title: "Nhạc",      icon: IconRef(symbol: "music.note"),                color: Color(hex: "ec4899"))
    static let calendar   = SystemApp(id: "calendar",   title: "Lịch",      icon: IconRef(symbol: "calendar"),                  color: Color(hex: "6366f1"))
    static let update     = SystemApp(id: "update",     title: "Cập nhật",  icon: IconRef(symbol: "arrow.triangle.2.circlepath"), color: Color(hex: "0ea5e9"))

    static let list: [SystemApp] = [settings, browser, appstore, terminal, files, calculator, notes, weather, music, calendar, update]

    static let dockAppIds: [String] = ["settings", "browser", "appstore", "terminal", "files"]

    static func find(_ id: String) -> SystemApp? {
        list.first(where: { $0.id == id })
    }
}
