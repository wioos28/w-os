// WOSShellState.swift
// UI-layer state wrapper — adds overlay toggles on top of core SystemState.
import SwiftUI
import WOSCore

final class WOSShellState: ObservableObject {
    let core: SystemState

    // ----- Overlay panels (UI-only concerns) -----
    @Published var showControlCenter = false
    @Published var showNotifications = false
    @Published var showSearch = false
    @Published var showMultitask = false

    init(core: SystemState = SystemState()) {
        self.core = core
    }

    // MARK: - Forwarded core properties

    var screen: ScreenState {
        get { core.screen }
        set { core.screen = newValue }
    }

    var windows: [WindowInstance] { core.windows }
    var frontWindowId: UUID? { core.frontWindowId }
    var installedApps: [RealApp] { core.installedApps }
    var firstName: String { core.firstName }
    var lastName: String { core.lastName }
    var age: String { core.age }
    var password: String { core.password }
    var hasSetup: Bool { core.hasSetup }
    var wallpaper: String { core.wallpaper }
    var bootDriveMode: BootDriveMode { core.bootDriveMode }
    var userName: String { core.userName }

    // MARK: - Forwarded core methods

    func boot() { core.boot() }
    func rebootThenDesktop() { core.rebootThenDesktop() }
    func openApp(_ appId: String) { core.openApp(appId) }
    func closeWindow(_ id: UUID) { core.closeWindow(id) }
    func minimizeWindow(_ id: UUID) { core.minimizeWindow(id) }
    func maximizeWindow(_ id: UUID) { core.maximizeWindow(id) }
    func bringToFront(_ id: UUID) { core.bringToFront(id) }
    func installApp(_ app: RealApp) { core.installApp(app) }
    func uninstallApp(_ app: RealApp) { core.uninstallApp(app) }
    func isInstalled(_ id: String) -> Bool { core.isInstalled(id) }
    func completeSetup(firstName: String, lastName: String, age: String, password: String, wallpaper: String) {
        core.completeSetup(firstName: firstName, lastName: lastName, age: age, password: password, wallpaper: wallpaper)
    }
    func setWallpaper(_ id: String) { core.setWallpaper(id) }
    func setBootDriveMode(_ mode: BootDriveMode) { core.setBootDriveMode(mode) }
    func factoryReset() { core.factoryReset() }
    func refreshAppCatalog() { core.refreshAppCatalog() }
    func resetAppCatalog() { core.resetAppCatalog() }
}
