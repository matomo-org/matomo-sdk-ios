//
//  PiwikTrackedViewController.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 07.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import UIKit


/// Controllers that inherit from this view controller with send a screen view event to Piwik each time the controller did show.
/// The tracker will use the trackedViewName as the screen view name or if that is not set the title of the controller. If neither is set, not event will be send.
public class PiwikTrackedViewController: UIViewController {
    
    /// The screen view name that will be used in the event sent to Piwik.
    /// If not set the controllers title will be used.
    public var trackedViewName: String?
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let trackedViewName = self.trackedViewName ?? self.title {
            // FIXME: add tracking here
            // [[PiwikTracker sharedInstance] sendView:name];
        }
    }

}
