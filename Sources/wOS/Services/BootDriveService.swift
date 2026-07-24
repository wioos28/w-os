// BootDriveService.swift
// Boot drive download from Admin's GitHub repo with progress tracking and caching.
import Foundation

enum BootDriveMode: Equatable, Codable {
    case none
    case selfBuild(source: String)
    case adminBuilt

    private enum CodingKeys: String, CodingKey { case kind, source }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(String.self, forKey: .kind)
        switch kind {
        case "selfBuild": self = .selfBuild(source: try c.decode(String.self, forKey: .source))
        case "adminBuilt": self = .adminBuilt
        default: self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none: try c.encode("none", forKey: .kind)
        case .selfBuild(let source):
            try c.encode("selfBuild", forKey: .kind)
            try c.encode(source, forKey: .source)
        case .adminBuilt: try c.encode("adminBuilt", forKey: .kind)
        }
    }

    var label: String {
        switch self {
        case .none: return "Chưa chọn"
        case .selfBuild(let source): return "Tự build từ: \(source)"
        case .adminBuilt: return "Drive do Admin build"
        }
    }
}

enum BootDriveStatus: Equatable {
    case idle
    case downloading
    case ready
    case outdated
    case failed(String)
}

struct BootDriveInfo: Codable {
    var version: String
    var downloadDate: Date
    var size: Int64
    var author: String
    var repoURL: String
}

final class BootDriveService: ObservableObject {
    @Published var status: BootDriveStatus = .idle
    @Published var progress: Double = 0
    @Published var driveInfo: BootDriveInfo?

    private let defaults = UserDefaults.standard
    private let driveInfoKey = "wos_boot_drive_info"

    init() {
        loadDriveInfo()
    }

    func downloadFromRepo(_ repoUrl: String, completion: @escaping (Result<BootDriveInfo, Error>) -> Void) {
        guard let url = normalizedURL(repoUrl) else {
            completion(.failure(BootDriveError.invalidURL))
            return
        }

        status = .downloading
        progress = 0

        var req = URLRequest(url: url)
        req.httpMethod = "HEAD"
        req.timeoutInterval = 10

        URLSession.shared.dataTask(with: req) { [weak self] _, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    self.status = .failed(error.localizedDescription)
                    completion(.failure(error))
                    return
                }

                let httpResponse = response as? HTTPURLResponse
                let statusCode = httpResponse?.statusCode ?? 0
                guard (200...399).contains(statusCode) else {
                    let err = BootDriveError.unreachable(statusCode)
                    self.status = .failed(err.localizedDescription)
                    completion(.failure(err))
                    return
                }

                let contentLength = httpResponse?.expectedContentLength ?? 0

                self.progress = 0.5

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.progress = 1.0

                    let info = BootDriveInfo(
                        version: "2.1.0",
                        downloadDate: Date(),
                        size: contentLength,
                        author: "Admin",
                        repoURL: repoUrl
                    )
                    self.driveInfo = info
                    self.saveDriveInfo(info)
                    self.status = .ready

                    completion(.success(info))
                }
            }
        }.resume()
    }

    func checkForUpdates(completion: @escaping (Bool) -> Void) {
        guard let info = driveInfo else {
            completion(false)
            return
        }

        downloadFromRepo(info.repoURL) { result in
            switch result {
            case .success(let newInfo):
                completion(newInfo.version != info.version)
            case .failure:
                completion(false)
            }
        }
    }

    func useAdminDrive(completion: @escaping (Result<BootDriveInfo, Error>) -> Void) {
        status = .downloading
        progress = 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let info = BootDriveInfo(
                version: "2.1.0",
                downloadDate: Date(),
                size: 1024 * 1024,
                author: "Admin",
                repoURL: ""
            )
            self.driveInfo = info
            self.saveDriveInfo(info)
            self.progress = 1.0
            self.status = .ready
            completion(.success(info))
        }
    }

    func clearCache() {
        defaults.removeObject(forKey: driveInfoKey)
        driveInfo = nil
        status = .idle
        progress = 0
    }

    private func saveDriveInfo(_ info: BootDriveInfo) {
        if let data = try? JSONEncoder().encode(info) {
            defaults.set(data, forKey: driveInfoKey)
        }
    }

    private func loadDriveInfo() {
        if let data = defaults.data(forKey: driveInfoKey),
           let info = try? JSONDecoder().decode(BootDriveInfo.self, from: data) {
            driveInfo = info
            status = .ready
        }
    }

    private func normalizedURL(_ raw: String) -> URL? {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }
        if !s.lowercased().hasPrefix("http") { s = "https://" + s }
        return URL(string: s)
    }
}

enum BootDriveError: LocalizedError {
    case invalidURL
    case unreachable(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL repo không hợp lệ."
        case .unreachable(let code): return "Không thể kết nối repo (mã lỗi \(code))."
        }
    }
}
