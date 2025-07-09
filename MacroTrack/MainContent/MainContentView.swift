//
//  MainContentView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

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
            FoodLogView()
                .tabItem {
                    Image(systemName: "pencil.and.list.clipboard")
                    Text("Food Log")
                }
            
            MacroCalculatorView()
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Macro Calculator")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .presentPaywallIfNeeded(
            requiredEntitlementIdentifier: "pro",
            presentationMode: .fullScreen, purchaseCompleted: { customerInfo in
                print("Purchase completed: \(customerInfo.entitlements)")
            },
            restoreCompleted: { customerInfo in
                print("Purchases restored: \(customerInfo.entitlements)")
            }
        )
        .accentColor(Colors.secondary)
        .background(Colors.gray)
    }
}

struct MainContentView_Preview: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
