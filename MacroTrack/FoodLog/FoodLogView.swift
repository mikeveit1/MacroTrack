import SwiftUI
import FatSecretSwift

struct FoodLogView: View {
    @State private var modalVisible = false
    @State private var showDatePicker = false
    @StateObject private var viewModel = FoodLogViewModel()
    @State private var searchQuery = ""
    @State private var isLoading = false
    @State private var localServingsString: String = "1.0"
    @State private var showCalories = true
    @State private var showProtein = true
    @State private var showCarbs = true
    @State private var showFat = true
    @State private var showFilterModal = false
    @State private var editedGoals: [String: Double] = [:]
    @State private var isSettingsPresented = false
    
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
            .sheet(isPresented: $isSettingsPresented) {
                VStack {
                    Text("Edit Your Daily Goals")
                        .font(.system(size: 22))
                        .foregroundColor(Colors.secondary)
                        .bold()
                        .padding()
                    
                    VStack(spacing: 8) { // Increased spacing for better separation between sections
                        // Editable fields for each goal
                        GoalEditorField(goalType: "Calories", value: $editedGoals["calories"])
                        Text("You can calculate your macro goals based on your body weight.")
                            .font(.caption)
                            .foregroundColor(Colors.primary)
                        
                        GoalEditorField(goalType: "Protein", value: $editedGoals["protein"])
                        Text("You can calculate your macro goals based on your body weight.")
                            .font(.caption)
                            .foregroundColor(Colors.primary)
                        
                        GoalEditorField(goalType: "Carbs", value: $editedGoals["carbs"])
                        Text("You can calculate your macro goals based on your body weight.")
                            .font(.caption)
                            .foregroundColor(Colors.primary)
                        
                        GoalEditorField(goalType: "Fat", value: $editedGoals["fat"])
                        Text("You can calculate your macro goals based on your body weight.")
                            .font(.caption)
                            .foregroundColor(Colors.primary)
                        
                        // Save Button
                        Button(action: {
                            viewModel.saveDailyGoals(newGoals: editedGoals)
                            isSettingsPresented = false // Close the modal
                        }) {
                            Text("Save")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 16) // Padding for spacing between the fields and the button
                        
                        // Cancel Button
                        Button(action: {
                            isSettingsPresented = false // Close the modal without saving
                        }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12) // Rounded corners for the modal
                    .shadow(radius: 10) // Shadow for the modal
                }
                .padding()
                .frame(maxHeight: .infinity) // Make the VStack take up the full height
                .background(Colors.primary.edgesIgnoringSafeArea(.all)) // Semi-transparent background behind the modal
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
            // Header with "Daily Total" and Filter Button
            HStack {
                Text("Daily Total")
                    .font(.system(size: 22))
                    .bold()
                    .foregroundColor(Colors.primary)
                
                Spacer()
                
                // Filter Button
                Button(action: {
                    showFilterModal.toggle()
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Colors.primary)
                }
                Button(action: {
                    editedGoals = viewModel.dailyGoals // Set current values in the edited state
                    isSettingsPresented.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Colors.primary)
                }
            }
            
            
            // Calories Progress
            if showCalories {
                HStack {
                    Text("Calories")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(Colors.primary)
                        .bold()
                    ZStack(alignment: .leading) {
                        Colors.gray  // Background color (empty space)
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
            }
            
            // Protein Progress
            if showProtein {
                HStack {
                    Text("Protein")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(Colors.primary)
                        .bold()
                    ZStack(alignment: .leading) {
                        Colors.gray  // Background color (empty space)
                            .frame(height: 30)
                        Colors.primaryLight
                            .opacity(0.2)
                            .frame(width: min(CGFloat(totalMacros.protein / (viewModel.dailyGoals["protein"] ?? 0) * 100), maxWidth), height: 30)
                        Text("\(String(format: "%.2f", totalMacros.protein)) / \(Int(viewModel.dailyGoals["protein"] ?? 0)) g")
                            .foregroundColor(Colors.primary)
                            .padding(.leading, 10)
                            .bold()
                            .lineLimit(1)
                    }
                    .cornerRadius(8)
                }
            }
            
            // Carbs Progress
            if showCarbs {
                HStack {
                    Text("Carbs")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(Colors.primary)
                        .bold()
                    ZStack(alignment: .leading) {
                        Colors.gray  // Background color (empty space)
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
            }
            
            // Fat Progress
            if showFat {
                HStack {
                    Text("Fat")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(Colors.primary)
                        .bold()
                    ZStack(alignment: .leading) {
                        Colors.gray    // Background color (empty space)
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
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 5)
        .sheet(isPresented: $showFilterModal) {
            filterModal
        }
    }
    
    var filterModal: some View {
        VStack {
            Text("Select Progress Bars")
                .font(.system(size: 22))
                .bold()
                .padding()
                .foregroundColor(Colors.secondary)
            VStack {
                // Checkbox-like UI
                Toggle(isOn: $showCalories) {
                    Text("Calories")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
                Toggle(isOn: $showProtein) {
                    Text("Protein")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
                Toggle(isOn: $showCarbs) {
                    Text("Carbs")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
                Toggle(isOn: $showFat) {
                    Text("Fat")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
                // Dismiss Button
                Button(action: {
                    showFilterModal.toggle()
                }) {
                    Text("Done")
                        .foregroundColor(Colors.primary)
                        .fontWeight(.bold)
                }
                .padding()
            }
            .background(Colors.secondary) // Gray background for the whole sheet
            .cornerRadius(10) // Optional: Corner radius if you want rounded corners
            .shadow(radius: 8) // Optional: Shadow for the modal itself
            Spacer()
        }
        .padding() // Padding around the content
        .frame(maxHeight: .infinity) // Make the VStack take up the full height
        .background(Colors.primary) // Gray background for the whole sheet
        .cornerRadius(10) // Optional: Corner radius if you want rounded corners
        .shadow(radius: 8) // Optional: Shadow for the modal itself
        .edgesIgnoringSafeArea(.all) // Ensures the gray background covers the entire screen
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
                        .background(Colors.primaryLight, in: RoundedRectangle(cornerRadius: 10))
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
        .background(Colors.primary, in: RoundedRectangle(cornerRadius: 10))
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
                .tint(Colors.primary)
                .font(.system(size: 22))
            }
            .frame(maxWidth: .infinity)  // Ensures the button takes up the full width
            VStack(alignment: .leading) {
                Text("\(meal.rawValue.capitalized) Total")
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
            .background(RoundedRectangle(cornerRadius: 8).fill(Colors.gray))
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
