//
//  ChallengeTrackerView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/19/25.
//

import SwiftUI

import SwiftUI
import CoreHaptics

struct ChallengeTrackerView: View {
    @State private var allChallenges: [GratitudeChallenge] = []
    @State private var activeChallenges = StorageManager.shared.loadActiveChallenges()
    @State private var selectedChallenge: GratitudeChallenge? = nil
    @State private var showJoinModal = false
    @State private var showCreateModal = false
    @State private var showConfetti = false
    @State private var sortOption: SortOption = .default

    enum SortOption: String, CaseIterable {
        case `default` = "Default"
        case short = "Shortest"
        case long = "Longest"
    }

    var sortedChallenges: [GratitudeChallenge] {
        switch sortOption {
        case .default:
            return allChallenges
        case .short:
            return allChallenges.sorted { $0.totalDays < $1.totalDays }
        case .long:
            return allChallenges.sorted { $0.totalDays > $1.totalDays }
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24, pinnedViews: [.sectionHeaders]) {
                activeChallengesSection()
                availableChallengesSection()
            }
            .padding(.vertical)
        }
        .navigationTitle("Challenges")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showCreateModal = true
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.lumenGreen)
                }
                .accessibilityLabel("Create new challenge")
                
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            sortOption = option
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.lumenGreen)
                }
                .accessibilityLabel("Sort challenges")
            }
        }
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
        .overlay(
            Group {
                if showJoinModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            showJoinModal = false
                            selectedChallenge = nil
                        }
                    JoinChallengeModalView(
                        challenge: selectedChallenge,
                        onJoin: {
                            joinSelectedChallenge()
                            showConfetti = true
                            triggerHaptic()
                        },
                        onCancel: {
                            selectedChallenge = nil
                            showJoinModal = false
                        }
                    )
                    .transition(.scale)
                }
                if showCreateModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            showCreateModal = false
                        }
                    CreateChallengeModalView(
                        onCreate: { newChallenge in
                            withAnimation(.easeInOut) {
                                allChallenges.append(newChallenge)
                                StorageManager.shared.saveCustomChallenges(
                                    allChallenges.filter { $0.isCustom }
                                )
                            }
                            showConfetti = true
                            triggerHaptic()
                            showCreateModal = false
                        },
                        onCancel: {
                            showCreateModal = false
                        }
                    )
                    .transition(.scale)
                }
            }
        )
        .onAppear {
            let templates = allChallengeTemplates
            let custom = StorageManager.shared.loadCustomChallenges()
            allChallenges = templates + custom
        }
    }

    private func joinSelectedChallenge() {
        guard let challenge = selectedChallenge else { return }
        if !activeChallenges.contains(where: { $0.id == challenge.id }) {
            withAnimation(.easeInOut) {
                activeChallenges.append(challenge)
                StorageManager.shared.saveActiveChallenges(activeChallenges)
            }
        }
        selectedChallenge = nil
        showJoinModal = false
    }

    private func triggerHaptic() {
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.prepare()
        haptic.impactOccurred()
    }

    @ViewBuilder
    private func activeChallengesSection() -> some View {
        Section(header: SectionHeaderView(title: "🌱 Active Challenges")) {
            if activeChallenges.isEmpty {
                EmptyStateView(
                    message: "No active challenges yet. Join one to start your journey!",
                    actionTitle: "Explore Challenges",
                    action: { showJoinModal = true }
                )
                .padding(.horizontal)
            } else {
                ForEach(activeChallenges) { challenge in
                    ChallengeCardView(challenge: challenge)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.lumenGreen.opacity(0.5), lineWidth: 1)
                        )
                        .overlay(
                            Text("Joined")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .padding(4)
                                .background(Color.lumenGreen)
                                .foregroundColor(.lumenWhite)
                                .clipShape(Capsule())
                                .offset(x: -8, y: -8),
                            alignment: .topTrailing
                        )
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }

    @ViewBuilder
        private func availableChallengesSection() -> some View {
            Section(header: SectionHeaderView(title: "🎯 Available Challenges")) {
                if sortedChallenges.isEmpty {
                    EmptyStateView(
                        message: "No challenges available right now. Create or join one!",
                        actionTitle: "Create Challenge",
                        action: { showCreateModal = true }
                    )
                    .padding(.horizontal)
                } else {
                    ForEach(sortedChallenges.filter { outer in !activeChallenges.contains(where: { inner in inner.id == outer.id }) }) { challenge in
                        ChallengeCardItemView(
                            challenge: challenge,
                            isSelected: selectedChallenge?.id == challenge.id,
                            onTap: {
                                selectedChallenge = challenge
                                showJoinModal = true
                                triggerHaptic()
                            }
                        )
                        .transition(.opacity.combined(with: .scale))
                    }
                }
            }
        }
}

// Create Challenge Modal
struct CreateChallengeModalView: View {
    let onCreate: (GratitudeChallenge) -> Void
    let onCancel: () -> Void
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var duration: String = ""
    @State private var titleError: String?
    @State private var durationError: String?
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title
        case description
        case duration
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your Challenge")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.darkBackground)

            VStack(spacing: 16) {
                // Title Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.textDarkCharcoal)
                    StyledTextField(
                        text: $title,
                        placeholder: "e.g., Daily Joy",
                        isFocused: focusedField == .title
                    )
                    .focused($focusedField, equals: .title)
                    .accessibilityLabel("Challenge title")
                    if let error = titleError {
                        Text(error)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.red)
                            .accessibilityLabel(error)
                    }
                }

                // Description Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description (optional)")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.textDarkCharcoal)
                    StyledTextField(
                        text: $description,
                        placeholder: "e.g., Reflect on joyful moments",
                        isFocused: focusedField == .description
                    )
                    .focused($focusedField, equals: .description)
                    .accessibilityLabel("Challenge description")
                }

                // Duration Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration (days)")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.textDarkCharcoal)
                    StyledTextField(
                        text: $duration,
                        placeholder: "e.g., 7",
                        isFocused: focusedField == .duration,
                        keyboardType: .numberPad
                    )
                    .focused($focusedField, equals: .duration)
                    .accessibilityLabel("Challenge duration in days")
                    if let error = durationError {
                        Text(error)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.red)
                            .accessibilityLabel(error)
                    }
                }
            }

            Button(action: {
                if validateInputs() {
                    let newChallenge = GratitudeChallenge(
                        id: UUID(),
                        title: title,
                        description: description.isEmpty ? "Your custom challenge" : description,
                        totalDays: Int(duration)!,
                        completedDays: 0,
                        isCompleted: false,
                        startDate: Date(),
                        isCustom: true
                    )
                    onCreate(newChallenge)
                }
            }) {
                Text("Create Challenge")
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
                    .scaleEffect(isValidForm ? 1.0 : 0.95)
                    .animation(.spring(), value: isValidForm)
            }
            .disabled(!isValidForm)
            .opacity(isValidForm ? 1.0 : 0.5)
            .accessibilityLabel("Create custom challenge")

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.lumenGreen)
                    .padding(.vertical, 4)
            }
            .accessibilityLabel("Cancel creating challenge")
        }
        .padding()
        .background(.lumenWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 8)
        .frame(maxWidth: 340)
        .padding(.horizontal)
        .onAppear {
            focusedField = .title // Auto-focus title field
        }
    }

    private var isValidForm: Bool {
        titleError == nil && durationError == nil && !title.isEmpty && !duration.isEmpty
    }

    private func validateInputs() -> Bool {
        titleError = nil
        durationError = nil

        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            titleError = "Title is required"
            return false
        }

        if let days = Int(duration) {
            if days < 1 || days > 30 {
                durationError = "Duration must be between 1 and 30 days"
                return false
            }
        } else {
            durationError = "Enter a valid number"
            return false
        }

        return true
    }
}
// Section Header
struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(.title3, design: .rounded, weight: .bold))
            .foregroundColor(.darkBackground)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.lumenWhite, .lumenWhite.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.lumenGreen),
                alignment: .bottom
            )
    }
}

// Empty State
struct EmptyStateView: View {
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.textSoftGray)
                .multilineTextAlignment(.center)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.lumenGreen)
                        .foregroundColor(.lumenWhite)
                        .cornerRadius(8)
                }
                .accessibilityLabel(actionTitle)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.lumenWhite)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }
}

// Join Challenge Modal
struct JoinChallengeModalView: View {
    let challenge: GratitudeChallenge?
    let onJoin: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(challenge?.title ?? "Join Challenge")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.darkBackground)

            Text(challenge?.description ?? "")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSoftGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Duration: \(challenge?.totalDays ?? 0) days")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.textSoftGray)

            Button(action: onJoin) {
                Text("Join Challenge")
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
            }
            .accessibilityLabel("Join \(challenge?.title ?? "challenge")")

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.lumenGreen)
            }
            .accessibilityLabel("Cancel joining challenge")
        }
        .padding()
        .background(.lumenWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 8)
        .frame(maxWidth: 340)
        .padding(.horizontal)
    }
}
struct StyledTextField: View {
    @Binding var text: String
    let placeholder: String
    let isFocused: Bool
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(.body, design: .rounded))
            .foregroundColor(.textDarkCharcoal)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.lumenWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isFocused ? Color.lumenGreen : Color.textSoftGray.opacity(0.5),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .shadow(color: .black.opacity(isFocused ? 0.1 : 0.05), radius: 2)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .keyboardType(keyboardType)
    }
}
