//
//  LogManager.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//


import SwiftUI
import Combine

class LogManager: ObservableObject {
    static let shared = LogManager()
    
    @Published var logs: [LogEntry] = []
    
    private init() {}
    
    func addLog(_ message: String, type: LogType = .info) {
        let entry = LogEntry(
            timestamp: Date(),
            type: type,
            message: message
        )
        DispatchQueue.main.async {
            self.logs.append(entry)
        }
    }
    
    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
    
    func getLogs() -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // Format: Year-Month-Day Hour:Minute:Second
           return logs.map {
               "[\(dateFormatter.string(from: $0.timestamp))] \($0.type.rawValue): \($0.message)"
           }.joined(separator: "\n")
    }
}
