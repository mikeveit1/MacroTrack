//
//  MealLogs.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import Foundation


struct MealLogs {
    var breakfast: [String] = []
    var lunch: [String] = []
    var dinner: [String] = []
    var snacks: [String] = []

    subscript(meal: Meal) -> [String]? {
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
}

