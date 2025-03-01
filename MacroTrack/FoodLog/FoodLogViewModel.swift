import SwiftUI
import FatSecretSwift

class FoodLogViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var mealLogs: MealLogs = MealLogs()
    @Published var currentDate: Date = Date()
    @Published var searchResults: [SearchedFood] = []
    @Published var servings: [String: Double] = [:] // Dictionary of servings for each food by food.id
    var selectedMeal: Meal = .breakfast
    var foodHelper = FoodHelper()
    
    func searchFoods(query: String) {
        guard !query.isEmpty else {
            return
        }
        
        self.isLoading = true
        foodHelper.searchFood(query: query) { foods in
            DispatchQueue.main.async {
                self.searchResults = foods
                self.isLoading = false
            }
        }
    }
    
    // Save food to the selected meal
    func saveFood(food: MacroFood) {
        addFoodToMeal(meal: selectedMeal, food: food)
    }
    
    // Add food to selected meal
    func addFoodToMeal(meal: Meal, food: MacroFood) {
        saveOriginalMacros(for: food)
        mealLogs[meal]?.append(food)
    }
    
    // Delete food from selected meal
    func deleteFoodFromMeal(meal: Meal, food: MacroFood) {
        mealLogs[meal]?.removeAll { $0.id == food.id }
    }
    
    // Go to today's date
    func goToToday() {
        currentDate = Date()
    }
    
    // Go to the previous day
    func goToPreviousDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
    }
    
    // Go to the next day
    func goToNextDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
    }
    
    // Format date into a readable string
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func convertSearchFoodToMacroFood(searchedFood: SearchedFood, completion: @escaping (MacroFood) -> Void) {
        foodHelper.convertSearchFoodToMacroFood(searchedFood: searchedFood) { macroFood in
            completion(macroFood)
        }
    }
    
    var originalMacronutrients: [String: MacronutrientInfo] = [:]
    
    func saveOriginalMacros(for food: MacroFood) {
        originalMacronutrients[food.id] = food.macronutrients
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
            updatedFood.macronutrients.protein = updatedFood.macronutrients.protein.rounded(toPlaces: 0)
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
        // Find the index of the food with the same ID in the selected meal's list
        if let index = mealLogs[meal]?.firstIndex(where: { $0.id == updatedFood.id }) {
            // Update the existing food in the meal
            mealLogs[meal]?[index] = updatedFood
        }
    }
}
