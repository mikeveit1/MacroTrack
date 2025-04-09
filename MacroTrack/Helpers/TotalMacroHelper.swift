//
//  TotalMacroHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 4/9/25.
//

import Foundation

class TotalMacroHelper {
    func getTotalMacronutrients(for meal: Meal, mealLogs: MealLogs) -> MacronutrientInfo {
        var totalMacronutrients = MacronutrientInfo(calories: 0, protein: 0, carbs: 0, fat: 0)
        
        if let foods = mealLogs[meal] {
            for food in foods {
                totalMacronutrients.calories += food.macronutrients.calories
                totalMacronutrients.protein += food.macronutrients.protein
                totalMacronutrients.carbs += food.macronutrients.carbs
                totalMacronutrients.fat += food.macronutrients.fat
            }
        }
        
        return totalMacronutrients
    }
}
