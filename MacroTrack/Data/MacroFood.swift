//
//  MacroFood.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation

struct MacroFood: Identifiable, Hashable, Equatable, Codable {
    var id: String
    var name: String
    var macronutrients: MacronutrientInfo
    var originalMacros: MacronutrientInfo
    var servingDescription: String
    var servings: Double
    var addDate: Date
    
    static func == (lhs: MacroFood, rhs: MacroFood) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
