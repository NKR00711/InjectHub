//
//  ContentView.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//

import SwiftUI

struct ContentView: View {
    @State private var dylibPath: URL?
    @State private var TargetPath: URL?
    @State private var InjectTargetPath: URL?
    @State private var showRootPasswordWindow = false
    @State private var hasRootPassword = false
    @State private var windowSize: CGSize = .zero
    @State private var prinstr: String = ""

    @StateObject var logManager = LogManager.shared
    @State private var passwordManager = PasswordManager()
    @AppStorage("autoCheckForUpdates") private var autoCheckForUpdates = false
    @AppStorage("autoDownloadUpdates") private var autoDownloadUpdates = false
    @AppStorage("rootMode") private var rootMode = true
    @AppStorage("useDefaultDylib") private var useDefaultDylib = false
    @AppStorage("defaultDylibPath") private var defaultDylibPath: String = ""
    @State private var selectedApp: SavedApp? = nil
    
    @State private var didLoadToolbar = false

    var body: some View {
        NavigationSplitView {
                // Sidebar
                SavedAppsSidebarView(selectedApp: $selectedApp)
            } detail: {
            ZStack {
                MainView(
                    dylibPath: $dylibPath,
                    TargetPath: $TargetPath,
                    InjectTargetPath: $InjectTargetPath,
                    showRootPasswordWindow: $showRootPasswordWindow,
                    hasRootPassword: $hasRootPassword,
                    windowSize: $windowSize,
                    prinstr: $prinstr,
                    passwordManager: $passwordManager,
                    logManager: logManager
                )
                .toolbar {
                    //            ToolbarItem(placement: .navigation) {
                    //                    // Show app icon or title
                    //                    Text("InsertDylib GUI")
                    //                        .font(.headline)
                    //                }
                    
                    ToolbarItem(placement: .primaryAction) {
                        ToolbarView(showingPasswordSheet: $showRootPasswordWindow, isPasswordSet: hasRootPassword)
                    }
                }
                .onAppear {
                    if FullDiskAccess.isGranted {
                        // Great!
                    } else {
                        FullDiskAccess.promptIfNotGranted(
                            title: "Enable Full Disk Access for InjectHub",
                            message: "InjectHub requires Full Disk Access to Easily Inject dylib and Make Backup Files.",
                            settingsButtonTitle: "Open Settings",
                            skipButtonTitle: "Later",
                            canBeSuppressed: false, // `true` will display a "Do not ask again." checkbox and honor it
                            icon: nil
                        )
                    }
                    if rootMode {
                        if passwordManager.getPassword() == nil {
                            showRootPasswordWindow = true
                            hasRootPassword = false
                        } else {
                            hasRootPassword = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                ShellManager.shared.isRunningAsRootViaAppleScript() { isRoot in
                                    if isRoot {
                                        hasRootPassword = true
                                    } else {
                                        showRootPasswordWindow = true
                                        hasRootPassword = false
                                    }
                                }
                            }
                        }
                    }
                    
                    if autoCheckForUpdates {
                        UpdateManager.shared.checkForUpdates(showAlertOnly: !autoDownloadUpdates)
                    }
                }
                .onChange(of: rootMode) { oldValue, newValue in
                    if oldValue == newValue { return }
                    if passwordManager.getPassword() == nil {
                        showRootPasswordWindow = true
                        hasRootPassword = false
                    } else {
                        hasRootPassword = true
                        ShellManager.shared.isRunningAsRootViaAppleScript() { isRoot in
                            if isRoot {
                                hasRootPassword = true
                            } else {
                                showRootPasswordWindow = true
                                hasRootPassword = false
                            }
                        }
                    }
                }
                .onChange(of: selectedApp) { oldapp, app in
                    if oldapp == app { return }
                    guard let app = app else { return }
                    dylibPath = URL(fileURLWithPath: app.dylibPath.trimmingCharacters(in: .whitespacesAndNewlines))
                    TargetPath = URL(fileURLWithPath: app.bundlePath.trimmingCharacters(in: .whitespacesAndNewlines))
                    InjectTargetPath = URL(fileURLWithPath: app.targetFile.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                .sheet(isPresented: $showRootPasswordWindow, content: {
                    PasswordView {
                        hasRootPassword = true
                        showRootPasswordWindow = false
                    }
                    .transition(.scale)
                    .animation(.easeInOut(duration: 0.25), value: showRootPasswordWindow)
                })
            }
        }
    }
}

#Preview {
    ContentView()
}
