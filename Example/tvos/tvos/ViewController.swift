//
//  ViewController.swift
//  tvos
//
//  Created by Cornelius Horstmann on 05.06.17.
//  Copyright © 2017 Piwik. All rights reserved.
//

import UIKit
import MatomoTracker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MatomoTracker.configureSharedInstance(withSiteID: "<id>", baseURL: URL(string:"http://example.com/piwik.php")!)
        MatomoTracker.shared?.track(view: ["start"])
        MatomoTracker.shared?.dispatch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
