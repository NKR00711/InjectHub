//
//  MainView.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//

import SwiftUI

struct MainView: View {
    @Binding var dylibPath: URL?
    @Binding var TargetPath: URL?
    @Binding var InjectTargetPath: URL?
    @Binding var showRootPasswordWindow: Bool
    @Binding var hasRootPassword: Bool
    @Binding var windowSize: CGSize
    @Binding var prinstr: String

    @Binding var passwordManager: PasswordManager
    @ObservedObject var logManager: LogManager
    @State private var didLoadDylib = false

    @AppStorage("useDefaultDylib") private var useDefaultDylib = false
    @AppStorage("defaultDylibPath") private var defaultDylibPath: String = ""
    
    var body: some View {
        VStack {
            
            //            Text("Helper: \(prinstr)")//\(Int(windowSize.width)) × \(Int(windowSize.height))")
            //                            .font(.caption)
            //                            .foregroundColor(.secondary)
            
            FileInfoRowView(dylibPath: $dylibPath, fileURL: $TargetPath, fileToInject: $InjectTargetPath, logManager: logManager)
                .frame(maxWidth: .infinity)
                        
            VStack(spacing: 0) {
                HStack {
                    Label {
                        Text("Console Output")
                            .font(.system(size: 13, weight: .medium))
                    } icon: {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                                    
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(logManager.getLogs(), forType: .string)
                    }) {
                        Label("Copy Logs", systemImage: "doc.on.clipboard")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    
                    Button(action: { logManager.clearLogs() }) {
                        Label("Clear", systemImage: "trash")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .frame(height: 36)
                
                Divider()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 1) {
                            ForEach(logManager.logs) { log in
                                MacLogEntryView(log: log)
                                    .id(log.id)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onChange(of: logManager.logs.count) { oldValue, newValue in
                        if oldValue != newValue, let lastLog = logManager.logs.last {
                            proxy.scrollTo(lastLog.id, anchor: .bottom)
                        }
                    }
                }
                .background(Color(NSColor.textBackgroundColor))
            }
            .background(Color(NSColor.controlBackgroundColor))
                        
            HStack {
                
                FileSelectionRow(
                    icon: "doc.circle",
                    title: "Select App or Binary",
                    extensions: ["app", "dylib", "binary"],
                    selection: $TargetPath
                )
                .frame(maxWidth: .infinity)
                
                FileSelectionRow(
                    icon: "doc.circle",
                    title: "Select Dynamic Library",
                    extensions: ["dylib"],
                    selection: $dylibPath
                )
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
            
            HStack {
                Text("Made with ❤️ by NKR 🦁 in 🇮🇳 ")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
                
                Spacer()
                
                Text(" © 2025 NKR All rights reserved. ")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.secondary.opacity(0.05))
            )
            .padding(.horizontal)
        }
        .padding()
//        frame(minWidth: 1120, idealWidth: 1120,
//               minHeight: 700, idealHeight: 700)
        .frame(minWidth: 900, minHeight: 700)
//        .background(WindowSizeReader(size: $windowSize))
        .onChange(of: InjectTargetPath) { oldValue, newValue in
            if oldValue != newValue {
                tryAutoFillDylibFromSavedApps()
            }
        }
        .onAppear {
            guard !didLoadDylib else { return }
                didLoadDylib = true
            
            if useDefaultDylib {
                DispatchQueue.global().async {
//                    sleep(2)
                    logManager.addLog("Using Default Dylib Path:\(defaultDylibPath)", type: .info)
                    dylibPath = URL(fileURLWithPath: defaultDylibPath)
                }
            }
        }
    }
    
    func tryAutoFillDylibFromSavedApps() {
        guard let currentTarget = InjectTargetPath ?? TargetPath else { return }

        // Try to find a matching saved app
        if let matchedApp = SavedAppManager.shared.savedApps.first(where: {
            $0.targetFile == currentTarget.path || $0.bundlePath == currentTarget.path
        }) {
            if dylibPath?.path != matchedApp.dylibPath {
                dylibPath = URL(fileURLWithPath: matchedApp.dylibPath)
                logManager.addLog("🔗 Auto-filled dylib path from saved app '\(matchedApp.name)'", type: .success)
            }
//            dylibPath = URL(fileURLWithPath: matchedApp.dylibPath)
        }
    }

}
