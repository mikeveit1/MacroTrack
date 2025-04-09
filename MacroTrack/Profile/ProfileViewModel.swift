//
//  ProfileViewModel.swift
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
        "calories": 2000,
        "protein": 150,
        "carbs": 250,
        "fat": 70,
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
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
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
                
                for (_, dailyLog) in foodLogs {
                    
                    if let dailyLog = dailyLog as? [String: Any] {
                        var dailyCalories: Int = 0
                        var dailyProtein: Double = 0
                        var dailyCarbs: Double = 0
                        var dailyFat: Double = 0
                        var dailyWater: Double = 0
                        
                        for (_, foods) in dailyLog {
                            if let foods = foods as? [String: Any] {
                                for (_, food) in foods {
                                    
                                    if let food = food as? [String: Any],
                                       let macronutrients = food["macronutrients"] as? [String: Any] {
                                        if food["id"] as? String == "-1" {
                                            if let water = food["servings"] as? Double {
                                                dailyWater += water
                                            }
                                        }
                                        
                                        if let calories = macronutrients["calories"] as? Int {
                                            dailyCalories += calories
                                        }
                                        if let protein = macronutrients["protein"] as? Double {
                                            dailyProtein += protein
                                        }
                                        
                                        if let carbs = macronutrients["carbs"] as? Double {
                                            dailyCarbs += carbs
                                        }
                                        
                                        if let fat = macronutrients["fat"] as? Double {
                                            dailyFat += fat
                                        }
                                    }
                                }
                            }
                        }
                        
                        totalCalories += dailyCalories
                        totalProtein += dailyProtein
                        totalCarbs += dailyCarbs
                        totalFat += dailyFat
                        totalWater += dailyWater
                        totalDays += 1
                    }
                }
                
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
        FirebaseService.shared.getAllFoodLogs() { foodLogs, error in
            guard let foodLogs = foodLogs else {
                self.consecutiveDaysLogged = 0
                return
            }
            
            let sortedDates = foodLogs.keys.sorted { date1, date2 in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                if let date1 = dateFormatter.date(from: date1),
                   let date2 = dateFormatter.date(from: date2) {
                    return date1 < date2
                }
                return false
            }
            
            guard !sortedDates.isEmpty else {
                self.consecutiveDaysLogged = 0
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            var previousDate: Date?
            var consecutiveDaysCount = 1
            var maxConsecutiveDays = 1
            
            for i in 1..<sortedDates.count {
                if let currentDate = dateFormatter.date(from: sortedDates[i]),
                   let prevDate = previousDate {
                    let calendar = Calendar.current
                    let dayDifference = calendar.dateComponents([.day], from: prevDate, to: currentDate).day ?? 0
                    
                    if dayDifference == 1 {
                        consecutiveDaysCount += 1
                    } else if dayDifference > 1 {
                        consecutiveDaysCount = 1
                    }
                    maxConsecutiveDays = max(maxConsecutiveDays, consecutiveDaysCount)
                }
                
                if let currentDate = dateFormatter.date(from: sortedDates[i]) {
                    previousDate = currentDate
                }
            }

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
