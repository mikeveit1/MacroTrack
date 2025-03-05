import SwiftUI
import FatSecretSwift

struct FoodLogView: View {
    @State private var modalVisible = false
    @State private var showDatePicker = false
    @StateObject private var viewModel = FoodLogViewModel()
    @State private var searchQuery = ""
    @State private var showFilterModal = false
    @State private var editedGoals: [String: Int] = [:]
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
            .onChange(of: viewModel.currentDate) { _ in
                // Trigger data fetching when the date changes
                viewModel.fetchFoodLog()
            }
            .padding()
            .background(Color(.white))
            .sheet(isPresented: $modalVisible) {
                foodModalView
            }
            .sheet(isPresented: $isSettingsPresented) {
                VStack {
                    Text("Edit Your Daily Macronutrient Goals")
                        .font(.title3)
                        .foregroundColor(Colors.secondary)
                        .bold()
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 8) { // Increased spacing for better separation between sections
                        // Editable fields for each goal
                        GoalEditorField(goalType: "Calories", value: $editedGoals["calories"])
                        
                        GoalEditorField(goalType: "Protein", value: $editedGoals["protein"])
                        
                        GoalEditorField(goalType: "Carbs", value: $editedGoals["carbs"])
                        
                        GoalEditorField(goalType: "Fat", value: $editedGoals["fat"])
                        
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
                    .background(Colors.secondary)
                    .cornerRadius(12) // Rounded corners for the modal
                    .shadow(radius: 10) // Shadow for the modal
                    Spacer()
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
        .onAppear {
            viewModel.fetchFoodLog() // Fetch food log when the view appears
            viewModel.fetchMacroGoals()
            viewModel.fetchProgressBarData()
        }
    }
    
    // Progress Bars for Daily Goals
    var progressChart: some View {
        let totalMacros = viewModel.getTotalMacros()
        let maxWidth: CGFloat = 300 // Maximum width for progress bars (adjust as needed)
        
        return VStack(alignment: .leading, spacing: 20) {
            // Header with "Daily Total" and Filter Button
            HStack {
                Text("Daily Goals")
                    .font(.title3)
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
                        .frame(width: 19, height: 19)
                        .foregroundColor(Colors.primary)
                }
                
                // Settings Button
                Button(action: {
                    editedGoals = viewModel.dailyGoals // Set current values in the edited state
                    isSettingsPresented.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                        .foregroundColor(Colors.primary)
                }
            }
            
            // Calories Progress
            if viewModel.showCalories {
                HStack {
                    Text("Calories")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(Colors.primary)
                        .bold()
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Colors.gray  // Background color (empty space)
                                .frame(height: 30)
                            Colors.primaryLight
                                .opacity(0.2)
                                .frame(width: min(CGFloat(totalMacros.calories / Double((viewModel.dailyGoals["calories"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(Int(totalMacros.calories)) / \(Int(viewModel.dailyGoals["calories"] ?? 0)) kcal")
                                .foregroundColor(Colors.primary)
                                .padding(.leading, 10)
                                .bold()
                                .lineLimit(1)
                        }
                        .cornerRadius(8)
                    }
                    .frame(height: 30) // Set height of progress bar here
                    .frame(maxWidth: maxWidth) // Apply maxWidth constraint here
                }
            }
            
            // Protein Progress
            if viewModel.showProtein {
                HStack {
                    Text("Protein")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(Colors.primary)
                        .bold()
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Colors.gray  // Background color (empty space)
                                .frame(height: 30)
                            Colors.primaryLight
                                .opacity(0.2)
                                .frame(width: min(CGFloat(totalMacros.protein / Double((viewModel.dailyGoals["protein"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", totalMacros.protein)) / \(Int(viewModel.dailyGoals["protein"] ?? 0)) g")
                                .foregroundColor(Colors.primary)
                                .padding(.leading, 10)
                                .bold()
                                .lineLimit(1)
                        }
                        .cornerRadius(8)
                    }
                    .frame(height: 30) // Set height of progress bar here
                    .frame(maxWidth: maxWidth) // Apply maxWidth constraint here
                }
            }
            
            // Carbs Progress
            if viewModel.showCarbs {
                HStack {
                    Text("Carbs")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(Colors.primary)
                        .bold()
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Colors.gray  // Background color (empty space)
                                .frame(height: 30)
                            Colors.primaryLight
                                .opacity(0.2)
                                .frame(width: min(CGFloat(totalMacros.carbs / Double((viewModel.dailyGoals["carbs"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", totalMacros.carbs)) / \(Int(viewModel.dailyGoals["carbs"] ?? 0)) g")
                                .foregroundColor(Colors.primary)
                                .padding(.leading, 10)
                                .bold()
                                .lineLimit(1)
                        }
                        .cornerRadius(8)
                    }
                    .frame(height: 30) // Set height of progress bar here
                    .frame(maxWidth: maxWidth) // Apply maxWidth constraint here
                }
            }
            
            // Fat Progress
            if viewModel.showFat {
                HStack {
                    Text("Fat")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(Colors.primary)
                        .bold()
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Colors.gray  // Background color (empty space)
                                .frame(height: 30)
                            Colors.primaryLight
                                .opacity(0.2)
                                .frame(width: min(CGFloat(totalMacros.fat / Double((viewModel.dailyGoals["fat"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", totalMacros.fat)) / \(Int(viewModel.dailyGoals["fat"] ?? 0)) g")
                                .foregroundColor(Colors.primary)
                                .padding(.leading, 10)
                                .bold()
                                .lineLimit(1)
                        }
                        .cornerRadius(8)
                    }
                    .frame(height: 30) // Set height of progress bar here
                    .frame(maxWidth: maxWidth) // Apply maxWidth constraint here
                }
            }
        }
        .padding()  // Proper padding around the entire progress chart
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
                .font(.title3)
                .bold()
                .padding()
                .foregroundColor(Colors.secondary)
            VStack {
                // Checkbox-like UI
                Toggle(isOn: $viewModel.showCalories) {
                    Text("Calories")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
                Toggle(isOn: $viewModel.showProtein) {
                    Text("Protein")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
                Toggle(isOn: $viewModel.showCarbs) {
                    Text("Carbs")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
                Toggle(isOn: $viewModel.showFat) {
                    Text("Fat")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
                // Dismiss Button
                Button(action: {
                    showFilterModal.toggle()
                    viewModel.saveProgressBarData()
                }) {
                    Text("Save")
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
            HStack(alignment: .center) {
                Button(action: viewModel.goToToday) {
                   Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .foregroundColor(Colors.secondary)
                }
                Spacer()
                HStack(alignment: .center) {
                    Button(action: viewModel.goToPreviousDay) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(Colors.secondary)
                    }
                    Text(viewModel.formatDate(viewModel.currentDate))
                        .font(.title3)
                        .lineLimit(2)
                        .fontWeight(.bold)
                        .foregroundColor(Colors.secondary)
                    Button(action: viewModel.goToNextDay) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(Colors.secondary)
                    }
                }
                Spacer()
                Button(action: { showDatePicker.toggle() }) {
                    Image(systemName: "calendar")
                        .font(.title3)
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
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                Spacer()
                Button(action: { selectMeal(meal: meal )}) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Colors.primary)
                }
                .tint(Colors.primary)
                .font(.title3)
            }
            .frame(maxWidth: .infinity)  // Ensures the button takes up the full width
            VStack(alignment: .leading) {
                Text("Total")
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
                                    String(food.servings)
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
                                    
                                    // Debugging logs to track what the user is entering
                                    print("New Value: \(newValue)")
                                    print("Servings to update: \(servingsToUpdate)")
                                    
                                    // Update the food's macronutrients based on the new servings value
                                    let updatedFood = viewModel.updateFoodMacrosForServings(food: food, servings: servingsToUpdate)
                                    
                                    print( "2", updatedFood)
                                    
                                    // Update the meal log with the updated food (also saving it to Firebase)
                                    // viewModel.updateMealLogWithUpdatedFood(updatedFood: updatedFood, meal: viewModel.selectedMeal)
                                }
                            ))
                            .accentColor(Colors.primary)
                            .keyboardType(.decimalPad)
                            .padding()
                            .frame(width: 60, height: 40)
                            .background(Colors.secondary)
                            .cornerRadius(8)
                            .foregroundColor(Colors.primary)
                            .textFieldStyle(PlainTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
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
                .background(RoundedRectangle(cornerRadius: 8).fill(Colors.primary))
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
                .font(.title3)
                .foregroundColor(Colors.primary)
                .bold()
            
            // Search bar
            TextField("Search for food", text: $searchQuery)
                .accentColor(Colors.primary)
                .padding()
                .background(Colors.secondary)  // Set background of the entire TextField to white
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
            
            if viewModel.isLoading {
                ProgressView("Searching...")
                    .padding()
                    .foregroundColor(Colors.primary)
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
