//
//  FoodLogViewModel.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import SwiftUI
import FatSecretSwift

class FoodLogViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var mealLogs: MealLogs = MealLogs()
    @Published var currentDate: Date = Date()
    @Published var searchResults: [SearchedFood] = []
    @Published var servings: [String: Double] = [:]
    @Published var showCalories = true
    @Published var showProtein = true
    @Published var showCarbs = true
    @Published var showFat = true
    @Published var showWater = true
    @Published var water: Double = 0
    @Published var totalMacros: MacronutrientInfo = MacronutrientInfo(calories: 0, protein: 0, carbs: 0, fat: 0)
    @Published var userMeals: [UserMeal] = []
    @Published var dailyGoals: [String: Int] = [
        "calories": 2000,
        "protein": 150,
        "carbs": 250,
        "fat": 70,
        "water": 128,
    ]
    
    var selectedMeal: Meal = .breakfast
    var foodHelper = FoodHelper()
    var fetchUserDataHelper = FetchUserDataHelper()
    var totalMacroHelper = TotalMacroHelper()
    
    func saveDailyGoals(newGoals: [String: Int]) {
        dailyGoals = newGoals
        FirebaseService.shared.updateDailyGoals(dailyGoals: newGoals)
    }
    
    func saveProgressBarData() {
        let progressBarData: [String: Bool] = [
            "showCalories": showCalories,
            "showProtein": showProtein,
            "showCarbs": showCarbs,
            "showFat": showFat,
            "showWater": showWater,
        ]
        FirebaseService.shared.saveProgressBarData(progressBarData: progressBarData) { success, error in
            if let error = error {
                print("Error saving daily goals: \(error.localizedDescription)")
            } else {
                print("Daily goals saved successfully.")
            }
        }
    }
    
    func fetchProgressBarData() {
        isLoading = true
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            self.isLoading = false
            return
        }
        FirebaseService.shared.fetchProgressBarData() { data, error  in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.showCalories = data?["showCalories"] ?? true
                self.showProtein = data?["showProtein"] ?? true
                self.showCarbs = data?["showCarbs"] ?? true
                self.showFat = data?["showFat"] ?? true
                self.showWater = data?["showWater"] ?? true
            }
            self.isLoading = false
        }
    }
    
    func fetchMacroGoals() {
        isLoading = true
        fetchUserDataHelper.fetchMacroGoals { goals in
            self.dailyGoals = goals
            self.isLoading = false
        }
    }

    func getTotalMacrosForAllMeals() {
        var totalCalories: Double = 0
        var totalProtein: Double = 0
        var totalCarbs: Double = 0
        var totalFat: Double = 0
        
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
        
        self.totalMacros = MacronutrientInfo(
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
    
    func saveFood(meal: Meal, food: MacroFood) {
        addFoodToMeal(meal: selectedMeal, food: food)
        saveFoodToFirebase(meal: meal, food: food)
    }

    func addFoodToMeal(meal: Meal, food: MacroFood) {
        _ = getTotalMacrosForAllMeals()
        DispatchQueue.main.async {
            self.mealLogs[meal]?.append(food)
        }
    }
    
    func deleteFoodFromMeal(meal: Meal, food: MacroFood) {
        DispatchQueue.main.async {
            self.mealLogs[meal]?.removeAll { $0.id == food.id }
            if meal == .water {
                self.water = 0
            }
        }
        deleteFoodFromFirebase(meal: meal, food: food)
    }
    
    func goToToday() {
        water = 0
        DispatchQueue.main.async {
            self.currentDate = Date()
            self.fetchFoodLog()
        }
    }
    
    func goToPreviousDay() {
        water = 0
        DispatchQueue.main.async {
            self.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDate) ?? Date()
            self.fetchFoodLog()
        }
    }
    
    func goToNextDay() {
        water = 0
        DispatchQueue.main.async {
            self.currentDate = Calendar.current.date(byAdding: .day, value: 1, to: self.currentDate) ?? Date()
            self.fetchFoodLog()
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    func convertSearchFoodToMacroFood(searchedFood: SearchedFood, completion: @escaping (MacroFood) -> Void) {
        foodHelper.convertSearchFoodToMacroFood(searchedFood: searchedFood) { macroFood in
            DispatchQueue.main.async {
                completion(macroFood)
            }
        }
    }
    
    func updateFoodMacrosForServings(meal: Meal, food: MacroFood, servings: Double) {
        let originalMacros = food.originalMacros
        
        if servings == 1 {
            let updatedFood = MacroFood(id: food.id, name: food.name, macronutrients: originalMacros, originalMacros: originalMacros, servingDescription: food.servingDescription, servings: 1, addDate: food.addDate)
            saveFoodToFirebase(meal: meal, food: updatedFood)
            getTotalMacrosForAllMeals()
        }

        var updatedFood = food
        
        updatedFood.servings = servings
        if meal == .water {
            water = servings
        }

        updatedFood.macronutrients.calories = originalMacros.calories * servings
        updatedFood.macronutrients.protein = originalMacros.protein * servings
        updatedFood.macronutrients.carbs = originalMacros.carbs * servings
        updatedFood.macronutrients.fat = originalMacros.fat * servings
        
        updatedFood.macronutrients.protein = updatedFood.macronutrients.protein.rounded(toPlaces: 2)
        updatedFood.macronutrients.carbs = updatedFood.macronutrients.carbs.rounded(toPlaces: 2)
        updatedFood.macronutrients.fat = updatedFood.macronutrients.fat.rounded(toPlaces: 2)
        updatedFood.macronutrients.calories = updatedFood.macronutrients.calories.rounded(toPlaces: 2)
        
        saveFoodToFirebase(meal: meal, food: updatedFood)
        
        getTotalMacrosForAllMeals()
    }

    func updateMealLogWithUpdatedFood(updatedFood: MacroFood, meal: Meal) {
        DispatchQueue.main.async {
            if let index = self.mealLogs[meal]?.firstIndex(where: { $0.id == updatedFood.id }) {
                self.mealLogs[meal]?[index] = updatedFood
            }
        }
    }

    func getTotalMacronutrients(for meal: Meal) -> MacronutrientInfo {
        return totalMacroHelper.getTotalMacronutrients(for: meal, mealLogs: mealLogs)
    }
    
    func fetchFoodLog() {
        isLoading = true
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            print("No user is logged in")
            self.isLoading = false
            return
        }
        
        self.mealLogs = MealLogs()
        
        let date = formatDate(currentDate)
        print("Fetching food log for date: \(date)")

        FirebaseService.shared.getFoodLog(date: date) { [weak self] foodLogData, error in
            if let error = error {
                print("Error fetching food log: \(error.localizedDescription)")
            } else if let foodLogData = foodLogData {
                DispatchQueue.main.async { [self] in
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
                            self?.mealLogs[meal] = foods.sorted(by: {$0.addDate < $1.addDate})
                            self?.water = (self?.mealLogs[.water]?.first?.servings ?? 0)
                        }
                    }
                }
            }
            self?.isLoading = false
        }
    }
    
    func fetchUserMeals() {
        self.isLoading = true
        FirebaseService.shared.fetchSavedMealsFromFirebase { meals in
            self.userMeals = meals
            self.isLoading = false
        }
    }
    
    func saveMealToFirebase(mealName: String, meal: Meal) {
        let foodsList = mealLogs[meal]?.map { food in
            return [
                "id":food.id,
                "name": food.name,
                "servingDescription": food.servingDescription,
                "macronutrients": [
                    "calories": food.macronutrients.calories,
                    "protein": food.macronutrients.protein,
                    "carbs": food.macronutrients.carbs,
                    "fat": food.macronutrients.fat
                ],
                "originalMacros": [
                    "calories": food.originalMacros.calories,
                    "protein": food.originalMacros.protein,
                    "carbs": food.originalMacros.carbs,
                    "fat": food.originalMacros.fat
                ],
                "servings": food.servings,
                "addDate": "\(food.addDate)"
                
            ]
        } ?? []
        FirebaseService.shared.saveUserMeal(mealName: mealName, meal: meal, foodsList: foodsList)
    }

    func saveFoodToFirebase(meal: Meal, food: MacroFood) {
        let date = formatDate(currentDate)
        FirebaseService.shared.saveFoodToMeal(date: date, meal: meal.rawValue, food: food) { success, error in
            if let error = error {
                print("Error saving food to Firebase: \(error.localizedDescription)")
            } else if success {
                print("Food saved to Firebase successfully")
            }
        }
    }
    
    func deleteFoodFromFirebase(meal: Meal, food: MacroFood) {
        let date = formatDate(currentDate)
        FirebaseService.shared.deleteFoodFromFirebase(date: date, meal: meal.rawValue, food: food) { success, error in
            if let error = error {
                print("Error deleting food from Firebase: \(error.localizedDescription)")
            } else if success {
                print("Food deleted from Firebase successfully")
            }
        }
    }

    func populateFoodsFromMeal(meal: Meal, userMeal: UserMeal) {
        for food in userMeal.foods {
            saveFood(meal: meal, food: food)
        }
    }
}
