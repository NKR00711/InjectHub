//
//  UpdateManager.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import SwiftUI
import Foundation
import AppKit

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    @StateObject private var logManager = LogManager.shared

    /// Check for updates. Set `showAlertOnly` to true to only notify about updates without downloading.
    func checkForUpdates(showAlertOnly: Bool = false,backgroundCheck: Bool = true) {
        guard let url = URL(string: "https://github.com/NKR00711/InjectHub/raw/refs/heads/main/update.json") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let info = try? JSONDecoder().decode(UpdateInfo.self, from: data) else {
                DispatchQueue.main.async {
                    if showAlertOnly, !backgroundCheck {
                        self.showNoUpdateAlert()
                    }
                }
                return
            }

            let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            let isUpdateAvailable = info.build.compare(currentBuild, options: .numeric) == .orderedDescending

            DispatchQueue.main.async {
                if isUpdateAvailable {
                    if showAlertOnly {
                        self.showUpdateAlert(info: info)
                    } else if let url = URL(string: info.download_url) {
                        self.downloadAndInstallUpdate(from: url)
                    }
                } else if showAlertOnly, !backgroundCheck {
                    self.showNoUpdateAlert()
                }
            }
        }.resume()
    }

    /// Download and install the update from a URL
    func downloadAndInstallUpdate(from url: URL) {
        URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL else {
                self.logManager.addLog("❌ Download failed: \(error?.localizedDescription ?? "Unknown error")", type: .error)
                return
            }

            let fileManager = FileManager.default
            let appName = Bundle.main.bundleURL.lastPathComponent
            let destinationPath = "/Applications/\(appName)"
            let destinationURL = URL(fileURLWithPath: destinationPath)

            DispatchQueue.main.async {
                do {
                    // Remove old app
                    if fileManager.fileExists(atPath: destinationPath) {
                        try fileManager.removeItem(at: destinationURL)
                    }

                    if tempURL.pathExtension == "zip" {
                        // Unzip and move
                        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
                        try self.unzipItem(at: tempURL, to: tempDir)

                        let extractedApp = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
                            .first(where: { $0.pathExtension == "app" }) ?? tempDir

                        try fileManager.moveItem(at: extractedApp, to: destinationURL)
                    } else if tempURL.pathExtension == "app" {
                        try fileManager.moveItem(at: tempURL, to: destinationURL)
                    } else {
                        throw NSError(domain: "UpdateError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown file format."])
                    }

                    // Fix attributes and codesign
                    ShellManager.shared.runCommandAsRoot("xattr -rc \"\(destinationPath)\"") { _ in }
                    ShellManager.shared.runCommandAsRoot("codesign -f -s - --deep \"\(destinationPath)\"") { _ in }

                    // Relaunch app
                    try Process.run(URL(fileURLWithPath: "/usr/bin/open"), arguments: [destinationPath])
                    exit(0)
                } catch {
                    self.logManager.addLog("❌ Update failed: \(error.localizedDescription)", type: .error)
                }
            }
        }.resume()
    }

    /// Show update available alert
    private func showUpdateAlert(info: UpdateInfo) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = "Version \(info.version) is available.\n\n\(info.notes)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Update")
        alert.addButton(withTitle: "Later")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn, let url = URL(string: info.download_url) {
            self.downloadAndInstallUpdate(from: url)
        }
    }

    /// Show no update available alert
    private func showNoUpdateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're up to date!"
        alert.informativeText = "You're already using the latest version of \(Bundle.main.bundleURL.deletingPathExtension().lastPathComponent)."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    /// Unzips a file using macOS's `unzip` utility
    private func unzipItem(at: URL, to: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", at.path, "-d", to.path]
        try process.run()
        process.waitUntilExit()
    }
}
