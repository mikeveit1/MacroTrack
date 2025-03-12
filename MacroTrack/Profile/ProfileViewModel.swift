//
//  SignUpViewModel.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var averageCalories: Int = 0
    @Published var averageProtein: Double = 0
    @Published var averageCarbs: Double = 0
    @Published var averageFat: Double = 0
    @Published var averageWater: Double = 0
    @Published var consecutiveDaysLogged: Int = 0
    @Published var dailyGoals: [String: Int] = [
        "calories": 2000,  // Example: 2000 calories
        "protein": 150,    // Example: 150g protein
        "carbs": 250,      // Example: 250g carbs
        "fat": 70,          // Example: 70g fat
        "water": 128,
    ]
    @Published var fitnessGoal: String = "Use the macro calculator to set your fitness goal!"
    @Published var termsLink: String = ""
    @Published var privacyLink: String = ""
    @Published var contactUsLink: String = ""
    @Published var errorMessage: String = ""
    @Published var error: Bool = false
    var fetchUserDataHelper = FetchUserDataHelper()
    private var linkHelper = LinkHelper()
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false // Persist login state
    
    func fetchMacroGoals() {
        isLoading = true
        fetchUserDataHelper.fetchMacroGoals { goals in
            self.dailyGoals = goals
            self.isLoading = false
        }
    }
    
    func fetchFitnessGoal() {
        isLoading = true
        fetchUserDataHelper.fetchFitnessGoal { goal in
            if goal != "" {
                self.fitnessGoal = goal
            }
            self.isLoading = false
        }
    }
    
    func resetError() {
        error = false
        errorMessage = ""
    }
    
    func calculateAverageMacros() {
        FirebaseService.shared.getAllFoodLogs() { foodLogs, error in
            if let foodLogs = foodLogs {
                var totalCalories: Int = 0
                var totalProtein: Double = 0
                var totalCarbs: Double = 0
                var totalFat: Double = 0
                var totalWater: Double = 0
                var totalDays: Int = 0
                
                // Iterate over each date in the foodLogs dictionary
                for (_, dailyLog) in foodLogs {
                    
                    // Check that dailyLog is a dictionary and cast it as a [String: Any]
                    if let dailyLog = dailyLog as? [String: Any] {
                        var dailyCalories: Int = 0
                        var dailyProtein: Double = 0
                        var dailyCarbs: Double = 0
                        var dailyFat: Double = 0
                        var dailyWater: Double = 0
                        
                        // Iterate over each meal in dailyLog (e.g., breakfast, lunch)
                        for (_, foods) in dailyLog {
                            
                            // Check that 'foods' is a dictionary [String: Any]
                            if let foods = foods as? [String: Any] {
                                
                                // Iterate over each food item in the meal
                                for (_, food) in foods {
                                    
                                    // Ensure 'food' is a dictionary that contains macronutrients
                                    if let food = food as? [String: Any],
                                       let macronutrients = food["macronutrients"] as? [String: Any] {
                                        if food["id"] as? String == "-1" {
                                            if let water = food["servings"] as? Double {
                                                dailyWater += water
                                            }
                                        }
                                        // Safely unwrap calories, protein, carbs, and fat
                                        if let calories = macronutrients["calories"] as? Int {
                                            dailyCalories += calories
                                        }
                                        if let protein = macronutrients["protein"] as? Double {
                                            dailyProtein += protein
                                        }
                                        
                                        // Debugging: Check if the carbs value exists
                                        if let carbs = macronutrients["carbs"] as? Double {
                                            print("Carbs for \(food["name"] ?? "Unnamed food"): \(carbs)")  // Debugging line
                                            dailyCarbs += carbs
                                        } else {
                                            print("No carbs data for \(food["name"] ?? "Unnamed food")")  // Debugging line if carbs is nil
                                        }
                                        
                                        if let fat = macronutrients["fat"] as? Double {
                                            dailyFat += fat
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Add the daily totals to the overall totals
                        totalCalories += dailyCalories
                        totalProtein += dailyProtein
                        totalCarbs += dailyCarbs
                        totalFat += dailyFat
                        totalWater += dailyWater
                        totalDays += 1
                    }
                }
                
                // Calculate averages
                if totalDays > 0 {
                    self.averageCalories = totalCalories / totalDays
                    self.averageProtein = totalProtein / Double(totalDays)
                    self.averageCarbs = totalCarbs / Double(totalDays)
                    self.averageFat = totalFat / Double(totalDays)
                    self.averageWater = totalWater / Double(totalDays)
                } else {
                    print("No data found to calculate averages")
                }
            } else {
                print("Error fetching food logs: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func calculateConsecutiveDaysLogged() {
        // Fetch all food logs asynchronously
        FirebaseService.shared.getAllFoodLogs() { foodLogs, error in
            // Ensure we have food logs
            guard let foodLogs = foodLogs else {
                self.consecutiveDaysLogged = 0  // Return 0 if no food logs are available
                return
            }
            
            // Extract and sort the dates
            let sortedDates = foodLogs.keys.sorted { date1, date2 in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                if let date1 = dateFormatter.date(from: date1),
                   let date2 = dateFormatter.date(from: date2) {
                    return date1 < date2
                }
                return false
            }
            
            // If no dates are found, return 0 (no logged days)
            guard !sortedDates.isEmpty else {
                self.consecutiveDaysLogged = 0
                return
            }
            
            // Initialize variables for tracking consecutive days
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            var previousDate: Date?
            var consecutiveDaysCount = 1  // Start from 1 because we have at least one logged day
            var maxConsecutiveDays = 1
            
            // Iterate over the sorted dates and count consecutive days
            for i in 1..<sortedDates.count {
                if let currentDate = dateFormatter.date(from: sortedDates[i]),
                   let prevDate = previousDate {
                    
                    // Check if the current date is the day after the previous date
                    let calendar = Calendar.current
                    let dayDifference = calendar.dateComponents([.day], from: prevDate, to: currentDate).day ?? 0
                    
                    if dayDifference == 1 {
                        // If the difference is 1, increment consecutive day count
                        consecutiveDaysCount += 1
                    } else if dayDifference > 1 {
                        // If the difference is more than 1 (i.e., user missed a day), reset count to 1
                        consecutiveDaysCount = 1
                    }
                    
                    // Update the max consecutive days
                    maxConsecutiveDays = max(maxConsecutiveDays, consecutiveDaysCount)
                }
                
                // Update the previousDate to the current date
                if let currentDate = dateFormatter.date(from: sortedDates[i]) {
                    previousDate = currentDate
                }
            }
            
            // Set the final consecutive days count
            self.consecutiveDaysLogged = max(maxConsecutiveDays, consecutiveDaysCount)
        }
    }
    
    func signOut() {
        FirebaseService.shared.signOut { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if result {
                self.isLoggedIn = false
            }
        }
    }
    
    func deleteAccount(email: String, password: String) {
        FirebaseService.shared.deleteAccount(email: email, password: password, completion: { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.error = true
            } else if result {
                self.isLoggedIn = false
            }
        })
    }
    
    func getTermsLink() {
        linkHelper.getTermsLink { link in
            self.termsLink = link
        }
    }
    
    func getPrivacyPolicyLink() {
        linkHelper.getPrivacyPolicyLink { link in
            self.privacyLink = link
        }
    }
    
    func getContactUsLink() {
        linkHelper.getContactUsLink { link in
            self.contactUsLink = link
        }
    }
    
}
