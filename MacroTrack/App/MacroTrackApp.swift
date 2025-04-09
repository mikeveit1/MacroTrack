//
//  MacroTrackApp.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import SwiftUI
import FirebaseCore
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        FirebaseService.shared.getRevenueCatKey { key in
            Purchases.configure(withAPIKey: key)
        }
        return true
    }
}

@main
struct MacroTrackApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                if appViewModel.isLoggedIn {

                    MainContentView()
                        .environmentObject(appViewModel)
                } else {
                    SignInView()
                        .environmentObject(appViewModel)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                        }
                }
            }
        }
    }
}
