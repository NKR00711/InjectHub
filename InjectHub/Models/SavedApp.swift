//
//  SavedApp.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//
import Foundation

struct SavedApp: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var bundlePath: String
    var bundleID: String
    var dylibPath: String
    var targetFile: String
}

