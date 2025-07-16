//
//  SavedAppManager.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import Foundation

class SavedAppManager: ObservableObject {
    static let shared = SavedAppManager()

    @Published var savedApps: [SavedApp] = [] {
        didSet { save() }
    }
    
    private let fileURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = appSupport.appendingPathComponent((Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String)! , isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("savedApps.json")
    }()

    private init() { load() }

    func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(savedApps) {
            try? data.write(to: fileURL)
        }
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        if let apps = try? decoder.decode([SavedApp].self, from: data) {
            savedApps = apps
        }
    }

    func addOrUpdate(_ app: SavedApp) {
        if let index = savedApps.firstIndex(where: { $0.bundleID == app.bundleID }) {
            savedApps[index] = app
        } else {
            savedApps.append(app)
        }
    }

    func delete(_ app: SavedApp) {
        savedApps.removeAll { $0.id == app.id }
    }
}
