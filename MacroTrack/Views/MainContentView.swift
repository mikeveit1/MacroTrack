//
//  MainContentView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

struct MainContentView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Colors.primary)
        appearance.selectionIndicatorTintColor =  UIColor(Colors.primary)
        UITabBar.appearance().tintColor = UIColor(Colors.gray)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some View {
        TabView {
            // Food Log Tab
            FoodLogView()
                .tabItem {
                    Image(systemName: "pencil.and.list.clipboard") // Icon for Food Log
                    Text("Food Log")               // Label for Food Log
                }
            
            // Macro Calculator Tab
            MacroCalculatorView()
                .tabItem {
                    Image(systemName: "figure.run") // Icon for Macro Calculator
                    Text("Macro Calculator")      // Label for Macro Calculator
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            
        }
        .accentColor(Colors.secondary) // Customize the tab bar accent color (optional)
        .background(Colors.gray)
      
    }
}

struct MainContentView_Preview: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
