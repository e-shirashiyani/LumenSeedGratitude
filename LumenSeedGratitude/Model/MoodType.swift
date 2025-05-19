//
//  MoodType.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/14/25.
//

import Foundation
enum MoodType: String, CaseIterable, Codable {
    case great = "😄"
    case good = "🙂"
    case neutral = "😐"
    case bad = "😕"
    case awful = "😩"

    var emoji: String { rawValue }
}
