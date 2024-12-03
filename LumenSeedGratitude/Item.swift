//
//  Item.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
