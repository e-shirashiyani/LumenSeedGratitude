//
//  ChallengeDetailView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/19/25.
//

import SwiftUI
import CoreHaptics

// Main Challenge Detail View
struct ChallengeDetailView: View {
    @Binding var challenge: GratitudeChallenge
    @Binding var allChallenges: [GratitudeChallenge]
    @State private var showConfetti = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChallengeHeaderView(challenge: challenge)

                if !challenge.isCompleted {
                    ChallengeActionButton(
                        challenge: challenge,
                        markTodayDone: {
                            markTodayDone()
                            triggerHaptic()
                            showConfetti = true
                        }
                    )
                }

                DailyProgressGridView(challenge: challenge)

                if challenge.isCompleted {
                    CompletionSectionView(
                        challenge: challenge,
                        showConfetti: showConfetti,
                        archiveChallenge: {
                            archiveChallenge()
                            triggerHaptic()
                        }
                    )
                }

                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
        .background(.lumenBackground)
        .navigationTitle("Challenge Details")
        .overlay(
            Group {
                if showConfetti {
                    ConfettiView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showConfetti = false
                            }
                        }
                }
            }
        )
    }

    // MARK: - Actions
    private func markTodayDone() {
        guard !challenge.isCompleted else { return }

        challenge.completedDays += 1
        if challenge.completedDays >= challenge.totalDays {
            challenge.completedDays = challenge.totalDays
            challenge.isCompleted = true
        }

        if let index = allChallenges.firstIndex(where: { $0.id == challenge.id }) {
            allChallenges[index] = challenge
        }

        StorageManager.shared.saveActiveChallenges(allChallenges)
    }

    private func archiveChallenge() {
        allChallenges.removeAll { $0.id == challenge.id }
        StorageManager.shared.saveActiveChallenges(allChallenges)
    }

    private func triggerHaptic() {
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.prepare()
        haptic.impactOccurred()
    }
}

// MARK: - Header Section
struct ChallengeHeaderView: View {
    let challenge: GratitudeChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(challenge.title)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(.darkBackground)

            Text(challenge.description)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSoftGray)

            HStack {
                CircularProgressView(
                    progress: Double(challenge.completedDays),
                    total: Double(challenge.totalDays),
                    isCompleted: challenge.isCompleted
                )

                VStack(alignment: .leading) {
                    Text("Progress: \(challenge.completedDays)/\(challenge.totalDays) Days")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.darkBackground)

                    Text("Started: \(challenge.startDate, format: .dateTime.month().day().year())")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.textSoftGray)
                }

                Spacer()
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(.lumenWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2)
        .padding(.horizontal)
    }
}

// MARK: - Action Button
struct ChallengeActionButton: View {
    let challenge: GratitudeChallenge
    let markTodayDone: () -> Void

    var body: some View {
        Button(action: markTodayDone) {
            Text("✅ Mark Today as Done")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.lumenGreen, .lumenGreen.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .foregroundColor(.lumenWhite)
                .cornerRadius(12)
                .shadow(color: .lumenGreen.opacity(0.3), radius: 4)
        }
        .padding(.horizontal)
        .accessibilityLabel("Mark today as done for \(challenge.title)")
    }
}

// MARK: - Daily Progress Grid
struct DailyProgressGridView: View {
    let challenge: GratitudeChallenge

    var body: some View {
        VStack(alignment: .leading) {
            Text("📅 Daily Progress")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(.darkBackground)
                .padding(.horizontal)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                ForEach(0..<challenge.totalDays, id: \.self) { day in
                    ZStack {
                        Image(systemName: day < challenge.completedDays ? "circle.fill" : "circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(day < challenge.completedDays ? .lumenGreen : .textSoftGray)

                        Text("\(day + 1)")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.darkBackground)
                    }
                    .accessibilityLabel("Day \(day + 1), \(day < challenge.completedDays ? "completed" : "not completed")")
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Completion Section
struct CompletionSectionView: View {
    let challenge: GratitudeChallenge
    let showConfetti: Bool
    let archiveChallenge: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("🎉 Challenge Completed!")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.lumenGreen)
                .scaleEffect(showConfetti ? 1.1 : 1.0)
                .animation(.spring(), value: showConfetti)

            Button(action: archiveChallenge) {
                Text("📦 Archive Challenge")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.textSoftGray.opacity(0.2))
                    .foregroundColor(.darkBackground)
                    .cornerRadius(12)
            }
            .accessibilityLabel("Archive \(challenge.title)")
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
