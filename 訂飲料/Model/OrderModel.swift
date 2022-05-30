//
//  OrderModel.swift
//  訂飲料
//
//  Created by 蔡念澄 on 2022/5/28.
//

import Foundation

struct OrderModel {
    let orderNo: String
    let customerName: String
    let drink: String
    let sugar: String
    let ice: String
    let toppings: [String]?
    let count: Int
    let size: String
    let total: Int
}
