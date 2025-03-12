//
//  Meal.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import Foundation


enum Meal: String, CaseIterable {
    case breakfast, lunch, dinner, snacks, water
    
    var iconName: String {
        switch self {
        case .breakfast:
            return "sun.max.fill"
        case .lunch:
            return "bag"
        case .dinner:
            return "fork.knife"
        case .snacks:
            return "carrot"
        case .water:
            return "waterbottle"
        }
    }
}
