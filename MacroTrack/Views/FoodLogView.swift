import SwiftUI

struct FoodLogScreen: View {
    @State private var modalVisible = false
    @State private var foodName = ""
    @State private var quantity = ""
    @State private var currentDate = Date()
    @State private var mealLogs: MealLogs = MealLogs()
    @State private var selectedMeal: Meal = .breakfast
    @State private var showDatePicker = false
    
    // For searchable modal
    @State private var searchQuery = ""
    @State private var searchResults: [String] = [] // Result list for food names
    @State private var isLoading = false

    // Create an instance of GetFoods
    @StateObject private var getFoods = GetFoods()

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
            Button(action: goToToday) {
                Text("Today")
                    .fontWeight(.bold)
                    .foregroundColor(Colors.secondary)
            }
            Spacer()
            Button(action: goToPreviousDay) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(Colors.secondary)
            }
            Text(formatDate(currentDate))
                .font(.title3)
                .lineLimit(2)
                .fontWeight(.bold)
                .foregroundColor(Colors.secondary)
            Button(action: goToNextDay) {
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
                selectedMeal = meal
                modalVisible = true
            }
            .padding()
            .frame(maxWidth: .infinity)  // Ensures the button takes up the full width
            .background(RoundedRectangle(cornerRadius: 8).stroke(Colors.primary, lineWidth: 1))
            .tint(Colors.primary)
            .bold()

            // Food List - Set maxWidth to .infinity for full width on each item
            ForEach(mealLogs[meal] ?? [], id: \.self) { food in
                HStack {
                    Text(food)
                        .foregroundColor(Colors.primary)
                    Spacer()
                    Button(action: { deleteFoodFromMeal(meal, food) }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)  // Ensures the food item takes up the full width
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                .shadow(radius: 5)
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

            // Search bar
            TextField("Search for food", text: $searchQuery)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)
                .onChange(of: searchQuery) { _ in
                    searchFoods()
                }

            if isLoading {
                ProgressView("Searching...")
                    .padding()
            }

            // List of food items
            List(searchResults, id: \.self) { food in
                Button(action: {
                    addFoodToMeal(meal: selectedMeal, food: food)
                    modalVisible = false
                }) {
                    Text(food)
                        .foregroundColor(Colors.primary)
                }
            }
            .padding(.top)

            // Buttons for canceling and saving
            HStack {
                Button("Cancel") {
                    foodName = ""
                    quantity = ""
                    modalVisible = false
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.red))
                .foregroundColor(.white)

                Button("Save") {
                    saveFood()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
                .foregroundColor(.white)
            }
            .padding(.top)
        }
        .padding()
        .cornerRadius(10)
        .shadow(radius: 10)
        .background(Color.white)
    }

    // Search food items from the API
    func searchFoods() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        getFoods.searchFood(query: searchQuery) { foods in
            DispatchQueue.main.async {
                self.searchResults = foods
                self.isLoading = false
            }
        }
    }

    // Save food to the selected meal
    func saveFood() {
        guard !foodName.isEmpty, !quantity.isEmpty else { return }
        let foodDetails = "\(foodName) (\(quantity))"
        addFoodToMeal(meal: selectedMeal, food: foodDetails)
        foodName = ""
        quantity = ""
        modalVisible = false
    }

    // Add food to selected meal
    func addFoodToMeal(meal: Meal, food: String) {
        mealLogs[meal]?.append(food)
    }

    // Delete food from selected meal
    func deleteFoodFromMeal(_ meal: Meal, _ food: String) {
        mealLogs[meal]?.removeAll { $0 == food }
    }

    // Go to today's date
    func goToToday() {
        currentDate = Date()
    }

    // Go to the previous day
    func goToPreviousDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
    }

    // Go to the next day
    func goToNextDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
    }

    // Format date into a readable string
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct FoodLogScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoodLogScreen()
    }
}

// Enum for Meal Types
enum Meal: String, CaseIterable {
    case breakfast, lunch, dinner, snacks
    
    var iconName: String {
        switch self {
        case .breakfast:
            return "egg.fried"
        case .lunch:
            return "bag"
        case .dinner:
            return "staroflife"
        case .snacks:
            return "applelogo"
        }
    }
}

// Struct to hold the meal logs
struct MealLogs {
    var breakfast: [String] = []
    var lunch: [String] = []
    var dinner: [String] = []
    var snacks: [String] = []

    subscript(meal: Meal) -> [String]? {
        get {
            switch meal {
            case .breakfast: return breakfast
            case .lunch: return lunch
            case .dinner: return dinner
            case .snacks: return snacks
            }
        }
        set {
            switch meal {
            case .breakfast: breakfast = newValue ?? []
            case .lunch: lunch = newValue ?? []
            case .dinner: dinner = newValue ?? []
            case .snacks: snacks = newValue ?? []
            }
        }
    }
}

