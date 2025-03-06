//
//  UserMeals.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/6/25.
//

import Foundation


struct UserMeal: Identifiable, Hashable, Equatable, Codable {
    var id: String
    var name: String
    var foods: [MacroFood]
    
    // Conforming to Equatable by comparing id
    static func == (lhs: UserMeal, rhs: UserMeal) -> Bool {
        return lhs.id == rhs.id
    }

    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

