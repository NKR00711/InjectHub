//
//  SavedAppsSidebarView.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import Foundation
import SwiftUI

struct SavedAppsSidebarView: View {
    @ObservedObject var manager = SavedAppManager.shared
    @Binding var selectedApp: SavedApp?
    @State private var searchText = ""

    var filteredApps: [SavedApp] {
        if searchText.isEmpty {
            return manager.savedApps
        } else {
            return manager.savedApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Saved Apps Congiguration")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 12)

            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                    
                    TextField("Search Apps", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
            }
            .padding(.leading, 16)
            .padding(.trailing, 12)
            .padding(.vertical, 12)
            Divider()

            List(selection: $selectedApp) {
                ForEach(filteredApps) { app in
                    HStack(spacing: 8) {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: app.bundlePath))
                            .resizable()
                            .frame(width: 20, height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        Text(app.name)
                            .font(.body)
                    }
                    .tag(app)
                    .contextMenu {
                        Button("Delete") {
                            manager.delete(app)
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
        }
        .frame(minWidth: 220, idealWidth: 240)
    }
}
