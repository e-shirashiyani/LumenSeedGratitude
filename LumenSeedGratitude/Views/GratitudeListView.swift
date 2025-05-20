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
    @State private var activeChallenges: [GratitudeChallenge] = []
    @State private var selectedChallenge: GratitudeChallenge? = nil
    @State private var showChallengeDetail: Bool = false

    var hasEntryForToday: Bool {
        let calendar = Calendar.current
        return entries.contains { calendar.isDateInToday($0.date) }
    }

    var groupedAndSortedEntries: [(key: String, value: [GratitudeEntry])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let sortedEntries = entries.sorted { $0.date > $1.date }
        let grouped = Dictionary(grouping: sortedEntries) { entry in
            formatter.string(from: entry.date)
        }
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
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                        HeaderView(
                            entries: entries,
                            currentStreak: currentStreak,
                            showStreakInfoSheet: $showStreakInfoSheet,
                            hasEntryForToday: hasEntryForToday,
                            streakBadgeText: streakBadgeText
                        )

                        ChallengesSectionView(
                            activeChallenges: $activeChallenges,
                            selectedChallenge: $selectedChallenge,
                            showChallengeDetail: $showChallengeDetail
                        )

                        JournalSectionView(
                            entries: entries,
                            groupedAndSortedEntries: groupedAndSortedEntries,
                            allEntries: $entries
                        )

                        Spacer()
                    }
                    .padding()
//                    .background(.lumenbackground)
                }
                .sheet(isPresented: $showStreakInfoSheet) {
                    StreakInfoSheetView(currentStreak: currentStreak)
                }
                .onAppear {
                    entries = StorageManager.shared.loadEntries()
                    activeChallenges = StorageManager.shared.loadActiveChallenges()
                    StreakManager.shared.updateStreak(with: entries)
                    currentStreak = StreakManager.shared.getCurrentStreak()
                }
                .onChange(of: entries) { newValue in
                    StorageManager.shared.saveEntries(newValue)
                    StreakManager.shared.updateStreak(with: newValue)
                    currentStreak = StreakManager.shared.getCurrentStreak()
                }

                AddEntryButtonView(entries: $entries)
            }
//            .background(.lumenba)
            .navigationBarHidden(true)
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

// Header with title, streak, badge, and prompt
struct HeaderView: View {
    let entries: [GratitudeEntry]
    let currentStreak: Int
    @Binding var showStreakInfoSheet: Bool
    let hasEntryForToday: Bool
    let streakBadgeText: String?

    var body: some View {
        VStack(spacing: 10) {
            Text(entries.isEmpty ? "Welcome to LumenSeed" : "Keep growing your gratitude")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundColor(.textDarkCharcoal)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            if currentStreak > 0 {
                Button(action: {
                    showStreakInfoSheet = true
                }) {
                    HStack(spacing: 4) {
                        Text("🌱 Current streak: \(currentStreak) days")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.textSoftGray)
                        Image(systemName: "info.circle")
                            .foregroundColor(.textSoftGray.opacity(0.7))
                    }
                }
                .padding(.bottom, 5)
            }

            if let badge = streakBadgeText {
                Text(badge)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.lumenGreen)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }

            if !hasEntryForToday && !entries.isEmpty {
                Text("You haven’t added anything today yet. What are you grateful for?")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 10)
    }
}

// Challenges section with horizontal scroll
struct ChallengesSectionView: View {
    @Binding var activeChallenges: [GratitudeChallenge]
    @Binding var selectedChallenge: GratitudeChallenge?
    @Binding var showChallengeDetail: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🎯 Your Challenges")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.textDarkCharcoal)
                Spacer()
                NavigationLink(destination: ChallengeTrackerView()) {
                    Text("View All")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.lumenGreen)
                }
            }
            .padding(.horizontal)

            if activeChallenges.isEmpty {
                VStack(spacing: 12) {
                    Text("You haven’t joined any challenges yet.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.textSoftGray)
                        .multilineTextAlignment(.center)

                    NavigationLink(destination: ChallengeTrackerView()) {
                        Text("✨ Explore Challenges")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.lumenGreen)
                            .foregroundColor(.lumenWhite)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.lumenWhite)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)
                .padding(.vertical)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(activeChallenges) { challenge in
                            Button {
                                selectedChallenge = challenge
                                showChallengeDetail = true
                            } label: {
                                ChallengeCardView(challenge: challenge)
                                    .frame(width: activeChallenges.count == 1 ? UIScreen.main.bounds.width - 64 : 280)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal)
                }

                NavigationLink(
                    destination: ChallengeDetailView(
                        challenge: Binding(
                            get: { selectedChallenge ?? activeChallenges.first! },
                            set: { updated in
                                if let index = activeChallenges.firstIndex(where: { $0.id == updated.id }) {
                                    activeChallenges[index] = updated
                                    selectedChallenge = updated
                                }
                            }
                        ),
                        allChallenges: $activeChallenges
                    ),
                    isActive: $showChallengeDetail
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .padding(.vertical, 5)
    }
}

// Gratitude journal section with entries
struct JournalSectionView: View {
    let entries: [GratitudeEntry]
    let groupedAndSortedEntries: [(key: String, value: [GratitudeEntry])]
    @Binding var allEntries: [GratitudeEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📝 Your Gratitude Journal")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(.textDarkCharcoal)
                .padding(.horizontal)

            if entries.isEmpty {
                Text("Your gratitude journey starts here. Let's fill this space with positivity and joy! 🌈")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.textSoftGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                ForEach(groupedAndSortedEntries, id: \.key) { date, dailyEntries in
                    GratitudeEntryView(
                        date: date,
                        entries: dailyEntries,
                        allEntries: $allEntries,
                        isToday: Calendar.current.isDateInToday(
                            dailyEntries.first?.date ?? Date()
                        )
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

// Add new entry button
struct AddEntryButtonView: View {
    @Binding var entries: [GratitudeEntry]

    var body: some View {
        NavigationLink(destination: NewEntrView_MoodTracker(entries: $entries)) {
            Text("Add a New Gratitude 🌱")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.darkBackground)
                .foregroundColor(.lumenWhite)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .cornerRadius(12)
                .padding(.horizontal, 16)
        }
        .background(.lumenBackground)
    }
}
//#Preview {
//    GratitudeListView()
//}
