//
//  GratitudeEntry.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import Foundation

struct GratitudeEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var date: Date
}
