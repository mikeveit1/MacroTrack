//
//  SignInView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//


import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var isPasswordHidden: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                LogoGreen
                Text("Sign In")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                    .padding(8)
                TextField("", text: $viewModel.email, prompt: Text("Email").foregroundColor(Colors.primary.opacity(0.5)))
                    .padding()
                    .background(Colors.secondary)
                    .cornerRadius(8)
                    .foregroundColor(Colors.primary)
                    .textFieldStyle(PlainTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Colors.primary, lineWidth: 1)
                    )
                
                HStack {
                    if isPasswordHidden {
                        SecureField("Password", text: $viewModel.password, prompt: Text("Password").foregroundColor(Colors.primary.opacity(0.5)))
                            .padding()
                            .background(Colors.secondary)
                            .cornerRadius(8)
                            .foregroundColor(Colors.primary)
                            .textFieldStyle(PlainTextFieldStyle())
                    } else {
                        TextField("Password", text: $viewModel.password, prompt: Text("Password").foregroundColor(Colors.primary.opacity(0.5)))
                            .padding()
                            .background(Colors.secondary)
                            .cornerRadius(8)
                            .foregroundColor(Colors.primary)
                            .textFieldStyle(PlainTextFieldStyle())
                           
                    }
                    Button(action: {
                        isPasswordHidden.toggle()
                    }) {
                        Image(systemName: isPasswordHidden ? "eye.slash" : "eye")
                            .foregroundColor(Colors.primary)
                            .padding(.trailing, 8)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Colors.primary, lineWidth: 1)
                )
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            
                Button(action: {
                    viewModel.signIn()
                }) {
                    Text("Sign In")
                        .fontWeight(.bold)
                        .frame(maxWidth: 200)
                        .padding()
                        .background(Colors.primary)
                        .foregroundColor(Colors.secondary)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(Colors.primaryLight)
                        .bold()
                        .font(.caption)
                }
                Spacer()
                fatSecretBadge
            }
            .padding(.horizontal)
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
