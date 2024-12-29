//
//  NewEntryView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import SwiftUI
import Speech

struct NewEntryView: View {
    @Binding var entries: [GratitudeEntry]
    @State private var newEntryText: String = ""
    @State private var currentSessionEntries: [String] = []
    @State private var isRecording: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var speechRecognizerHelper = SpeechRecognizerHelper()
    
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

                    // Gratitude Input with Mic
                    ZStack(alignment: .bottomTrailing) {
                        // Gratitude Input
                        TextEditor(text: $newEntryText)
                            .padding(16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
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
                                // Placeholder Text
                                VStack {
                                    if newEntryText.isEmpty {
                                        Text("I am grateful for ")
                                            .foregroundColor(.textSoftGray.opacity(0.4))
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
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                                    )
                            }
                        }
                        .padding(.trailing, 30) // Adjust padding from the right
                        .padding(.bottom, 10)   // Adjust padding from the bottom
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
                                .foregroundColor(.white)
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
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2) // Subtle shadow
                                )
                        }
                        .disabled(currentSessionEntries.isEmpty)
                        .opacity(currentSessionEntries.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func toggleVoiceInput() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
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
    }
}// Preview
#Preview {
    // Provide a mock binding for the entries
    let mockEntries = [
        GratitudeEntry(id: UUID(), text: "Grateful for a sunny day", date: Date()),
        GratitudeEntry(id: UUID(), text: "Grateful for family and friends", date: Date())
    ]
    
    // Use a constant binding for preview
    @State var previewEntries = mockEntries
    
    return NewEntryView(entries: .constant(previewEntries))
}
