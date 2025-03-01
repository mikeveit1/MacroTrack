//
//  FoodHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 2/28/25.
//

import Foundation
import FatSecretSwift

class FoodHelper: ObservableObject {
    
    let apiKey = "d0439c098ae940d4845d84f57a1e6312" // Set your API key here
    let apiSecret = "2c59553aefc64fe29ea4215d1dab1056" // Set your API secret here
    
    // Create a FatSecret client
    let fatSecretClient = FatSecretClient()
    
    // No need for override init, initialization is done here
    init() {
        // Set credentials for the FatSecret API
        FatSecretCredentials.setConsumerKey(apiKey)
        FatSecretCredentials.setSharedSecret(apiSecret)
    }
    
    // Search for foods by name
    func searchFood(query: String, completion: @escaping ([SearchedFood]) -> Void) {
        fatSecretClient.searchFood(name: query) { search in
            completion(search.foods)
        }
    }
    
    func convertSearchFoodToMacroFood(searchedFood: SearchedFood, completion: @escaping (MacroFood) -> Void) {
        fatSecretClient.getFood(id: searchedFood.id) { food in
            self.getMacros(food: food) { macros in
                completion(MacroFood(id: food.id, name: food.name, macronutrients: macros, servingDescription: food.servings?[0].servingDescription ?? ""))
            }
        }
    }
    
    func getMacros(food: Food, completion: @escaping(MacronutrientInfo) -> Void) {
        completion(MacronutrientInfo(calories: food.servings?[0].calories ?? "", protein: food.servings?[0].protein ?? "", carbs: food.servings?[0].carbohydrate ?? "", fat: food.servings?[0].fat ?? ""))
    }
}
