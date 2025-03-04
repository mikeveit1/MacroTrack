import SwiftUI
import FatSecretSwift

class FoodLogViewModel: ObservableObject {
    @Published var mealLogs: MealLogs = MealLogs()
    @Published var currentDate: Date = Date()
    @Published var searchResults: [SearchedFood] = []
    @Published var servings: [String: Double] = [:] // Dictionary of servings for each food by food.id
    @Published var dailyGoals: [String: Double] = [
        "calories": 2000.0,  // Example: 2000 calories
        "protein": 150.0,    // Example: 150g protein
        "carbs": 250.0,      // Example: 250g carbs
        "fat": 70.0          // Example: 70g fat
    ]
    
    var selectedMeal: Meal = .breakfast
    var foodHelper = FoodHelper()
    
    func saveDailyGoals(newGoals: [String: Double]) {
        dailyGoals = newGoals
        guard let userID = FirebaseService.shared.getCurrentUserID() else { return }
        FirebaseService.shared.saveDailyGoals(userID: userID, goals: newGoals) { success, error in
            if let error = error {
                print("Error saving daily goals: \(error.localizedDescription)")
            } else {
                print("Daily goals saved successfully.")
            }
        }
    }
    
    // Function to get the total macros across all meals
    func getTotalMacros() -> MacronutrientInfo {
        var totalCalories: Double = 0
        var totalProtein: Double = 0
        var totalCarbs: Double = 0
        var totalFat: Double = 0
        
        // Sum across each meal type
        for meal in Meal.allCases {
            if let mealItems = mealLogs[meal] {
                for food in mealItems {
                    totalCalories += food.macronutrients.calories
                    totalProtein += food.macronutrients.protein
                    totalCarbs += food.macronutrients.carbs
                    totalFat += food.macronutrients.fat
                }
            }
        }
        
        return MacronutrientInfo(
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat
        )
    }
    
    func searchFoods(query: String) {
        guard !query.isEmpty else {
            return
        }
        
        foodHelper.searchFood(query: query) { foods in
            DispatchQueue.main.async {
                self.searchResults = foods
            }
        }
    }
    
    // Save food to the selected meal
    func saveFood(food: MacroFood) {
        addFoodToMeal(meal: selectedMeal, food: food)
        saveFoodToFirebase(food: food) // Save the food to Firebase
    }
    
    // Add food to selected meal
    func addFoodToMeal(meal: Meal, food: MacroFood) {
        saveOriginalMacros(for: food)
        _ = getTotalMacros()
        
        // Ensuring mealLogs is updated on the main thread
        DispatchQueue.main.async {
            self.mealLogs[meal]?.append(food)
        }
    }
    
    // Delete food from selected meal
    func deleteFoodFromMeal(meal: Meal, food: MacroFood) {
        DispatchQueue.main.async {
            self.mealLogs[meal]?.removeAll { $0.id == food.id }
        }
        deleteFoodFromFirebase(food: food) // Delete food from Firebase
    }
    
    // Go to today's date
    func goToToday() {
        DispatchQueue.main.async {
            self.currentDate = Date()
            self.fetchFoodLog()
        }
    }
    
    // Go to the previous day
    func goToPreviousDay() {
        DispatchQueue.main.async {
            self.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDate) ?? Date()
            self.fetchFoodLog()
        }
    }
    
    // Go to the next day
    func goToNextDay() {
        DispatchQueue.main.async {
            self.currentDate = Calendar.current.date(byAdding: .day, value: 1, to: self.currentDate) ?? Date()
            self.fetchFoodLog()
        }
    }

    // Format date into a readable string
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"  // Use a simpler format, e.g., "2025-03-05"
        return formatter.string(from: date)
    }
    
    func convertSearchFoodToMacroFood(searchedFood: SearchedFood, completion: @escaping (MacroFood) -> Void) {
        foodHelper.convertSearchFoodToMacroFood(searchedFood: searchedFood) { macroFood in
            DispatchQueue.main.async {
                completion(macroFood)
            }
        }
    }
    
    var originalMacronutrients: [String: MacronutrientInfo] = [:]
    
    func saveOriginalMacros(for food: MacroFood) {
        DispatchQueue.main.async {
            self.originalMacronutrients[food.id] = food.macronutrients
        }
    }
    
    func updateFoodMacrosForServings(food: MacroFood, servings: Double) -> MacroFood {
        // If servings are reset to 1, return the original food
        if servings == 1 {
            if let originalMacros = originalMacronutrients[food.id] {
                return MacroFood(id: food.id, name: food.name, macronutrients: originalMacros, servingDescription: food.servingDescription)
            }
        }
        
        // Get the original macronutrients for multiplication
        if let originalMacros = originalMacronutrients[food.id] {
            var updatedFood = food
            
            // Multiply original values by servings
            updatedFood.macronutrients.calories = originalMacros.calories * servings
            updatedFood.macronutrients.protein = originalMacros.protein * servings
            updatedFood.macronutrients.carbs = originalMacros.carbs * servings
            updatedFood.macronutrients.fat = originalMacros.fat * servings
            
            // Round values to 2 decimal places
            updatedFood.macronutrients.protein = updatedFood.macronutrients.protein.rounded(toPlaces: 2)
            updatedFood.macronutrients.carbs = updatedFood.macronutrients.carbs.rounded(toPlaces: 2)
            updatedFood.macronutrients.fat = updatedFood.macronutrients.fat.rounded(toPlaces: 2)
            
            return updatedFood
        }
        
        // If no original macros were found, return the original food without modifications
        return food
    }
    
    // Update the meal log with the updated food
    func updateMealLogWithUpdatedFood(updatedFood: MacroFood, meal: Meal) {
        DispatchQueue.main.async {
            // Find the index of the food with the same ID in the selected meal's list
            if let index = self.mealLogs[meal]?.firstIndex(where: { $0.id == updatedFood.id }) {
                // Update the existing food in the meal
                self.mealLogs[meal]?[index] = updatedFood
            }
        }
    }
    
    func getTotalMacronutrients(for meal: Meal) -> MacronutrientInfo {
        var totalMacronutrients = MacronutrientInfo(calories: 0, protein: 0, carbs: 0, fat: 0)
        
        // Sum the macronutrients of all foods in the meal
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
    
    // MARK: - Firebase Integration Methods
    func fetchFoodLog() {
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            print("No user is logged in")
            return
        }
        
        self.mealLogs = MealLogs()
        
        let date = formatDate(currentDate)  // Make sure the format is correct (e.g., "Mar 5, 2025")
        print("Fetching food log for date: \(date)")  // Debugging log

        FirebaseService.shared.getFoodLog(userID: userID, date: date) { [weak self] foodLogData, error in
            if let error = error {
                print("Error fetching food log: \(error.localizedDescription)")
            } else if let foodLogData = foodLogData {
                DispatchQueue.main.async {
                    print("Food log fetched successfully")
                        // Reset mealLogs to avoid stale data
                    
                    // Parse the fetched data
                    for (mealKey, mealData) in foodLogData {
                        if let meal = Meal(rawValue: mealKey) {
                            var foods: [MacroFood] = []
                            if let mealFoods = mealData as? [String: [String: Any]] {
                                for (_, foodData) in mealFoods {
                                    if let foodData = try? JSONSerialization.data(withJSONObject: foodData, options: []) {
                                        let decoder = JSONDecoder()
                                        do {
                                            let food = try decoder.decode(MacroFood.self, from: foodData)
                                            foods.append(food)
                                        } catch {
                                            print("Error decoding food data: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                            self?.mealLogs[meal] = foods
                        }
                    }
                }
            }
        }
    }





    
    // Save food to Firebase
    func saveFoodToFirebase(food: MacroFood) {
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            print("No user is logged in")
            return
        }
        
        let date = formatDate(currentDate)
        FirebaseService.shared.saveFoodToMeal(userID: userID, date: date, meal: selectedMeal.rawValue, food: food) { success, error in
            if let error = error {
                print("Error saving food to Firebase: \(error.localizedDescription)")
            } else if success {
                print("Food saved to Firebase successfully")
            }
        }
    }
    
    // Delete food from Firebase
    func deleteFoodFromFirebase(food: MacroFood) {
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            print("No user is logged in")
            return
        }
        
        let date = formatDate(currentDate)
        FirebaseService.shared.deleteFoodFromFirebase(userID: userID, date: date, meal: selectedMeal.rawValue, food: food) { success, error in
            if let error = error {
                print("Error deleting food from Firebase: \(error.localizedDescription)")
            } else if success {
                print("Food deleted from Firebase successfully")
            }
        }
    }
}
