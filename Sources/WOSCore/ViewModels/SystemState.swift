// SystemState.swift
// Core OS state — screen routing, windows, user profile, persistence.
// No SwiftUI dependency. Overlay booleans live in the UI layer.
import Foundation
import Combine

enum ScreenState: Equatable {
    case boot
    case setup
    case lock
    case desktop
}

/// One open "window" on the desktop. Uses hex strings for colors.
final class WindowInstance: Identifiable, ObservableObject, Equatable {
    let id = UUID()
    let appId: String
    let title: String
    let iconSymbol: String
    let colorHex: String
    @Published var x: CGFloat
    @Published var y: CGFloat
    @Published var width: CGFloat
    @Published var height: CGFloat
    @Published var minimized: Bool = false
    @Published var maximized: Bool = false

    init(appId: String, title: String, iconSymbol: String, colorHex: String,
         x: CGFloat = 24, y: CGFloat = 90, width: CGFloat = 340, height: CGFloat = 480) {
        self.appId = appId
        self.title = title
        self.iconSymbol = iconSymbol
        self.colorHex = colorHex
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    static func == (lhs: WindowInstance, rhs: WindowInstance) -> Bool { lhs.id == rhs.id }
}

final class SystemState: ObservableObject {
    // ----- Screen routing -----
    @Published var screen: ScreenState = .boot

    // ----- Windows -----
    @Published var windows: [WindowInstance] = []
    @Published var frontWindowId: UUID?

    // ----- Installed real apps -----
    @Published var installedApps: [RealApp] = []

    // ----- Profile / setup -----
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var age: String = ""
    @Published var password: String = ""
    @Published var hasSetup: Bool = false
    @Published var wallpaper: String = "default"

    // ----- Boot drive choice -----
    @Published var bootDriveMode: BootDriveMode = .none

    var userName: String { "\(lastName) \(firstName)".trimmingCharacters(in: .whitespaces) }

    private let defaults = UserDefaults.standard

    init() {
        load()
        fetchAppCatalog()
    }

    // MARK: - Persistence

    func load() {
        firstName = defaults.string(forKey: WOSConstants.Keys.firstName) ?? ""
        lastName = defaults.string(forKey: WOSConstants.Keys.lastName) ?? ""
        age = defaults.string(forKey: WOSConstants.Keys.age) ?? ""
        password = defaults.string(forKey: WOSConstants.Keys.password) ?? ""
        hasSetup = defaults.bool(forKey: WOSConstants.Keys.hasSetup)
        wallpaper = defaults.string(forKey: WOSConstants.Keys.wallpaper) ?? "default"
        if let data = defaults.data(forKey: WOSConstants.Keys.installedApps),
           let apps = try? JSONDecoder().decode([RealApp].self, from: data) {
            installedApps = apps
        }
        if let data = defaults.data(forKey: WOSConstants.Keys.bootDriveMode),
           let mode = try? JSONDecoder().decode(BootDriveMode.self, from: data) {
            bootDriveMode = mode
        }
    }

    func completeSetup(firstName: String, lastName: String, age: String, password: String, wallpaper: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.password = password
        self.wallpaper = wallpaper
        self.hasSetup = true
        defaults.set(firstName, forKey: WOSConstants.Keys.firstName)
        defaults.set(lastName, forKey: WOSConstants.Keys.lastName)
        defaults.set(age, forKey: WOSConstants.Keys.age)
        defaults.set(password, forKey: WOSConstants.Keys.password)
        defaults.set(true, forKey: WOSConstants.Keys.hasSetup)
        defaults.set(wallpaper, forKey: WOSConstants.Keys.wallpaper)
    }

    func setWallpaper(_ id: String) {
        wallpaper = id
        defaults.set(id, forKey: WOSConstants.Keys.wallpaper)
    }

    func setBootDriveMode(_ mode: BootDriveMode) {
        bootDriveMode = mode
        if let data = try? JSONEncoder().encode(mode) {
            defaults.set(data, forKey: WOSConstants.Keys.bootDriveMode)
        }
    }

    func factoryReset() {
        [WOSConstants.Keys.firstName, WOSConstants.Keys.lastName, WOSConstants.Keys.age,
         WOSConstants.Keys.password, WOSConstants.Keys.hasSetup, WOSConstants.Keys.wallpaper,
         WOSConstants.Keys.installedApps, WOSConstants.Keys.bootDriveMode
        ].forEach { defaults.removeObject(forKey: $0) }
        firstName = ""; lastName = ""; age = ""; password = ""
        hasSetup = false; wallpaper = "default"; installedApps = []
        bootDriveMode = .none
        windows = []
        screen = .setup
    }

    // MARK: - Boot sequence

    func boot() {
        screen = .boot
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            self.screen = self.hasSetup ? .lock : .setup
        }
    }

    func rebootThenDesktop() {
        screen = .boot
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.screen = .desktop
        }
    }

    // MARK: - Window management

    func openApp(_ appId: String) {
        if let existing = windows.first(where: { $0.appId == appId }) {
            existing.minimized = false
            bringToFront(existing.id)
            return
        }
        let registry = SystemAppsData.find(appId)
        let title = registry?.title ?? appId.capitalized
        let iconSymbol = registry?.iconSymbol ?? "app.fill"
        let colorHex = registry?.colorHex ?? "1a1a1a"
        let offset = CGFloat(windows.count % 5) * 16
        let win = WindowInstance(appId: appId, title: title, iconSymbol: iconSymbol, colorHex: colorHex,
                                  x: 24 + offset, y: 90 + offset)
        windows.append(win)
        frontWindowId = win.id
    }

    func closeWindow(_ id: UUID) {
        windows.removeAll { $0.id == id }
        if frontWindowId == id { frontWindowId = windows.last?.id }
    }

    func minimizeWindow(_ id: UUID) {
        windows.first(where: { $0.id == id })?.minimized = true
    }

    func maximizeWindow(_ id: UUID) {
        guard let win = windows.first(where: { $0.id == id }) else { return }
        win.maximized.toggle()
    }

    func bringToFront(_ id: UUID) {
        guard let index = windows.firstIndex(where: { $0.id == id }) else { return }
        let win = windows.remove(at: index)
        win.minimized = false
        windows.append(win)
        frontWindowId = win.id
    }

    // MARK: - Installed real apps

    func installApp(_ app: RealApp) {
        guard !installedApps.contains(where: { $0.id == app.id }) else { return }
        installedApps.append(app)
        persistInstalledApps()
    }

    func uninstallApp(_ app: RealApp) {
        installedApps.removeAll { $0.id == app.id }
        persistInstalledApps()
    }

    func isInstalled(_ id: String) -> Bool {
        installedApps.contains(where: { $0.id == id })
    }

    private func persistInstalledApps() {
        if let data = try? JSONEncoder().encode(installedApps) {
            defaults.set(data, forKey: WOSConstants.Keys.installedApps)
        }
    }

    // MARK: - App Catalog (from GitHub)

    private func fetchAppCatalog() {
        AppCatalogService.shared.fetchCatalog { [weak self] catalog in
            SystemAppsData.updateFromCatalog(catalog)
            self?.objectWillChange.send()
        }
    }

    func refreshAppCatalog() {
        AppCatalogService.shared.fetchCatalog { [weak self] catalog in
            SystemAppsData.updateFromCatalog(catalog)
            self?.objectWillChange.send()
        }
    }

    func resetAppCatalog() {
        AppCatalogService.shared.resetCatalog()
        SystemAppsData.resetToDefaults()
        objectWillChange.send()
    }
}
