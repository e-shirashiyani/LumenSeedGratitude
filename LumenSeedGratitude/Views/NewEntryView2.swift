//
//  NewEntryView2.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 1/3/25.
//

import SwiftUI

struct NewEntryView2: View {
    @Binding var entries: [GratitudeEntry]
    @State private var newEntryText: String = ""
    @State private var currentSessionEntries: [String] = []
    @State private var isRecording: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var speechRecognizerHelper = SpeechRecognizerHelper()

    // Gratitude prompts
    @State private var gratitudePrompts: [String] = GratitudePrompts.all

    @State private var typingPrompt: String = "" // The animated text
    @State private var promptTimer: Timer? = nil // Timer for inactivity
    @State private var isTyping: Bool = false // Flag to indicate typing animation

    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Title
                    VStack(spacing: 8) {
                        Text("🌟 What are you grateful for today?")
                            .foregroundColor(.textDarkCharcoal)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Reflect on something meaningful and share your thoughts below.")
                            .foregroundColor(.textSoftGray)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)

                    ZStack(alignment: .bottomTrailing) {
                        // Gratitude Input
                        TextEditor(text: $newEntryText)
                            .onChange(of: newEntryText) { _ in
                                resetTimer() // Reset the inactivity timer on text change
                            }
                            .onAppear {
                                typingPrompt = "I am grateful for ..." // Set the default placeholder
                            }
                            .padding(16)
                            .scrollContentBackground(.hidden)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.lumenWhite)
                                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.textSoftGray, lineWidth: 1)
                                }
                            )
                            .frame(minHeight: 150, maxHeight: 250)
                            .foregroundColor(.textDarkCharcoal)
                            .font(.body)
                            .lineSpacing(4)
                            .padding(.horizontal)
                            .overlay(
                                // Static Placeholder Text
                                VStack {
                                    if newEntryText.isEmpty {
                                        Text(typingPrompt)
                                            .foregroundColor(.textSoftGray.opacity(0.8))
                                            .font(.body)
                                            .padding(.horizontal, 20)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.top)
                                            .padding(.leading)
                                    }
                                    Spacer()
                                }
                            )
                        
                        // Mic Button
                        Button(action: {
                            toggleVoiceInput()
                        }) {
                            ZStack {
                                // Pulsating Animation when Recording
                                if isRecording {
                                    Circle()
                                        .stroke(Color.red.opacity(0.6), lineWidth: 4)
                                        .frame(width: 50, height: 50)
                                        .scaleEffect(isRecording ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRecording)
                                }

                                // Microphone Icon
                                Image(systemName: isRecording ? "mic.fill" : "mic")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(isRecording ? .red : .darkBackground)
                                    .padding()
                                    .background(
                                        Circle()
                                            .fill(Color.background)
                                            .shadow(color: Color.background.opacity(0.2), radius: 6, x: 0, y: 4)
                                    )
                            }
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 10)
                    }

                    // Buttons for Gratitude Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            currentSessionEntries.append(newEntryText)
                            newEntryText = ""
                        }) {
                            Text("✨ Add Another Gratitude")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.darkBackground)
                                .foregroundColor(.lumenWhite)
                                .fontWeight(.bold)
                                .cornerRadius(12)
                        }
                        .disabled(newEntryText.isEmpty)
                        .opacity(newEntryText.isEmpty ? 0.5 : 1.0)

                        Button(action: {
                            let newEntries = currentSessionEntries.map { GratitudeEntry(id: UUID(), text: $0, date: Date()) }
                            entries.insert(contentsOf: newEntries, at: 0)
                            currentSessionEntries.removeAll()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("🎉 Celebrate and Save")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.darkBackground)
                                .fontWeight(.bold)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.darkBackground, lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                                )
                        }
                        .disabled(currentSessionEntries.isEmpty)
                        .opacity(currentSessionEntries.isEmpty ? 0.5 : 1.0)
                        
                        Button(action: {
                            // Immediately display a random prompt
//                            displayRandomPromptWithTyping()
                            
                            // Start or reset the prompt cycle timer
                            startPromptCycle()
                        }) {
                            Text("💡 Get Inspired")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.lumenGreen)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .cornerRadius(12)
                        }

                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear {
            promptTimer?.invalidate()
            promptTimer = nil
        }
    }

    // Speech Recognition Logic
    private func toggleVoiceInput() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        // Stop random prompt animation and timer
        promptTimer?.invalidate()
        isTyping = false
        typingPrompt = "" // Clear the typing prompt

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
        newEntryText += speechRecognizerHelper.transcribedText // Append transcribed text

//        // Restart the prompt cycle after recording stops
        typingPrompt = "I am grateful for ..."
//        if newEntryText.isEmpty {
//            startPromptCycle()
//        }
    }

    // Automatic Prompt Logic
    private func startPromptCycle() {
        // Invalidate the existing timer if it exists
        promptTimer?.invalidate()

        // Create a new timer
        promptTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [self] _ in
            if self.newEntryText.isEmpty {
                self.displayRandomPromptWithTyping()
            }
        }
    }

    private func resetTimer() {
        // Reset the timer to delay the next prompt
        promptTimer?.invalidate()
        startPromptCycle()
    }

    private func displayRandomPromptWithTyping() {
        guard !isTyping, let randomPrompt = gratitudePrompts.randomElement() else { return }

        isTyping = true
        typingPrompt = "" // Clear the current prompt

        // Simulate typing animation
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
}

//#Preview {
//    NewEntryView2()
//}
