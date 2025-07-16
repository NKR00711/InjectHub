//
//  GeneralSettingsView.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("autoCheckForUpdates") private var autoCheckForUpdates = false
    @AppStorage("autoDownloadUpdates") private var autoDownloadUpdates = false
    @AppStorage("minimizeOnExit") private var minimizeOnExit = true

    @State private var showPasswordSheet = false
    let passwordManager = PasswordManager()
    @State private var showPasswordDeleted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // MARK: - Title
            VStack(alignment: .leading, spacing: 4) {
                Text("General Settings")
                    .font(.system(size: 24, weight: .bold))
                Text("Configure basic application settings and preferences")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // MARK: - Update Section
            SettingsSection(title: "Update Settings", icon: "arrow.down.circle") {
                Toggle(isOn: $autoCheckForUpdates) {
                    VStack(alignment: .leading) {
                        Text("Automatically check for updates")
                            .fontWeight(.medium)
                        Text("Check for new versions when the app starts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.checkbox) // macOS-native look
                .frame(maxWidth: .infinity, alignment: .leading)

                Toggle(isOn: $autoDownloadUpdates) {
                    VStack(alignment: .leading) {
                        Text("Automatically download updates")
                            .fontWeight(.medium)
                        Text("Download updates in the background when available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(!autoCheckForUpdates)
                .opacity(autoCheckForUpdates ? 1 : 0.5)
                .toggleStyle(.checkbox) // macOS-native look
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle(isOn: $minimizeOnExit) {
                    VStack(alignment: .leading) {
                        Text("Minimize App on Exit")
                            .fontWeight(.medium)
                        Text("App will Minimize to tray instead of quitting")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.checkbox) // macOS-native look
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)

            // MARK: - Password Section
            SettingsSection(title: "Password Management", icon: "key.fill") {
                Text("Your password is stored in Your Keychain.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Button {
                        showPasswordSheet = true
                    } label: {
                        Label("Set Password", systemImage: "key.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        if passwordManager.deletePassword() {
                            showPasswordDeleted = true
                            showPasswordSheet = true
                            // Hide the message after 10 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                showPasswordDeleted = false
                            }
                        }
                    } label: {
                        Label("Delete Password", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
                if showPasswordDeleted {
                    
                    Text("Password deleted.")
                        .font(.caption)
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .sheet(isPresented: $showPasswordSheet) {
            PasswordView {
                showPasswordSheet = false
            }
        }
    }
}
