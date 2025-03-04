//
//  UserFoodLogData.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation

struct UserFoodLogData {
    var mealLogs: [String: [[String: Any]]] // Meal type (e.g., breakfast, lunch) with food items (array of dictionaries)
    var servings: [String: Double] // Serving sizes for foods
    var dailyGoals: [String: Double] // Daily goal values

    // Convert to dictionary for Firestore
    func toDict() -> [String: Any] {
        return [
            "mealLogs": mealLogs,
            "servings": servings,
            "dailyGoals": dailyGoals
        ]
    }

    // Initialize from Firestore data
    init?(data: [String: Any]?) {
        guard let data = data else { return nil }

        // Correctly parse `mealLogs` to be an array of dictionaries
        self.mealLogs = data["mealLogs"] as? [String: [[String: Any]]] ?? [:]
        self.servings = data["servings"] as? [String: Double] ?? [:]
        self.dailyGoals = data["dailyGoals"] as? [String: Double] ?? [
            "calories": 2000.0,
            "protein": 150.0,
            "carbs": 250.0,
            "fat": 70.0
        ]
    }
}
