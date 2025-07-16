//
//  ToolbarTab.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import SwiftUI

struct ToolbarTab: View {
    var icon: String
    var label: String
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(label)
                    .font(.system(size: 12))
            }
            .padding(8)
            .frame(width: 70)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(selected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(selected ? .accentColor : .secondary)
    }
}
