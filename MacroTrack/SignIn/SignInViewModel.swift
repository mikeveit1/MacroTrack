//
//  SignInViewModel.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import SwiftUI

class SignInViewModel: ObservableObject {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    func signIn() {
        isLoading = true
        FirebaseService.shared.signIn(email: email, password: password) { success, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error
                self.isLoggedIn = false
                return
            }
            if success {
                self.isLoggedIn = true
            } else {
                self.errorMessage = error
                self.isLoggedIn = false
            }
        }
    }
}
