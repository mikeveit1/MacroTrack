import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // First Card: Daily Goals
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
                
                // Third Card: Logging Streak
                VStack(spacing: 4) {  // Reduced spacing between cards
                    HStack {
                        Spacer()
                        Text("You Logging Streak")
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
                
                Spacer()
            }
            .padding()
        }
        .background(Colors.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.fetchMacroGoals()
            viewModel.calculateAverageMacros()
            viewModel.calculateConsecutiveDaysLogged()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
