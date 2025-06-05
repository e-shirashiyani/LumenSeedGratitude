//
//  NewEntryView+MoodTracker.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 1/6/25.
//

import SwiftUI

struct NewEntrView_MoodTracker: View {
    @Binding var entries: [GratitudeEntry]
    @State private var newEntryText: String = ""
    @State private var currentSessionEntries: [String] = []
    @State private var isRecording: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var speechRecognizerHelper = SpeechRecognizerHelper()

    // Gratitude prompts
    @State private var gratitudePrompts: [String] = GratitudePrompts.all
    @State private var moodBasedPrompts: [String] = []
    @State private var typingPrompt: String = ""
    @State private var promptTimer: Timer?
    @State private var isTyping: Bool = false
    @State private var isTextEditorFocused: Bool = false

    // Mood Selection
    @State private var isMoodSelectionActive: Bool = false
    @State private var selectedMood: MoodType?

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.lumenBackground, .lumenWhite.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Title Card
                        VStack(spacing: 8) {
                            Text("🌟 What are you grateful for today?")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundColor(.textDarkCharcoal)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(.lumenGreen)
                                        .offset(y: 4),
                                    alignment: .bottom
                                )
                            Text("Reflect on something meaningful and share your thoughts below.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.textSoftGray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(.lumenWhite)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)

                        // Mood Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How are you feeling?")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundColor(.textDarkCharcoal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(MoodType.allCases, id: \.self) { mood in
                                        MoodButton(
                                            mood: mood,
                                            isSelected: selectedMood == mood,
                                            action: { selectedMood = mood }
                                        )
                                        .accessibilityLabel("Select \(mood.rawValue) mood")
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(.lumenWhite)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)

                        // Gratitude Input
                        ZStack(alignment: .bottomTrailing) {
                            TextEditor(text: $newEntryText)
                                .onChange(of: newEntryText) { _ in
                                    resetTimer()
                                }
                                .onAppear {
                                    typingPrompt = "I am grateful for ..."
                                }
                                .padding(16)
                                .scrollContentBackground(.hidden)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.lumenWhite)
                                            .shadow(color: .black.opacity(isTextEditorFocused ? 0.15 : 0.1), radius: isTextEditorFocused ? 6 : 4, x: 0, y: 2)
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isTextEditorFocused ? Color.lumenGreen : Color.textSoftGray.opacity(0.5), lineWidth: isTextEditorFocused ? 2 : 1)
                                    }
                                )
                                .frame(minHeight: 150, maxHeight: 250)
                                .foregroundColor(.textDarkCharcoal)
                                .font(.system(.body, design: .rounded))
                                .lineSpacing(4)
                                .overlay(
                                    VStack {
                                        if newEntryText.isEmpty {
                                            Text(typingPrompt)
                                                .foregroundColor(.textSoftGray)
                                                .font(.system(.body, design: .rounded))
                                                .padding(.horizontal, 20)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top)
                                                .padding(.leading)
                                        }
                                        Spacer()
                                    }
                                )
                                .onTapGesture {
                                    isTextEditorFocused = true
                                }
                                .onChange(of: newEntryText) { _ in
                                    isTextEditorFocused = !newEntryText.isEmpty
                                }

                            // Mic Button
                            Button(action: {
                                toggleVoiceInput()
                                triggerHaptic()
                            }) {
                                ZStack {
                                    if isRecording {
                                        Circle()
                                            .stroke(.lumenGreen.opacity(0.6), lineWidth: 4)
                                            .frame(width: 40, height: 40)
                                            .scaleEffect(isRecording ? 1.2 : 1.0)
                                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRecording)
                                    }

                                    Image(systemName: isRecording ? "mic.fill" : "mic")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(isRecording ? .lumenGreen : .darkBackground)
                                        .padding()
                                        .background(
                                            Circle()
                                                .fill(.lumenWhite)
                                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
                                        )
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 10)
                            .accessibilityLabel(isRecording ? "Stop voice input" : "Start voice input")
                        }
                        .padding(.horizontal)

                        // Action Buttons
                        VStack(spacing: 12) {
                            ActionButton(
                                title: "✨ Add Another Gratitude",
                                isDisabled: newEntryText.isEmpty,
                                action: {
                                    currentSessionEntries.append(newEntryText)
                                    newEntryText = ""
                                    triggerHaptic()
                                }
                            )

                            ActionButton(
                                title: "🎉 Celebrate and Save",
                                isDisabled: currentSessionEntries.isEmpty,
                                action: {
                                    let now = Date()
                                    let newEntries = currentSessionEntries.map { GratitudeEntry(id: UUID(), text: $0, date: now) }
                                    entries.insert(contentsOf: newEntries, at: 0)
                                    currentSessionEntries.removeAll()

                                    if let mood = selectedMood {
                                        StorageManager.shared.saveMood(for: now, mood: mood)
                                    }

                                    UserDefaults.standard.set(true, forKey: "hasAddedGratitudeToday")
                                    StreakManager.shared.updateStreak(with: entries)
                                    presentationMode.wrappedValue.dismiss()
                                    triggerHaptic()
                                },
                                isSecondary: true
                            )

                            ActionButton(
                                title: "💡 Get Inspired",
                                isDisabled: false,
                                action: {
                                    isMoodSelectionActive = true
                                    triggerHaptic()
                                }
                            )
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear {
            promptTimer?.invalidate()
            promptTimer = nil
        }
    }

    // MARK: - Helper Components
    private struct MoodButton: View {
        let mood: MoodType
        let isSelected: Bool
        let action: () -> Void
        @State private var isPressed = false

        var body: some View {
            Button(action: {
                action()
                isPressed = true
                triggerHaptic()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                }
            }) {
                VStack(spacing: 4) {
                    Text(mood.emoji)
                        .font(.system(size: 24))
//                    Text(mood.rawValue.capitalized)
//                        .font(.system(.caption2, design: .rounded, weight: .medium))
//                        .foregroundColor(.textDarkCharcoal)
                }
                .padding(12)
                .background(
                    ZStack {
                        Circle()
                            .fill(.lumenWhite)
                            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.1), radius: isSelected ? 4 : 2)
                        if isSelected {
                            Circle()
                                .stroke(.lumenGreen, lineWidth: 2)
                        }
                    }
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .frame(width: 48, height: 48)
            .animation(.spring(), value: isPressed)
        }

        private func triggerHaptic() {
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.prepare()
            haptic.impactOccurred()
        }
    }

    private struct ActionButton: View {
        let title: String
        let isDisabled: Bool
        let action: () -> Void
        let isSecondary: Bool
        @State private var isPressed = false

        init(title: String, isDisabled: Bool, action: @escaping () -> Void, isSecondary: Bool = false) {
            self.title = title
            self.isDisabled = isDisabled
            self.action = action
            self.isSecondary = isSecondary
        }

        var body: some View {
            Button(action: {
                action()
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                }
            }) {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.lumenWhite)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: isSecondary ? [.textSoftGray.opacity(0.2), .textSoftGray.opacity(0.1)] : [.lumenGreen, .lumenGreen.opacity(0.8)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSecondary ? .darkBackground : .lumenGreen.opacity(0.5), lineWidth: isSecondary ? 1 : 2)
                                )
                        }
                    )
                    .foregroundColor(isSecondary ? .darkBackground : .lumenWhite)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
            .animation(.spring(), value: isPressed)
            .accessibilityLabel(title)
        }
    }

    // MARK: - Logic (Unchanged)
    private func toggleVoiceInput() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        promptTimer?.invalidate()
        isTyping = false
        typingPrompt = ""

        speechRecognizerHelper.startRecording { error in
            if let error = error {
                print("Error starting speech recognition: \(error.localizedDescription)")
            } else {
                isRecording = true
            }
        }
    }

    private func stopRecording() {
        speechRecognizerHelper.stopRecording()
        isRecording = false
        newEntryText += speechRecognizerHelper.transcribedText
        typingPrompt = "I am grateful for ..."
    }

    private func startPromptCycle() {
        promptTimer?.invalidate()
        promptTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [self] _ in
            if self.newEntryText.isEmpty {
                self.displayRandomPromptWithTyping()
            }
        }
    }

    private func resetTimer() {
        promptTimer?.invalidate()
        startPromptCycle()
    }

    private func displayRandomPromptWithTyping() {
        guard !isTyping, let randomPrompt = gratitudePrompts.randomElement() else { return }
        isTyping = true
        typingPrompt = ""
        var currentIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentIndex < randomPrompt.count {
                let index = randomPrompt.index(randomPrompt.startIndex, offsetBy: currentIndex)
                typingPrompt.append(randomPrompt[index])
                currentIndex += 1
            } else {
                isTyping = false
                timer.invalidate()
            }
        }
    }

    private func triggerHaptic() {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        haptic.impactOccurred()
    }
}
//#Preview {
//    NewEntryView_MoodTracker()
//}
