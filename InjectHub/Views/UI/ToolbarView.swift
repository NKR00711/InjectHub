//
//  Toolbar.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//

import SwiftUI

struct ToolbarView: View {
    @Binding var showingPasswordSheet: Bool
    let isPasswordSet: Bool
    @AppStorage("rootMode") private var rootMode = true
    
    var body: some View {
        Button(action: {
            showingPasswordSheet = !isPasswordSet
        }) {
            HStack(spacing: 6) {
                Image(systemName: isPasswordSet ? "lock.open.fill" : "lock.fill")
//                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
                
                Text(rootMode ? (isPasswordSet ? "Root" : "Requires Root Password") : NSUserName())
                    .font(.caption2)
                    .fontWeight(.medium)
//                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(((isPasswordSet || !rootMode) ? Color.green : Color.red).opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke((isPasswordSet || !rootMode) ? Color.green : Color.red, lineWidth: 1)
            )
            .padding(6)
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)

        }
        .buttonStyle(.plain)
        .help("Root Status")
    }
}
