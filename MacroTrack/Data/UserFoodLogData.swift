//
//  UserFoodLogData.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation

struct UserFoodLogData {
    var mealLogs: [String: [[String: Any]]]
    var servings: [String: Double]
    var dailyGoals: [String: Double]

    func toDict() -> [String: Any] {
        return [
            "mealLogs": mealLogs,
            "servings": servings,
            "dailyGoals": dailyGoals
        ]
    }

    init?(data: [String: Any]?) {
        guard let data = data else { return nil }

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
