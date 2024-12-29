//
//  LumenSeedGratitudeApp.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import SwiftUI
import SwiftData

@main
struct LumenSeedGratitudeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
