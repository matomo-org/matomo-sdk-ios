//
//  ViewController.swift
//  macos
//
//  Created by Cornelius Horstmann on 07.05.17.
//  Copyright © 2017 Piwik. All rights reserved.
//

import Cocoa
import MatomoTracker

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        MatomoTracker.configureSharedInstance(withSiteID: "<id>", baseURL: URL(string:"http://example.com/piwik.php")!)
        MatomoTracker.shared?.track(view: ["start"])
        MatomoTracker.shared?.dispatch()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

