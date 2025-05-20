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
    
    func hasEntryForToday() -> Bool {
           let entries = loadEntries()
           let today = Calendar.current.startOfDay(for: Date())

           return entries.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
       }
}
extension StorageManager {
    private static let moodsKey = "dailyMoods"

    func saveMood(for date: Date, mood: MoodType) {
        var moods = loadMoods()
        let calendar = Calendar.current

        // Remove any existing mood for the same day
        moods.removeAll { calendar.isDate($0.date, inSameDayAs: date) }

        moods.append(DailyMood(date: date, mood: mood))
        if let data = try? JSONEncoder().encode(moods) {
            UserDefaults.standard.set(data, forKey: Self.moodsKey)
        }
    }

    func loadMoods() -> [DailyMood] {
        guard let data = UserDefaults.standard.data(forKey: Self.moodsKey),
              let moods = try? JSONDecoder().decode([DailyMood].self, from: data) else {
            return []
        }
        return moods
    }
}
extension StorageManager {
    private static let activeChallengesKey = "ActiveChallenges"
    private static let customChallengesKey = "CustomChallenges"

    func saveActiveChallenges(_ challenges: [GratitudeChallenge]) {
        if let data = try? JSONEncoder().encode(challenges) {
            UserDefaults.standard.set(data, forKey: Self.activeChallengesKey)
        }
    }

    func loadActiveChallenges() -> [GratitudeChallenge] {
        guard let data = UserDefaults.standard.data(forKey: Self.activeChallengesKey),
              let challenges = try? JSONDecoder().decode([GratitudeChallenge].self, from: data) else {
            return []
        }
        return challenges
    }

    func saveCustomChallenges(_ challenges: [GratitudeChallenge]) {
        if let data = try? JSONEncoder().encode(challenges) {
            UserDefaults.standard.set(data, forKey: Self.customChallengesKey)
        }
    }

    func loadCustomChallenges() -> [GratitudeChallenge] {
        guard let data = UserDefaults.standard.data(forKey: Self.customChallengesKey),
              let challenges = try? JSONDecoder().decode([GratitudeChallenge].self, from: data) else {
            return []
        }
        return challenges
    }
}
