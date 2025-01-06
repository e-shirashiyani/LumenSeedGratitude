//
//  SplashScreenView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/23/24.
//

import SwiftUI
struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        Group {
            if isActive {
                let hasSetGratitudeTime = UserDefaults.standard.bool(forKey: "isGratitudeTimeSet")
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
                        .frame(width: 300, height: 300)
                }
                .onAppear {
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
