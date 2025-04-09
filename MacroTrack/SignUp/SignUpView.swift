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
            VStack(spacing: 8) {
                LogoGreen
                Text("Sign Up")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                    .padding(8)
                
                TextField("Email", text: $viewModel.email, prompt: Text("Email").foregroundColor(Colors.primary.opacity(0.5)))
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
                HStack {
                    if isPasswordHidden {
                        SecureField("Confirm Password", text: $viewModel.confirmPassword, prompt: Text("Confirm Password").foregroundColor(Colors.primary.opacity(0.5)))
                            .padding()
                            .background(Colors.secondary)
                            .cornerRadius(8)
                            .foregroundColor(Colors.primary)
                            .textFieldStyle(PlainTextFieldStyle())
                    } else {
                        TextField("Confirm Password", text: $viewModel.confirmPassword, prompt: Text("Confirm Password").foregroundColor(Colors.primary.opacity(0.5)))
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
                
                VStack {
                    Button(action: {
                        viewModel.signUp()
                    }) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .frame(maxWidth: 200)
                            .padding()
                            .background(Colors.primary)
                            .foregroundColor(Colors.secondary)
                            .cornerRadius(10)
                    }
                    HStack {
                        if let url = URL(string: viewModel.termsLink), UIApplication.shared.canOpenURL(url) {
                            let termsText = "By creating an account, you are agreeing to our [terms and conditions](\(url))."
                            Text(.init(termsText))
                                .foregroundColor(Colors.primary)
                                .font(.caption)
                                .bold()
                                .multilineTextAlignment(.center)
                        } else {
                            let termsText = "By creating an account, you are agreeing to our [terms and conditions]()."
                            Text(.init(termsText))
                                .foregroundColor(Colors.primary)
                                .font(.caption)
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .padding(.horizontal)
            Spacer()
        }
        .background(Colors.secondary)
        .onAppear {
            viewModel.getTermsLink()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
