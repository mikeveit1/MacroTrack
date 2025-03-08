import SwiftUI
import FatSecretSwift

struct FoodLogView: View {
    @State private var modalVisible = false
    @State private var showDatePicker = false
    @StateObject private var viewModel = FoodLogViewModel()
    @State private var searchQuery = ""
    @State private var searchTab: Int = 0 // 0 for Food tab, 1 for Meals tab
    @State private var mealSearchQuery: String = ""
    @State private var mealName = ""
    @State private var showFilterModal = false
    @State private var editedGoals: [String: Int] = [:]
    @State private var isSettingsPresented = false
    @State private var showingMealNameAlert = false
    @State private var showOptionsModal = false
    @State private var selectedOption: String? = nil
    private var maxWidth: CGFloat = 300
    
    func selectMeal(meal: Meal) {
        viewModel.selectedMeal = meal
        modalVisible = true
    }
    
    func captureSnapshot(view: some View) {
        // Create a UIHostingController for the custom SwiftUI view
        let hostingController = UIHostingController(rootView: view)
        
        // Calculate the intrinsic content size of the view
        let targetSize = hostingController.view.intrinsicContentSize
        if targetSize.width <= 0 || targetSize.height <= 0 {
            return
        }
        
        // Add padding around the content to make sure nothing gets clipped
        let padding: CGFloat = 150
        let adjustedSize = CGSize(width: targetSize.width + padding, height: targetSize.height + padding)
        
        // Set the hosting controller's view frame
        hostingController.view.frame = CGRect(origin: .zero, size: adjustedSize)
        
        // Add the hosting controller's view to the root view so it can layout
        UIApplication.shared.windows.first?.rootViewController?.view.addSubview(hostingController.view)
        
        // Ensure the layout is updated before rendering the snapshot
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // Create an image renderer with the adjusted size (including padding)
        let renderer = UIGraphicsImageRenderer(size: adjustedSize)
        
        // Render the view into an image
        let image = renderer.image { context in
            hostingController.view.layer.render(in: context.cgContext)
        }
        
        // Remove the hosting controller's view after capturing
        hostingController.view.removeFromSuperview()
        
        // Set the rendered image as the snapshot
        showShareSheet(image: image)
    }
    
    func showShareSheet(image: UIImage) {
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            // Check if a modal is being presented
            if rootViewController.presentedViewController != nil {
                rootViewController.dismiss(animated: true, completion: nil)
            }
        }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // Find the current view controller to present the share sheet
        if let currentVC = UIApplication.shared.windows.first?.rootViewController {
            currentVC.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    var screenshotIndividualMealView: some View {
        return VStack(alignment: .center) {
            let totalMacronutrients = viewModel.getTotalMacronutrients(for: viewModel.selectedMeal)
            HStack {
                Image(systemName: viewModel.selectedMeal.iconName)
                    .foregroundColor(Colors.primary)
                Text(viewModel.selectedMeal.rawValue.capitalized)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                Spacer()
                Text(viewModel.formatDate(viewModel.currentDate))
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                    .padding(.horizontal, 8)
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
            ForEach(viewModel.mealLogs[viewModel.selectedMeal]?.sorted(by: {$0.addDate < $1.addDate}) ?? [], id: \.id) { food in
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
                            Text("Servings: " + String(format: "%.1f", food.servings))
                                .foregroundColor(Colors.secondary)
                            Spacer()
                        }
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)  // Ensures the food item takes up the full width
                .background(RoundedRectangle(cornerRadius: 8).fill(Colors.primary))
            }
            Image("FullLogoGreen")
                .resizable()
                .frame(width: 100, height: 10)
                .padding(.top)
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    var screenshotAllMealsView: some View {
        return VStack(alignment: .center) {
            Text(viewModel.formatDate(viewModel.currentDate))
                .font(.title3)
                .bold()
                .foregroundColor(Colors.primary)
                .padding(.horizontal, 8)
            HStack {
                VStack(alignment: .leading, spacing: 20) {
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
                                        .frame(width: min(CGFloat(viewModel.totalMacros.calories / Double((viewModel.dailyGoals["calories"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                                    Text("\(Int(viewModel.totalMacros.calories)) / \(Int(viewModel.dailyGoals["calories"] ?? 0)) kcal")
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
                                        .frame(width: min(CGFloat(viewModel.totalMacros.protein / Double((viewModel.dailyGoals["protein"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                                    Text("\(String(format: "%.2f", viewModel.totalMacros.protein)) / \(Int(viewModel.dailyGoals["protein"] ?? 0)) g")
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
                                        .frame(width: min(CGFloat(viewModel.totalMacros.carbs / Double((viewModel.dailyGoals["carbs"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                                    Text("\(String(format: "%.2f", viewModel.totalMacros.carbs)) / \(Int(viewModel.dailyGoals["carbs"] ?? 0)) g")
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
                                        .frame(width: min(CGFloat(viewModel.totalMacros.fat / Double((viewModel.dailyGoals["fat"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                                    Text("\(String(format: "%.2f", viewModel.totalMacros.fat)) / \(Int(viewModel.dailyGoals["fat"] ?? 0)) g")
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
                Spacer()
            }
            .padding()
            .background(Colors.secondary)
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: .infinity)
            
            ForEach(Meal.allCases, id: \.self) { meal in
                VStack (alignment: .leading) {
                    let totalMacronutrients = viewModel.getTotalMacronutrients(for: meal)
                    HStack {
                        Image(systemName: meal.iconName)
                            .foregroundColor(Colors.primary)
                        Text(meal.rawValue.capitalized)
                            .font(.title3)
                            .bold()
                            .foregroundColor(Colors.primary)
                        Spacer()
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
                    ForEach(viewModel.mealLogs[meal]?.sorted(by: {$0.addDate < $1.addDate}) ?? [], id: \.id) { food in
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
                                    Text("Servings: " + String(format: "%.1f", food.servings))
                                        .foregroundColor(Colors.secondary)
                                    Spacer()
                                }
                                
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
            Image("FullLogoGreen")
                .resizable()
                .frame(width: 100, height: 10)
                .padding(.top)
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    var screenshotDailyGoalsView: some View {
        return VStack(alignment: .center, spacing: 20) {
            Text(viewModel.formatDate(viewModel.currentDate))
                .font(.title3)
                .bold()
                .foregroundColor(Colors.primary)
            
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
                                .frame(width: min(CGFloat(viewModel.totalMacros.calories / Double((viewModel.dailyGoals["calories"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(Int(viewModel.totalMacros.calories)) / \(Int(viewModel.dailyGoals["calories"] ?? 0)) kcal")
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
                                .frame(width: min(CGFloat(viewModel.totalMacros.protein / Double((viewModel.dailyGoals["protein"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", viewModel.totalMacros.protein)) / \(Int(viewModel.dailyGoals["protein"] ?? 0)) g")
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
                                .frame(width: min(CGFloat(viewModel.totalMacros.carbs / Double((viewModel.dailyGoals["carbs"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", viewModel.totalMacros.carbs)) / \(Int(viewModel.dailyGoals["carbs"] ?? 0)) g")
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
                                .frame(width: min(CGFloat(viewModel.totalMacros.fat / Double((viewModel.dailyGoals["fat"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", viewModel.totalMacros.fat)) / \(Int(viewModel.dailyGoals["fat"] ?? 0)) g")
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
            // LogoGreen
            Image("FullLogoGreen")
                .resizable()
                .frame(width: 100, height: 10)
                .padding(.top)
            
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    LogoGreen
                        .padding(.bottom, 8)
                    // Header View (Date Navigation)
                    Spacer()
                    Button(action: {
                        showOptionsModal = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19, height: 19)
                            .foregroundColor(Colors.primary)
                    }
                }
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
            .padding(.horizontal)
            .padding(.bottom)
            .background(Colors.secondary)
            .sheet(isPresented: $modalVisible) {
                foodModalView
            }
            .sheet(isPresented: $showOptionsModal) {
                       // Modal content with meal options
                ShareOptionsView
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
                        
                        HStack {
                            Spacer()
                            // Save Button
                            Button(action: {
                                viewModel.saveDailyGoals(newGoals: editedGoals)
                                isSettingsPresented = false // Close the modal
                            }) {
                                Text("Save")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: 200)
                                    .padding()
                                    .background(Colors.primary)
                                    .foregroundColor(Colors.secondary)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 16) // Padding for spacing between the fields and the button
                            Spacer()
                        }
                        
                        // Cancel Button
                        HStack {
                            Spacer()
                            Button(action: {
                                isSettingsPresented = false // Close the modal without saving
                            }) {
                                Text("Cancel")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: 200)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(Colors.secondary)
                                    .cornerRadius(10)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Colors.secondary)
                    .cornerRadius(8) // Rounded corners for the modal
                    .shadow(radius: 10) // Shadow for the modal
                    Spacer()
                }
                .padding()
                .frame(maxHeight: .infinity) // Make the VStack take up the full height
                .background(Colors.primary.edgesIgnoringSafeArea(.all)) // Semi-transparent background behind the modal
            }
            
            .background(Colors.secondary)
        }
        
        .background(Colors.secondary)
        .onTapGesture {
            UIApplication.shared.endEditing() // This will dismiss the keyboard
        }
        .onChange(of: viewModel.mealLogs) { _ in
            // Recalculate macros whenever mealLogs changes
            _ = viewModel.getTotalMacros()
        }
        .onAppear {
            viewModel.fetchFoodLog()
            viewModel.fetchMacroGoals()
            viewModel.fetchProgressBarData()
            viewModel.fetchUserMeals()
            viewModel.getTotalMacros()
        }
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded { value in
            // Detect swipe direction
            if value.translation.width < 0 {
                // Swipe left (next day)
                viewModel.goToNextDay()
            } else if value.translation.width > 0 {
                // Swipe right (previous day)
                viewModel.goToPreviousDay()
            }
        }
        )
    }
    
    var ShareOptionsView: some View {
        VStack(spacing: 20) {
            Text("Select Log Data to Share:")
                .font(.headline)
            
            // Option buttons
            Button("Daily Goals") {
                selectedOption = "Daily Goals"
                captureSnapshot(view: screenshotDailyGoalsView)
            }
            .fontWeight(.bold)
            .frame(maxWidth: 200)
            .padding()
            .background(Colors.primary)
            .foregroundColor(Colors.secondary)
            .cornerRadius(10)
            
            Button(action: {
                selectedOption = "Breakfast"
                viewModel.selectedMeal = .breakfast
                captureSnapshot(view: screenshotIndividualMealView)
            }) {
                Image(systemName: Meal.breakfast.iconName)
                    .foregroundColor(Colors.secondary)
                Text("Breakfast")
            }
            .fontWeight(.bold)
            .frame(maxWidth: 200)
            .padding()
            .background(Colors.primary)
            .foregroundColor(Colors.secondary)
            .cornerRadius(10)
            
            Button(action: {
                selectedOption = "Lunch"
                viewModel.selectedMeal = .lunch
                captureSnapshot(view: screenshotIndividualMealView)
            }) {
                Image(systemName: Meal.lunch.iconName)
                    .foregroundColor(Colors.secondary)
                Text("Lunch")
            }
            .fontWeight(.bold)
            .frame(maxWidth: 200)
            .padding()
            .background(Colors.primary)
            .foregroundColor(Colors.secondary)
            .cornerRadius(10)
            
            Button(action: {
                selectedOption = "Dinner"
                viewModel.selectedMeal = .dinner
                captureSnapshot(view: screenshotIndividualMealView)
            }) {
                Image(systemName: Meal.dinner.iconName)
                    .foregroundColor(Colors.secondary)
                Text("Dinner")
            }
            .fontWeight(.bold)
            .frame(maxWidth: 200)
            .padding()
            .background(Colors.primary)
            .foregroundColor(Colors.secondary)
            .cornerRadius(10)
            
            Button(action: {
                selectedOption = "Snacks"
                viewModel.selectedMeal = .snacks
                captureSnapshot(view: screenshotIndividualMealView)
            }) {
                Image(systemName: Meal.snacks.iconName)
                    .foregroundColor(Colors.secondary)
                Text("Snacks")
            }
            .fontWeight(.bold)
            .frame(maxWidth: 200)
            .padding()
            .background(Colors.primary)
            .foregroundColor(Colors.secondary)
            .cornerRadius(10)

            Button("All Meals") {
                selectedOption = "All Meals"
                captureSnapshot(view: screenshotAllMealsView)
            }
            .fontWeight(.bold)
            .frame(maxWidth: 200)
            .padding()
            .background(Colors.primary)
            .foregroundColor(Colors.secondary)
            .cornerRadius(10)
        }
        .padding()
    }
    
    // Progress Bars for Daily Goals
    var progressChart: some View {
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
                                .frame(width: min(CGFloat(viewModel.totalMacros.calories / Double((viewModel.dailyGoals["calories"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(Int(viewModel.totalMacros.calories)) / \(Int(viewModel.dailyGoals["calories"] ?? 0)) kcal")
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
                                .frame(width: min(CGFloat(viewModel.totalMacros.protein / Double((viewModel.dailyGoals["protein"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", viewModel.totalMacros.protein)) / \(Int(viewModel.dailyGoals["protein"] ?? 0)) g")
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
                                .frame(width: min(CGFloat(viewModel.totalMacros.carbs / Double((viewModel.dailyGoals["carbs"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", viewModel.totalMacros.carbs)) / \(Int(viewModel.dailyGoals["carbs"] ?? 0)) g")
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
                                .frame(width: min(CGFloat(viewModel.totalMacros.fat / Double((viewModel.dailyGoals["fat"] ?? 0))) * geometry.size.width, geometry.size.width), height: 30)
                            Text("\(String(format: "%.2f", viewModel.totalMacros.fat)) / \(Int(viewModel.dailyGoals["fat"] ?? 0)) g")
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
            Text("Filter Your Daily Macronutrient Goals")
                .font(.title3)
                .bold()
                .padding(.vertical)
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
                HStack {
                    Spacer()
                    Button(action: {
                        showFilterModal.toggle()
                        viewModel.saveProgressBarData()
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .frame(maxWidth: 200)
                            .padding()
                            .background(Colors.primary)
                            .foregroundColor(Colors.secondary)
                            .cornerRadius(10)
                    }
                    .padding()
                    Spacer()
                }
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
                Button(action: {
                    viewModel.selectedMeal = meal
                    showingMealNameAlert = true
                }) {
                    Text("Save")
                        .foregroundColor(Colors.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Colors.primary)
                        .cornerRadius(8)
                }
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
            ForEach(viewModel.mealLogs[meal]?.sorted(by: {$0.addDate < $1.addDate}) ?? [], id: \.id) { food in
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
                                    
                                    let updatedFood = viewModel.updateFoodMacrosForServings(meal: meal, food: food, servings: servingsToUpdate)
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
        .sheet(isPresented: $showingMealNameAlert) {
            VStack {
                VStack {
                    Text("Save Meal")
                        .font(.title3)
                        .foregroundColor(Colors.primary)
                        .bold()
                    Text("Enter a name for this meal:")
                        .foregroundColor(Colors.primary)
                }
                .padding(.top)
                ZStack(alignment: .leading) {
                    if mealName.isEmpty {
                        Text("Meal Name")
                            .foregroundColor(Colors.primaryLight)  // Placeholder text color
                            .padding(32)
                    }
                    TextField("", text: $mealName)
                        .padding()
                        .cornerRadius(8)
                        .accentColor(Colors.primary)
                        .foregroundColor(Colors.primary)
                        .textFieldStyle(PlainTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Colors.primary, lineWidth: 1)
                        )
                        .padding()
                }
                
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button("Save") {
                            if !mealName.isEmpty {
                                viewModel.saveMealToFirebase(mealName: mealName, meal: viewModel.selectedMeal)
                            }
                            self.showingMealNameAlert = false
                        }
                        .fontWeight(.bold)
                        .frame(maxWidth: 200)
                        .padding()
                        .background(Colors.primary)
                        .foregroundColor(Colors.secondary)
                        .cornerRadius(10)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Button("Cancel") {
                            self.showingMealNameAlert = false
                        }
                        .fontWeight(.bold)
                        .frame(maxWidth: 200)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(Colors.secondary)
                        .cornerRadius(10)
                        Spacer()
                    }
                }
                Spacer()
                    .padding()
            }
            .frame(maxHeight: .infinity)
            .background(Colors.secondary)
            //.padding()
        }
    }
    
    // Modal for Food Details Entry with search
    var foodModalView: some View {
        VStack {
            Text("Search")
                .font(.title3)
                .foregroundColor(Colors.primary)
                .bold()
                .padding(.top)
            
            // Top Tab Bar with Underline
            HStack {
                Spacer()
                Button(action: {
                    searchTab = 0
                }) {
                    Text("Foods")
                        .font(.headline)
                        .padding()
                        .foregroundColor(searchTab == 0 ? Colors.primary : Colors.primaryLight)
                        .overlay(
                            VStack {
                                Spacer()
                                if searchTab == 0 {
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Colors.primary)
                                }
                            }
                        )
                }
                Spacer()
                
                Button(action: {
                    searchTab = 1
                }) {
                    Text("Your Meals")
                        .font(.headline)
                        .padding()
                        .foregroundColor(searchTab == 1 ? Colors.primary : Colors.primaryLight)
                        .overlay(
                            VStack {
                                Spacer()
                                if searchTab == 1 {
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Colors.primary)
                                }
                            }
                        )
                }
                Spacer()
            }
            .background(Colors.secondary) // Background for the top tab bar
            
            // Content view based on the selected tab
            if searchTab == 0 {
                searchFoodsView
            } else {
                searchMealsView
            }
            
            Spacer()
        }
        .background(Colors.secondary)
    }
    
    // View for searching foods
    private var searchFoodsView: some View {
        VStack {
            ZStack(alignment: .leading) {
                if searchQuery.isEmpty {
                    Text("Search for foods")
                        .foregroundColor(Colors.primaryLight)
                        .padding(.leading, 15)
                }
                TextField("", text: $searchQuery)
                    .accentColor(Colors.primary)
                    .padding()
                    .cornerRadius(8)
                    .foregroundColor(Colors.primary)
                    .textFieldStyle(PlainTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Colors.primary, lineWidth: 1)
                    )
                    .onChange(of: searchQuery) { newValue in
                        viewModel.searchFoods(query: newValue)
                    }
            }
            
            // List of food items
            List(viewModel.searchResults, id: \.id) { food in
                Section {
                    Button(action: {
                        // Prompt user for servings after selecting a food
                        viewModel.convertSearchFoodToMacroFood(searchedFood: food) { macroFood in
                            viewModel.saveFood(meal: viewModel.selectedMeal, food: macroFood)
                            modalVisible = false
                        }
                    }) {
                        VStack(alignment: .leading) {
                            Text(food.name)
                                .foregroundColor(Colors.primary)
                                .bold()
                                .lineLimit(2)
                            if let brand = food.brand {
                                Text(brand)
                                    .foregroundColor(Colors.primaryLight)
                            }
                        }
                    }
                }
                .listRowBackground(Colors.secondary)
            }
            .listStyle(.plain)
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .frame(maxHeight: .infinity)
    }
    
    // View for searching meals
    private var searchMealsView: some View {
        VStack {
            ZStack(alignment: .leading) {
                if mealSearchQuery.isEmpty {
                    Text("Search your meals")
                        .foregroundColor(Colors.primaryLight)
                        .padding(.leading, 15)
                }
                TextField("", text: $mealSearchQuery)
                    .accentColor(Colors.primary)
                    .padding()
                    .cornerRadius(8)
                    .foregroundColor(Colors.primary)
                    .textFieldStyle(PlainTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Colors.primary, lineWidth: 1)
                    )
            }
            
            // List of saved meals
            List {
                let filteredMeals = mealSearchQuery.isEmpty ? viewModel.userMeals :
                viewModel.userMeals.filter { meal in
                    meal.name.lowercased().contains(mealSearchQuery.lowercased())
                }
                
                ForEach(filteredMeals, id: \.id) { meal in
                    Section {
                        Button(action: {
                            // Populate foods from the selected meal
                            viewModel.populateFoodsFromMeal(meal: viewModel.selectedMeal, userMeal: meal)
                            modalVisible = false
                        }) {
                            VStack(alignment: .leading) {
                                Text(meal.name)
                                    .foregroundColor(Colors.primary)
                                    .bold()
                                    .lineLimit(2)
                            }
                        }
                    }
                    .listRowBackground(Colors.secondary)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .background(Colors.secondary)
        .cornerRadius(10)
        .frame(maxHeight: .infinity)
    }
}


struct FoodLogScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoodLogView()
    }
}
