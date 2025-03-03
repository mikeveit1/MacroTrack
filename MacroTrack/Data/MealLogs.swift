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

    subscript(meal: Meal) -> [MacroFood]? {
        get {
            switch meal {
            case .breakfast: return breakfast
            case .lunch: return lunch
            case .dinner: return dinner
            case .snacks: return snacks
            }
        }
        set {
            switch meal {
            case .breakfast: breakfast = newValue ?? []
            case .lunch: lunch = newValue ?? []
            case .dinner: dinner = newValue ?? []
            case .snacks: snacks = newValue ?? []
            }
        }
    }

    // Conformance to Equatable protocol
    static func ==(lhs: MealLogs, rhs: MealLogs) -> Bool {
        return lhs.breakfast == rhs.breakfast &&
               lhs.lunch == rhs.lunch &&
               lhs.dinner == rhs.dinner &&
               lhs.snacks == rhs.snacks
    }
}

