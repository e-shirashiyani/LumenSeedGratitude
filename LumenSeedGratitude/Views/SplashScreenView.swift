//
//  SplashScreenView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/23/24.
//

import SwiftUI

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var hasSetGratitudeTime = false

    var body: some View {
        Group {
            if isActive {
                if hasSetGratitudeTime {
                    ContentView()
                } else {
                    GratitudeTimeScreen()
                }
            } else {
                ZStack {
                    Color.background
                        .ignoresSafeArea()
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300) // Adjust size as needed
                }
                .onAppear {
                    // Check if gratitude time is already set
                    hasSetGratitudeTime = UserDefaults.standard.bool(forKey: "isGratitudeTimeSet")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
