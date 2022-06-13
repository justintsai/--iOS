import Foundation

struct OrderData: Codable {
    let records: [Record]

    struct Record: Codable {
        let fields: Fields
    }

    struct Fields: Codable {
//        let orderNo: String?
        let customerName: String
        let drink: String
        let sugar: String
        let ice: String
        let toppings: [String]?
        let count: Int
        let size: String
        let total: Int
    }
}
