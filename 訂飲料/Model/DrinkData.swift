import Foundation

struct DrinkData: Codable {
    let records: [Record]

    struct Record: Codable {
        let fields: Fields
    }

    struct Fields: Codable {
        let name: String
        let priceM: Int?
        let priceL: Int?
        let description: String
        let category: String
        let iced: Bool?
        let sweet: Bool?
        let imageURL: URL
        let thumbnail: [Thumbnails]
    }
    
    struct Thumbnails: Codable {
        let thumbnails: Sizes
    }
    
    struct Sizes: Codable {
        let large: Details
    }
    
    struct Details: Codable {
        let url: URL
    }
}
