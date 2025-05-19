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
    @State private var showStreakInfoSheet = false

    var hasEntryForToday: Bool {
        let calendar = Calendar.current
        return entries.contains { calendar.isDateInToday($0.date) }
    }
    
    var groupedAndSortedEntries: [(key: String, value: [GratitudeEntry])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        // Step 1: Sort entries by date descending
        let sortedEntries = entries.sorted { $0.date > $1.date }

        // Step 2: Group sorted entries by date string
        let grouped = Dictionary(grouping: sortedEntries) { entry in
            formatter.string(from: entry.date)
        }

        // Step 3: Sort grouped sections by date descending
        return grouped.sorted {
            guard let date1 = formatter.date(from: $0.key),
                  let date2 = formatter.date(from: $1.key) else {
                return false
            }
            return date1 > date2
        }
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
                    Button(action: {
                        showStreakInfoSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Text("🌱 Current streak: \(currentStreak) days")
                                .font(.subheadline)
                                .foregroundColor(.textSoftGray)
                            Image(systemName: "info.circle")
                                .foregroundColor(.textSoftGray.opacity(0.7))
                        }
                    }
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
                let moods = StorageManager.shared.loadMoods()

                if !moods.isEmpty {
                    NavigationLink(destination: MoodHistoryView(moods: moods)) {
                        HStack {
                            Text("🧠 View Mood Trends")
                                .foregroundColor(.textDarkCharcoal)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textSoftGray)
                        }
                        .padding()
                        .background(.lumenWhite)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                    }
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
        .sheet(isPresented: $showStreakInfoSheet) {
            StreakInfoSheetView(currentStreak: currentStreak)
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

//#Preview {
//    GratitudeListView()
//}
