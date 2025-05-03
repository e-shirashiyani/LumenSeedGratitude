//
//  ContentView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import SwiftUI
import SwiftData

struct GratitudeListView: View {
    @State private var entries: [GratitudeEntry] = []
    @State private var currentStreak: Int = 0

    var hasEntryForToday: Bool {
        let calendar = Calendar.current
        return entries.contains { calendar.isDateInToday($0.date) }
    }
    
    var groupedAndSortedEntries: [(key: String, value: [GratitudeEntry])] {
        let grouped = Dictionary(grouping: entries) { entry in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: entry.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                Text(entries.isEmpty ? "Welcome to LumenSeed" : "Keep growing your gratitude")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textDarkCharcoal)
                    . multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
                if currentStreak > 0 {
                    Text("🌱 Current streak: \(currentStreak) days")
                        .font(.subheadline)
                        .foregroundColor(.textSoftGray)
                        .padding(.bottom, 5)
                }

                if let badge = streakBadgeText {
                    Text(badge)
                        .font(.footnote)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }
                
                if !hasEntryForToday && !entries.isEmpty {
                    Text("You haven’t added anything today yet. What are you grateful for?")
                        .font(.footnote)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                }
                
                // Content
                if entries.isEmpty {
                    Text("Your gratitude journey starts here. Let's fill this space with positivity and joy! 🌈")
                        .font(.body)
                        .foregroundColor(.textSoftGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    ScrollView {
                        ForEach(groupedAndSortedEntries, id: \.key) { date, dailyEntries in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(date)
                                    .font(.headline)
                                    .foregroundColor(.textDarkCharcoal)
                                    .padding(.vertical, 5)
                                
                                // Combine entries into one card
                                VStack(alignment: .leading, spacing: 5) {
                                    // Display up to 4 entries with bullet points
                                    ForEach(dailyEntries.prefix(3), id: \.id) { entry in
                                        Text("• \(entry.text)")
                                            .font(.body)
                                            .foregroundColor(.textDarkCharcoal)
                                            .multilineTextAlignment(.leading)
                                    }
                                    // Add "..." if there are more than 4 entries
                                    if dailyEntries.count > 4 {
                                        Text("...and \(dailyEntries.count - 4) more")
                                            .font(.subheadline)
                                            .foregroundColor(.textSoftGray)
                                            .italic()
                                            .multilineTextAlignment(.leading) 
                                    }
                                }
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .padding()
                                .background(.lumenWhite)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                
                Spacer()
                
                // Navigation Button
                NavigationLink(destination: NewEntrView_MoodTracker(entries: $entries)) {
                    Text("Add a New Gratitude 🌱")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.darkBackground)
                        .foregroundColor(.lumenWhite)
                        .fontWeight(.bold)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.background)
            .navigationBarHidden(true)
        }
        .onAppear {
            entries = StorageManager.shared.loadEntries()
            StreakManager.shared.updateStreak(with: entries)
            currentStreak = StreakManager.shared.getCurrentStreak()
        }
        .onChange(of: entries) { newValue in
            StorageManager.shared.saveEntries(newValue)
            StreakManager.shared.updateStreak(with: newValue)
            currentStreak = StreakManager.shared.getCurrentStreak()
        }
    }
    
    var streakBadgeText: String? {
        switch currentStreak {
        case 7:
            return "🌱 7-day streak! You’re growing strong."
        case 14:
            return "🌿 14-day streak! Keep the momentum."
        case 30:
            return "🌳 30 days of gratitude! Amazing."
        default:
            return nil
        }
    }
}

#Preview {
    GratitudeListView()
}
