//
//  SignUpView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var isPasswordHidden: Bool = true
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Text("Sign Up")
                    .font(.system(size: 22))
                    .bold()
                    .foregroundColor(Colors.primary)
                    .padding()
                
                TextField("Email", text: $viewModel.email, prompt: Text("Email").foregroundColor(Colors.primary.opacity(0.5)))
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
                 // Add some padding for spacing between fields
                
                // Confirm Password SecureField with Show/Hide functionality
                HStack {
                    if isPasswordHidden {
                        SecureField("Confirm Password", text: $viewModel.confirmPassword, prompt: Text("Confirm Password").foregroundColor(Colors.primary.opacity(0.5)))
                            .padding()
                            .background(Colors.secondary)  // Set background of the entire TextField to white
                            .cornerRadius(8)          // Optional: round the corners for a nicer appearance
                            .foregroundColor(Colors.primary)  // Text color
                            .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle to remove default styling
                    } else {
                        TextField("Confirm Password", text: $viewModel.confirmPassword, prompt: Text("Confirm Password").foregroundColor(Colors.primary.opacity(0.5)))
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
                        .foregroundColor(Colors.primary)
                }
                
                Button(action: {
                    viewModel.signUp { user in
                        print(user)
                    }
                }) {
                    Text("Sign Up")
                        .foregroundColor(Colors.secondary)
                        .padding()
                        .bold()
                        .background(Colors.primary)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            Spacer()
        }
        .background(Colors.secondary)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
