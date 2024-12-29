//
//  GratitudeTimeScreen.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/28/24.
//

import SwiftUI

struct GratitudeTimeScreen: View {
    @State private var selectedTime = Date()
    @State private var isTimeSet = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToContentView = false

    var body: some View {
        VStack(spacing: 40) {
            // Title and Subtitle
            VStack(spacing: 10) {
                Text("Set Your Gratitude Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                Text("Pick a time to reflect on your day and stay mindful.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Time Picker
            DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .accentColor(.darkBackground) // Match your app's theme color

            Spacer()

            // Save Button
            Button(action: {
                saveTimeToUserDefaults()
                scheduleDailyReminder()
                navigateToContentView = true
            }) {
                Text("Set Reminder")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.darkBackground)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 20)

            // Skip Option
            Button(action: {
                UserDefaults.standard.set(true, forKey: "isGratitudeTimeSet")
                scheduleDefaultReminder()
                navigateToContentView = true
            }) {
                Text("Skip for now")
                    .font(.footnote)
                    .foregroundColor(.darkBackground)
            }
        }
        .padding()
        .background(Color.background)
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $navigateToContentView) {
            ContentView()
        }
    }

    private func saveTimeToUserDefaults() {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: selectedTime)

        UserDefaults.standard.set(timeString, forKey: "gratitudeTime")
        UserDefaults.standard.set(true, forKey: "isGratitudeTimeSet")
    }

    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Gratitude Reminder"
        content.body = "Take a moment to reflect on what you're grateful for today!"
        content.sound = .default

        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = calendar.component(.hour, from: selectedTime)
        dateComponents.minute = calendar.component(.minute, from: selectedTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled at selected time.")
            }
        }
    }

    private func scheduleDefaultReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Gratitude Reminder"
        content.body = "Take a moment to reflect on what you're grateful for today!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Default notification scheduled at 7:00 AM.")
            }
        }
    }
}

#Preview {
    GratitudeTimeScreen()
}
