//
//  PastEntriesView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import SwiftUI

struct PastEntriesView: View {
    @Binding var entries: [GratitudeEntry]

    var body: some View {
        List(entries) { entry in
            NavigationLink(destination: EntryDetailView(entry: entry, entries: $entries)) {
                VStack(alignment: .leading) {
                    Text(entry.text)
                        .foregroundColor(.textDarkCharcoal)
                        .lineLimit(1)
                    Text(entry.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.textSoftGray)
                }
                .padding(5)
//                .background(Color.accentSkyBlue.opacity(0.2))
                .cornerRadius(8)
            }
//            .listRowBackground(Color.backgroundMint)
        }
        .listStyle(InsetGroupedListStyle())
//        .background(Color.backgroundMint.edgesIgnoringSafeArea(.all))
        .navigationTitle("Past Entries")
    }
}

//#Preview {
//    PastEntriesView()
//}
