//
//  GoalsViewController.swift
//  ios
//
//  Created by Cornelius Horstmann on 08.10.18.
//  Copyright © 2018 Mattias Levin. All rights reserved.
//

import UIKit
import MatomoTracker

class GoalsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        MatomoTracker.shared.track(view: ["menu","goals"])
    }
    
    @IBAction func donateButtonTapped(_ sender: Any) {
       MatomoTracker.shared.trackGoal(id: 1, revenue: 5)
    }
    
}

