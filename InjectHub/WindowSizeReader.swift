//
//  WindowSizeReader.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//


import SwiftUI
import AppKit

struct WindowSizeReader: NSViewRepresentable {
    @Binding var size: CGSize

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.size = window.frame.size
                window.delegate = context.coordinator
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(size: $size)
    }

    class Coordinator: NSObject, NSWindowDelegate {
        @Binding var size: CGSize

        init(size: Binding<CGSize>) {
            self._size = size
        }

        func windowDidResize(_ notification: Notification) {
            if let window = notification.object as? NSWindow {
                size = window.frame.size
            }
        }
    }
}
