import Foundation
import UIKit

class DataManager {
    
    static let shared = DataManager()
    
    let baseID: String
    let apiKey: String
    var drinks: [DrinkModel] = []
    
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
    
    func fetchMenu(completion: @escaping (Result<[DrinkCategory], Error>) -> Void) {
        let urlString = "https://api.airtable.com/v0/\(baseID)/Menu"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let drinkData = try decoder.decode(DrinkData.self, from: data)
                        self.drinks = self.parseDrinkData(drinkData)
                        let drinkCategories = self.getCategories(self.drinks)
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
    func uploadOrder(order: OrderModel, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        let orderData = serializeOrderModel(order)
        guard let url = URL(string: "https://api.airtable.com/v0/\(baseID)/Order") else {
            completion(.failure(.invalidUrl))
            return
        }
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
                completion(.failure(.requestFailed(error)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            guard data != nil else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
    func serializeOrderModel(_ order: OrderModel) -> OrderData {
        let orderData = OrderData(
            records: [.init(
                id: nil,
                fields: .init(
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
    
    func fetchOrder(completion: @escaping (Result<[OrderModel], Error>) -> Void) {
        let urlString = "https://api.airtable.com/v0/\(baseID)/Order?sort[][field]=orderNo&sort[][direction]=asc"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let orderData = try decoder.decode(OrderData.self, from: data)
                        let orders = self.parseOrderData(orderData)
                        completion(.success(orders))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func parseOrderData(_ orderData: OrderData) -> [OrderModel] {
        var orders = [OrderModel]()
        for record in orderData.records {
            let toppings: [String]? = record.fields.toppings
            let drink: DrinkModel = drinks.first(where: {$0.name == record.fields.drink})!
            let order = OrderModel(
                id: record.id,
                customerName: record.fields.customerName,
                drink: drink,
                sugar: record.fields.sugar,
                ice: record.fields.ice,
                toppings: toppings,
                count: record.fields.count,
                size: record.fields.size,
                total: record.fields.total
            )
            orders.append(order)
        }
        return orders
    }
    
    func deleteOrder(_ order: OrderModel) {
        if let url = URL(string: "https://api.airtable.com/v0/\(baseID)/Order/" + order.id!) {
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "DELETE"
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let response = response as? HTTPURLResponse, error == nil {
                    print(response.statusCode)
                    print("Deleted successfully")
                } else if let error = error {
                    print(error)
                }
            }.resume()
        }
    }
}

enum NetworkError: Error {
    case invalidUrl
    case requestFailed(Error)
    case invalidData
    case invalidResponse
}
