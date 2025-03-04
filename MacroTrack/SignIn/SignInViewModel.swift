import FirebaseAuth
import SwiftUI

class SignInViewModel: ObservableObject {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false // Persist login state

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    func signIn(completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            // On successful sign-in
            if result != nil {
                self.isLoggedIn = true // Persist the login state
                completion(true)
            } else {
                self.errorMessage = "Unexpected error occurred."
                completion(false)
            }
        }
    }

    func checkLoginStatus() -> Bool {
        return isLoggedIn
    }
}
