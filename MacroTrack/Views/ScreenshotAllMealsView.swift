//
//  ScreenshotAllMealsView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI


struct ScreenshotAllMealsView: View {
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
    var mealLogs: MealLogs
    
    var body: some View {
        VStack(alignment: .center) {
            Text(date)
                .font(.title3)
                .bold()
                .foregroundColor(Colors.primary)
                .padding(.horizontal, 8)
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    DailyGoalsView(date: date, showCalories: showCalories, showProtein: showProtein, showCarbs: showCarbs, showFat: showFat, showWater: showWater, totalCalories: totalCalories ?? 0, calorieGoal: calorieGoal ?? 0, totalProtein: totalProtein ?? 0, proteinGoal: proteinGoal ?? 0, totalCarbs: totalCarbs ?? 0, carbGoal: carbGoal ?? 0, totalFat: totalFat ?? 0, fatGoal: fatGoal ?? 0, totalWater: totalWater ?? 0 , waterGoal: waterGoal ?? 0, maxWidth: maxWidth)
                }
                Spacer()
            }
            .padding()
            .background(Colors.secondary)
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: .infinity)
            ForEach(Meal.allCases, id: \.self) { meal in
                let totalMacroHeper = TotalMacroHelper()
                let totalMacronutrients = totalMacroHeper.getTotalMacronutrients(for: meal, mealLogs: mealLogs)
                VStack (alignment: .leading) {
                    HStack {
                        Image(systemName: meal.iconName)
                            .foregroundColor(Colors.primary)
                        Text(meal.rawValue.capitalized)
                            .font(.title3)
                            .bold()
                            .foregroundColor(Colors.primary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    VStack(alignment: .leading) {
                        Text("Total")
                            .foregroundColor(Colors.primary)
                            .bold()
                        if meal != .water {
                            Text("\(Int(totalMacronutrients.calories)) kcal")
                                .foregroundColor(Colors.primary)
                                .bold()
                                .lineLimit(1)
                            HStack {
                                HStack {
                                    Text("P:")
                                        .foregroundColor(Colors.primary)
                                    Text(String(format: "%.2f", totalMacronutrients.protein) + " g")
                                        .foregroundColor(Colors.primary)
                                        .bold()
                                        .lineLimit(1)
                                }
                                HStack {
                                    Text("C:")
                                        .foregroundColor(Colors.primary)
                                    Text(String(format: "%.2f", totalMacronutrients.carbs) + " g")
                                        .foregroundColor(Colors.primary)
                                        .bold()
                                        .lineLimit(1)
                                }
                                HStack {
                                    Text("F:")
                                        .foregroundColor(Colors.primary)
                                    Text(String(format: "%.2f", totalMacronutrients.fat) + " g")
                                        .foregroundColor(Colors.primary)
                                        .bold()
                                        .lineLimit(1)
                                    
                                }
                                Spacer()
                            }
                        } else {
                            HStack {
                                Text(String(format: "%.2f", totalWater ?? 0) + " oz")
                                    .foregroundColor(Colors.primary)
                                    .bold()
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Colors.gray))
                    ForEach(mealLogs[meal]?.sorted(by: {$0.addDate < $1.addDate}) ?? [], id: \.id) { food in
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(food.name) (serving size: \(food.servingDescription))")
                                        .foregroundColor(Colors.secondary)
                                        .bold()
                                }
                                if meal != .water {
                                    VStack(alignment: .leading) {
                                        Text("\(Int(food.macronutrients.calories)) kcal")
                                            .lineLimit(1)
                                            .bold()
                                            .foregroundColor(Colors.secondary)
                                        HStack {
                                            HStack {
                                                Text("P:")
                                                    .foregroundColor(Colors.secondary)
                                                Text(String(format: "%.2f", food.macronutrients.protein) + " g")
                                                    .foregroundColor(Colors.secondary)
                                                    .bold()
                                                    .lineLimit(1)
                                            }
                                            HStack {
                                                Text("C:")
                                                    .foregroundColor(Colors.secondary)
                                                Text(String(format: "%.2f", food.macronutrients.carbs) + " g")
                                                    .foregroundColor(Colors.secondary)
                                                    .bold()
                                                    .lineLimit(1)
                                            }
                                            HStack {
                                                Text("F:")
                                                    .foregroundColor(Colors.secondary)
                                                Text(String(format: "%.2f", food.macronutrients.fat) + " g")
                                                    .foregroundColor(Colors.secondary)
                                                    .bold()
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                                HStack {
                                    Text("Servings: " + String(format: "%.1f", food.servings))
                                        .foregroundColor(Colors.secondary)
                                    Spacer()
                                }
                                
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Colors.primary))
                    }
                }
                .padding()
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            Image("FullLogoGreen")
                .resizable()
                .frame(width: 100, height: 10)
                .padding(.top, 6)
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
    }
}
