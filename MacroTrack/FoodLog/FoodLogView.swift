import SwiftUI
import FatSecretSwift

struct FoodLogView: View {
    @State private var modalVisible = false
    @State private var showDatePicker = false
    @StateObject private var viewModel = FoodLogViewModel()
    @State private var searchQuery = ""
    @State private var isLoading = false
    @State private var localServingsString: String = "1.0"
    
    func selectMeal(meal: Meal) {
        viewModel.selectedMeal = meal
        modalVisible = true
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Header View (Date Navigation)
                headerView
                
                // Progress Bars for Daily Goals
                progressChart
                
                // Meal Sections
                ForEach(Meal.allCases, id: \.self) { meal in
                    mealSection(meal)
                }
            }
            .padding()
            .background(Color(.white))
            .sheet(isPresented: $modalVisible) {
                foodModalView
            }
            .background(Color(.white))
        }
        .background(Color(.white))
        .onTapGesture {
            UIApplication.shared.endEditing() // This will dismiss the keyboard
        }
        .onChange(of: viewModel.mealLogs) { _ in
            // Recalculate macros whenever mealLogs changes
            _ = viewModel.getTotalMacros()
        }
    }
    
    // Progress Bars for Daily Goals
    var progressChart: some View {
        let totalMacros = viewModel.getTotalMacros()
        
        let maxWidth: CGFloat = 80 // Maximum width for progress bars

        return VStack(alignment: .leading, spacing: 20) {
            // Calories Progress
            Text("Daily Total")
                .font(.system(size: 22))
                .bold()
                .foregroundColor(Colors.primary)
            HStack {
                Text("Calories")
                    .frame(width: 80, alignment: .leading)
                    .foregroundColor(Colors.primary)
                    .bold()
                ZStack(alignment: .leading) {
                    (Color(UIColor(white: 0.9, alpha: 1.0)))  // Background color (empty space)
                        .frame(height: 30)
                    Colors.primaryLight
                        .opacity(0.2)
                        .frame(width: min(CGFloat(totalMacros.calories / (viewModel.dailyGoals["calories"] ?? 0) * 100), maxWidth), height: 30)
                    Text("\(Int(totalMacros.calories)) / \(Int(viewModel.dailyGoals["calories"] ?? 0)) kcal")
                        .foregroundColor(Colors.primary)
                        .padding(.leading, 10)
                        .bold()
                        .lineLimit(1)
                }
                .cornerRadius(8)
            }

            // Protein Progress
            HStack {
                Text("Protein")
                    .frame(width: 80, alignment: .leading)
                    .foregroundColor(Colors.primary)
                    .bold()
                ZStack(alignment: .leading) {
                    (Color(UIColor(white: 0.9, alpha: 1.0)))  // Background color (empty space)
                        .frame(height: 30)
                    Colors.primaryLight
                        .opacity(0.2)
                        .frame(width: min(CGFloat(totalMacros.calories / (viewModel.dailyGoals["protein"] ?? 0) * 100), maxWidth), height: 30)
                    Text("\(String(format: "%.2f", totalMacros.protein)) / \(Int(viewModel.dailyGoals["protein"] ?? 0)) g")
                        .foregroundColor(Colors.primary)
                        .padding(.leading, 10)
                        .bold()
                        .lineLimit(1)
                }
                .cornerRadius(8)
            }
            // Carbs Progress
            HStack {
                Text("Carbs")
                    .frame(width: 80, alignment: .leading)
                    .foregroundColor(Colors.primary)
                    .bold()
                ZStack(alignment: .leading) {
                    (Color(UIColor(white: 0.9, alpha: 1.0)))  // Background color (empty space)
                        .frame(height: 30)
                    Colors.primaryLight
                        .opacity(0.2)
                        .frame(width: min(CGFloat(totalMacros.calories / (viewModel.dailyGoals["carbs"] ?? 0) * 100), maxWidth), height: 30)
                    Text("\(String(format: "%.2f", totalMacros.carbs)) / \(Int(viewModel.dailyGoals["carbs"] ?? 0)) g")
                        .foregroundColor(Colors.primary)
                        .padding(.leading, 10)
                        .bold()
                        .lineLimit(1)
                }
                .cornerRadius(8)
            }

            // Fat Progress
            HStack {
                Text("Fat")
                    .frame(width: 80, alignment: .leading)
                    .foregroundColor(Colors.primary)
                    .bold()
                ZStack(alignment: .leading) {
                    (Color(UIColor(white: 0.9, alpha: 1.0)))  // Background color (empty space)
                        .frame(height: 30)
                    Colors.primaryLight
                        .opacity(0.2)
                        .frame(width: min(CGFloat(totalMacros.calories / (viewModel.dailyGoals["fat"] ?? 0) * 100), maxWidth), height: 30)
                    Text("\(String(format: "%.2f", totalMacros.fat)) / \(Int(viewModel.dailyGoals["fat"] ?? 0)) g")
                        .foregroundColor(Colors.primary)
                        .padding(.leading, 10)
                        .bold()
                        .lineLimit(1)
                }
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    
    var headerView: some View {
        VStack {
            HStack {
                Button(action: viewModel.goToToday) {
                    Text("Today")
                        .fontWeight(.bold)
                        .foregroundColor(Colors.secondary)
                        .font(.system(size: 17))
                        .padding(8)
                        .background(Colors.primary, in: RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
                Button(action: viewModel.goToPreviousDay) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(Colors.secondary)
                }
                Text(viewModel.formatDate(viewModel.currentDate))
                    .font(.system(size: 22))
                    .lineLimit(2)
                    .fontWeight(.bold)
                    .foregroundColor(Colors.secondary)
                Button(action: viewModel.goToNextDay) {
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .foregroundColor(Colors.secondary)
                }
                Spacer()
                Button(action: { showDatePicker.toggle() }) {
                    Image(systemName: "calendar")
                        .font(.title)
                        .foregroundColor(Colors.secondary)
                }
            }
            //.padding()
            .frame(maxWidth: .infinity)
            .background(Colors.primaryLight, in: RoundedRectangle(cornerRadius: 10))
            
            // Show DatePicker when showDatePicker is true
            if showDatePicker {
                DatePicker(
                    "Select Date",
                    selection: $viewModel.currentDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .tint(Colors.secondary)
                .padding()
                .onTapGesture(count: 99, perform: {
                })
                .onChange(of: viewModel.currentDate) { newDate in
                    // Log the selected date and close the date picker
                    print("New selected date: \(newDate)")
                    
                }
            }
        }
        
        .padding()
        .frame(maxWidth: .infinity)
        .background(Colors.primaryLight, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // Meal Section (for breakfast, lunch, dinner, snacks)
    func mealSection(_ meal: Meal) -> some View {
        VStack(alignment: .leading) {
            let totalMacronutrients = viewModel.getTotalMacronutrients(for: meal)
            HStack {
                Image(systemName: meal.iconName)
                    .foregroundColor(Colors.primary)
                Text(meal.rawValue.capitalized)
                    .font(.system(size: 22))
                    .bold()
                    .foregroundColor(Colors.primary)
                Spacer()
                Button(action: { selectMeal(meal: meal )}) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Colors.primary)
                }
                .padding()
                .tint(Colors.primary)
                .font(.system(size: 19))
            }
            .frame(maxWidth: .infinity)  // Ensures the button takes up the full width
            VStack(alignment: .leading) {
                Text("Meal Total")
                    .font(.system(size: 19))
                    .foregroundColor(Colors.primary)
                    .bold()
                Text("\(Int(totalMacronutrients.calories)) kcal")
                    .foregroundColor(Colors.primary)
                    .bold()
                    .lineLimit(1)
                HStack {
                    HStack {
                        Text("P:")
                            .foregroundColor(Colors.primary)
                        Text(String(format: "%.2f", totalMacronutrients.protein) + " g")
                            .foregroundColor(Colors.primary)
                            .bold()
                            .lineLimit(1)
                    }
                    HStack {
                        Text("C:")
                            .foregroundColor(Colors.primary)
                        Text(String(format: "%.2f", totalMacronutrients.carbs) + " g")
                            .foregroundColor(Colors.primary)
                            .bold()
                            .lineLimit(1)
                    }
                    HStack {
                        Text("F:")
                            .foregroundColor(Colors.primary)
                        Text(String(format: "%.2f", totalMacronutrients.fat) + " g")
                            .foregroundColor(Colors.primary)
                            .bold()
                            .lineLimit(1)
                        
                    }
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)  // Ensures the food item takes up the full width
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor(white: 0.9, alpha: 1.0))))
            ForEach(viewModel.mealLogs[meal] ?? [], id: \.self) { food in
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(food.name) (serving size: \(food.servingDescription))")
                                .foregroundColor(Colors.secondary)
                                .bold()
                                .font(.system(size: 19))
                        }
                        VStack(alignment: .leading) {
                            Text("\(Int(food.macronutrients.calories)) kcal")
                                .lineLimit(1)
                                .bold()
                                .foregroundColor(Colors.secondary)
                            HStack {
                                HStack {
                                    Text("P:")
                                        .foregroundColor(Colors.secondary)
                                    Text(String(format: "%.2f", food.macronutrients.protein) + " g")
                                        .foregroundColor(Colors.secondary)
                                        .bold()
                                        .lineLimit(1)
                                }
                                HStack {
                                    Text("C:")
                                        .foregroundColor(Colors.secondary)
                                    Text(String(format: "%.2f", food.macronutrients.carbs) + " g")
                                        .foregroundColor(Colors.secondary)
                                        .bold()
                                        .lineLimit(1)
                                }
                                HStack {
                                    Text("F:")
                                        .foregroundColor(Colors.secondary)
                                    Text(String(format: "%.2f", food.macronutrients.fat) + " g")
                                        .foregroundColor(Colors.secondary)
                                        .bold()
                                        .lineLimit(1)
                                }
                            }
                        }
                        HStack {
                            Text("Servings:")
                            TextField("", text: Binding(
                                get: {
                                    // Return the current servings value for this food, or default to "1.0" if not found
                                    String(viewModel.servings[food.id] ?? 1.0)
                                },
                                set: { newValue in
                                    // Handle the text input and update the servings value for this food
                                    var servingsToUpdate: Double = 1.0
                                    
                                    if let newDoubleValue = Double(newValue), newDoubleValue > 0 {
                                        servingsToUpdate = newDoubleValue
                                    } else if newValue.isEmpty {
                                        // Handle empty string (backspace)
                                        servingsToUpdate = 1.0
                                    }
                                    
                                    // Update the servings dictionary for this specific food
                                    viewModel.servings[food.id] = servingsToUpdate
                                    
                                    // Update the food's macronutrients based on the new servings
                                    let updatedFood = viewModel.updateFoodMacrosForServings(food: food, servings: servingsToUpdate)
                                    
                                    // Update the meal log with the updated food
                                    viewModel.updateMealLogWithUpdatedFood(updatedFood: updatedFood, meal: viewModel.selectedMeal)
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .padding()
                            .frame(width: 60, height: 40)
                            .background(Color.white)
                            .cornerRadius(8)
                            .foregroundColor(Colors.primary)
                            .textFieldStyle(PlainTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .onChange(of: localServingsString) { newValue in
                                // Handle backspace (empty string case) and conversion to Double
                                var servingsToUpdate: Double = 1.0  // Default value
                                
                                if let newDoubleValue = Double(newValue), newDoubleValue > 0 {
                                    servingsToUpdate = newDoubleValue
                                } else if newValue.isEmpty {
                                    // Handle empty case (backspace scenario)
                                    servingsToUpdate = 1.0
                                }
                                
                                // Debugging logs
                                print("New Value: \(newValue)")
                                print("Servings to update: \(servingsToUpdate)")
                                
                                // Update the servings dictionary in the view model
                                viewModel.servings[food.id] = servingsToUpdate
                                
                                // Get the updated food with scaled macros
                                let updatedFood = viewModel.updateFoodMacrosForServings(food: food, servings: servingsToUpdate)
                                
                                // Update the meal log with the updated food
                                viewModel.updateMealLogWithUpdatedFood(updatedFood: updatedFood, meal: viewModel.selectedMeal)
                            }
                        }
                        
                    }
                    Spacer()
                    Button(action: { viewModel.deleteFoodFromMeal(meal: meal, food: food) }) {
                        Image(systemName: "trash")
                            .foregroundColor(Colors.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)  // Ensures the food item takes up the full width
                .background(RoundedRectangle(cornerRadius: 8).fill(Colors.primaryLight))
            }
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    // Modal for Food Details Entry with search
    var foodModalView: some View {
        VStack {
            Text("Search for Food")
                .font(.headline)
                .foregroundColor(Colors.primary)
                .bold()
            
            // Search bar
            TextField("Search for food", text: $searchQuery)
                .padding()
                .background(Color.white)  // Set background of the entire TextField to white
                .cornerRadius(8)          // Optional: round the corners for a nicer appearance
                .foregroundColor(Colors.primary)  // Text color
                .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle to remove default styling
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1) // Optional: add a border to the TextField
                )
                .onChange(of: searchQuery) { newValue in
                    viewModel.searchFoods(query: newValue)
                }
            
            if isLoading {
                ProgressView("Searching...")
                    .padding()
            }
            
            // List of food items
            List(viewModel.searchResults, id: \.id) { food in
                Section {
                    Button(action: {
                        // Prompt user for servings after selecting a food
                        viewModel.convertSearchFoodToMacroFood(searchedFood: food) { macroFood in
                            viewModel.saveFood(food: macroFood)
                            modalVisible = false
                        }
                    }) {
                        VStack(alignment: .leading) {
                            Text(food.name)
                                .foregroundColor(Colors.primary)
                                .bold()
                                .lineLimit(2)
                            (food.brand != nil) ? Text(food.brand ?? "")
                                .foregroundColor(Colors.primaryLight)
                            : nil
                        }
                    }
                }
                .listRowBackground(Colors.secondary)
            }
            //.padding(.vertical)
            .listStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1) // Optional: add a border to the TextField
            )
            // Buttons for canceling and saving
            HStack {
                Button("Cancel") {
                    modalVisible = false
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.red))
                .foregroundColor(.white)
                .bold()
            }
            .padding(.top)
        }
        .padding()
        .cornerRadius(10)
        .shadow(radius: 10)
        .background(Colors.secondary)
    }
}

struct FoodLogScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoodLogView()
    }
}
