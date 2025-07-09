//
//  ProfileView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import SwiftUI
import StoreKit

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
                        Text("\(viewModel.dailyGoals["water"] ?? 0) oz")
                            .bold()
                            .foregroundColor(Colors.primary)
                    }
                }
                .padding()
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 350)
                
                HStack {
                    Spacer()
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
                            Text("\(String(format: "%.2f", viewModel.averageProtein)) g")
                                .bold()
                                .foregroundColor(Colors.primary)
                        }
                        HStack {
                            Text("Carbs:")
                                .foregroundColor(Colors.primary)
                            Text("\(String(format: "%.2f", viewModel.averageCarbs)) g")
                                .bold()
                                .foregroundColor(Colors.primary)
                        }
                        HStack {
                            Text("Fat:")
                                .foregroundColor(Colors.primary)
                            Text("\(String(format: "%.2f", viewModel.averageFat)) g")
                                .bold()
                                .foregroundColor(Colors.primary)
                        }
                        HStack {
                            Text("Water:")
                                .foregroundColor(Colors.primary)
                            Text("\(String(format: "%.2f", viewModel.averageWater)) oz")
                                .bold()
                                .foregroundColor(Colors.primary)
                        }
                    }
                    .padding()
                    .background(Colors.secondary)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .frame(width: 350)
                    Spacer()
                }
                
                VStack(spacing: 4) {
                    Text("Your Fitness Goal")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Colors.primary)
                    HStack {
                        Spacer()
                            .foregroundColor(Colors.primary)
                        Text(viewModel.fitnessGoal)
                            .bold()
                            .foregroundColor(Colors.primary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                .padding()
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 350)
              
                VStack(spacing: 4) {
                    HStack {
                        Spacer()
                        Text("Your Logging Streak")
                            .foregroundColor(Colors.primary)
                            .bold()
                            .font(.title3)
                        Spacer()
                    }
                    Text("\(viewModel.consecutiveDaysLogged) \(viewModel.consecutiveDaysLogged == 1 ? "day" : "days")")
                        .bold()
                        .foregroundColor(Colors.primary)
                }
                .padding()
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 350)
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        Text("Manage Your Account")
                            .foregroundColor(Colors.primary)
                            .bold()
                            .font(.title3)
                        Spacer()
                    }
                    
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
                }
                .padding()
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 350)
                VStack {
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .fontWeight(.bold)
                            .frame(maxWidth: 200)
                            .padding()
                            .background(Colors.primary)
                            .foregroundColor(Colors.secondary)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text("Delete Account")
                            .fontWeight(.bold)
                            .frame(maxWidth: 200)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(Colors.secondary)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $viewModel.error) {
                        Alert(
                            title: Text("Error"),
                            message: Text(viewModel.errorMessage),
                            dismissButton: .default(Text("Dismiss")) {
                                viewModel.resetError()
                            }
                        )
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Are you sure?"),
                            message: Text("This action cannot be undone. Do you want to delete your account?"),
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
