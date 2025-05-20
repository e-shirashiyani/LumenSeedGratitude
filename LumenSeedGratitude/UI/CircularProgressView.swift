//
//  CircularProgressView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/19/25.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let total: Double
    let isCompleted: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .foregroundColor(.textSoftGray.opacity(0.2))
            
            Circle()
                .trim(from: 0, to: min(progress / total, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .foregroundColor(isCompleted ? .lumenGreen : .lumenGreen.opacity(0.8))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int((progress / total) * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.darkBackground)
        }
        .frame(width: 50, height: 50)
    }
}
