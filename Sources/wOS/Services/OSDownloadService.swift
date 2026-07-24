// OSDownloadService.swift
// Downloads W OS from GitHub on first launch - dynamic system updates.
import Foundation
import SwiftUI

enum OSDownloadState: Equatable {
    case idle
    case checking
    case downloading(Double)
    case extracting
    case ready
    case failed(String)
}

struct OSVersion: Codable, Equatable {
    let version: String
    let buildDate: String
    let minIOSVersion: String
    let features: [String]
}

final class OSDownloadService: ObservableObject {
    @Published var state: OSDownloadState = .idle
    @Published var currentVersion: OSVersion?
    @Published var latestVersion: OSVersion?
    @Published var downloadProgress: Double = 0

    private let defaults = UserDefaults.standard
    private let versionKey = "wos_installed_version"
    private let osFilesKey = "wos_downloaded_files"

    // GitHub repo URL for W OS
    private let repoOwner = "wioos28"
    private let repoName = "w-os"
    private let branch = "main"

    var isOSReady: Bool {
        if let version = currentVersion, !version.version.isEmpty {
            return true
        }
        return false
    }

    init() {
        loadInstalledVersion()
    }

    // MARK: - Main Flow

    func checkAndUpdateOS() {
        state = .checking

        // First check if we have a local copy
        if isOSReady {
            // Check for updates in background
            checkForUpdate()
            return
        }

        // No local copy - download from GitHub
        downloadOS()
    }

    // MARK: - Download from GitHub

    func downloadOS() {
        state = .downloading(0)
        downloadProgress = 0

        // Download the source code as zip
        let zipURL = "https://github.com/\(repoOwner)/\(repoName)/archive/refs/heads/\(branch).zip"

        guard let url = URL(string: zipURL) else {
            state = .failed("Invalid download URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    self.state = .failed("Download failed: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self.state = .failed("Server error")
                    return
                }

                guard let data = data else {
                    self.state = .failed("No data received")
                    return
                }

                self.processDownloadedData(data)
            }
        }

        // Track progress
        let observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.downloadProgress = progress.fractionCompleted
                self?.state = .downloading(progress.fractionCompleted)
            }
        }

        task.resume()

        // Store observation to keep it alive
        objc_setAssociatedObject(task, "progressObservation", observation, .OBJC_ASSOCIATION_RETAIN)
    }

    private func processDownloadedData(_ data: Data) {
        state = .extracting

        // Save the downloaded data
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let osPath = documentsPath.appendingPathComponent("WOS_System")

        do {
            // Create directory
            try FileManager.default.createDirectory(at: osPath, withIntermediateDirectories: true)

            // Save version info
            let version = OSVersion(
                version: "2.2.0",
                buildDate: ISO8601DateFormatter().string(from: Date()),
                minIOSVersion: "16.0",
                features: [
                    "Landscape + Portrait layout",
                    "In-app browser",
                    "Glassmorphism UI",
                    "Animated boot screen",
                    "Modern lock screen",
                    "Window management",
                    "12 system apps"
                ]
            )

            let versionData = try JSONEncoder().encode(version)
            try versionData.write(to: osPath.appendingPathComponent("version.json"))

            // Save the OS data
            try data.write(to: osPath.appendingPathComponent("os_archive.zip"))

            // Update state
            self.currentVersion = version
            self.saveInstalledVersion(version)
            self.state = .ready

        } catch {
            self.state = .failed("Extraction failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Update Check

    func checkForUpdate() {
        let versionURL = "https://raw.githubusercontent.com/\(repoOwner)/\(repoName)/\(branch)/Sources/wOS/Resources/version.json"

        guard let url = URL(string: versionURL) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self,
                      let data = data,
                      let remote = try? JSONDecoder().decode(OSVersion.self, from: data) else {
                    return
                }

                self.latestVersion = remote

                if let current = self.currentVersion, remote.version != current.version {
                    // Update available
                    self.downloadOS()
                }
            }
        }.resume()
    }

    // MARK: - Persistence

    private func saveInstalledVersion(_ version: OSVersion) {
        if let data = try? JSONEncoder().encode(version) {
            defaults.set(data, forKey: versionKey)
        }
    }

    private func loadInstalledVersion() {
        if let data = defaults.data(forKey: versionKey),
           let version = try? JSONDecoder().decode(OSVersion.self, from: data) {
            currentVersion = version
        }
    }

    func getInstalledVersionString() -> String {
        currentVersion?.version ?? "Not installed"
    }

    func getInstalledFeatures() -> [String] {
        currentVersion?.features ?? []
    }
}
