import Foundation

/// Order item as described in: https://matomo.org/docs/ecommerce-analytics/#tracking-ecommerce-orders-items-purchased-required
public struct OrderItem {
    
    /// The SKU of the order item
    let sku: String
    
    /// The name of the order item
    let name: String
    
    /// The category of the order item
    let category: String
    
    /// The price of the order item
    let price: Float
    
    /// The quantity of the order item
    let quantity: Int
    
    public init(sku: String, name: String, category: String, price: Float, quantity: Int) {
        self.sku = sku
        self.name = name
        self.category = category
        self.price = price
        self.quantity = quantity
    }
}
