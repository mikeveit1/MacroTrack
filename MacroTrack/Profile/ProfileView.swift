//
//  ProfileView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showDeleteAlert = false
    @State private var showReauthDialog = false
    @State private var email: String = ""
    @State private var password: String = ""
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                LogoGreen
                    .padding(.bottom, 8)
                VStack(spacing: 4) {
                    Text("Your Daily Goals")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Colors.primary)
                    HStack {
                        Spacer()
                        Text("Calories:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.dailyGoals["calories"] ?? 0) kcal")
                            .bold()
                            .foregroundColor(Colors.primary)
                        Spacer()
                    }
                    HStack {
                        Text("Protein:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.dailyGoals["protein"] ?? 0) g")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                    HStack {
                        Text("Carbs:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.dailyGoals["carbs"] ?? 0) g")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                    HStack {
                        Text("Fat:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.dailyGoals["fat"] ?? 0) g")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                    HStack {
                        Text("Water:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.dailyGoals["water"] ?? 0) fl oz")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.secondary)
                        .stroke(Colors.primary, lineWidth: 2)
                )
                
                VStack(spacing: 4) {
                    Text("Your Daily Averages")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Colors.primary)
                    HStack {
                        Spacer()
                        Text("Calories:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.averageCalories) kcal")
                            .bold()
                            .foregroundColor(Colors.primary)
                        Spacer()
                    }
                    HStack {
                        Text("Protein:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.averageProtein, specifier: "%.1f") g")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                    HStack {
                        Text("Carbs:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.averageCarbs, specifier: "%.1f") g")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                    HStack {
                        Text("Fat:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.averageFat, specifier: "%.1f") g")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                    HStack {
                        Text("Water:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.averageWater, specifier: "%.1f") fl oz")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.secondary)
                        .stroke(Colors.primary, lineWidth: 2)
                )
                
                VStack(spacing: 4) {
                    Text("Consecutive Days Logged")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Colors.primary)
                    HStack {
                        Spacer()
                        Text("Days:")
                            .foregroundColor(Colors.primary)
                        Text("\(viewModel.consecutiveDaysLogged)")
                            .bold()
                            .foregroundColor(Colors.primary)
                        Spacer()
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.secondary)
                        .stroke(Colors.primary, lineWidth: 2)
                )
                
                VStack(spacing: 4) {
                    Text("Fitness Goal")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Colors.primary)
                    Text(viewModel.fitnessGoal)
                        .font(.body)
                        .foregroundColor(Colors.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.secondary)
                        .stroke(Colors.primary, lineWidth: 2)
                )
                VStack(spacing: 4) {
                    Text("Info")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Colors.primary)
                    
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                            .font(.headline)
                        if let url = URL(string: viewModel.termsLink), UIApplication.shared.canOpenURL(url) {
                            Link("Terms and Conditions", destination: url)
                                .font(.headline)
                                .foregroundColor(.blue)
                        } else {
                            Text("Terms and Conditions")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                            .font(.headline)
                        if let url = URL(string: viewModel.privacyLink), UIApplication.shared.canOpenURL(url) {
                            Link("Privacy Policy", destination: url)
                                .font(.headline)
                                .foregroundColor(.blue)
                        } else {
                            Text("Privacy Policy")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                            .font(.headline)
                        if let url = URL(string: viewModel.contactUsLink), UIApplication.shared.canOpenURL(url) {
                            Link("Contact Us", destination: url)
                                .font(.headline)
                                .foregroundColor(.blue)
                        } else {
                            Text("Contact Us")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Colors.primary)
                            .foregroundColor(Colors.secondary)
                            .cornerRadius(10)
                    }
                    .padding(.top, 8)
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text("Delete Account")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(Colors.secondary)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Are you sure you want to delete your account?"),
                            message: Text("This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                showReauthDialog = true
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    .sheet(isPresented: $showReauthDialog) {
                        ReauthenticationSheet(
                            email: $email,
                            password: $password,
                            onDelete: {
                                viewModel.deleteAccount(email: email, password: password)
                                showReauthDialog = false
                            },
                            onCancel: {
                                showReauthDialog = false
                            }
                        )
                    }
                    Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                        .foregroundColor(Colors.primary)
                        .padding(8)
                    
                }
                .padding(.bottom)
            }
        }
        .background(Colors.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.fetchMacroGoals()
            viewModel.fetchFitnessGoal()
            viewModel.calculateAverageMacros()
            viewModel.calculateConsecutiveDaysLogged()
            viewModel.getTermsLink()
            viewModel.getPrivacyPolicyLink()
            viewModel.getContactUsLink()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
