//
//  ViewController.swift
//  tvos
//
//  Created by Cornelius Horstmann on 05.06.17.
//  Copyright © 2017 Piwik. All rights reserved.
//

import UIKit
import PiwikTracker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Tracker.configureSharedInstance(withSiteID: "5", baseURL: URL(string:"http://piwik.tboprojects.de/piwik.php")!)
        Tracker.shared?.track(view: ["start"])
        Tracker.shared?.dispatch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
