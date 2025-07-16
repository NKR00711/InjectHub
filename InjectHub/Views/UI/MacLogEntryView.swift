//
//  MacLogEntryView.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//


import SwiftUI

struct MacLogEntryView: View {
    let log: LogEntry
    
    private var typeColor: Color {
        switch log.type {
        case .info: return .blue
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        case .debug: return .secondary
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Colored dot for type
            Circle()
                .fill(typeColor)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            // Timestamp
            Text(log.timestamp, style: .time)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)

            // Message
            ScrollView(.vertical, showsIndicators: true) {
                Text(log.message)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .frame(height: 100)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}
