//
//  InjectHubApp.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//

import SwiftUI

@main
struct InjectHubApp: App {
//    @State private var windowFrame: NSRect = .zero

    @AppStorage("autoCheckForUpdates") private var autoCheckForUpdates = false
    @AppStorage("autoDownloadUpdates") private var autoDownloadUpdates = false
    @AppStorage("minimizeOnExit") private var minimizeOnExit = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1120,
                       minHeight: 700)
//                .onAppear {
//                    // Restore the window position when the app appears
//                    if let savedFrame = UserDefaults.standard.string(forKey: "windowFrame") {
//                        let frameValues = savedFrame.split(separator: ",").compactMap { Double($0) }
//                        if frameValues.count == 4 {
//                            windowFrame = NSRect(x: frameValues[0], y: frameValues[1], width: frameValues[2], height: frameValues[3])
//                        }
//                    }
//                }
                .onDisappear {
//                    let frameString = "\(windowFrame.origin.x),\(windowFrame.origin.y),\(windowFrame.size.width),\(windowFrame.size.height)"
//                    UserDefaults.standard.set(frameString, forKey: "windowFrame")
                    
                    if minimizeOnExit {
                        if let window = NSApp.keyWindow {
                            window.miniaturize(nil) // Minimize the current key window
                        }
                    } else {
                        NSApp.terminate(nil) // terminates app when last window closes
                    }
                }
        }
//        .defaultPosition(.center)
//        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(appDisplayName())") {
                    NSApp.orderFrontStandardAboutPanel(options: [
                        NSApplication.AboutPanelOptionKey.credits: NSAttributedString(string: "Made by NKR 🇮🇳", attributes: [
                            .font: NSFont.systemFont(ofSize: 12),
                            .foregroundColor: NSColor.secondaryLabelColor
                        ])
                    ])
                }
                Divider()
                Button("Check for Updates…") {
                    if autoCheckForUpdates {
                        UpdateManager.shared.checkForUpdates(showAlertOnly: !autoDownloadUpdates)
                    }
                }
                .keyboardShortcut("U", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
                .frame(width: 500, height: 410)
        }
    }
    
    func appDisplayName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "InjectHub"
    }

}
