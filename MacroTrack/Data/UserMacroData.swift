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
    var gender: String
    var activityLevel: String
    var fitnessGoal: String
    var totalCalories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var water: Int? = 128
    
    init(weight: Double, height: Double, age: Int, gender: String, activityLevel: String, fitnessGoal: String, totalCalories: Int, protein: Int, carbs: Int, fat: Int, water: Int? = 128) {
        self.weight = weight
        self.height = height
        self.age = age
        self.gender = gender
        self.activityLevel = activityLevel
        self.fitnessGoal = fitnessGoal
        self.totalCalories = totalCalories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        if water != nil {
            self.water = water
        }
    }
    
    func toDict() -> [String: Any] {
        return [
            "weight": weight,
            "height": height,
            "age": age,
            "gender": gender,
            "activityLevel": activityLevel,
            "fitnessGoal": fitnessGoal,
            "totalCalories": totalCalories,
            "protein": protein,
            "carbs": carbs,
            "fat": fat,
            "water": water ?? 128
        ]
    }
    
    init?(data: [String: Any]?) {
        guard let data = data else { return nil }
        
        self.weight = data["weight"] as? Double ?? 0.0
        self.height = data["height"] as? Double ?? 0.0
        self.age = data["age"] as? Int ?? 0
        self.gender = data["gender"] as? String ?? "Male"
        self.activityLevel = data["activityLevel"] as? String ?? "Moderately Active"
        self.fitnessGoal = data["fitnessGoal"] as? String ?? "Maintain Weight"
        self.totalCalories = data["totalCalories"] as? Int ?? 0
        self.protein = data["protein"] as? Int ?? 0
        self.carbs = data["carbs"] as? Int ?? 0
        self.fat = data["fat"] as? Int ?? 0
        self.water = data["water"] as? Int ?? 0
    }
}
