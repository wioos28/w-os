// WOSConstants.swift
// Shared constants for the OS core layer.
import Foundation

enum WOSConstants {
    static let version = "2.3.0"
    static let repoOwner = "wioos28"
    static let repoName = "w-os"
    static let branch = "main"

    static var repoURL: String { "https://github.com/\(repoOwner)/\(repoName)" }
    static var catalogURL: String {
        "https://raw.githubusercontent.com/\(repoOwner)/\(repoName)/\(branch)/apps.json"
    }
    static var versionURL: String {
        "https://raw.githubusercontent.com/\(repoOwner)/\(repoName)/\(branch)/Sources/wOS/Resources/version.json"
    }

    enum Keys {
        static let firstName = "wos_firstName"
        static let lastName = "wos_lastName"
        static let age = "wos_age"
        static let password = "wos_password"
        static let hasSetup = "wos_has_setup"
        static let wallpaper = "wos_wallpaper"
        static let installedApps = "wos_installed_apps"
        static let bootDriveMode = "wos_boot_drive_mode"
        static let appCatalog = "wos_app_catalog"
        static let catalogUpdated = "wos_catalog_updated"
        static let catalogCache = "wos_catalog_cache"
        static let installedVersion = "wos_installed_version"
        static let bootDriveInfo = "wos_boot_drive_info"
        static let apiBaseURL = "wos_api_base_url"
    }
}
