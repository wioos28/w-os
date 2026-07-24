// AppCatalogService.swift
// Fetches the system app catalog from GitHub repo (apps.json).
// Falls back to local defaults if offline. No SwiftUI dependency.
import Foundation

struct AppCatalogEntry: Codable, Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: String
    var enabled: Bool
    var dock: Bool
}

struct AppCatalog: Codable {
    let version: String
    let apps: [AppCatalogEntry]
}

final class AppCatalogService: ObservableObject {
    static let shared = AppCatalogService()

    @Published var catalog: AppCatalog?
    @Published var lastUpdated: String = ""

    private let defaults = UserDefaults.standard

    init() {
        loadLocal()
    }

    // MARK: - Public API

    func fetchCatalog(completion: @escaping (AppCatalog) -> Void) {
        guard let url = URL(string: WOSConstants.catalogURL) else { return }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        let session = URLSession(configuration: config)

        session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("[AppCatalog] Fetch failed: \(error.localizedDescription), using cache")
                DispatchQueue.main.async {
                    if let cached = self.catalog { completion(cached) }
                }
                return
            }

            guard let data = data,
                  let decoded = try? JSONDecoder().decode(AppCatalog.self, from: data) else {
                DispatchQueue.main.async {
                    if let cached = self.catalog { completion(cached) }
                }
                return
            }

            self.catalog = decoded
            self.saveLocal(decoded)
            self.lastUpdated = ISO8601DateFormatter().string(from: Date())
            self.defaults.set(self.lastUpdated, forKey: WOSConstants.Keys.catalogUpdated)

            DispatchQueue.main.async { completion(decoded) }
        }.resume()
    }

    func fetchCatalogAsync() async -> AppCatalog? {
        await withCheckedContinuation { continuation in
            fetchCatalog { catalog in
                continuation.resume(returning: catalog)
            }
        }
    }

    // MARK: - Convert to SystemApp

    func toSystemApps(_ catalog: AppCatalog) -> [SystemApp] {
        catalog.apps.filter { $0.enabled }.map { entry in
            SystemApp(
                id: entry.id,
                title: entry.title,
                iconSymbol: entry.icon,
                colorHex: entry.color
            )
        }
    }

    func dockIds(_ catalog: AppCatalog) -> [String] {
        catalog.apps.filter { $0.dock && $0.enabled }.map(\.id)
    }

    // MARK: - Persistence

    private func saveLocal(_ catalog: AppCatalog) {
        if let data = try? JSONEncoder().encode(catalog) {
            defaults.set(data, forKey: WOSConstants.Keys.appCatalog)
        }
    }

    private func loadLocal() {
        if let data = defaults.data(forKey: WOSConstants.Keys.appCatalog),
           let decoded = try? JSONDecoder().decode(AppCatalog.self, from: data) {
            catalog = decoded
        }
        lastUpdated = defaults.string(forKey: WOSConstants.Keys.catalogUpdated) ?? ""
    }

    func resetCatalog() {
        defaults.removeObject(forKey: WOSConstants.Keys.appCatalog)
        defaults.removeObject(forKey: WOSConstants.Keys.catalogUpdated)
        catalog = nil
        lastUpdated = ""
    }
}
