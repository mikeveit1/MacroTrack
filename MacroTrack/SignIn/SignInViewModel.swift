import SwiftUI

class SignInViewModel: ObservableObject {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false // Persist login state

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    func signIn(completion: @escaping (Bool) -> Void) {
        isLoading = true
        FirebaseService.shared.signIn(email: email, password: password) { success, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error
                completion(false)
                return
            }
            if success {
                self.isLoggedIn = true // Persist the login state
                completion(true)
            } else {
                self.errorMessage = error
                completion(false)
            }
        }
    }
}
