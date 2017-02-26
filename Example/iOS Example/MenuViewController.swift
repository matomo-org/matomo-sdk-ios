//
//  MenuViewController.swift
//  Example
//
//  Created by Cornelius Horstmann on 26.02.17.
//  Copyright © 2017 Mattias Levin. All rights reserved.
//

import UIKit
import PiwikTracker

class MenuViewController: UITableViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tracker.sharedInstance?.track(view: ["menu"])
    }
}
