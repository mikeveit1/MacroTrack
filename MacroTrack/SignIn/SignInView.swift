import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var isPasswordHidden: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                Spacer()
                Text("Sign In")
                    .font(.system(size: 22))
                    .bold()
                    .foregroundColor(Colors.primary)
                    .padding()
                TextField("", text: $viewModel.email, prompt: Text("Email").foregroundColor(Colors.primary.opacity(0.5)))
                    .padding()
                    .background(Colors.secondary)  // Set background of the entire TextField to white
                    .cornerRadius(8)          // Optional: round the corners for a nicer appearance
                    .foregroundColor(Colors.primary)  // Text color
                    .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle to remove default styling
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Colors.primary, lineWidth: 1) // Optional: add a border to the TextField
                    )
                
                HStack {
                    if isPasswordHidden {
                        SecureField("Password", text: $viewModel.password, prompt: Text("Password").foregroundColor(Colors.primary.opacity(0.5)))
                            .padding()
                            .background(Colors.secondary)  // Set background of the entire TextField to white
                            .cornerRadius(8)          // Optional: round the corners for a nicer appearance
                            .foregroundColor(Colors.primary)  // Text color
                            .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle to remove default styling
                    } else {
                        TextField("Password", text: $viewModel.password, prompt: Text("Password").foregroundColor(Colors.primary.opacity(0.5)))
                            .padding()
                            .background(Colors.secondary)  // Set background of the entire TextField to white
                            .cornerRadius(8)          // Optional: round the corners for a nicer appearance
                            .foregroundColor(Colors.primary)  // Text color
                            .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle to remove default styling
                           
                    }
                    Button(action: {
                        isPasswordHidden.toggle() // Toggle password visibility
                    }) {
                        Image(systemName: isPasswordHidden ? "eye.slash" : "eye") // Eye icon for show/hide
                            .foregroundColor(Colors.primary)
                            .padding(.trailing, 8)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Colors.primary, lineWidth: 1) // Optional: add a border to the TextField
                )
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                
                Button(action: {
                    viewModel.signIn { success in
                        if success {
                            // After successful sign-in, the view model handles login status
                        }
                    }
                }) {
                    Text("Sign In")
                        .foregroundColor(Colors.secondary)
                        .padding()
                        .bold()
                        .background(Colors.primary)
                        .cornerRadius(10)
                }
                .padding()
                
                // Navigation to Sign Up View
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(Colors.primaryLight)
                        .padding()
                        .bold()
                }
                Spacer()
            }
            .padding()
            .background(Colors.secondary)
        }
        .accentColor(Colors.primary)
        .background(Colors.secondary)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
