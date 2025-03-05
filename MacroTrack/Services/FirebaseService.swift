import FirebaseDatabase
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService() // Singleton
    
    private let db = Database.database().reference()
    
    // Get current user ID from Firebase Authentication
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
    
    // Save daily goals to Firebase Realtime Database
    func saveDailyGoals(goals: [String: Int], completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("dailyGoals").setValue(goals) { error, _ in
            self.handleFirebaseError(error, completion: completion)
        }
    }
    
    // Get daily goals from Firebase Realtime Database
    func getDailyGoals(completion: @escaping ([String: Double]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("dailyGoals").observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Double] {
                completion(data, nil)
            } else {
                completion(nil, nil)
            }
        })
    }
    
    // Save food log to Firebase Realtime Database
    func saveFoodLog(date: String, foodLogData: [String: Any], completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        db.child("users").child(userID).child("foodLogs").child(date).setValue(foodLogData) { error, _ in
            self.handleFirebaseError(error, completion: completion)
        }
    }
    
    // Save food to a meal in Firebase Realtime Database
    func saveFoodToMeal(date: String, meal: String, food: MacroFood, completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }
        do {
            // The food object passed in here should have the updated servings and macronutrients
            let encoder = JSONEncoder()
            // Encode the MacroFood object to JSON data
            let data = try encoder.encode(food)
            
            // Convert the JSON data to a dictionary
            let foodDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            print(foodDict)  // For debugging purposes, you can check the dictionary
            
            // Save the food data to Firebase
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
    
    // Get food log from Firebase Realtime Database
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
    
    // Get food for a meal from Firebase Realtime Database
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
    
    // Update user macro data in Firebase
    func updateUserMacroData(userMacroData: UserMacroData) {
        guard let userID = getCurrentUserID() else { return }
        let userMacroDataRef = db.child("users").child(userID).child("macroData")
        
        userMacroDataRef.setValue([
            "weight": userMacroData.weight,
            "height": userMacroData.height,
            "age": userMacroData.age,
            "activityLevel": userMacroData.activityLevel,
            "fitnessGoal": userMacroData.fitnessGoal,
            "totalCalories": userMacroData.totalCalories,
            "protein": userMacroData.protein,
            "carbs": userMacroData.carbs,
            "fat": userMacroData.fat
        ]) { error, _ in
            if let error = error {
                print("Error updating user macro data: \(error.localizedDescription)")
            } else {
                print("User macro data updated successfully!")
            }
        }
    }
    
    // Fetch user macro data from Firebase
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
                        activityLevel: data["activityLevel"] as? String ?? "",
                        fitnessGoal: data["fitnessGoal"] as? String ?? "",
                        totalCalories: data["totalCalories"] as? Int ?? 0,
                        protein: data["protein"] as? Int ?? 0,
                        carbs: data["carbs"] as? Int ?? 0,
                        fat: data["fat"] as? Int ?? 0
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
    
    // Delete food from Firebase Realtime Database
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
                completion(false, error.localizedDescription) // Sign-up failed
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
            // On successful sign-in
            if result != nil {
                completion(true, nil)
            } else {
                completion(false, "Unexpected error")
            }
        }
    }
    
    // Helper function to handle Firebase error
    private func handleFirebaseError(_ error: Error?, completion: @escaping (Bool, Error?) -> Void) {
        if let error = error {
            print("Firebase Error: \(error.localizedDescription)")
            completion(false, error)
        } else {
            completion(true, nil)
        }
    }
}
