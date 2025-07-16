//
//  FileSelectionRow.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//
import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct FileSelectionRow: View {
    let icon: String
    let title: String
    let extensions: [String]
    @Binding var selection: URL?
    @State private var isHovering = false
    @State private var showAlert = false
    @State private var unsupportedFile = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.accentColor)

                Text(selection?.lastPathComponent ?? "Select File")
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundColor(selection == nil ? .secondary : .primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.textBackgroundColor))
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor.opacity(isHovering ? 0.4 : 0.15), lineWidth: 1)
            )
            .contentShape(Rectangle()) // makes the whole row tappable
            .onTapGesture {
                selectFile()
            }
            .onHover { hovering in
                isHovering = hovering
            }
//            .onChange(of: selection) { newValue in
//                if let url = newValue, extensions.contains(url.pathExtension.lowercased()) || extensions.contains("any") {
//                    DispatchQueue.main.async {
//                        selection = url
//                    }
//                } else {
//                    showAlert = true
//                    NSSound.beep()
//                }
//            }
            .onDrop(of: [.fileURL], isTargeted: .none) { providers in
                guard let provider = providers.first else { return false }

                provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url, extensions.contains(url.pathExtension.lowercased()) || extensions.contains("any") {
                        DispatchQueue.main.async {
                            selection = url
                        }
                    } else {
                        showAlert = true
                        NSSound.beep()
                    }
                }.completedUnitCount = 1
                return true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("File Not Supported"),
                message: Text("“\(unsupportedFile)” is not a supported file."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func isUnixExecutable(fileURL: URL) -> Bool {
        // Check if the file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            // Get the file attributes
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            
            // Check if it's a regular file
            if let fileType = attributes[.type] as? FileAttributeType {
                if fileType == .typeRegular {
                    // Check if the file is executable
                    return FileManager.default.isExecutableFile(atPath: fileURL.path)
                }
            }
        } catch {
            print("Error retrieving file attributes: \(error)")
        }
        
        return false
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.title = "Select App or Binary"
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = true           // Allow selecting `.app`
        panel.treatsFilePackagesAsDirectories = true // Allow browsing inside `.app`
//        if extensions.contains("dylib"),
//           let dylibType = UTType(filenameExtension: "dylib") {
//            panel.allowedContentTypes = [dylibType]
//        } else {
            panel.allowedContentTypes = [] // Allow all
//        }

        if panel.runModal() == .OK, let url = panel.url {
            let pathExt = url.pathExtension.lowercased()
            let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false

            let isAppBundle = isDir && pathExt == "app"
            let isAllowedExtension = extensions.contains(pathExt)
            let isBinaryNoExtension = !isDir && pathExt.isEmpty && isUnixExecutable(fileURL: url) && extensions.contains("binary")

            if isAppBundle || isAllowedExtension || isBinaryNoExtension || isAllowedExtension || (isDir && extensions.contains("app")) {
                selection = url
            } else {
                unsupportedFile = url.lastPathComponent
                showAlert = true
                NSSound.beep()
            }
        }
    }
}
