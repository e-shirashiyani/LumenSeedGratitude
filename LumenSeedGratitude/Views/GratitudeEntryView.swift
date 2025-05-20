//
//  GratitudeEntryView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/19/25.
//

import SwiftUI

struct GratitudeEntryView: View {
    let date: String
    let entries: [GratitudeEntry]
    @State private var isExpanded = false
    @State private var navigateToEdit = false
    @Binding var allEntries: [GratitudeEntry]
    let isToday: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            EntryHeaderView(date: date, isToday: isToday)
            EntryContentView(
                entries: entries,
                isExpanded: $isExpanded,
                date: date
            )
        }
//        .padding(.horizontal)
        .background(cardBackground)
        .scaleEffect(navigateToEdit ? 0.95 : 1.0)
        .animation(.spring(), value: navigateToEdit)
        .onTapGesture {
            navigateToEdit = true
            triggerHaptic()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Gratitude entries for \(date), \(entries.count) items")
    }

    @ViewBuilder
    private var cardBackground: some View {
        ZStack {
            NavigationLink(
                destination: EditEntryView(entries: $allEntries, date: date, dailyEntries: entries),
                isActive: $navigateToEdit
            ) {
                EmptyView()
            }
            .hidden()

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.lumenWhite)
                .shadow(color: Color.black.opacity(0.08), radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isToday
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.lumenGreen, Color.lumenGreen.opacity(0.5)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                : AnyShapeStyle(Color.lumenWhite),
                            lineWidth: isToday ? 2 : 0
                        )
                )
        }
    }

    private func triggerHaptic() {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        haptic.impactOccurred()
    }
}

// Header with date and today's star
struct EntryHeaderView: View {
    let date: String
    let isToday: Bool

    var body: some View {
        HStack {
            Text(date)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(.textDarkCharcoal)

            // Uncomment to show mood emoji if available
            // if let mood = entries.first?.mood {
            //     Text(moodEmoji(for: mood))
            //         .font(.subheadline)
            // }

            Spacer()

            if isToday {
                Image(systemName: "star.fill")
                    .foregroundColor(.lumenGreen)
                    .font(.caption)
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

// Entry content with expand/collapse functionality
struct EntryContentView: View {
    let entries: [GratitudeEntry]
    @Binding var isExpanded: Bool
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entries.prefix(isExpanded ? entries.count : 3), id: \.id) { entry in
                Text("• \(entry.text)")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.textDarkCharcoal)
                    .multilineTextAlignment(.leading)
            }

            if entries.count > 3 && !isExpanded {
                Button(action: {
                    withAnimation(.easeInOut) {
                        isExpanded = true
                    }
                    triggerHaptic()
                }) {
                    Text("...and \(entries.count - 3) more")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.lumenGreen)
                        .italic()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Show \(entries.count - 3) more entries for \(date)")
            }

            if isExpanded && entries.count > 3 {
                Button(action: {
                    withAnimation(.easeInOut) {
                        isExpanded = false
                    }
                    triggerHaptic()
                }) {
                    Text("Show less")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.lumenGreen)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Collapse entries for \(date)")
            }
        }
        .padding()
    }

    private func triggerHaptic() {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        haptic.impactOccurred()
    }
}

// Placeholder for EditEntryView (replace with your actual view)
struct EditEntryView: View {
    @Binding var entries: [GratitudeEntry]
    let date: String
    let dailyEntries: [GratitudeEntry]

    var body: some View {
        VStack {
            Text("Entries for \(date)")
                .font(.title)
            ForEach(dailyEntries) { entry in
                Text(entry.text)
            }
            Button("Close") {
                // Handle dismissal
            }
        }
    }
}
