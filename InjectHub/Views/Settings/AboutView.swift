//
//  AboutView.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import SwiftUI

struct AboutView: View {
    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Made By NKR 🇮🇳"
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
    private let bundleID = Bundle.main.bundleIdentifier ?? "-"

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            // MARK: App Info Section
            SectionHeader(icon: "info.circle", title: "Application Information")

            HStack(spacing: 16) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath))
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .shadow(radius: 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(appName)
                        .font(.title2.bold())

                    Text("By NKR 🦁")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Link(destination: URL(string: "https://github.com/NKR00711")!) {
                        Label("Visit my GitHub page", systemImage: "link")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .padding(.top, 4)
                }

                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.05)))

            // MARK: Version Info
            SectionHeader(icon: "tag", title: "Version Information")

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(title: "Version:", value: version, icon: "number.circle.fill")
                InfoRow(title: "Build:", value: build, icon: "hammer.fill")
                InfoRow(title: "Bundle ID:", value: bundleID, icon: "cube.box.fill")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.05)))

            // MARK: Disclaimer
            SectionHeader(icon: "exclamationmark.triangle", title: "Disclaimer")

            VStack(alignment: .leading, spacing: 6) {
                Text("It's completely free to use, if you have to pay to use it then you are being cheated!")
                    .fontWeight(.semibold)
                Text("This application is provided as-is without any warranties. Use at your own risk.")
                    .foregroundColor(.secondary)
            }
            .font(.footnote)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.05)))

            Spacer()
        }
        .padding()
    }
}

// MARK: - Components

struct SectionHeader: View {
    var icon: String
    var title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(.headline)
        }
        .foregroundColor(.primary)
    }
}
