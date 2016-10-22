//
//  PiwikDebugDispatcher.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 07.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

internal class PiwikDebugDispatcher: PiwikDispatcher {
    var userAgent: String? {
        didSet {
            print("Set custom user agent: \(userAgent)")
        }
    }
    
    func send(event: Event, success: ()->(), failure: (Bool)->()) {
        print("Request: \(event)")
        success()
    }
    
    func send(events: [Event], success: ()->(), failure: (Bool)->()) {
        for event in events {
            print("Request: \(event)")
        }
        success()
    }
}
