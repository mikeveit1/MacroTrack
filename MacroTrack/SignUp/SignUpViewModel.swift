//
//  SignUpViewModel.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

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
        
        FirebaseService.shared.signUp(email: email, password: password) { success, error in
            if success {
                self.isLoggedIn = true
                self.isLoading = false
                completion(true)
            } else {
                self.errorMessage = error
                self.isLoading = false
                completion(false)
            }
        }
    }
}
