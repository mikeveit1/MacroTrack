//
//  DailyGoalsView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

struct DailyGoalsView: View {
    var date: String
    var showCalories: Bool
    var showProtein: Bool
    var showCarbs: Bool
    var showFat: Bool
    var showWater: Bool
    var totalCalories: Double
    var calorieGoal: Int
    var totalProtein: Double
    var proteinGoal: Int
    var totalCarbs: Double
    var carbGoal: Int
    var totalFat: Double
    var fatGoal: Int
    var totalWater: Double
    var waterGoal: Int
    var maxWidth: CGFloat

    var body: some View {
        if showCalories {
            ProgressView(title: "Calories", actualValue: totalCalories, dailyGoal: calorieGoal, unit: "kcal", maxWidth: maxWidth)
        }
        if showProtein {
            ProgressView(title: "Protein", actualValue: totalProtein, dailyGoal: proteinGoal, unit: "g", maxWidth: maxWidth)
        }
        if showCarbs {
            ProgressView(title: "Carbs", actualValue: totalCarbs, dailyGoal: carbGoal, unit: "g", maxWidth: maxWidth)
        }
        if showFat {
            ProgressView(title: "Fat", actualValue: totalFat, dailyGoal: fatGoal, unit: "g", maxWidth: maxWidth)
        }
        if showWater {
            ProgressView(title: "Water", actualValue: totalWater, dailyGoal: waterGoal, unit: "oz", maxWidth: maxWidth)
        }
    }
}
