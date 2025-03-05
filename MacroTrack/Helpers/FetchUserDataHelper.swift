//
//  FetchUserDataHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/5/25.
//

import Foundation

class FetchUserDataHelper {
    func fetchMacroGoals(completion: @escaping([String: Int]) -> Void) {
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            return
        }
        FirebaseService.shared.fetchUserMacroData() { data in
            let dailyGoals = [
                "calories": data?.totalCalories ?? 2000,  // Example: 2000 calories
                "protein": data?.protein ?? 150,    // Example: 150g protein
                "carbs": data?.carbs ?? 250,      // Example: 250g carbs
                "fat": data?.fat ?? 70          // Example: 70g fat
            ]
            completion(dailyGoals)
        }
    }
}
