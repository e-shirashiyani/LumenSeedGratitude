//
//  StorageManager.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/4/24.
//

import SwiftUI
import Foundation

class StorageManager {
    static let shared = StorageManager()

    private let entriesKey = "GratitudeEntriesKey"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    func saveEntries(_ entries: [GratitudeEntry]) {
        do {
            let data = try encoder.encode(entries)
            UserDefaults.standard.set(data, forKey: entriesKey)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }

    func loadEntries() -> [GratitudeEntry] {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
            return []
        }
        do {
            return try decoder.decode([GratitudeEntry].self, from: data)
        } catch {
            print("Failed to load entries: \(error)")
            return []
        }
    }
}
