//
//  MoodSelectionView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 1/6/25.
//

import SwiftUI

struct MoodSelectionView: View {
    @Binding var selectedMood: String?
    var onMoodSelected: (String) -> Void

    private let moods: [String] = ["Happy", "Calm", "Stressed", "Sad"]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("How are you feeling today?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textDarkCharcoal)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)

                Text("Select your mood to get tailored gratitude prompts.")
                    .font(.subheadline)
                    .foregroundColor(.textSoftGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer()

                // Mood Buttons
                VStack(spacing: 16) {
                    ForEach(moods, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                            onMoodSelected(mood)
                        }) {
                            HStack {
                                Text(mood)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(color(for: mood))
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
                Button(action: {
                    selectedMood = nil
                }) {
                    Text("Cancel")
                        .font(.body)
                        .foregroundColor(.red)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }

    private func color(for mood: String) -> Color {
        switch mood {
        case "Happy": return .yellow
        case "Calm": return .blue
        case "Stressed": return .orange
        case "Sad": return .purple
        default: return .gray
        }
    }
}
