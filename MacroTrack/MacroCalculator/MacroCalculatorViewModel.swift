//
//  MacroCalculatorViewModel.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import SwiftUI

class MacroCalculatorViewModel: ObservableObject {
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var age: String = ""
    @Published var activityLevel: String = "Moderately Active"
    @Published var fitnessGoal: String = "Maintain Weight"
    @Published var gender: String = "Male"
    
    @Published var protein: Int = 0
    @Published var carbs: Int = 0
    @Published var fat: Int = 0
    @Published var totalCalories: Int = 0
    
    @Published var macroLink: String = "https://shop.bodybuilding.com/blogs/tools-and-calculators/macro-calculator-count-your-macros-like-a-pro?srsltid=AfmBOoqfhvL-6tD8d-qzzMKbeEKEHWIsm-xMpxkEWuFSFOZ3-8BHk4nb"
    
    let genders = ["Male", "Female"]
    let activityLevels = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Super Active"]
    let fitnessGoals = ["Lose Weight", "Maintain Weight", "Gain Weight"]
    
    func calculateMacronutrients() {
        guard let weightInPounds = Double(weight),
              let heightInInches = Double(height),
              let age = Int(age) else {
            return
        }
        
        let weightInKg = weightInPounds * 0.453592
        let heightInCm = heightInInches * 2.54
        
        var bmr: Double
        
        if gender == "Male" {
            bmr = 10 * weightInKg + 6.25 * heightInCm - 5 * Double(age) + 5
        } else {
            bmr = 10 * weightInKg + 6.25 * heightInCm - 5 * Double(age) - 161
        }
        
        var tdee: Double
        switch activityLevel {
        case "Sedentary":
            tdee = bmr * 1.2
        case "Lightly Active":
            tdee = bmr * 1.375
        case "Moderately Active":
            tdee = bmr * 1.55
        case "Very Active":
            tdee = bmr * 1.725
        case "Super Active":
            tdee = bmr * 1.9
        default:
            tdee = bmr * 1.55
        }
        
        switch fitnessGoal {
        case "Lose Weight":
            totalCalories = Int(tdee * 0.8)
        case "Gain Weight":
            totalCalories = Int(tdee + 500)
        default:
            totalCalories = Int(tdee)
        }
        
        let proteinPercentage: Double
        let carbsPercentage: Double
        let fatPercentage: Double
        
        proteinPercentage = 0.25
        carbsPercentage = 0.45
        fatPercentage = 0.30
        
        let proteinCalories = 4
        let carbsCalories = 4
        let fatCalories = 9
        
        let proteinGrams = (Double(totalCalories) * proteinPercentage) / Double(proteinCalories)
        let carbsGrams = (Double(totalCalories) * carbsPercentage) / Double(carbsCalories)
        let fatGrams = (Double(totalCalories) * fatPercentage) / Double(fatCalories)
        
        protein = Int(proteinGrams)
        carbs = Int(carbsGrams)
        fat = Int(fatGrams)
        
        saveUserMacroDataToFirebase()
    }
    
    func saveUserMacroDataToFirebase() {
        let userMacroData = UserMacroData(
            weight: Double(weight) ?? 0,
            height: Double(height) ?? 0,
            age: Int(age) ?? 0,
            gender: gender,
            activityLevel: activityLevel,
            fitnessGoal: fitnessGoal,
            totalCalories: totalCalories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
        
        FirebaseService.shared.updateUserMacroData(userMacroData: userMacroData)
    }

    func fetchUserMacroData() {
        FirebaseService.shared.fetchUserMacroData() { [weak self] userMacroData in
            if let data = userMacroData {
                self?.weight = String(data.weight)
                self?.height = String(data.height)
                self?.age = String(data.age)
                self?.activityLevel = data.activityLevel
                self?.fitnessGoal = data.fitnessGoal
                self?.gender = data.gender
                self?.totalCalories = data.totalCalories
                self?.protein = data.protein
                self?.carbs = data.carbs
                self?.fat = data.fat
            }
        }
    }
}
