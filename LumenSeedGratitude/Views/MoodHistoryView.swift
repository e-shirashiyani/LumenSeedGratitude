//
//  MoodHistoryView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/14/25.
//

import SwiftUI
import Charts

//struct MoodHistoryView: View {
//    let moods: [DailyMood]
//
//    var last7Days: [DailyMood] {
//        let calendar = Calendar.current
//        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: Date())!
//        return moods
//            .filter { $0.date >= sevenDaysAgo }
//            .sorted { $0.date < $1.date }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Your Mood Over the Last 7 Days")
//                .font(.title2)
//                .fontWeight(.bold)
//                .padding()
//
//            Chart {
//                ForEach(last7Days) { mood in
//                    PointMark(
//                        x: .value("Date", mood.date, unit: .day),
//                        y: .value("Mood", mood.yValue)
//                    )
//                    .annotation(position: .top) {
//                        Text(mood.mood.emoji)
//                            .font(.title3)
//                    }
//                }
//            }
//            .chartYScale(domain: 1...5)
//            .frame(height: 250)
//            .padding()
//
//            Spacer()
//        }
//        .background(Color.background)
//        .navigationTitle("Mood History")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}

//extension MoodType {
//    var yValue: Int {
//        switch self {
//        case .great: return 5
//        case .good: return 4
//        case .neutral: return 3
//        case .bad: return 2
//        case .awful: return 1
//        }
//    }
//}
//
//extension DailyMood {
//    var yValue: Int { mood.yValue }
//}
