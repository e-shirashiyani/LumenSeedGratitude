//
//  GratitudeChallenge.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/19/25.
//

import Foundation
struct GratitudeChallenge: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let totalDays: Int
    var completedDays: Int
    var isCompleted: Bool
    var startDate: Date
    let isCustom: Bool

    init(id: UUID, title: String, description: String, totalDays: Int, completedDays: Int, isCompleted: Bool, startDate: Date, lastMarkedDate: Date? = nil, isCustom: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.isCompleted = isCompleted
        self.startDate = startDate
        self.isCustom = isCustom
    }


}
let allChallengeTemplates = [
    GratitudeChallenge(id: UUID(), title: "3 Days of Kindness", description: "Write about one kind act each day", totalDays: 3, completedDays: 0, isCompleted: false, startDate: Date()),
    GratitudeChallenge(id: UUID(), title: "5 Days of Nature", description: "Reflect on something beautiful in nature", totalDays: 5, completedDays: 0, isCompleted: false, startDate: Date()),
    GratitudeChallenge(id: UUID(), title: "7 Days of Self-Love", description: "Appreciate something about yourself each day", totalDays: 7, completedDays: 0, isCompleted: false, startDate: Date()),
    GratitudeChallenge(id: UUID(), title: "10 Days of Connection", description: "Reflect on a meaningful interaction with someone each day", totalDays: 10, completedDays: 0, isCompleted: false, startDate: Date()),
    GratitudeChallenge(id: UUID(), title: "3 Days of Mindfulness", description: "Write about a moment you were fully present today", totalDays: 3, completedDays: 0, isCompleted: false, startDate: Date()),
    GratitudeChallenge(id: UUID(), title: "14 Days of Gratitude Journal", description: "Record three things you’re grateful for each day", totalDays: 14, completedDays: 0, isCompleted: false, startDate: Date()),
    GratitudeChallenge(id: UUID(), title: "5 Days of Overcoming Challenges", description: "Reflect on a challenge you faced and how you grew from it", totalDays: 5, completedDays: 0, isCompleted: false, startDate: Date())
]
