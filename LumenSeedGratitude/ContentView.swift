//
//  ContentView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var entries: [GratitudeEntry] = []
    
    var groupedAndSortedEntries: [(key: String, value: [GratitudeEntry])] {
        let grouped = Dictionary(grouping: entries) { entry in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: entry.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                Text(entries.isEmpty ? "Welcome to LumenSeed" : "Keep growing your gratitude")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textDarkCharcoal)
                    . multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
                // Content
                if entries.isEmpty {
                    Text("Your gratitude journey starts here. Let's fill this space with positivity and joy! 🌈")
                        .font(.body)
                        .foregroundColor(.textSoftGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    ScrollView {
                        ForEach(groupedAndSortedEntries, id: \.key) { date, dailyEntries in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(date)
                                    .font(.headline)
                                    .foregroundColor(.textDarkCharcoal)
                                    .padding(.vertical, 5)
                                
                                // Combine entries into one card
                                VStack(alignment: .leading, spacing: 5) {
                                    // Display up to 4 entries with bullet points
                                    ForEach(dailyEntries.prefix(3), id: \.id) { entry in
                                        Text("• \(entry.text)")
                                            .font(.body)
                                            .foregroundColor(.textDarkCharcoal)
                                    }
                                    // Add "..." if there are more than 4 entries
                                    if dailyEntries.count > 4 {
                                        Text("...and \(dailyEntries.count - 4) more")
                                            .font(.subheadline)
                                            .foregroundColor(.textSoftGray)
                                            .italic()
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                
                Spacer()
                
                // Navigation Button
                NavigationLink(destination: NewEntryView(entries: $entries)) {
                    Text("Add a New Gratitude 🌱")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.darkBackground)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.background)
            .navigationBarHidden(true)
        }
        .onAppear {
            entries = StorageManager.shared.loadEntries()
        }
        .onChange(of: entries) { newValue in
            StorageManager.shared.saveEntries(newValue)
        }
    }
}
#Preview {
    ContentView()
    //        .modelContainer(for: Item.self, inMemory: true)
}
