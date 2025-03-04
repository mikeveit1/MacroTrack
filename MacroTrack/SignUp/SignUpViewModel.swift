//
//  SignUpViewModel.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false // Persist login state
    
    // Sign-up function with a completion handler
    func signUp(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Check if passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            isLoading = false
            completion(false)
            return
        }
        
        // Create a new user with Firebase
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false) // Sign-up failed
            } else {
                self.isLoggedIn = true // Persist the login state
                completion(true) // Sign-up successful
            }
        }
    }
}
