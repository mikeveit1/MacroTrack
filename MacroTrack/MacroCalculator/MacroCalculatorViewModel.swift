import SwiftUI

class MacroCalculatorViewModel: ObservableObject {
    // User inputs
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var age: String = ""
    @Published var activityLevel: String = "Moderately Active"
    @Published var fitnessGoal: String = "Maintain Weight" // Fitness goal added
    
    // Calculation results
    @Published var protein: Int = 0
    @Published var carbs: Int = 0
    @Published var fat: Int = 0
    @Published var totalCalories: Int = 0
    
    // Activity and fitness goal options
    let activityLevels = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Super Active"]
    let fitnessGoals = ["Lose Weight", "Maintain Weight", "Gain Weight"]
    
    func calculateMacronutrients() {
        // Ensure the inputs are valid
        guard let weight = Double(weight), let height = Double(height), let age = Int(age) else {
            return // Exit if any input is invalid
        }
        
        // Calculate BMR using the Mifflin-St Jeor Formula (pounds and inches)
        let bmr = 66 + (6.23 * weight) + (12.7 * height) - (6.8 * Double(age))
        
        // TDEE (Total Daily Energy Expenditure) based on activity level
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
            tdee = bmr * 1.55 // Default to moderately active
        }
        
        // Adjust TDEE based on fitness goal
        switch fitnessGoal {
        case "Lose Weight":
            totalCalories = Int(tdee - 500) // Calorie deficit
        case "Gain Weight":
            totalCalories = Int(tdee + 500) // Calorie surplus
        default:
            totalCalories = Int(tdee) // Maintain weight
        }
        
        // Macronutrient breakdown (percentages based on total calories)
        let proteinPercentage = 0.25  // 30% of total calories from protein
        let carbsPercentage = 0.45    // 40% of total calories from carbs
        let fatPercentage = 0.30      // 30% of total calories from fat
        
        // Calories per gram for each macro
        let proteinCalories = 4
        let carbsCalories = 4
        let fatCalories = 9
        
        // Calculate grams of each macronutrient
        let proteinGrams = (Double(totalCalories) * proteinPercentage) / Double(proteinCalories)
        let carbsGrams = (Double(totalCalories) * carbsPercentage) / Double(carbsCalories)
        let fatGrams = (Double(totalCalories) * fatPercentage) / Double(fatCalories)
        
        // Assign the calculated values to variables
        protein = Int(proteinGrams)
        carbs = Int(carbsGrams)
        fat = Int(fatGrams)
        
        saveUserMacroDataToFirebase()
    }

    
    // Save the calculated data to Firebase
    func saveUserMacroDataToFirebase() {
        let userMacroData = UserMacroData(
            weight: Double(weight) ?? 0,
            height: Double(height) ?? 0,
            age: Int(age) ?? 0,
            activityLevel: activityLevel,
            fitnessGoal: fitnessGoal,
            totalCalories: totalCalories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
        
        FirebaseService.shared.updateUserMacroData(userMacroData: userMacroData)
    }
    
    // Fetch user data from Firebase
    func fetchUserMacroData() {
        FirebaseService.shared.fetchUserMacroData() { [weak self] userMacroData in
            if let data = userMacroData {
                self?.weight = String(data.weight)
                self?.height = String(data.height)
                self?.age = String(data.age)
                self?.activityLevel = data.activityLevel
                self?.fitnessGoal = data.fitnessGoal
                self?.totalCalories = data.totalCalories
                self?.protein = data.protein
                self?.carbs = data.carbs
                self?.fat = data.fat
            }
        }
    }
}
