//
//  FoodHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import Foundation
import FatSecretSwift

class FoodHelper: ObservableObject {
    let fatSecretClient = FatSecretClient()

    init() {
        FirebaseService.shared.getFatSecretKey { key in
            FatSecretCredentials.setConsumerKey(key)
        }
        FirebaseService.shared.getFatSecretSecret { secret in
            FatSecretCredentials.setSharedSecret(secret)
        }
    }
    
    func searchFood(query: String, completion: @escaping ([SearchedFood]) -> Void) {
        fatSecretClient.searchFood(name: query) { search in
            completion(search.foods)
        }
    }
    
    func convertSearchFoodToMacroFood(searchedFood: SearchedFood, completion: @escaping (MacroFood) -> Void) {
        fatSecretClient.getFood(id: searchedFood.id) { food in
            self.getMacros(food: food) { macros in
                completion(MacroFood(id: food.id, name: food.name, macronutrients: macros, originalMacros: macros, servingDescription: food.servings?[0].servingDescription ?? "", servings: 1.0, addDate: Date()))
            }
        }
    }
    
    func getMacros(food: Food, completion: @escaping(MacronutrientInfo) -> Void) {
        completion(MacronutrientInfo(
            calories: Double(food.servings?[0].calories ?? "") ?? 0,
            protein: (Double(food.servings?[0].protein ?? "") ?? 0).rounded(toPlaces: 2),
            carbs: (Double(food.servings?[0].carbohydrate ?? "") ?? 0).rounded(toPlaces: 2),
            fat: (Double(food.servings?[0].fat ?? "") ?? 0).rounded(toPlaces: 2)
        ))
        
    }
    
    func getOriginalFood(id: String, completion: @escaping (MacroFood) -> Void) {
        fatSecretClient.getFood(id: id) { food in
            self.getMacros(food: food) { macros in
                completion(MacroFood(id: food.id, name: food.name, macronutrients: macros, originalMacros: macros, servingDescription: food.servings?[0].servingDescription ?? "", servings: 1.0, addDate: Date()))
            }
        }
    }
}
