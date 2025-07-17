//
//  AppInfoRowView.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//

import SwiftUI
import AppKit

import SwiftUI
import AppKit

struct FileInfoRowView: View {
    @Binding var dylibPath: URL?
    @Binding var fileURL: URL?
    @Binding var fileToInject: URL?
    @ObservedObject var logManager: LogManager
    @State var dylibDest: String = ""
    @State var mainExec: String = ""

    
    @State private var appPath: String = ""
    @State private var icon: NSImage?
    @State private var appName: String = ""
    @State private var bundleID: String = ""
    @State private var version: String = ""
    @State private var fullVersion: String = ""
    @State private var architectures: [String] = []
    
    @AppStorage("stripCodeSign") private var stripCodeSign = false
    @AppStorage("noBackup") private var noBackup = false
    @AppStorage("rootMode") private var rootMode = true
    @AppStorage("autoDeQuarantine") private var autoDeQuarantine = true
    @AppStorage("dummyCodeSign") private var dummyCodeSign = true
    @AppStorage("specialInject") private var specialInject = false
    
    @State private var didLoadInfo = false

    var body: some View {
        VStack(alignment: .leading) {
            if let fileURL = fileURL, let fileToInject = fileToInject {
                VStack {
                    HStack {
                        Image(nsImage: icon ?? NSWorkspace.shared.icon(forFile: fileURL.path))
                            .resizable()
                            .interpolation(.high)
                            .frame(width: 64, height: 64)
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appName)
                                .font(.system(size: 20, weight: .semibold))
                            
                            Text("Version \(version) (\(fullVersion))")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }

                    VStack(alignment: .leading) {

                        VStack(alignment: .leading, spacing: 12) {
                            Text("App Information")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 10) {
                                InfoRow(title: "Bundle ID", value: bundleID, icon: "info.circle.fill")
                                
                                InfoRow(title: LocalizedStringKey("Target File"), value: fileToInject.path, icon: "doc.fill")
                                InfoRow(title: "Architectures", value: "[\(architectures.joined(separator: "  "))]", icon: "cpu")
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Action Buttons section - Reorganized into a grid
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 120, maximum: 130), spacing: 12),
                            ], spacing: 12) {
                                
                                if specialInject, let dylibPath = dylibPath {
                                    ActionButton(
                                        title: "Try",
                                        icon: "bolt",
                                        isPrimary: 0,
                                        action: {
                                            ShellManager.shared.runCommandInTerminal("""
                                                echo "dylib_path: \(dylibPath.path)"
                                                echo "app_path: \(mainExec)"
                                                env DYLD_INSERT_LIBRARIES="\(dylibPath.path)\" "\(mainExec)\"
                                                """) { result in
                                                switch result {
                                                case .success(let output):
                                                    self.logManager.addLog("Output: \(output)", type: .info)
                                                    print("Output: \(output)")
                                                case .failure(let error):
                                                    self.logManager.addLog("Error: \(error.localizedDescription)", type: .error)
                                                    print("Error: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                    )
                                }
                                
                                if let dylibPath = dylibPath {
                                    ActionButton(
                                        title: "Inject",
                                        icon: "bolt.circle",
                                        isPrimary: 1,
                                        action: {
                                            ShellManager.shared.InjectDylib(targetPath: fileToInject, dylibPath: dylibPath, dylibDestination: dylibDest)
                                    
                                            let bundleURL = URL(fileURLWithPath: appPath)

                                                if let bundle = Bundle(url: bundleURL),
                                                   let bundleID = bundle.bundleIdentifier {

                                                    let savedApp = SavedApp(
                                                        name: bundleURL.lastPathComponent,
                                                        bundlePath: appPath,
                                                        bundleID: bundleID,
                                                        dylibPath: dylibPath.path,
                                                        targetFile: fileToInject.path
                                                    )

                                                    SavedAppManager.shared.addOrUpdate(savedApp)
                                                    logManager.addLog("✅ App saved: \(savedApp.name)", type: .success)

                                                } else {
                                                    logManager.addLog("❌ Invalid bundle or missing bundle ID", type: .error)
                                                }
                                        }
                                    )
                                }
                                
                                if !appPath.isEmpty {
                                    ActionButton(
                                        title: "Run App",
                                        icon: "play.fill",
                                        action: { NSWorkspace.shared.open(URL(fileURLWithPath: appPath)) }
                                    )
                                    
                                    ActionButton(
                                        title: "DeQuarantine",
                                        icon: "arrow.right.circle",
                                        isPrimary: 1,
                                        action: {
                                            ShellManager.shared.runCommandAsRoot("sudo xattr -rc \"\(appPath)\"") { result in
                                                switch result {
                                                case .success(let output):
                                                    self.logManager.addLog("Output: \(output)", type: .info)
                                                    print("Output: \(output)")
                                                    if self.dummyCodeSign && !ShellManager.shared.isSIPDisabled() {
                                                        ShellManager.shared.runCommandAsRoot("sudo codesign -f -s - --deep \"\(appPath)\"") { result in
                                                            switch result {
                                                            case .success(let output):
                                                                self.logManager.addLog("Output: \(output)", type: .info)
                                                                print("Output: \(output)")
                                                            case .failure(let error):
                                                                self.logManager.addLog("Error: \(error.localizedDescription)", type: .error)
                                                                print("Error: \(error.localizedDescription)")
                                                            }
                                                        }
                                                    }
                                                case .failure(let error):
                                                    self.logManager.addLog("Error: \(error.localizedDescription)", type: .error)
                                                    print("Error: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                    )
                                }
                                
                                ActionButton(
                                    title: "Show in Finder",
                                    icon: "folder",
                                    action: {
                                        NSWorkspace.shared.selectFile(appPath, inFileViewerRootedAtPath: "")
                                    }
                                )
                                
                                restoreButtonView(fileToInject: fileToInject)

                            }
                        }
                        .padding(14)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }

                    Spacer()
                }
            } else {
                HomePagePreview()
            }
        }
//        .padding(.vertical)
        .onChange(of: fileURL) { oldValue, newValue in
            if oldValue == newValue { return }
            loadAppInfo()
        }
        .onChange(of: fileToInject) { oldValue, newValue in
            if oldValue == newValue { return }
            loadAppInfo()
        }
        .onAppear {
            guard !didLoadInfo else { return }
                didLoadInfo = true
            loadAppInfo()
        }
    }

    private func loadAppInfo() {
        guard let appURL = (fileToInject?.path.isEmpty == false) ? fileToInject : fileURL else { return }

        self.icon = NSWorkspace.shared.icon(forFile: appURL.path)

        let bundleURL = findEnclosingAppBundle(for: appURL)

        if let bundle = bundleURL.flatMap(Bundle.init(url:)), bundle.bundleIdentifier != nil {
            // Valid .app bundle found
            self.appName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? bundleURL!.deletingPathExtension().lastPathComponent
            self.bundleID = bundle.bundleIdentifier ?? "Unknown"
            self.version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
            self.fullVersion = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
            self.icon = NSWorkspace.shared.icon(forFile: bundleURL!.path)
            if let tmpbundle = bundleURL.flatMap(Bundle.init(url:)), tmpbundle.bundleIdentifier != nil {
                if isUnixExecutable(fileURL: appURL) {
                    fileToInject = appURL
                    dylibDest = tmpbundle.executableURL!.deletingLastPathComponent().path
                    mainExec = tmpbundle.executableURL!.path
                    print("The selected file is a binary executable. \(appURL.path)")
                } else {
                    fileToInject = tmpbundle.executableURL
                    dylibDest = tmpbundle.executableURL!.deletingLastPathComponent().path
                    mainExec = tmpbundle.executableURL!.path
                    print("The selected file is not a binary executable. \(appURL.path)")
                }
                self.architectures = detectArchitectures(at: tmpbundle.executableURL!.path)
            } else {
                dylibDest = appURL.deletingLastPathComponent().path
                fileToInject = appURL
                mainExec = fileToInject!.path
                self.architectures = detectArchitectures(at: appURL.path)
            }
            self.appPath = bundleURL!.path
        } else {
            // It is a plain binary file
            self.appName = appURL.deletingPathExtension().lastPathComponent
            self.bundleID = getBinaryIdentifier(at: appURL) ?? "N/A"
            self.version = "—"
            fileToInject = appURL
            dylibDest = appURL.deletingLastPathComponent().path
            mainExec = appURL.path
            self.architectures = detectArchitectures(at: appURL.path)
        }
    }
    
    func isUnixExecutable(fileURL: URL) -> Bool {
        // Check if the file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            // Get the file attributes
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            
            // Check if it's a regular file
            if let fileType = attributes[.type] as? FileAttributeType {
                if fileType == .typeRegular {
                    // Check if the file is executable
                    return FileManager.default.isExecutableFile(atPath: fileURL.path)
                }
            }
        } catch {
            print("Error retrieving file attributes: \(error)")
        }
        
        return false
    }
    private func findEnclosingAppBundle(for url: URL) -> URL? {
        var currentURL = url
        for _ in 0..<7 {
            if currentURL.pathExtension == "app", FileManager.default.fileExists(atPath: currentURL.path) {
                return currentURL
            }
            currentURL.deleteLastPathComponent()
        }
        return nil
    }

    private func getBinaryIdentifier(at path: URL) -> String? {
        let task = Process()
        task.launchPath = "/usr/bin/otool"
        task.arguments = ["-l", "\"\(path.path)\""]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return nil }

        // Example: look for LC_ID_DYLIB
        if let match = output.range(of: "name ") {
            let line = output[match.upperBound...].split(separator: "\n").first ?? ""
            return line.trimmingCharacters(in: .whitespaces)
        }

        return nil
    }
    
    private func detectArchitectures(at path: String) -> [String] {
            var archs: [String] = []

            let task = Process()
            task.launchPath = "/usr/bin/lipo"
            task.arguments = ["-info", path]

            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                if output.contains("arm64") { archs.append("arm64") }
                if output.contains("x86_64") { archs.append("x86_64") }
            }

            return archs
        }
    
    struct ActionButton: View {
        let title: LocalizedStringKey
        let icon: String
        var isPrimary: Int = 3
        var isDisabled: Bool = false
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                    Text(title)
                }
                .frame(minWidth: 100, maxWidth: 130)
                .frame(height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isPrimary == 0 ? Color.red : isPrimary == 1 ? Color.blue : Color(NSColor.windowBackgroundColor))
                        .shadow(color: .black.opacity(0.1), radius: 0.5, x: 0, y: 0.5)
                )
                .foregroundColor(isPrimary == 0 || isPrimary == 1 ? .white : .primary)
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
        }
    }
    
    @ViewBuilder
    func restoreButtonView(fileToInject: URL?) -> some View {
        if let targetPath = fileToInject {
            let backupPath = targetPath.appendingPathExtension("backup")
            let fileExists = FileManager.default.fileExists(atPath: backupPath.path)

            if fileExists {
                ActionButton(
                    title: "Restore",
                    icon: "folder.fill.badge.plus",
                    action: {
                        let restoreCommand = """
                        mv ""\(backupPath.path)\"" ""\(targetPath.path)\""
                        """
                        ShellManager.shared.runCommandAsRoot(restoreCommand) { copyResult in
                            self.logManager.addLog("✅ Restore Done", type: .success)
                            print("✅ Restore Done:", copyResult)
                        }
                    }
                )
            } else {
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }

}

