//
//  MealLogs.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import Foundation


struct MealLogs: Equatable {
    var breakfast: [MacroFood] = []
    var lunch: [MacroFood] = []
    var dinner: [MacroFood] = []
    var snacks: [MacroFood] = []
    var water: [MacroFood] = []
    
    subscript(meal: Meal) -> [MacroFood]? {
        get {
            switch meal {
            case .breakfast: return breakfast
            case .lunch: return lunch
            case .dinner: return dinner
            case .snacks: return snacks
            case .water: return water
            }
        }
        set {
            switch meal {
            case .breakfast: breakfast = newValue ?? []
            case .lunch: lunch = newValue ?? []
            case .dinner: dinner = newValue ?? []
            case .snacks: snacks = newValue ?? []
            case .water: water = newValue ?? []
            }
        }
    }
    
    // Conformance to Equatable protocol
    static func ==(lhs: MealLogs, rhs: MealLogs) -> Bool {
        return lhs.breakfast == rhs.breakfast &&
        lhs.lunch == rhs.lunch &&
        lhs.dinner == rhs.dinner &&
        lhs.snacks == rhs.snacks &&
        lhs.water == rhs.water
    }
}

