//
//  LogType.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import SwiftUI

enum LogType: String {
    case debug = "Debug"
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
    case success = "Success"
    
    var icon: String {
        switch self {
        case .debug: return "ladybug"
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        case .success: return "checkmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .debug: return .secondary
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .success: return .green
        }
    }
}
