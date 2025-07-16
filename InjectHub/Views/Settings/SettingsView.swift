//
//  SettingsView.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            InsertHubSettingsView()
                .tabItem {
                    Label("InjectHub", systemImage: "bolt")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .labelStyle(.titleAndIcon)
        .presentedWindowToolbarStyle(.expanded)
        .contentShape(Rectangle())
        .onTapGesture {
            // Deselect textfield when clicking away
            Task { @MainActor in
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
    }
}

#Preview {
    SettingsView()
}
