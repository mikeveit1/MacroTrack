//
//  ScreenshotDailyGoalsView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

struct ScreenshotDailyGoalsView: View {
    var date: String
    var showCalories: Bool
    var showProtein: Bool
    var showCarbs: Bool
    var showFat: Bool
    var showWater: Bool
    var totalCalories: Double?
    var calorieGoal: Int?
    var totalProtein: Double?
    var proteinGoal: Int?
    var totalCarbs: Double?
    var carbGoal: Int?
    var totalFat: Double?
    var fatGoal: Int?
    var totalWater: Double?
    var waterGoal: Int?
    var maxWidth: CGFloat

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(date)
                .font(.title3)
                .bold()
                .foregroundColor(Colors.primary)
            DailyGoalsView(date: date, showCalories: showCalories, showProtein: showProtein, showCarbs: showCarbs, showFat: showFat, showWater: showWater, totalCalories: totalCalories ?? 0, calorieGoal: calorieGoal ?? 0, totalProtein: totalProtein ?? 0, proteinGoal: proteinGoal ?? 0, totalCarbs: totalCarbs ?? 0, carbGoal: carbGoal ?? 0, totalFat: totalFat ?? 0, fatGoal: fatGoal ?? 0, totalWater: totalWater ?? 0 , waterGoal: waterGoal ?? 0, maxWidth: maxWidth)
            Image("FullLogoGreen")
                .resizable()
                .frame(width: 100, height: 10)
                .padding(.top, 6)
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
    }
}
