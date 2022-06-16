import Foundation

struct OrderModel {
    var id: String? = nil
    var customerName: String = ""
    var drink: DrinkModel
    var sugar: String
    var ice: String
    var toppings: [String]?
    var count: Int
    var size: String
    var total: Int = 0
    
    mutating func updateTotal(count: Int) {
        var toppingPrice = 0
        if let toppings = toppings {
            for topping in toppings {
                toppingPrice += toppingDict[topping] ?? 0
            }
        }
        total = ((size == "M" ? drink.priceM! : drink.priceL!) + toppingPrice) * count
    }
}
