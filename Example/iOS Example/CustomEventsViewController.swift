//
//  CustomEventsViewController.swift
//  Example
//
//  Created by Cornelius Horstmann on 03.06.17.
//  Copyright © 2017 Mattias Levin. All rights reserved.
//

import UIKit
import PiwikTracker

class CustomEventsViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PiwikTracker.shared?.track(view: ["menu","custom event"])
    }
    
    @IBAction func trackCustomEventButtonTapped(_ sender: Any) {
        guard let tracker = PiwikTracker.shared else { return }
        let downloadURL = URL(string: "https://builds.piwik.org/piwik.zip")!
        let event = tracker.event().setting(url: downloadURL).setting(customTrackingParameters: ["download":downloadURL.absoluteString])
        tracker.track(event)
    }
}
