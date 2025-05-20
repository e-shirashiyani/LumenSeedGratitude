//
//  ChallengeCardView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/19/25.
//

import SwiftUI

struct ChallengeCardView: View {
    var challenge: GratitudeChallenge
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.cardGradientStart, .cardGradientEnd]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(challenge.title)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundColor(.darkBackground)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.lumenGreen)
                            .scaleEffect(challenge.isCompleted ? 1.1 : 1.0)
                            .animation(.spring(), value: challenge.isCompleted)
                    }
                }
                
                Text(challenge.description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.textSoftGray)
                    .lineLimit(2)
                
                HStack {
                    CircularProgressView(
                        progress: Double(challenge.completedDays),
                        total: Double(challenge.totalDays),
                        isCompleted: challenge.isCompleted
                    )
                    
                    VStack(alignment: .leading) {
                        Text(challenge.isCompleted ? "🎉 Completed!" : "Day \(challenge.completedDays) of \(challenge.totalDays)")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundColor(challenge.isCompleted ? .lumenGreen : .textSoftGray)
                        
                        Text("Started: \(challenge.startDate, format: .dateTime.month().day().year())")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.textSoftGray.opacity(0.8))
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
        }
//        .padding(.horizontal)
        .scaleEffect(challenge.isCompleted ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: challenge.isCompleted)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(challenge.title), \(challenge.description), \(challenge.completedDays) of \(challenge.totalDays) days completed")
    }
}
struct ChallengeCardItemView: View {
        let challenge: GratitudeChallenge
        let isSelected: Bool
        let onTap: () -> Void

        var body: some View {
            ChallengeCardView(challenge: challenge)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                .overlay(
                    Group {
                        if challenge.isCustom {
                            Text("Custom")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .padding(4)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.lumenWhite)
                                .clipShape(Capsule())
                                .offset(x: 8, y: -8)
                        }
                    },
                    alignment: .topLeading
                )
                .scaleEffect(isSelected ? 0.95 : 1.0)
                .animation(.spring(), value: isSelected)
                .onTapGesture {
                    onTap()
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("Join \(challenge.title) challenge")
        }
    }
