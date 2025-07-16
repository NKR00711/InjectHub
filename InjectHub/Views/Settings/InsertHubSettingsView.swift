//
//  DylibSettingsView.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//


import SwiftUI

import SwiftUI

struct InsertHubSettingsView: View {
    // MARK: - AppStorage Options
    @AppStorage("stripCodeSign") private var stripCodeSign = false
    @AppStorage("noBackup") private var noBackup = false
    @AppStorage("rootMode") private var rootMode = true
    @AppStorage("autoDeQuarantine") private var autoDeQuarantine = true
    @AppStorage("dummyCodeSign") private var dummyCodeSign = true
    @AppStorage("specialInject") private var specialInject = false
    @AppStorage("useDefaultDylib") private var useDefaultDylib = false
    @AppStorage("defaultDylibPath") private var defaultDylibPath: String = ""

    @State private var showFilePicker = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - App Preferences Section
                SettingsSection(title: "App Preferences", icon: "gearshape") {
                    VStack(alignment: .leading, spacing: 12) {
                    if ShellManager.shared.isSIPDisabled() {
                        Label("SIP is disabled", systemImage: "checkmark.shield")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .padding(.trailing, 12)
                            .transition(.opacity)
                    }
//                    Toggle("Run in Root Mode", isOn: $rootMode).frame(maxWidth: .infinity, alignment: .leading)
                    Toggle("Auto De-Quarantine", isOn: $autoDeQuarantine).frame(maxWidth: .infinity, alignment: .leading)
                    Toggle("Use Dummy Code Signature \(ShellManager.shared.isSIPDisabled() ? "(❌ No Need when SiP is Disabled)" : "")", isOn: $dummyCodeSign).frame(maxWidth: .infinity, alignment: .leading)
                    
                    if ShellManager.shared.isSIPDisabled() {
                        Toggle("Use Spical Injection Mode (Does Not Copy dylib in Apps Folder)", isOn: $specialInject).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Divider().padding(.vertical, 4)
                    
                    Toggle(isOn: $useDefaultDylib) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Use Default DyLib")
                                .fontWeight(.medium)
                            Text("Enable to use a fixed DyLib path on launch.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
//                    if useDefaultDylib {
                        SimpleFilePickerRow(
                            title: "Selected",
                            allowedExtensions: ["dylib", "binary"],
                            selectedPath: $defaultDylibPath
                        )
                        .disabled(!useDefaultDylib)
//                    }
                }
//                .fileImporter(
//                    isPresented: $showFilePicker,
//                    allowedContentTypes: [.data],
//                    allowsMultipleSelection: false
//                ) { result in
//                    switch result {
//                    case .success(let urls):
//                        if let selected = urls.first {
//                            defaultDylibPath = selected.path
//                        }
//                    case .failure(let error):
//                        print("Failed to select file: \(error.localizedDescription)")
//                    }
//                }
                }

                // MARK: - Arguments Section
                SettingsSection(title: "Arguments", icon: "terminal") {
                    Toggle("Strip Code Signature", isOn: $stripCodeSign).frame(maxWidth: .infinity, alignment: .leading)
                    Toggle("Do Not Make Backup", isOn: $noBackup).frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

