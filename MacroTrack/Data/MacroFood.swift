import Foundation

struct MacroFood: Identifiable, Hashable, Equatable, Codable {
    var id: String
    var name: String
    var macronutrients: MacronutrientInfo
    var servingDescription: String
    
    // Conforming to Equatable by comparing id
    static func == (lhs: MacroFood, rhs: MacroFood) -> Bool {
        return lhs.id == rhs.id
    }

    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
