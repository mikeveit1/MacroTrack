//
//  ScreenshotIndividualMealView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

struct ScreenshotIndividualMealView: View {
    var totalMacronutrients: MacronutrientInfo
    var selectedMeal: Meal
    var dateString: String
    var water: Double?
    var mealLogs: MealLogs
    
    var sortedMealLogs: [MacroFood] {
        return mealLogs[selectedMeal]?.sorted { $0.addDate < $1.addDate } ?? []
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(systemName: selectedMeal.iconName)
                    .foregroundColor(Colors.primary)
                Text(selectedMeal.rawValue.capitalized)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                Spacer()
                Text(dateString)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading) {
                Text("Total")
                    .foregroundColor(Colors.primary)
                    .bold()
                
                if selectedMeal != .water {
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
                        Text(String(format: "%.2f", water ?? 0) + " oz")
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
            
            ForEach(sortedMealLogs, id: \.id) { food in
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(food.name) (serving size: \(food.servingDescription))")
                                .foregroundColor(Colors.secondary)
                                .bold()
                        }
                        VStack(alignment: .leading) {
                            if selectedMeal != .water {
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
            Image("FullLogoGreen")
                .resizable()
                .frame(width: 100, height: 10)
                .padding(.top, 6)
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
    }
}
