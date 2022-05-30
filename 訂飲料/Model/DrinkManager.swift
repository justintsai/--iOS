//
//  DrinkManager.swift
//  訂飲料
//
//  Created by 蔡念澄 on 2022/5/28.
//

import Foundation
import UIKit

class DrinkManager {
    
    static let shared = DrinkManager()
    
    func fetchIdKey() -> [String] {
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
    
    func fetchMenu(tableName: String, completion: @escaping (Result<[DrinkCategory], Error>) -> Void) {
        let credentials = fetchIdKey()
        let baseID = credentials[0]
        let apiKey = credentials[1]
        
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
            let drink = DrinkModel(
                name: record.fields.name,
                priceM: M,
                priceL: L,
                description: record.fields.description,
                category: record.fields.category,
                imageURL: record.fields.imageURL,
                thunbnailURL: record.fields.thumbnail.first!.thumbnails.large.url
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
}

