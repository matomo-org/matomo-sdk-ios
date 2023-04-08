//
//  ContentViewController.swift
//  ios
//
//  Created by miang on 20/6/2561 BE.
//  Copyright © 2561 Mattias Levin. All rights reserved.
//

import UIKit
import MatomoTracker

class ContentTrackerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MatomoTracker.shared.trackContentImpression(name: "Content name", piece: "button", target: "http://dn.se")
    }
    
    @IBAction func adInteraction(_ sender: Any) {
        MatomoTracker.shared.trackContentInteraction(name: "Content name", interaction: "click", piece: "button", target: "http://dn.se")
        UIApplication.shared.open(URL(string: "http://dn.se")!)
    }
}

