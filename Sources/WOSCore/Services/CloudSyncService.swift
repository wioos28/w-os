// CloudSyncService.swift
// Client for the W OS cloud server. No SwiftUI dependency.
import Foundation

struct RemoteNote: Codable {
    var id: String
    var title: String
    var content: String
    var updatedAt: String? = nil
}

final class CloudSyncService {
    static let shared = CloudSyncService()
    private let defaults = UserDefaults.standard
    private let timeout: TimeInterval = 6

    var baseURL: String {
        get { (defaults.string(forKey: WOSConstants.Keys.apiBaseURL) ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        set { defaults.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: WOSConstants.Keys.apiBaseURL) }
    }

    private func session() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        return URLSession(configuration: config)
    }

    private func request(_ path: String) -> URLRequest? {
        guard !baseURL.isEmpty, let url = URL(string: baseURL + path) else { return nil }
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }

    // ---------- Health ----------
    func checkConnection(completion: @escaping (Bool) -> Void) {
        guard let req = request("/api/health") else { completion(false); return }
        session().dataTask(with: req) { data, response, error in
            let ok = error == nil && (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(ok) }
        }.resume()
    }

    // ---------- Real-app catalog (synced from cloud) ----------
    func getRealAppsCatalog(completion: @escaping (_ apps: [RealApp], _ source: String) -> Void) {
        guard let req = request("/api/catalog") else {
            completion(RealAppsData.all, "offline")
            return
        }
        session().dataTask(with: req) { [weak self] data, response, error in
            guard let self = self, error == nil, let data = data,
                  let decoded = try? JSONDecoder().decode([RealApp].self, from: data), !decoded.isEmpty else {
                if let cached = self?.defaults.data(forKey: WOSConstants.Keys.catalogCache),
                   let apps = try? JSONDecoder().decode([RealApp].self, from: cached) {
                    DispatchQueue.main.async { completion(apps, "cache") }
                } else {
                    DispatchQueue.main.async { completion(RealAppsData.all, "offline") }
                }
                return
            }
            if let encoded = try? JSONEncoder().encode(decoded) {
                self.defaults.set(encoded, forKey: WOSConstants.Keys.catalogCache)
            }
            DispatchQueue.main.async { completion(decoded, "cloud") }
        }.resume()
    }

    // ---------- Notes sync ----------
    func fetchRemoteNotes(completion: @escaping ([RemoteNote]?) -> Void) {
        guard let req = request("/api/notes") else { completion(nil); return }
        session().dataTask(with: req) { data, _, error in
            guard error == nil, let data = data, let notes = try? JSONDecoder().decode([RemoteNote].self, from: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(notes) }
        }.resume()
    }

    func pushNote(_ note: RemoteNote, completion: @escaping (Bool) -> Void) {
        guard var req = request("/api/notes"), let body = try? JSONEncoder().encode(note) else {
            completion(false); return
        }
        req.httpMethod = "POST"
        req.httpBody = body
        session().dataTask(with: req) { _, response, error in
            let ok = error == nil && (200...299).contains((response as? HTTPURLResponse)?.statusCode ?? 0)
            DispatchQueue.main.async { completion(ok) }
        }.resume()
    }

    func deleteRemoteNote(_ id: String, completion: @escaping (Bool) -> Void) {
        guard var req = request("/api/notes/\(id)") else { completion(false); return }
        req.httpMethod = "DELETE"
        session().dataTask(with: req) { _, response, error in
            let ok = error == nil && (200...299).contains((response as? HTTPURLResponse)?.statusCode ?? 0)
            DispatchQueue.main.async { completion(ok) }
        }.resume()
    }
}
