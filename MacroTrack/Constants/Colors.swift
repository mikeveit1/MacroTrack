//
//  Constants.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//


import SwiftUI

struct Colors {
    static let primary = Color(hex: "#2f7d70")
    static let secondary = Color(hex: "#ffffff")
    static let primaryLight = Color(hex: "#3f9c91")
    static let gray = (Color(UIColor(white: 0.9, alpha: 1.0)))
}

import SwiftUI

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
