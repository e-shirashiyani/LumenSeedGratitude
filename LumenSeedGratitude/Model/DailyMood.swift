//
//  DailyMood.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/14/25.
//

import Foundation
struct DailyMood: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let mood: MoodType
}
