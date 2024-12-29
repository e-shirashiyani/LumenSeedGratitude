//
//  Color.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/3/24.
//

import SwiftUI

extension Color {
    static let softBackgroundMint = Color(hex: "#C7E8D1")
    static let backgroundMint = Color(hex: "#DFF7E1")
    static let background = Color(hex: "#EEEEEE")
    static let backgroundLavender = Color(hex: "#F3E8FD")
    static let buttonPeach = Color(hex: "#FFD6A5")
    static let buttonCoral = Color(hex: "#FFABAB")
    static let textDarkCharcoal = Color(hex: "#3C3C3C")
    static let textSoftGray = Color(hex: "#707070")
    static let accentSkyBlue = Color(hex: "#AEEAF2")
    static let accentCalmYellow = Color(hex: "#FFF8A5")
    static let lGreen = Color(hex: "#7BC74D")
    static let darkBackground = Color(hex: "#393E46")
    static let lightBackground = Color(hex: "#eeeeee")

}

// Hex-to-Color Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
