//
//  ColorExtensions.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import SwiftUI

extension Color {
    // Background colors
    static let primaryBackground = Color(hex: "ae2d27")
    static let secondaryBackground = Color(hex: "dfb492")
    static let tertiaryBackground = Color(hex: "ffc934")
    
    // Element/Button colors
    static let primaryButton = Color(hex: "1ed55f")
    static let secondaryButton = Color(hex: "ffff03")
    static let accentButton = Color(hex: "eb262f")
    
    // Additional UI colors
    static let cardBackground = Color(white: 0.95)
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    
    // Initialize color from hex string
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Gradient definitions
extension LinearGradient {
    static let newsBackground = LinearGradient(
        gradient: Gradient(colors: [.primaryBackground, .secondaryBackground]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [.primaryButton, .primaryButton.opacity(0.8)]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

