// SystemState.swift
// Ported from App.js's WOSContext + all the useState/AsyncStorage wiring
// that used to be spread across DesktopScreen.js, LockScreen.js,
// SetupScreen.js, SettingsScreen.js and Window.js. This is the single
// source of truth for the whole OS, injected as @EnvironmentObject.
import SwiftUI
import Combine

enum ScreenState: Equatable {
    case boot
    case setup
    case lock
    case desktop
}

/// One open "window" on the desktop — ported from the `windows` array that
/// used to live in App.js and get rendered by Window.js.
final class WindowInstance: Identifiable, ObservableObject, Equatable {
    let id = UUID()
    let appId: String
    let title: String
    let icon: IconRef
    let color: Color
    @Published var x: CGFloat
    @Published var y: CGFloat
    @Published var width: CGFloat
    @Published var height: CGFloat
    @Published var minimized: Bool = false
    @Published var maximized: Bool = false

    init(appId: String, title: String, icon: IconRef, color: Color,
         x: CGFloat = 24, y: CGFloat = 90, width: CGFloat = 340, height: CGFloat = 480) {
        self.appId = appId
        self.title = title
        self.icon = icon
        self.color = color
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    static func == (lhs: WindowInstance, rhs: WindowInstance) -> Bool { lhs.id == rhs.id }
}

final class SystemState: ObservableObject {
    // ----- Screen routing (setScreen in the old context) -----
    @Published var screen: ScreenState = .boot

    // ----- Windows (openWindow/closeWindow/minimizeWindow/maximizeWindow/bringToFront) -----
    @Published var windows: [WindowInstance] = []
    @Published var frontWindowId: UUID?

    // ----- Overlay panels (ControlCenter/NotificationCenter/Search/Multitask) -----
    @Published var showControlCenter = false
    @Published var showNotifications = false
    @Published var showSearch = false
    @Published var showMultitask = false

    // ----- Installed real apps (AsyncStorage @wos_installed_apps) -----
    @Published var installedApps: [RealApp] = []

    // ----- Profile / setup (AsyncStorage @wos_firstName / lastName / age / password) -----
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var age: String = ""
    @Published var password: String = ""
    @Published var hasSetup: Bool = false
    @Published var wallpaper: String = "default"

    // ----- Boot drive choice (NEW feature requested on top of the original app) -----
    @Published var bootDriveMode: BootDriveMode = .none

    var userName: String { "\(lastName) \(firstName)".trimmingCharacters(in: .whitespaces) }

    private let defaults = UserDefaults.standard

    init() {
        load()
    }

    // ---------------- Persistence (mirrors AsyncStorage keys 1:1) ----------------
    private enum Keys {
        static let firstName = "wos_firstName"
        static let lastName = "wos_lastName"
        static let age = "wos_age"
        static let password = "wos_password"
        static let hasSetup = "wos_has_setup"
        static let wallpaper = "wos_wallpaper"
        static let installedApps = "wos_installed_apps"
        static let bootDriveMode = "wos_boot_drive_mode"
    }

    func load() {
        firstName = defaults.string(forKey: Keys.firstName) ?? ""
        lastName = defaults.string(forKey: Keys.lastName) ?? ""
        age = defaults.string(forKey: Keys.age) ?? ""
        password = defaults.string(forKey: Keys.password) ?? ""
        hasSetup = defaults.bool(forKey: Keys.hasSetup)
        wallpaper = defaults.string(forKey: Keys.wallpaper) ?? "default"
        if let data = defaults.data(forKey: Keys.installedApps),
           let apps = try? JSONDecoder().decode([RealApp].self, from: data) {
            installedApps = apps
        }
        if let data = defaults.data(forKey: Keys.bootDriveMode),
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
        defaults.set(firstName, forKey: Keys.firstName)
        defaults.set(lastName, forKey: Keys.lastName)
        defaults.set(age, forKey: Keys.age)
        defaults.set(password, forKey: Keys.password)
        defaults.set(true, forKey: Keys.hasSetup)
        defaults.set(wallpaper, forKey: Keys.wallpaper)
    }

    func setWallpaper(_ id: String) {
        wallpaper = id
        defaults.set(id, forKey: Keys.wallpaper)
    }

    func setBootDriveMode(_ mode: BootDriveMode) {
        bootDriveMode = mode
        if let data = try? JSONEncoder().encode(mode) {
            defaults.set(data, forKey: Keys.bootDriveMode)
        }
    }

    func factoryReset() {
        [Keys.firstName, Keys.lastName, Keys.age, Keys.password, Keys.hasSetup,
         Keys.wallpaper, Keys.installedApps, Keys.bootDriveMode].forEach { defaults.removeObject(forKey: $0) }
        firstName = ""; lastName = ""; age = ""; password = ""
        hasSetup = false; wallpaper = "default"; installedApps = []
        bootDriveMode = .none
        windows = []
        screen = .setup
    }

    // ---------------- Boot sequence (App.js useEffect that checks setup) ----------------
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

    // ---------------- Window management (Window.js + DesktopScreen.js logic) ----------------
    func openApp(_ appId: String) {
        // If already open, just bring to front instead of duplicating (matches
        // DesktopScreen's dock behaviour: tapping an already-open dock icon focuses it).
        if let existing = windows.first(where: { $0.appId == appId }) {
            existing.minimized = false
            bringToFront(existing.id)
            return
        }
        let registry = SystemAppsData.find(appId)
        let title = registry?.title ?? appId.capitalized
        let icon = registry?.icon ?? IconRef(symbol: "app.fill")
        let color = registry?.color ?? .wosPanelAlt
        let offset = CGFloat(windows.count % 5) * 16
        let win = WindowInstance(appId: appId, title: title, icon: icon, color: color,
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

    // ---------------- Installed real apps (AppStoreScreen.js install/uninstall) ----------------
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
            defaults.set(data, forKey: Keys.installedApps)
        }
    }
}
