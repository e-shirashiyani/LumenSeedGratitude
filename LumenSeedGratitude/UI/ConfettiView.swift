//
//  ConfettiView.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 5/19/25.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct ConfettiView: View {
    private let particleCount = 30
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ParticleView(particle: particle, geometry: geometry)
                        .offset(x: particle.xOffset, y: particle.yOffset)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            // Initialize particles
            particles = (0..<particleCount).map { _ in
                Particle(
                    xOffset: 0,
                    yOffset: -100,
                    opacity: 1.0,
                    rotation: Double.random(in: -45...45),
                    shape: ParticleShape.allCases.randomElement()!,
                    color: [.lumenGreen, .init(red: 0.9, green: 0.6, blue: 0.8), .init(red: 0.6, green: 0.8, blue: 1.0), .yellow].randomElement()!,
                    speed: Double.random(in: 300...600),
                    drift: Double.random(in: -100...100),
                    delay: Double.random(in: 0...0.5)
                )
            }

            // Animate particles
            for index in particles.indices {
                withAnimation(.interpolatingSpring(stiffness: 50, damping: 10).delay(particles[index].delay)) {
                    particles[index].yOffset = 800 // Move to bottom
                    particles[index].xOffset = particles[index].drift
                    particles[index].opacity = 0.0 // Fade out
                    particles[index].rotation += Double.random(in: 90...360)
                }
            }
        }
    }

    // Particle data model
    struct Particle: Identifiable {
        let id = UUID()
        var xOffset: CGFloat
        var yOffset: CGFloat
        var opacity: Double
        var rotation: Double
        let shape: ParticleShape
        let color: Color
        let speed: Double
        let drift: Double
        let delay: Double
    }

    // Particle shape options
    enum ParticleShape: CaseIterable {
        case circle
        case rectangle
        case square
    }
}

// View for rendering individual particles
struct ParticleView: View {
    let particle: ConfettiView.Particle
    let geometry: GeometryProxy

    var body: some View {
        Group {
            switch particle.shape {
            case .circle:
                Circle()
                    .frame(width: 8, height: 8)
            case .rectangle:
                Rectangle()
                    .frame(width: 10, height: 6)
            case .square:
                Rectangle()
                    .frame(width: 8, height: 8)
            }
        }
        .foregroundColor(particle.color)
        .offset(x: geometry.size.width / 2) 
    }
}

