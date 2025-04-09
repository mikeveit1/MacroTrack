//
//  ProgressView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI


struct ProgressView: View {
    var title: String
    var actualValue: Double
    var dailyGoal: Int
    var unit: String
    var maxWidth: CGFloat
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 80, alignment: .leading)
                .foregroundColor(Colors.primary)
                .bold()
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Colors.gray
                        .frame(height: 30)
                    Colors.primaryLight
                        .opacity(0.2)
                        .frame(width: min(CGFloat(actualValue / Double((dailyGoal))) * geometry.size.width, geometry.size.width), height: 30)
                    Text(title == "Calories"
                         ? "\(Int(actualValue).formatted(.number.grouping(.automatic))) / \(dailyGoal) \(unit)"
                         : "\(String(format: "%.2f", actualValue)) / \(dailyGoal) \(unit)")
                    .foregroundColor(Colors.primary)
                    .padding(.leading, 10)
                    .bold()
                    .lineLimit(1)
                }
                .cornerRadius(8)
            }
            .frame(height: 30)
            .frame(maxWidth: maxWidth)
        }
    }
}
