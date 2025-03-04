//
//  GoalEditorField.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/3/25.
//

import Foundation
import SwiftUI


struct GoalEditorField: View {
    var goalType: String
    @Binding var value: Double?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(goalType)
                .bold()
                .foregroundColor(Colors.primary)
            TextField("\(goalType)", value: $value, format: .number)
                .padding()
                .background(Colors.gray)
                .foregroundColor(Colors.primary)
                .cornerRadius(8)
                .keyboardType(.decimalPad)
        }
    }
}
