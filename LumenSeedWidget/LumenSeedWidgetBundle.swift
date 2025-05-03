//
//  LumenSeedWidgetBundle.swift
//  LumenSeedWidget
//
//  Created by e.shirashiyani on 5/3/25.
//

import WidgetKit
import SwiftUI

@main
struct LumenSeedWidgetBundle: WidgetBundle {
    var body: some Widget {
        LumenSeedWidget()
        LumenSeedWidgetControl()
        LumenSeedWidgetLiveActivity()
    }
}
