import SwiftUI
import FatSecretSwift

struct FoodLogView: View {
    @State private var modalVisible = false
    @State private var showDatePicker = false
    @StateObject private var viewModel = FoodLogViewModel()
    @State private var searchQuery = ""
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack {
                // Date Navigation
                headerView
                
                // Meal Sections
                ForEach(Meal.allCases, id: \.self) { meal in
                    mealSection(meal)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .sheet(isPresented: $modalVisible) {
                foodModalView
            }
        }
        .background(Color(.systemGray6))
    }
    
    // Header View (Date Navigation)
    var headerView: some View {
        HStack {
            Button(action: viewModel.goToToday) {
                Text("Today")
                    .fontWeight(.bold)
                    .foregroundColor(Colors.secondary)
            }
            Spacer()
            Button(action: viewModel.goToPreviousDay) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(Colors.secondary)
            }
            Text(viewModel.formatDate(viewModel.currentDate))
                .font(.title3)
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
        .padding()
        .frame(maxWidth: .infinity)
        .background(Colors.primary, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // Meal Section (for breakfast, lunch, dinner, snacks)
    func mealSection(_ meal: Meal) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: meal.iconName)
                    .foregroundColor(Colors.primary)
                Text(meal.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(Colors.primary)
            }
            .padding(.horizontal, 8)
            
            // Add Food Button - Set maxWidth to .infinity to make it full width
            Button("Add Food") {
                viewModel.selectedMeal = meal
                modalVisible = true
            }
            .padding()
            .frame(maxWidth: .infinity)  // Ensures the button takes up the full width
            .background(RoundedRectangle(cornerRadius: 8).stroke(Colors.primary, lineWidth: 1))
            .tint(Colors.primary)
            .bold()
            
            // Food List - Set maxWidth to .infinity for full width on each item
            ForEach(viewModel.mealLogs[meal] ?? [], id: \.self) { food in
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(food.name)
                                .foregroundColor(Colors.primary)
                                .bold()
                                .font(.headline)
                            Text("-")
                                .foregroundColor(Colors.primary)
                            Text("\(food.macronutrients.calories) cal")
                                .foregroundColor(Colors.primary)
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                HStack {
                                    Text("P:")
                                        .foregroundColor(Colors.primaryLight)
                                    Text("\(food.macronutrients.protein)g")
                                        .foregroundColor(Colors.primaryLight)
                                        .bold()
                                }
                                HStack {
                                    Text("C:")
                                        .foregroundColor(Colors.primaryLight)
                                    Text("\(food.macronutrients.carbs)g")
                                        .foregroundColor(Colors.primaryLight)
                                        .bold()
                                }
                                HStack {
                                    Text("F:")
                                        .foregroundColor(Colors.primaryLight)
                                    Text("\(food.macronutrients.fat)g")
                                        .foregroundColor(Colors.primaryLight)
                                        .bold()
                                }
                            }
                        }
                    }
                    Spacer()
                    Button(action: { viewModel.deleteFoodFromMeal(meal: meal, food: food) }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)  // Ensures the food item takes up the full width
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            }
        }
        .padding()
        .background(Color.white)
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
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Colors.primary)
                .onChange(of: searchQuery) { newValue in
                    viewModel.searchFoods(query: newValue)
                }
            
            if isLoading {
                ProgressView("Searching...")
                    .padding()
            }
            
            // List of food items
            List(viewModel.searchResults, id: \.id) { food in
                Button(action: {
                    viewModel.convertSearchFoodToMacroFood(searchedFood: food) { food in
                        viewModel.saveFood(food: food)
                    }
                    modalVisible = false
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
            .padding(.vertical)
            
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
        .background(Color.white)
    }
}

struct FoodLogScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoodLogView()
    }
}
