import SwiftUI

struct MacroCalculatorView: View {
    @ObservedObject var viewModel = MacroCalculatorViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Macronutrient Calculator")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                    .padding(.top)
                // Weight input
                VStack(spacing: 8) {
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
                }
                .padding()
                
                // Activity level picker
                VStack(spacing: 16) {
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
                        .padding(8)
                        .foregroundColor(Colors.primary)
                        .pickerStyle(MenuPickerStyle())
                        .tint(Colors.primary)
                        .background(Colors.gray)
                        .cornerRadius(10)
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
                        .background(Colors.gray)
                        .cornerRadius(10)
                    }
                }
             //   .padding()
                
                VStack(spacing: 8) {
                    // Calculate Button
                    Button(action: {
                        viewModel.calculateMacronutrients()
                    }) {
                        Text("Calculate")
                            .foregroundColor(.white)
                            .padding()
                            .background(Colors.primary)
                            .cornerRadius(8)
                    }
                }
                .padding(.top)
                
                // Display results if calculations are done
                VStack(spacing: 8) {
                    Text("Your Daily Macronutrient Goals:")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Colors.primary)
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
                .padding()
            }
            .background(Colors.secondary)
            .ignoresSafeArea(.all)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
            .onTapGesture {
                UIApplication.shared.endEditing() // This will dismiss the keyboard
            }
            .cornerRadius(10)
            .background(Colors.secondary)
        }
        .background(Colors.secondary)
    }
}

struct MacroCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        MacroCalculatorView()
    }
}
