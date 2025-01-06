//
//  EntryDetailView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import SwiftUI

struct EntryDetailView: View {
    var entry: GratitudeEntry
    @Binding var entries: [GratitudeEntry]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: .constant(entry.text))
                .padding()
//                .background(Color.backgroundLavender)
                .cornerRadius(10)
                .disabled(true)

            Text("Date: \(entry.date, style: .date)")
//                .foregroundColor(.textSoftGray)
                .font(.subheadline)

            Spacer()

            HStack {
                Button(action: {
                    if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                        entries.remove(at: index)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                        .padding()
//                        .background(Color.buttonCoral)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.vertical)
        }
        .padding()
//        .background(Color.backgroundMint)
        .navigationTitle("Entry Details")
    }
}
//#Preview {
//    EntryDetailView()
//}
