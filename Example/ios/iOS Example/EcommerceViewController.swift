//
//  EcommerceViewController.swift
//  iOSExampleApp
//
//  Created by Cornelius Horstmann on 05.09.24.
//  Copyright © 2024 Mattias Levin. All rights reserved.
//

import UIKit
import MatomoTracker

class EcommerceViewController: UIViewController {
    @IBOutlet weak var itemCountStepper: UIStepper!

    @IBOutlet weak var numberOfItemsTextField: UITextField!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var shippingCostLabel: UILabel!
    
    private var total: Double {
        itemCountStepper.value * 3.0
    }
    private var tax: Double {
        total * 0.3
    }
    private var shipping: Double {
        max(1, itemCountStepper.value / 3.0) * 0.1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MatomoTracker.shared.track(view: ["menu","ecommerce"])
    }
    
    @IBAction func itemCountValueChanged(_ stepper: UIStepper) {
        numberOfItemsTextField.text = String(format: "%.0f", stepper.value)
        
        totalCostLabel.text = String(format: "%.2f", total)
        taxLabel.text = String(format: "%.2f", tax)
        shippingCostLabel.text = String(format: "%.2f", shipping)
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        let orderItem = OrderItem(sku: "SKU123", name: "Cookies", category: "Food", price: 1.0, quantity: Int(itemCountStepper.value))
        MatomoTracker.shared.trackOrder(id: "Trans-\(arc4random_uniform(1000))", items: [orderItem], revenue: Float(total))
    }
    
}

