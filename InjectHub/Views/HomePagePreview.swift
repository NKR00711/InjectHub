//
//  HomePagePreview.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//


import SwiftUI

struct HomePagePreview: View {
    @Environment(\.colorScheme) var colorScheme

    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Made By NKR 🇮🇳"
    
    var body: some View {
        ZStack {
            // Blurred system background (macOS native feel)
            VisualEffectView(material: .windowBackground, blendingMode: .withinWindow)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                Spacer()

                // App icon
                Image(nsImage: getAppIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 10)

                // Title
                Text("Welcome to \(appName)")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(titleColor())
                    .padding(.top, 8)

                // Description
                Text("Select an app to view details and inject dynamic libraries.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(descriptionColor())
                    .multilineTextAlignment(.center)

                // Links in modern button style
                HStack(spacing: 16) {
                    linkButton("GitHub", url: "https://github.com/NKR00711/InjectHub")
//                    linkButton("Contact", url: "https://t.me/NKR00711")
//                    linkButton("Channel", url: "https://t.me/FreeIDMZoneC")
//                    linkButton("Group", url: "https://t.me/FreeIDMZone")
                }
                .padding(.top, 16)

                Spacer()
            }
            .padding()
//            .frame(minWidth: 500, maxWidth: 600)
        }
    }

    func getAppIcon() -> NSImage {
        NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
    }

    func titleColor() -> Color {
        colorScheme == .dark ? .white : .primary
    }

    func descriptionColor() -> Color {
        colorScheme == .dark ? .white.opacity(0.7) : .secondary
    }

    @ViewBuilder
    func linkButton(_ title: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.1))
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
