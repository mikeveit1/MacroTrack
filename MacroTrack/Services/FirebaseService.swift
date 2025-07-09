//
//  FirebaseService.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import FirebaseDatabase
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Database.database().reference()

    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func saveProgressBarData(progressBarData: [String: Bool], completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("progressBarData").setValue(progressBarData) { error, _ in
            self.handleFirebaseError(error, completion: completion)
        }
    }
    
    func fetchProgressBarData(completion: @escaping ([String: Bool]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("progressBarData").observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Bool] {
                completion(data, nil)
            } else {
                completion(nil, nil)
            }
        })
    }

    func saveFoodLog(date: String, foodLogData: [String: Any], completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("foodLogs").child(date).setValue(foodLogData) { error, _ in
            self.handleFirebaseError(error, completion: completion)
        }
    }
    
    func saveFoodToMeal(date: String, meal: String, food: MacroFood, completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(food)
            let foodDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            db.child("users").child(userID).child("foodLogs").child(date).child(meal).child(food.id).setValue(foodDict) { error, _ in
                self.handleFirebaseError(error, completion: completion)
            }
        } catch let error {
            completion(false, error)
        }
    }
    
    func updateFood(date: String, meal: String, food: MacroFood, completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        do {
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(food)
            let foodDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            db.child("users").child(userID).child("foodLogs").child(date).child(meal).child(food.id).setValue(foodDict) { error, _ in
                self.handleFirebaseError(error, completion: completion)
            }
        } catch let error {
            completion(false, error)
        }
    }
    
    func getFoodLog(date: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("foodLogs").child(date).observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                completion(data, nil)
            } else {
                completion(nil, nil)
            }
        })
    }
    
    func getAllFoodLogs(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("foodLogs").observe(.value, with: { snapshot in
            if let foodLogs = snapshot.value as? [String: [String: Any]] {
                completion(foodLogs, nil)
            } else {
                completion(nil, nil)
            }
        })
    }
    
    func getFoodForMeal(date: String, meal: String, completion: @escaping ([MacroFood]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("foodLogs").child(date).child(meal).observe(.value, with: { snapshot in
            if snapshot.exists() {
                var foods: [MacroFood] = []
                
                if let mealData = snapshot.value as? [String: [String: Any]] {
                    for (_, foodData) in mealData {
                        do {
                            let data = try JSONSerialization.data(withJSONObject: foodData, options: [])
                            let decoder = JSONDecoder()
                            let food = try decoder.decode(MacroFood.self, from: data)
                            foods.append(food)
                        } catch let error {
                            print("Error decoding food: \(error)")
                        }
                    }
                }
                completion(foods, nil)
            } else {
                completion(nil, nil)
            }
        })
    }
    
    func updateUserMacroData(userMacroData: UserMacroData) {
        guard let userID = getCurrentUserID() else { return }
        let userMacroDataRef = db.child("users").child(userID).child("macroData")
        let updatedValues: [String: Any] = [
            "weight": userMacroData.weight,
            "height": userMacroData.height,
            "age": userMacroData.age,
            "gender": userMacroData.gender,
            "activityLevel": userMacroData.activityLevel,
            "fitnessGoal": userMacroData.fitnessGoal,
            "totalCalories": userMacroData.totalCalories,
            "protein": userMacroData.protein,
            "carbs": userMacroData.carbs,
            "fat": userMacroData.fat
        ]
        
        userMacroDataRef.updateChildValues(updatedValues) { error, _ in
            if let error = error {
                print("Error updating user macro data: \(error.localizedDescription)")
            } else {
                print("User macro data updated successfully!")
            }
        }
    }

    
    func updateDailyGoals(dailyGoals: [String: Int]) {
        guard let userID = getCurrentUserID() else { return }
        let userMacroDataRef = db.child("users").child(userID).child("macroData")
        
        userMacroDataRef.updateChildValues([
            "totalCalories": dailyGoals["calories"] ?? 0,
            "protein": dailyGoals["protein"] ?? 0,
            "carbs": dailyGoals["carbs"] ?? 0,
            "fat": dailyGoals["fat"] ?? 0,
            "water": dailyGoals["water"] ?? 128
        ]) { error, _ in
            if let error = error {
                print("Error updating user macro data: \(error.localizedDescription)")
            } else {
                print("User macro data updated successfully!")
            }
        }
    }
    
    func saveUserMeal(mealName: String, meal: Meal, foodsList: [[String: Any]]) {
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            print("No user is logged in")
            return
        }
        
        let mealID = UUID().uuidString
        let mealRef = db.child("users").child(userID).child("meals").child(mealID)
        
        let mealData: [String: Any] = [
            "id": mealID,
            "mealName": mealName,
            "foods": foodsList,
            "createdAt": "\(Date())"
        ]
        
        mealRef.setValue(mealData) { error, _ in
            if let error = error {
                print("Error saving meal to Firebase: \(error.localizedDescription)")
            } else {
                print("Meal saved to Firebase successfully!")
            }
        }
    }
    
    func fetchSavedMealsFromFirebase(completion: @escaping ([UserMeal]) -> Void) {
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            print("No user is logged in")
            return
        }

        let mealsRef = db.child("users").child(userID).child("meals")
        mealsRef.observe(.value, with: { snapshot in
            var meals: [UserMeal] = []

            for childSnapshot in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                if let mealData = childSnapshot.value as? [String: Any] {
                    if let mealName = mealData["mealName"] as? String,
                       let mealId = mealData["id"] as? String,
                       let foodsData = mealData["foods"] as? [[String: Any]] {
                        var foods: [MacroFood] = []
                        
                        for foodData in foodsData {
                            if let name = foodData["name"] as? String,
                               let id = foodData["id"] as? String,
                               let servingDescription = foodData["servingDescription"] as? String,
                               let macronutrients = foodData["macronutrients"] as? [String: Any],
                               let originalMacros = foodData["originalMacros"] as? [String: Any],
                               let servings = foodData["servings"] as? Double,
                               let addDateString = foodData["addDate"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let addDate = dateFormatter.date(from: addDateString)

                                let macronutrientInfo = MacronutrientInfo(
                                    calories: macronutrients["calories"] as? Double ?? 0,
                                    protein: macronutrients["protein"] as? Double ?? 0,
                                    carbs: macronutrients["carbs"] as? Double ?? 0,
                                    fat: macronutrients["fat"] as? Double ?? 0
                                )
                                
                                let originalMacronutrientInfo = MacronutrientInfo(
                                    calories: originalMacros["calories"] as? Double ?? 0,
                                    protein: originalMacros["protein"] as? Double ?? 0,
                                    carbs: originalMacros["carbs"] as? Double ?? 0,
                                    fat: originalMacros["fat"] as? Double ?? 0
                                )
                                
                                let macroFood = MacroFood(
                                    id: id,
                                    name: name,
                                    macronutrients: macronutrientInfo,
                                    originalMacros: originalMacronutrientInfo,
                                    servingDescription: servingDescription,
                                    servings: servings,
                                    addDate: addDate ?? Date()
                                )
                                
                                foods.append(macroFood)
                            }
                        }
                        
                        let userMeal = UserMeal(id: mealId, name: mealName, foods: foods)
                        meals.append(userMeal)
                    }
                }
            }
            completion(meals)
        })
    }
    
    func fetchUserMacroData(completion: @escaping (UserMacroData?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        let userMacroDataRef = db.child("users").child(userID).child("macroData")
        
        userMacroDataRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                if let data = snapshot.value as? [String: Any] {
                    let userMacroData = UserMacroData(
                        weight: data["weight"] as? Double ?? 0,
                        height: data["height"] as? Double ?? 0,
                        age: data["age"] as? Int ?? 0, 
                        gender: data["gender"] as? String ?? "",
                        activityLevel: data["activityLevel"] as? String ?? "",
                        fitnessGoal: data["fitnessGoal"] as? String ?? "",
                        totalCalories: data["totalCalories"] as? Int ?? 0,
                        protein: data["protein"] as? Int ?? 0,
                        carbs: data["carbs"] as? Int ?? 0,
                        fat: data["fat"] as? Int ?? 0,
                        water: data["water"] as? Int ?? 128
                    )
                    completion(userMacroData)
                } else {
                    print("Data format is incorrect")
                    completion(nil)
                }
            } else {
                print("Document does not exist or error occurred")
                completion(nil)
            }
        })
    }
    
    func deleteFoodFromFirebase(date: String, meal: String, food: MacroFood, completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("foodLogs").child(date).child(meal).child(food.id).removeValue { error, _ in
            self.handleFirebaseError(error, completion: completion)
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
                self.db.child("users").child(result?.user.uid ?? "").child("id").setValue(result?.user.uid) { error, _ in
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            if result != nil {
                completion(true, nil)
            } else {
                completion(false, "Unexpected error")
            }
        }
    }
    
    func getLink(linkName: String, completion: @escaping (String) -> Void) {
        db.child("links").child(linkName).observe(.value, with: { snapshot in
            let link = snapshot.value as? String ?? ""
            completion(link)
        })
    }
    
    func signOut(completion: @escaping (Bool, Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true, nil)
        } catch let signOutError as NSError {
            completion(false, signOutError)
        }
    }
    
    func deleteAccount(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false, NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in."]))
            return
        }
        
        let id = currentUser.uid
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error)
            } else {
                self.db.child("users").child(id).setValue(nil) { error, _ in
                    if let error = error {
                        print("Failed to delete user data from database: \(error.localizedDescription)")
                    } else {
                        currentUser.delete { error in
                            if let error = error {
                                completion(false, error)
                            } else {
                                completion(true, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getFatSecretKey(completion: @escaping (String) -> Void) {
        db.child("secret").child("key").observe(.value, with: { snapshot in
            let key = snapshot.value as? String ?? ""
            completion(key)
        })
    }
    
    func getFatSecretSecret(completion: @escaping (String) -> Void) {
        db.child("secret").child("secret").observe(.value, with: { snapshot in
            let secret = snapshot.value as? String ?? ""
            completion(secret)
        })
    }
    
    private func handleFirebaseError(_ error: Error?, completion: @escaping (Bool, Error?) -> Void) {
        if let error = error {
            completion(false, error)
        } else {
            completion(true, nil)
        }
    }
}
