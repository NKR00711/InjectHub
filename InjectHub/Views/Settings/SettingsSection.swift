//
//  SettingsSection.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content

    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                Text(title)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.windowBackgroundColor).opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.2))
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }
}
