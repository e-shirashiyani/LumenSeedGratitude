//
//  LumenSeedWidget.swift
//  LumenSeedWidget
//
//  Created by e.shirashiyani on 5/3/25.
//

import WidgetKit
import SwiftUI

struct GratitudeWidgetEntry: TimelineEntry {
    let date: Date
    let displayText: String
    let streakText: String?
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> GratitudeWidgetEntry {
        GratitudeWidgetEntry(date: Date(), displayText: "Stay grateful 🌱", streakText: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> GratitudeWidgetEntry {
        let (text, streakText) = latestGratitudeOrQuote()
        return GratitudeWidgetEntry(date: Date(), displayText: text, streakText: streakText)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<GratitudeWidgetEntry> {
        let (text, streakText) = latestGratitudeOrQuote()
        let entry = GratitudeWidgetEntry(date: Date(), displayText: text, streakText: streakText)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        return timeline
    }

    private func latestGratitudeOrQuote() -> (String, String?) {
        let entries = StorageManager.shared.loadEntries()
        let calendar = Calendar.current

        // Calculate streak
        let streak = StreakManager.shared.calculateStreak(from: entries)
        let streakText = streak > 0 ? "🔥 \(streak)-day gratitude streak" : nil

        if let latest = entries.first,
           calendar.isDate(latest.date, equalTo: Date(), toGranularity: .weekOfYear) {
            return (latest.text, streakText)
        } else {
            return ("Start today’s gratitude 🌱", streakText)
        }
    }
}



struct LumenSeedWidgetEntryView : View {
    var entry: GratitudeWidgetEntry

    var body: some View {
        VStack(spacing: 4) {
            if let streak = entry.streakText {
                Text(streak)
                    .font(.caption)
                    .foregroundColor(.green)
            }

            Text(entry.displayText)
                .font(.footnote)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(3)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct LumenSeedWidget: Widget {
    let kind: String = "LumenSeedWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            LumenSeedWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("LumenSeed Daily")
        .description("See your latest gratitude or an inspiring quote.")
        .supportedFamilies([.accessoryRectangular])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}
