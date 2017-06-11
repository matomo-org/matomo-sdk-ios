//
//  ViewController.swift
//  macos
//
//  Created by Cornelius Horstmann on 07.05.17.
//  Copyright © 2017 Piwik. All rights reserved.
//

import Cocoa
import PiwikTracker

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        PiwikTracker.configureSharedInstance(withSiteID: "<id>", baseURL: URL(string:"http://example.com/piwik.php")!)
        PiwikTracker.shared?.track(view: ["start"])
        PiwikTracker.shared?.dispatch()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

