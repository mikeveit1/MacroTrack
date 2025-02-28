//
//  Meal.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import Foundation


enum Meal: String, CaseIterable {
    case breakfast, lunch, dinner, snacks
    
    var iconName: String {
        switch self {
        case .breakfast:
            return "egg.fried"
        case .lunch:
            return "bag"
        case .dinner:
            return "staroflife"
        case .snacks:
            return "applelogo"
        }
    }
}
