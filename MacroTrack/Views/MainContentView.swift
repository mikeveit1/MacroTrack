//
//  MainContentView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

struct MainContentView: View {
    var body: some View {
        TabView {
            // Food Log Tab
            FoodLogView()
                .tabItem {
                    Image(systemName: "list.dash") // Icon for Food Log
                    Text("Food Log")               // Label for Food Log
                }
            
            // Macro Calculator Tab
            MacroCalculatorView()
                .tabItem {
                    Image(systemName: "calculator") // Icon for Macro Calculator
                    Text("Macro Calculator")      // Label for Macro Calculator
                }
        }
        .accentColor(.blue) // Customize the tab bar accent color (optional)
    }
}
