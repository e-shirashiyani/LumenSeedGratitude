//
//  AppDelegate.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.scheduleDailyReminder()
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        return true
    }

    func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Gratitude Reminder"
        content.body = "Take a moment to reflect on what you're grateful for today!"
        content.sound = .default

        // Get the saved time or default to 7:00 AM
        let timeString = UserDefaults.standard.string(forKey: "gratitudeTime")
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var dateComponents = DateComponents()
        if let timeString = timeString, let savedTime = timeFormatter.date(from: timeString) {
            let calendar = Calendar.current
            dateComponents.hour = calendar.component(.hour, from: savedTime)
            dateComponents.minute = calendar.component(.minute, from: savedTime)
        } else {
            // Default to 7:00 AM if no time is set
            dateComponents.hour = 7
            dateComponents.minute = 0
        }

        // Create the notification trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the notification request
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        // Add the notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Daily notification scheduled successfully.")
            }
        }
    }
}
