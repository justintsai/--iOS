import Foundation
import UIKit

class DataManager {
    
    static let shared = DataManager()
    
    let baseID: String
    let apiKey: String
    
    init() {
        var fetchIdKey:[String] {
            guard let filePath = Bundle.main.path(forResource: "Airtable-Info", ofType: "plist") else {
                fatalError("Couldn't find file 'Airtable-Info.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let baseID = plist?.value(forKey: "Base ID") as? String else {
                fatalError("Couldn't find key 'Base ID' in 'Airtable-Info.plist'.")
            }
            guard let apiKey = plist?.value(forKey: "API Key") as? String else {
                fatalError("Couldn't find key 'API Key' in 'Airtable-Info.plist'.")
            }
            return [baseID, apiKey]
        }
        
        self.baseID = fetchIdKey[0]
        self.apiKey = fetchIdKey[1]
    }
    
    func fetchMenu(tableName: String, completion: @escaping(Result<[DrinkCategory], Error>) -> Void) {

//        let baseID = fetchIdKey[0]
//        let apiKey = fetchIdKey[1]
        
        let urlString = "https://api.airtable.com/v0/\(baseID)/\(tableName)"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let drinkData = try decoder.decode(DrinkData.self, from: data)
                        let drinks = self.parseDrinkData(drinkData)
                        let drinkCategories = self.getCategories(drinks)
                        completion(.success(drinkCategories))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        }
    }

    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
               let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func decodeJsonData<T: Decodable>(_ data: Data) -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError()
        }
    }
    
    func parseDrinkData(_ drinkData: DrinkData) -> [DrinkModel] {
        var drinks = [DrinkModel]()
        for record in drinkData.records {
            let M: Int? = record.fields.priceM
            let L: Int? = record.fields.priceL
            let iced: Bool? = record.fields.iced
            let sweet: Bool? = record.fields.sweet
            let drink = DrinkModel(
                name: record.fields.name,
                priceM: M,
                priceL: L,
                description: record.fields.description,
                category: record.fields.category,
                iced: iced,
                sweet: sweet,
                imageURL: record.fields.imageURL,
                thumbnailURL: record.fields.thumbnail.first!.thumbnails.large.url
            )
            drinks.append(drink)
        }
        return drinks
    }
    
    func getCategories(_ drinks: [DrinkModel]) -> [DrinkCategory] {
        var drinkCategories: [DrinkCategory] = []
        let categories = ["期間限定", "經典飲品"]
        for category in categories {
            drinkCategories += [DrinkCategory(name: category, drinks: [])]
        }
        
        for drink in drinks {
            if let categoryIndex = categories.firstIndex(of: drink.category) {
                drinkCategories[categoryIndex].drinks += [drink]
            }
        }
        return drinkCategories
    }
    
    // MARK: - Order
    func uploadOrder(order: OrderModel) {
        let orderData = serializeOrderModel(order)
        let url = URL(string: "https://api.airtable.com/v0/\(baseID)/Order")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.string(from: Date())
//        encoder.dateEncodingStrategy = .formatted(formatter)
        request.httpBody = try? encoder.encode(orderData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP response status code: \(httpResponse.statusCode)")
            }
            if let data = data, let content = String(data: data, encoding: .utf8) {
                print(content)
            }
        }.resume()
    }
    
    func serializeOrderModel(_ order: OrderModel) -> OrderData {
        let orderData = OrderData(
            records: [.init(fields: .init(
                customerName: order.customerName,
                drink: order.drink.name,
                sugar: order.sugar,
                ice: order.ice,
                toppings: order.toppings,
                count: order.count,
                size: order.size,
                total: order.total))]
        )
        return orderData
    }
}

