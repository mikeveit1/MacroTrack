//
//  MacroTrackApp.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MacroTrackApp: App {
    // Initialize the AppViewModel to manage global login state
    @StateObject private var appViewModel = AppViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        // Add a delay to simulate the splash screen duration
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 2 seconds delay
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                // Check the global login state from AppViewModel
                if appViewModel.isLoggedIn {
                    // If the user is logged in, show the main content
                    MainContentView()
                        .environmentObject(appViewModel)  // Pass the global state to content view
                } else {
                    // If the user is not logged in, show the Sign-In screen
                    SignInView()
                        .environmentObject(appViewModel)  // Pass the global state to SignInView
                        .onTapGesture {
                            UIApplication.shared.endEditing() // This will dismiss the keyboard
                        }
                }
            }
        }
    }
}
