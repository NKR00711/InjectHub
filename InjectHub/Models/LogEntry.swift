//
//  LogEntry.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import SwiftUI

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let type: LogType
    let message: String
}
