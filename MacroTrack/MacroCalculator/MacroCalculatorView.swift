import SwiftUI

struct MacroCalculatorView: View {
    @ObservedObject var viewModel = MacroCalculatorViewModel()
    
    var body: some View {
        VStack {
            Text("Macro Calculator")
                .font(.system(size: 22))
                .bold()
                .foregroundColor(Colors.primary)
                .padding(.top)
            
            VStack(spacing: 20) {
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
                }
                
                // Activity level picker
                VStack {
                    Text("Activity Level")
                        .foregroundColor(Colors.primary) // Change this to your desired color
                        .font(.system(size: 19))
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
                
                
                // Fitness goal picker
                VStack {
                    Text("Fitness Goal")
                        .foregroundColor(Colors.primary) // Change this to your desired color
                        .font(.system(size: 19))
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
                
                // Calculate Button
                Button(action: {
                    viewModel.calculateMacronutrients()
                }) {
                    Text("Calculate")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Colors.primary)
                        .cornerRadius(8)
                }
                
                // Display results if calculations are done
                if viewModel.totalCalories > 0 {
                    VStack(spacing: 10) {
                        Text("Your Daily Macro Goals:")
                            .font(.system(size: 19))
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
            }
            .padding()
        }
        .background(Colors.secondary)
        .cornerRadius(10)
        .frame(maxHeight: .infinity)
        .shadow(radius: 5)
        .padding()
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
