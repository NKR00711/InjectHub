//
//  SimpleFilePickerRow.swift
//  InjectHub
//
//  Created by NKR on 16/07/25.
//


import SwiftUI
import AppKit

struct SimpleFilePickerRow: View {
    let title: String
    let allowedExtensions: [String]
    @Binding var selectedPath: String

    @State private var showAlert = false
    @State private var unsupportedFile = ""

    var body: some View {
        HStack {
            Text("\(title):")
                .foregroundColor(.secondary)

            Text(selectedPath.isEmpty ? "No path selected" : selectedPath)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundColor(selectedPath.isEmpty ? .red : .primary)

            Spacer()

            Button("Browse…") {
                selectFile()
            }
        }
//        .padding(10)
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color(.textBackgroundColor))
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
//        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("File Not Supported"),
                message: Text("“\(unsupportedFile)” is not a supported file."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.title = "Select File"
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.treatsFilePackagesAsDirectories = true
        panel.allowedContentTypes = []

        if panel.runModal() == .OK, let url = panel.url {
            let pathExt = url.pathExtension.lowercased()
            let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            let isAllowedExtension = allowedExtensions.contains(pathExt)
            let isBinaryNoExtension = !isDir && pathExt.isEmpty && allowedExtensions.contains("binary")

            if isAllowedExtension || isBinaryNoExtension {
                selectedPath = url.path
            } else {
                unsupportedFile = url.lastPathComponent
                showAlert = true
                NSSound.beep()
            }
        }
    }
}
