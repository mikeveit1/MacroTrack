//
//  FetchUserDataHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/5/25.
//

import Foundation

class FetchUserDataHelper {
    func fetchMacroGoals(completion: @escaping([String: Int]) -> Void) {
        FirebaseService.shared.fetchUserMacroData() { data in
            let dailyGoals = [
                "calories": data?.totalCalories ?? 2000,
                "protein": data?.protein ?? 150,
                "carbs": data?.carbs ?? 250,
                "fat": data?.fat ?? 70,
                "water": data?.water ?? 128,
            ]
            completion(dailyGoals)
        }
    }
    
    func fetchFitnessGoal(completion: @escaping(String) -> Void) {
        FirebaseService.shared.fetchUserMacroData() { data in
            let fitnessGoal = data?.fitnessGoal ?? ""
            completion(fitnessGoal)
        }
    }
}
