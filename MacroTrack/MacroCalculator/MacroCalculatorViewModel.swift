import SwiftUI

class MacroCalculatorViewModel: ObservableObject {
    // User inputs
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var age: String = ""
    @Published var activityLevel: String = "Moderately Active"
    @Published var fitnessGoal: String = "Maintain Weight" // Fitness goal added
    
    // Calculation results
    @Published var protein: Double = 0
    @Published var carbs: Double = 0
    @Published var fat: Double = 0
    @Published var totalCalories: Double = 0
    
    // Activity and fitness goal options
    let activityLevels = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Super Active"]
    let fitnessGoals = ["Lose Weight", "Maintain Weight", "Gain Weight"]
    
    // Reference to Firebase service
    private var firebaseService = FirebaseService.shared
    
    func calculateMacronutrients() {
        // Ensure the inputs are valid
        guard let weight = Double(weight), let height = Double(height), let age = Int(age) else {
            return // Exit if any input is invalid
        }
        
        // Calculate BMR using the Mifflin-St Jeor Formula (for pounds/inches)
        let bmr: Double
        if activityLevel == "Sedentary" {
            bmr = 66 + (6.23 * weight) + (12.7 * height) - (6.8 * Double(age))
        } else if activityLevel == "Lightly Active" {
            bmr = 66 + (6.23 * weight) + (12.7 * height) - (6.8 * Double(age))
        } else if activityLevel == "Moderately Active" {
            bmr = 66 + (6.23 * weight) + (12.7 * height) - (6.8 * Double(age))
        } else if activityLevel == "Very Active" {
            bmr = 66 + (6.23 * weight) + (12.7 * height) - (6.8 * Double(age))
        } else {
            bmr = 66 + (6.23 * weight) + (12.7 * height) - (6.8 * Double(age))
        }
        
        // TDEE (Total Daily Energy Expenditure)
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
            totalCalories = tdee - 500 // Calorie deficit
        case "Gain Weight":
            totalCalories = tdee + 500 // Calorie surplus
        default:
            totalCalories = tdee // Maintain weight
        }
        
        // Macronutrient calculations (adjust based on weight)
        protein = weight * 0.73
        carbs = weight * 1.36
        fat = weight * 0.36
    }
    
    // Save the calculated data to Firebase
    func saveUserMacroDataToFirebase(userId: String) {
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
        
        firebaseService.updateUserMacroData(userId: userId, userMacroData: userMacroData)
    }
    
    // Fetch user data from Firebase
    func fetchUserMacroData(userId: String) {
        firebaseService.fetchUserMacroData(userId: userId) { [weak self] userMacroData in
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
