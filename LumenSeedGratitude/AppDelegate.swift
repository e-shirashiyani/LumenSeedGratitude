//
//  AppDelegate.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import UIKit
import UserNotifications
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.lumenseed.resetGratitudeFlag", using: nil) { task in
                self.handleResetGratitudeFlagTask(task: task as! BGAppRefreshTask)
            }

        scheduleResetGratitudeFlagTask()
        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.scheduleDailyReminder()
                self.scheduleEveningReminderIfNeeded()
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
    
    func scheduleEveningReminderIfNeeded() {
        let hasGratitude = StorageManager.shared.hasEntryForToday()
        guard !hasGratitude else {
            print("Gratitude already added today. Skipping evening reminder.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "Did you remember to add your gratitude today?"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 21  // 9 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "eveningReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling evening reminder: \(error)")
            } else {
                print("Evening reminder scheduled.")
            }
        }
    }
    
    func scheduleResetGratitudeFlagTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.lumenseed.resetGratitudeFlag")
        request.earliestBeginDate = Calendar.current.date(bySettingHour: 0, minute: 5, second: 0, of: Date().addingTimeInterval(86400)) // Tomorrow 00:05 AM

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule reset gratitude task: \(error)")
        }
    }
    
    func handleResetGratitudeFlagTask(task: BGAppRefreshTask) {
        scheduleResetGratitudeFlagTask() // Reschedule next

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let resetOperation = BlockOperation {
            // You can reset a UserDefaults flag, or let `hasEntryForToday()` naturally re-evaluate entries.
            UserDefaults.standard.set(false, forKey: "hasAddedGratitudeToday")
            print("Reset gratitude daily flag.")
        }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        resetOperation.completionBlock = {
            task.setTaskCompleted(success: !resetOperation.isCancelled)
        }

        queue.addOperation(resetOperation)
    }
}
