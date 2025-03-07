import SwiftUI

struct MacroCalculatorView: View {
    @ObservedObject var viewModel = MacroCalculatorViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                LogoGreen
                    .padding(.bottom, 8)
                VStack(spacing: 4) {
                    Text("Macronutrient Calculator")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Colors.primary)
                        .padding()
                    // Weight input
                    ZStack(alignment: .leading) {
                        if viewModel.weight.isEmpty {
                            Text("Enter Weight (lbs)")
                                .foregroundColor(Colors.primaryLight)
                                .padding(.leading, 10)
                        }
                        TextField("", text: $viewModel.weight)
                            .keyboardType(.decimalPad)
                            .padding(.vertical)
                            .padding(.leading, 10)
                            .foregroundColor(Colors.primary)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .accentColor(Colors.primary)
                    }
                    
                    
                    // Height input
                    ZStack(alignment: .leading) {
                        if viewModel.height.isEmpty {
                            Text("Enter Height (inches)")
                                .foregroundColor(Colors.primaryLight)
                                .padding(.leading, 10)
                        }
                        TextField("", text: $viewModel.height)
                            .keyboardType(.decimalPad)
                            .padding(.vertical)
                            .padding(.leading, 10)
                            .foregroundColor(Colors.primary)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .accentColor(Colors.primary)
                    }
                    
                    // Age input
                    ZStack(alignment: .leading) {
                        if viewModel.age.isEmpty {
                            Text("Enter Age")
                                .padding(.leading, 10)
                                .foregroundColor(Colors.primaryLight)
                        }
                        TextField("", text: $viewModel.age)
                            .keyboardType(.decimalPad)
                            .padding(.vertical)
                            .padding(.leading, 10)
                            .foregroundColor(Colors.primary)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .accentColor(Colors.primary)
                    }
                
                    HStack {
                        Spacer()
                        VStack {
                            Text("Activity Level")
                                .foregroundColor(Colors.primary) // Change this to your desired color
                                .font(.title3)
                                .bold()
                            Picker("", selection: $viewModel.activityLevel) {
                                ForEach(viewModel.activityLevels, id: \.self) { level in
                                    Text(level)
                                }
                            }
                            .foregroundColor(Colors.primary)
                            .pickerStyle(MenuPickerStyle())
                            .tint(Colors.primary)
                            .padding(8)
                            .frame(maxWidth: 200)
                            .background(Colors.gray)
                            .cornerRadius(10)
                        }
                        .padding(8)
                        Spacer()
                    }
                    
                    VStack {
                        Text("Fitness Goal")
                            .foregroundColor(Colors.primary) // Change this to your desired color
                            .font(.title3)
                            .bold()
                        Picker("", selection: $viewModel.fitnessGoal) {
                            ForEach(viewModel.fitnessGoals, id: \.self) { goal in
                                Text(goal)
                            }
                        }
                        .foregroundColor(Colors.primary)
                        .pickerStyle(MenuPickerStyle())
                        .tint(Colors.primary)
                        .padding(8)
                        .frame(maxWidth: 200)
                        .background(Colors.gray)
                        .cornerRadius(10)
                    }
                    .padding(8)
                    
                    Button(action: {
                        viewModel.calculateMacronutrients()
                    }) {
                        Text("Calculate")
                            .fontWeight(.bold)
                            .frame(maxWidth: 200)
                            .padding()
                            .background(Colors.primary)
                            .foregroundColor(Colors.secondary)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()  // Proper padding around the entire progress chart
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: .infinity) // Fixed
                // Display results if calculations are done
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        Text("Your Daily Macronutrient Goals:")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Colors.primary)
                            //.padding(.horizontal)
                        Spacer()
                    }
                    Text("Calories: \(Int(viewModel.totalCalories)) kcal")
                        .bold()
                        .foregroundColor(Colors.primary)
                    Text("Protein: \(Int(viewModel.protein)) grams")
                        .bold()
                        .foregroundColor(Colors.primary)
                    Text("Carbs: \(Int(viewModel.carbs)) grams")
                        .bold()
                        .foregroundColor(Colors.primary)
                    Text("Fat: \(Int(viewModel.fat)) grams")
                        .bold()
                        .foregroundColor(Colors.primary)
                }
                .padding()  // Proper padding around the entire progress chart
                .background(Colors.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: .infinity) // Fixed
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Colors.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            UIApplication.shared.endEditing() // This will dismiss the keyboard
        }
    }
}
    
    struct MacroCalculatorView_Previews: PreviewProvider {
        static var previews: some View {
            MacroCalculatorView()
        }
    }
