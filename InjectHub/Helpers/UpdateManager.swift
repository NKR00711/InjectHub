//
//  UpdateManager.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import Foundation
import SwiftUI

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    @StateObject private var logManager = LogManager.shared

//    func checkForUpdates(showAlertOnly: Bool = false) {
//        guard let url = URL(string: "https://github.com/NKR00711/InjectHub/raw/refs/heads/main/update.json") else { return }
//
//        URLSession.shared.dataTask(with: url) { data, _, _ in
//            guard let data = data,
//                  let info = try? JSONDecoder().decode(UpdateInfo.self, from: data) else {
//                DispatchQueue.main.async {
//                    self.showNoUpdateAlert() // fallback alert
//                }
//                return
//            }
//
//            let current = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
//            if info.build.compare(current, options: .numeric) == .orderedDescending {
//                DispatchQueue.main.async {
//                    // show update alert and download if necessary
//                    if let downloadURL = URL(string: info.download_url), !showAlertOnly {
//                        self.downloadAndInstallUpdate(from: downloadURL)
//                    } else {
//                        self.showUpdateAlert(info: info)
//                    }
//                }
//            } else if showAlertOnly {
//                DispatchQueue.main.async {
//                    self.showNoUpdateAlert()
//                }
//            }
//        }.resume()
//    }
    /// Checks for updates and either shows alert or downloads
    func checkForUpdates(showAlertOnly: Bool = false) {
        guard let url = URL(string: "https://github.com/NKR00711/InjectHub/raw/refs/heads/main/update.json") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let info = try? JSONDecoder().decode(UpdateInfo.self, from: data) else {
                DispatchQueue.main.async {
                    self.showNoUpdateAlert() // fallback alert
                }
                return
            }

            let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            if info.build.compare(currentBuild, options: .numeric) == .orderedDescending {
                DispatchQueue.main.async {
                    if showAlertOnly {
                        self.showUpdateAlert(info: info)
                    } else {
                        if let url = URL(string: info.download_url) {
                            self.downloadAndInstallUpdate(from: url)
                        }
                    }
                }
            }
        }.resume()
    }

    /// Downloads and installs the update, replacing current app
    func downloadAndInstallUpdate(from url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL else {
                self.logManager.addLog("❌ Download failed: \(error?.localizedDescription ?? "Unknown error")", type: .error)
                print("❌ Download failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let fileManager = FileManager.default
            let destinationPath = "/Applications/\(Bundle.main.bundleURL.lastPathComponent)"
            let destinationURL = URL(fileURLWithPath: destinationPath)

            DispatchQueue.main.async {
                do {
                    // Remove old app if exists
                    if fileManager.fileExists(atPath: destinationPath) {
                        try fileManager.removeItem(at: destinationURL)
                    }

                    // Unzip or move the new app to /Applications
                    // Assumes ZIP — change if your server sends `.app` directly
                    try self.unzipItem(at: tempURL, to: destinationURL)

                    // Relaunch app
                    try Process.run(URL(fileURLWithPath: "/usr/bin/open"), arguments: [destinationPath])
                    exit(0)
                } catch {
                    self.logManager.addLog("❌ Failed to replace app: \(error.localizedDescription)", type: .error)
                    print("❌ Failed to replace app: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    /// Shows an alert (can replace with SwiftUI alert callback)
    private func showUpdateAlert(info: UpdateInfo) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = "Version \(info.version) is available.\nWould you like to update now? \n\(info.notes)"

        alert.alertStyle = .informational
        alert.addButton(withTitle: "Update")
        alert.addButton(withTitle: "Later")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: info.download_url) {
                self.downloadAndInstallUpdate(from: url)
            }
        }
    }
    
    private func unzipItem(at: URL, to: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", at.path, "-d", to.path]
        try process.run()
        process.waitUntilExit()
    }
    
    private func showNoUpdateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're up to date"
        alert.informativeText = "You're already using the latest version of \(Bundle.main.bundleURL.lastPathComponent)."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
