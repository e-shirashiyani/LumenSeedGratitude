//
//  StreakInfoSheetView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/12/25.
//

import SwiftUI

struct StreakInfoSheetView: View {
    var currentStreak: Int

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🌱 Your Gratitude Streak")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("You've shown up for yourself \(currentStreak) day\(currentStreak == 1 ? "" : "s") in a row. That’s incredible progress 🌟")
                .font(.body)
                .foregroundColor(.textSoftGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Divider()
                .padding(.horizontal)

            VStack(spacing: 10) {
                Text("Why streaks matter?")
                    .font(.headline)
                    .foregroundColor(.textDarkCharcoal)

                Text("Streaks are a reminder of your consistency — not a punishment. If you miss a day, don't worry. 🌧️ Even nature takes breaks. What matters is returning.")
                    .font(.body)
                    .foregroundColor(.textSoftGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            Button(action: {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
            }) {
                Text("Got it 🌱")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.darkBackground)
                    .foregroundColor(.lumenWhite)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .background(Color.background)
    }
}
