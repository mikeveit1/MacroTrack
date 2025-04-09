//
//  ReauthenticationSheet.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/6/25.
//

import Foundation
import SwiftUI

struct ReauthenticationSheet: View {
    @Binding var email: String
    @Binding var password: String
    var onDelete: () -> Void
    var onCancel: () -> Void
    @State private var isPasswordHidden: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Reauthenticate to delete account:")
                .font(.headline)
                .padding()
                .foregroundColor(Colors.primary)
            TextField("", text: $email, prompt: Text("Email").foregroundColor(Colors.primary.opacity(0.5)))
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
                    SecureField("Password", text: $password, prompt: Text("Password").foregroundColor(Colors.primary.opacity(0.5)))
                        .padding()
                        .background(Colors.secondary)
                        .cornerRadius(8)
                        .foregroundColor(Colors.primary)
                        .textFieldStyle(PlainTextFieldStyle())
                } else {
                    TextField("Password", text: $password, prompt: Text("Password").foregroundColor(Colors.primary.opacity(0.5)))
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
            VStack {
                Button("Cancel") {
                    onCancel()
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Colors.primary)
                .foregroundColor(Colors.secondary)
                .cornerRadius(8)

                Button("Delete") {
                    onDelete()
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(Colors.secondary)
                .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxWidth: 350)
    }
}



struct ReauthenticationSheet_Previews: PreviewProvider {
    static var previews: some View {
        ReauthenticationSheet(
            email: .constant("email"),
            password: .constant("pass"),
            onDelete: {
                print("delete")
            },
            onCancel: {
                print("cancel")
            }
        )
    }
}
