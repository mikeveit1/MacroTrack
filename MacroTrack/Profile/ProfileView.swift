import SwiftUI
import StoreKit

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showDeleteAlert = false
    @State private var showReauthDialog = false
    @State private var email: String = ""  // Ensure this is initialized
    @State private var password: String = ""  // Ensure this is initialized
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // First Card: Daily Goals
                LogoGreen
                    .padding(.bottom, 8)
                VStack(spacing: 4) {  // Reduced spacing between cards
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
                }
                .padding()  // Proper padding around the entire progress chart
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 350) // Fixed width for consistency across all cards
                
                // Second Card: Stats (per day)
                HStack {
                    Spacer()
                    VStack(spacing: 4) {  // Reduced spacing between cards
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
                    }
                    .padding()  // Proper padding around the entire progress chart
                    .background(Colors.secondary)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .frame(width: 350) // Fixed width for consistency across all cards Ensures the card has the same width
                    Spacer()
                }
                
                VStack(spacing: 4) {  // Reduced spacing between cards
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
                .padding()  // Proper padding around the entire progress chart
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 350) // Fixed width for consistency across all cards Ensures the card has the same width
                
                // Third Card: Logging Streak
                VStack(spacing: 4) {  // Reduced spacing between cards
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
                .padding()  // Proper padding around the entire progress chart
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 350) // Fixed
                //.frame(maxWidth: .infinity) // Fixed width for consistency across all cards
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        Text("Manage Your Account")
                            .foregroundColor(Colors.primary)
                            .bold()
                            .font(.title3)
                        Spacer()
                    }
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        HStack {
                            Image(systemName: "link") // Eye icon for show/hide
                                .foregroundColor(.blue)
                                .font(.headline)
                            Link("Manage Subscription", destination: url)
                            //  .padding()
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    } else {
                        HStack {
                            Image(systemName: "link") // Eye icon for show/hide
                                .foregroundColor(.blue)
                                .font(.headline)
                            Link("Manage Subscription", destination: URL(string: "https://google.com")!)
                            //  .padding()
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    // Terms and Conditions
                    HStack {
                        Image(systemName: "link") // Eye icon for show/hide
                            .foregroundColor(.blue)
                            .font(.headline)
                        if let url = URL(string: viewModel.termsLink), UIApplication.shared.canOpenURL(url) {
                            // Safely unwrap the URL
                            Link("Terms and Conditions", destination: url)
                                .font(.headline)
                                .foregroundColor(.blue)
                        } else {
                            Text("Terms and Conditions")
                                .font(.headline)
                                .foregroundColor(.gray) // Show a fallback text if the URL is invalid
                        }
                    }
                    
                    // Privacy Policy
                    HStack {
                        Image(systemName: "link") // Eye icon for show/hide
                            .foregroundColor(.blue)
                            .font(.headline)
                        if let url = URL(string: viewModel.privacyLink), UIApplication.shared.canOpenURL(url) {
                            // Safely unwrap the URL
                            Link("Privacy Policy", destination: url)
                                .font(.headline)
                                .foregroundColor(.blue)
                        } else {
                            Text("Privacy Policy")
                                .font(.headline)
                                .foregroundColor(.gray) // Show a fallback text if the URL is invalid
                        }
                    }
                    
                    // Submit Inquiry (mailto)
                    HStack {
                        Image(systemName: "link") // Eye icon for show/hide
                            .foregroundColor(.blue)
                            .font(.headline)
                        if let url = URL(string: viewModel.contactUsLink), UIApplication.shared.canOpenURL(url) {
                            // Safely unwrap the URL
                            Link("Contact Us", destination: url)
                                .font(.headline)
                                .foregroundColor(.blue)
                        } else {
                            Text("Contact Us")
                                .font(.headline)
                                .foregroundColor(.gray) // Show a fallback text if the URL is invalid
                        }
                    }
                }
                .padding()  // Proper padding around the entire progress chart
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 350) // Fixed
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
                                // Show re-authentication dialog when trying to delete the account
                                showReauthDialog = true
                            },
                            secondaryButton: .cancel() // User taps "Cancel"
                        )
                    }
                    .sheet(isPresented: $showReauthDialog) {
                        // Presenting the re-authentication sheet
                        ReauthenticationSheet(
                            email: $email,
                            password: $password,
                            onDelete: {
                                // Call the delete function with re-authentication
                                viewModel.deleteAccount(email: email, password: password)
                                showReauthDialog = false // Dismiss the sheet after deletion
                            },
                            onCancel: {
                                // Dismiss the sheet without action
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
