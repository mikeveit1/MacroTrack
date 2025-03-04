//
//  UserMacroData.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation

struct UserMacroData {
    var weight: Double
    var height: Double
    var age: Int
    var activityLevel: String
    var fitnessGoal: String
    var totalCalories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    
    init(weight: Double, height: Double, age: Int, activityLevel: String, fitnessGoal: String, totalCalories: Double, protein: Double, carbs: Double, fat: Double) {
        self.weight = weight
        self.height = height
        self.age = age
        self.activityLevel = activityLevel
        self.fitnessGoal = fitnessGoal
        self.totalCalories = totalCalories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
    
    // Convert UserMacroData to dictionary for Firestore
    func toDict() -> [String: Any] {
        return [
            "weight": weight,
            "height": height,
            "age": age,
            "activityLevel": activityLevel,
            "fitnessGoal": fitnessGoal,
            "totalCalories": totalCalories,
            "protein": protein,
            "carbs": carbs,
            "fat": fat
        ]
    }
    
    // Initialize from Firestore data
    init?(data: [String: Any]?) {
        guard let data = data else { return nil }
        
        self.weight = data["weight"] as? Double ?? 0.0
        self.height = data["height"] as? Double ?? 0.0
        self.age = data["age"] as? Int ?? 0
        self.activityLevel = data["activityLevel"] as? String ?? "Moderately Active"
        self.fitnessGoal = data["fitnessGoal"] as? String ?? "Maintain Weight"
        self.totalCalories = data["totalCalories"] as? Double ?? 0.0
        self.protein = data["protein"] as? Double ?? 0.0
        self.carbs = data["carbs"] as? Double ?? 0.0
        self.fat = data["fat"] as? Double ?? 0.0
    }
}
