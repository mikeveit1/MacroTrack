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
    var onDelete: () -> Void // Action to perform when the user confirms deletion
    var onCancel: () -> Void // Action to perform when the user cancels
    @State private var isPasswordHidden: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Reauthenticate to delete account:")
                .font(.headline)
                .padding()
                .foregroundColor(Colors.primary)
            TextField("", text: $email, prompt: Text("Email").foregroundColor(Colors.primary.opacity(0.5)))
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
                    SecureField("Password", text: $password, prompt: Text("Password").foregroundColor(Colors.primary.opacity(0.5)))
                        .padding()
                        .background(Colors.secondary)  // Set background of the entire TextField to white
                        .cornerRadius(8)          // Optional: round the corners for a nicer appearance
                        .foregroundColor(Colors.primary)  // Text color
                        .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle to remove default styling
                } else {
                    TextField("Password", text: $password, prompt: Text("Password").foregroundColor(Colors.primary.opacity(0.5)))
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
            VStack {
                Button("Cancel") {
                    onCancel() // Dismiss the sheet
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Colors.primary)
                .foregroundColor(Colors.secondary)
                .cornerRadius(8)

                Button("Confirm") {
                    onDelete() // Call the delete action
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
            email: .constant("email"), // Binding for email
            password: .constant("pass"), // Binding for password
            onDelete: {
                print("delete")
            },
            onCancel: {
                print("cancel")
            }
        )
    }
}
