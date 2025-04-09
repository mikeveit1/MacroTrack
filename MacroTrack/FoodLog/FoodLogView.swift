//
//  FoodLogView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import SwiftUI
import FatSecretSwift

struct FoodLogView: View {
    @State private var modalVisible = false
    @State private var showDatePicker = false
    @StateObject private var viewModel = FoodLogViewModel()
    @State private var searchQuery = ""
    @State private var searchTab: Int = 0
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
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .white
        
        let targetSize = hostingController.view.intrinsicContentSize
        if targetSize.width <= 0 || targetSize.height <= 0 {
            return
        }
        
        let adjustedSize = CGSize(width: targetSize.width + 250, height: targetSize.height)
        
        hostingController.view.frame = CGRect(x: 0, y: 0, width: adjustedSize.width, height: adjustedSize.height)
        
        UIApplication.shared.windows.first?.rootViewController?.view.addSubview(hostingController.view)
        
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: adjustedSize)
        
        let image = renderer.image { context in
            hostingController.view.layer.render(in: context.cgContext)
        }
        
        hostingController.view.removeFromSuperview()
        
        showShareSheet(image: image)
    }
    
    func showShareSheet(image: UIImage) {
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            if rootViewController.presentedViewController != nil {
                rootViewController.dismiss(animated: true, completion: nil)
            }
        }
        
        if let data = image.jpegData(compressionQuality: 1) {
            let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent("MacroTrack_\(Date().timeIntervalSince1970).jpg")
            do {
                try data.write(to: imageURL)
                let activityViewController = UIActivityViewController(activityItems: [imageURL], applicationActivities: nil)
                
                if let currentVC = UIApplication.shared.windows.first?.rootViewController {
                    currentVC.present(activityViewController, animated: true, completion: nil)
                }
            } catch {
                print("error")
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    LogoGreen
                        .padding(.bottom, 8)
                    Spacer()
                }
                headerView
                progressChart
                
                ForEach(Meal.allCases, id: \.self) { meal in
                    mealSection(meal)
                }
            }
            .onChange(of: viewModel.currentDate) { _ in
                viewModel.fetchFoodLog()
            }
            .padding(.horizontal)
            .padding(.bottom)
            .background(Colors.secondary)
            .sheet(isPresented: $modalVisible) {
                foodModalView
            }
            .sheet(isPresented: $showOptionsModal) {
                shareOptionsView
            }
            .sheet(isPresented: $isSettingsPresented) {
                VStack {
                    Text("Edit Your Daily Goals")
                        .font(.title3)
                        .foregroundColor(Colors.primary)
                        .bold()
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        GoalEditorField(goalType: "Calories", value: $editedGoals["calories"])
                        GoalEditorField(goalType: "Protein", value: $editedGoals["protein"])
                        GoalEditorField(goalType: "Carbs", value: $editedGoals["carbs"])
                        GoalEditorField(goalType: "Fat", value: $editedGoals["fat"])
                        GoalEditorField(goalType: "Water", value: $editedGoals["water"])
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.saveDailyGoals(newGoals: editedGoals)
                                isSettingsPresented = false
                            }) {
                                Text("Save")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: 200)
                                    .padding()
                                    .background(Colors.primary)
                                    .foregroundColor(Colors.secondary)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 16)
                            Spacer()
                        }

                        HStack {
                            Spacer()
                            Button(action: {
                                isSettingsPresented = false
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
                    .cornerRadius(8)
                    .shadow(radius: 10)
                    Spacer()
                }
                .padding()
                .frame(maxHeight: .infinity)
                .background(Colors.secondary.edgesIgnoringSafeArea(.all))
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            }
            .background(Colors.secondary)
        }
        .background(Colors.secondary)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onChange(of: viewModel.mealLogs) { _ in
            viewModel.getTotalMacrosForAllMeals()
        }
        .onAppear {
            viewModel.fetchFoodLog()
            viewModel.fetchMacroGoals()
            viewModel.fetchProgressBarData()
            viewModel.fetchUserMeals()
            viewModel.getTotalMacrosForAllMeals()
        }
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded { value in
            if value.translation.width < 0 {
                viewModel.goToNextDay()
            } else if value.translation.width > 0 {
                viewModel.goToPreviousDay()
            }
        }
        )
    }
    
    var shareOptionsView: some View {
        VStack {
            Text("Select Log Data to Share")
                .font(.title3)
                .foregroundColor(Colors.primary)
                .bold()
                .padding()
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    Button("Daily Goals") {
                        selectedOption = "Daily Goals"
                        captureSnapshot(view: ScreenshotDailyGoalsView(date: viewModel.formatDate(viewModel.currentDate), showCalories: viewModel.showCalories, showProtein: viewModel.showProtein, showCarbs: viewModel.showCarbs, showFat: viewModel.showFat, showWater: viewModel.showWater, totalCalories: viewModel.totalMacros.calories, calorieGoal: viewModel.dailyGoals["calories"] ?? 0, totalProtein: viewModel.totalMacros.protein, proteinGoal: viewModel.dailyGoals["protein"] ?? 0, totalCarbs: viewModel.totalMacros.carbs, carbGoal: viewModel.dailyGoals["carbs"] ?? 0, totalFat: viewModel.totalMacros.fat, fatGoal: viewModel.dailyGoals["fat"] ?? 0, totalWater: viewModel.water, waterGoal: viewModel.dailyGoals["water"], maxWidth: maxWidth))
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(Colors.primary)
                    .foregroundColor(Colors.secondary)
                    .cornerRadius(10)
                    Spacer()
                }
                
                Button(action: {
                    selectedOption = "Breakfast"
                    viewModel.selectedMeal = .breakfast
                    captureSnapshot(view: ScreenshotIndividualMealView(totalMacronutrients: viewModel.getTotalMacronutrients(for: viewModel.selectedMeal), selectedMeal: viewModel.selectedMeal, dateString: viewModel.formatDate(viewModel.currentDate), water: viewModel.water, mealLogs: viewModel.mealLogs))
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
                    captureSnapshot(view: ScreenshotIndividualMealView(totalMacronutrients: viewModel.getTotalMacronutrients(for: viewModel.selectedMeal), selectedMeal: viewModel.selectedMeal, dateString: viewModel.formatDate(viewModel.currentDate), water: viewModel.water, mealLogs: viewModel.mealLogs))
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
                    captureSnapshot(view: ScreenshotIndividualMealView(totalMacronutrients: viewModel.getTotalMacronutrients(for: viewModel.selectedMeal), selectedMeal: viewModel.selectedMeal, dateString: viewModel.formatDate(viewModel.currentDate), water: viewModel.water, mealLogs: viewModel.mealLogs))
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
                    captureSnapshot(view: ScreenshotIndividualMealView(totalMacronutrients: viewModel.totalMacros, selectedMeal: viewModel.selectedMeal, dateString: viewModel.formatDate(viewModel.currentDate), water: viewModel.water, mealLogs: viewModel.mealLogs))
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
                
                Button(action: {
                    selectedOption = "Water"
                    viewModel.selectedMeal = .water
                    captureSnapshot(view: ScreenshotIndividualMealView(totalMacronutrients: viewModel.getTotalMacronutrients(for: viewModel.selectedMeal), selectedMeal: viewModel.selectedMeal, dateString: viewModel.formatDate(viewModel.currentDate), water: viewModel.water, mealLogs: viewModel.mealLogs))
                }) {
                    Image(systemName: Meal.water.iconName)
                        .foregroundColor(Colors.secondary)
                    Text("Water")
                }
                .fontWeight(.bold)
                .frame(maxWidth: 200)
                .padding()
                .background(Colors.primary)
                .foregroundColor(Colors.secondary)
                .cornerRadius(10)
                
                Button("All Meals") {
                    selectedOption = "All Meals"
                    captureSnapshot(view: ScreenshotAllMealsView(date: viewModel.formatDate(viewModel.currentDate), showCalories: viewModel.showCalories, showProtein: viewModel.showProtein, showCarbs: viewModel.showCarbs, showFat: viewModel.showFat, showWater: viewModel.showWater, totalCalories: viewModel.totalMacros.calories, calorieGoal: viewModel.dailyGoals["calories"] ?? 0, totalProtein: viewModel.totalMacros.protein, proteinGoal: viewModel.dailyGoals["protein"] ?? 0, totalCarbs: viewModel.totalMacros.carbs, carbGoal: viewModel.dailyGoals["carbs"] ?? 0, totalFat: viewModel.totalMacros.fat, fatGoal: viewModel.dailyGoals["fat"] ?? 0, totalWater: viewModel.water, waterGoal: viewModel.dailyGoals["water"], maxWidth: maxWidth, mealLogs: viewModel.mealLogs))
                }
                .fontWeight(.bold)
                .frame(maxWidth: 200)
                .padding()
                .background(Colors.primary)
                .foregroundColor(Colors.secondary)
                .cornerRadius(10)
            }
            .padding()
            .background(Colors.secondary)
            .cornerRadius(10)
            .shadow(radius: 8)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 8)
        .edgesIgnoringSafeArea(.all)
    }
    
    var progressChart: some View {
        return VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Daily Goals")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Colors.primary)
                Spacer()
                Button(action: {
                    showOptionsModal = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(Colors.primary)
                }
                Button(action: {
                    showFilterModal.toggle()
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                        .foregroundColor(Colors.primary)
                }
                
                Button(action: {
                    editedGoals = viewModel.dailyGoals
                    isSettingsPresented.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                        .foregroundColor(Colors.primary)
                }
            }
            
            DailyGoalsView(date: viewModel.formatDate(viewModel.currentDate), showCalories: viewModel.showCalories, showProtein: viewModel.showProtein, showCarbs: viewModel.showCarbs, showFat: viewModel.showFat, showWater: viewModel.showWater, totalCalories: viewModel.totalMacros.calories, calorieGoal: viewModel.dailyGoals["calories"] ?? 0, totalProtein: viewModel.totalMacros.protein, proteinGoal: viewModel.dailyGoals["protein"] ?? 0, totalCarbs: viewModel.totalMacros.carbs, carbGoal: viewModel.dailyGoals["carbs"] ?? 0, totalFat: viewModel.totalMacros.fat, fatGoal: viewModel.dailyGoals["fat"] ?? 0, totalWater: viewModel.water, waterGoal: viewModel.dailyGoals["water"] ?? 0, maxWidth: maxWidth)
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
            Text("Filter Your Daily Goals")
                .font(.title3)
                .bold()
                .padding(.vertical)
                .foregroundColor(Colors.primary)
            VStack {
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
                
                Toggle(isOn: $viewModel.showWater) {
                    Text("Water")
                        .foregroundColor(Colors.primary)
                        .bold()
                }
                .tint(Colors.primary)
                .padding()
                
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
            .background(Colors.secondary)
            .cornerRadius(10)
            .shadow(radius: 8)
            Spacer()
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(Colors.secondary)
        .cornerRadius(10)
        .shadow(radius: 8)
        .edgesIgnoringSafeArea(.all)
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
            .frame(maxWidth: .infinity)
            
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
                    print("New selected date: \(newDate)")
                    
                }
            }
        }
        
        .padding()
        .frame(maxWidth: .infinity)
        .background(Colors.primary, in: RoundedRectangle(cornerRadius: 10))
    }
    
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
                if meal != .water {
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
                } else {
                    Button(action: {
                        viewModel.selectedMeal = meal
                        if viewModel.water >= 8 {
                            viewModel.water -= 8
                        } else {
                            viewModel.water = 0
                        }
                        viewModel.updateFoodMacrosForServings(meal: meal, food: MacroFood(id: "-1", name: "Water", macronutrients: MacronutrientInfo(calories: 0, protein: 0, carbs: 0, fat: 0), originalMacros: MacronutrientInfo(calories: 0, protein: 0, carbs: 0, fat: 0), servingDescription: "1 oz", servings: Double(viewModel.water), addDate: Date()), servings: Double(viewModel.water))
                    }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(Colors.primary)
                    }
                    .tint(Colors.primary)
                    .font(.title3)
                    Button(action: {
                        viewModel.selectedMeal = meal
                        viewModel.water += 8
                        viewModel.updateFoodMacrosForServings(meal: meal, food: MacroFood(id: "-1", name: "Water", macronutrients: MacronutrientInfo(calories: 0, protein: 0, carbs: 0, fat: 0), originalMacros: MacronutrientInfo(calories: 0, protein: 0, carbs: 0, fat: 0), servingDescription: "1 oz", servings: Double(viewModel.water), addDate: Date()), servings: Double(viewModel.water))
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(Colors.primary)
                    }
                    .tint(Colors.primary)
                    .font(.title3)
                }
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading) {
                Text("Total")
                    .foregroundColor(Colors.primary)
                    .bold()
                if meal != .water {
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
                } else {
                    HStack {
                        Text(String(format: "%.2f", viewModel.water) + " oz")
                            .foregroundColor(Colors.primary)
                            .bold()
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 8).fill(Colors.gray))
            ForEach(viewModel.mealLogs[meal]?.sorted(by: {$0.addDate < $1.addDate}) ?? [], id: \.id) { food in
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(food.name) (serving size: \(food.servingDescription))")
                                .foregroundColor(Colors.secondary)
                                .bold()
                        }
                        if meal != .water {
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
                        }
                        HStack {
                            Text("Servings:")
                                .foregroundColor(Colors.secondary)
                            TextField("", text: Binding(
                                get: {
                                    String(food.servings)
                                },
                                set: { newValue in
                                    var servingsToUpdate: Double = 1.0
                                    
                                    if let newDoubleValue = Double(newValue), newDoubleValue > 0 {
                                        servingsToUpdate = newDoubleValue
                                    } else if newValue.isEmpty {
                                        servingsToUpdate = 1.0
                                    }
                                    viewModel.updateFoodMacrosForServings(meal: meal, food: food, servings: servingsToUpdate)
                                }
                            ))
                            .fixedSize()
                            .accentColor(Colors.primary)
                            .keyboardType(.decimalPad)
                            .padding(8)
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
                .frame(maxWidth: .infinity)
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
                            .foregroundColor(Colors.primaryLight)
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
        }
    }
    
    var foodModalView: some View {
        VStack {
            Text("Search")
                .font(.title3)
                .foregroundColor(Colors.primary)
                .bold()
                .padding(.top)
            
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
            .background(Colors.secondary)
            
            if searchTab == 0 {
                searchFoodsView
            } else {
                searchMealsView
            }
            
            Spacer()
            fatSecretBadge
        }
        .background(Colors.secondary)
    }
    
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
            
            List(viewModel.searchResults, id: \.id) { food in
                Section {
                    Button(action: {
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
            
            List {
                let filteredMeals = mealSearchQuery.isEmpty ? viewModel.userMeals :
                viewModel.userMeals.filter { meal in
                    meal.name.lowercased().contains(mealSearchQuery.lowercased())
                }
                
                ForEach(filteredMeals, id: \.id) { meal in
                    Section {
                        Button(action: {
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
