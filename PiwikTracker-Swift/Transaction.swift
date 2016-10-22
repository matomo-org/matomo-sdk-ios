//
//  Transaction.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 22.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

public class TransactionItem: NSObject {
    let sku: String
    let name: String
    let category: String
    let price: Float
    let quantity: UInt32
    
    init(sku: String, name: String, category: String, price: Float, quantity: UInt32) {
        self.sku = sku
        self.name = name
        self.category = category // are there more than one?
        self.price = price
        self.quantity = quantity
    }
    
    func asArray() -> [String] {
        return [sku, name, category, "\(price)", "\(quantity)"]
    }
}

// two things I am thinking about:
// - should we calculate revenue, tax, ... from the items?
// - should we make the items editable (add items?)
public class Transaction: NSObject {
    let identifier: String
    let revenue: Float
    let tax: Float
    let shippingCost: Float
    let discount: Float
    let subTotal: Float
    
    let items: [TransactionItem]
    
    convenience init(identifier: String, revenue: Float, tax: Float, shippingCost: Float, discount: Float, items: [TransactionItem]) {
        self.init(identifier: identifier, revenue: revenue, tax: tax, shippingCost: shippingCost, discount: discount, subTotal: revenue - shippingCost, items: items)
    }
    
    init(identifier: String, revenue: Float, tax: Float, shippingCost: Float, discount: Float, subTotal: Float, items: [TransactionItem]) {
        self.identifier = identifier
        self.revenue = revenue
        self.tax = tax
        self.shippingCost = shippingCost
        self.discount = discount
        self.subTotal = subTotal
        self.items = items
    }
    
}
