import Foundation

enum IceLevel: String, CaseIterable {
    case 正常冰, 少冰, 微冰, 去冰, 完全去冰, 常溫, 溫, 熱
}

enum SugarLevel: String, CaseIterable {
    case 正常糖
    case 少糖
    case 半糖
    case 微糖
    case 二分糖
    case 一分糖
    case 無糖
}

//enum Toppings: Int, CaseIterable {
//    case 白玉, 水玉 = 10
//    case 百香蒟蒻凍 = 20
//}

let toppingDict: [String:Int] = ["白玉":10, "水玉":10, "百香蒟蒻凍":20]
