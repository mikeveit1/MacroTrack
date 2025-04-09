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
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Published var termsLink: String = ""
    private var linkHelper = LinkHelper()
    
    func signUp() {
        isLoading = true
        errorMessage = nil

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            isLoading = false
            return
        }
        
        FirebaseService.shared.signUp(email: email, password: password) { success, error in
            self.isLoading = false
            if success {
                self.isLoggedIn = true
            } else {
                self.errorMessage = error
                self.isLoggedIn = false
            }
        }
    }

    func getTermsLink() {
        linkHelper.getTermsLink { link in
            self.termsLink = link
        }
    }
}
