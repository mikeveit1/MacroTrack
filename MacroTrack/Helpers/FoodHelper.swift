import FatSecretSwift
import SwiftUI

class GetFoods: ObservableObject {

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
    func searchFood(query: String, completion: @escaping ([String]) -> Void) {
        fatSecretClient.searchFood(name: query) { search in
            let foodNames = search.foods.map { $0.name }
            completion(foodNames)
        }
    }
}
