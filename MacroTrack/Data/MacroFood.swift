//
//  MacroFood.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import Foundation


struct MacroFood: Identifiable, Hashable, Equatable {
    var id: String
    var name: String
    var macronutrients: MacronutrientInfo
    
    // Conforming to Equatable by comparing id
    static func == (lhs: MacroFood, rhs: MacroFood) -> Bool {
        return lhs.id == rhs.id  // Assuming food is uniquely identified by 'id'
    }
    
    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)  // Use the unique 'id' to create the hash value
    }
}
