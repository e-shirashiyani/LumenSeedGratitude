//
//  StreakManager.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/3/25.
//

import SwiftUI

class StreakManager {
    static let shared = StreakManager()
    
    private let streakKey = "currentStreak"
    private let lastEntryDateKey = "lastEntryDate"

    private init() {}

    func updateStreak(with entries: [GratitudeEntry]) {
        let calendar = Calendar.current
        let sortedDates = Array(Set(entries.map { calendar.startOfDay(for: $0.date) })).sorted(by: >)

        guard !sortedDates.isEmpty else {
            resetStreak()
            return
        }

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate),
                      calendar.isDate(date, inSameDayAs: yesterday) {
                streak += 1
                currentDate = yesterday
            } else {
                break
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }

        UserDefaults.standard.set(streak, forKey: streakKey)
        saveLastEntryDate(sortedDates.first!)
    }
    
    private func incrementStreak() {
        let current = UserDefaults.standard.integer(forKey: streakKey)
        UserDefaults.standard.set(current + 1, forKey: streakKey)
    }

    private func resetStreak() {
        UserDefaults.standard.set(1, forKey: streakKey)
    }

    func getCurrentStreak() -> Int {
        return UserDefaults.standard.integer(forKey: streakKey)
    }

    private func getLastEntryDate() -> Date? {
        if let date = UserDefaults.standard.object(forKey: lastEntryDateKey) as? Date {
            return date
        }
        return nil
    }

    private func saveLastEntryDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: lastEntryDateKey)
    }
    
    func calculateStreak(from entries: [GratitudeEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()

        for entry in entries {
            if calendar.isDate(entry.date, inSameDayAs: currentDate) || calendar.isDate(entry.date, inSameDayAs: calendar.date(byAdding: .day, value: -streak, to: currentDate)!) {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }
}
