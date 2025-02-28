import SwiftUI
import FatSecretSwift

class FoodLogViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var mealLogs: MealLogs = MealLogs()
    @Published var currentDate: Date = Date()
    @Published var searchResults: [SearchedFood] = []
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
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    func convertSearchFoodToMacroFood(searchedFood: SearchedFood, completion: @escaping (MacroFood) -> Void) {
        foodHelper.convertSearchFoodToMacroFood(searchedFood: searchedFood) { macroFood in
            completion(macroFood)
        }
    }
    
}
