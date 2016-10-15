//
//  PiwikDispatcherStub.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation
import PiwikTrackerSwift

class PiwikDispatcherStub : PiwikDispatcher {
    
    public var numberOfCalls: UInt = 0
    public var lastParameters: [String:String]? = nil
    
    var userAgent: String?
    
    func send(event: Event, success: ()->(), failure: (Bool)->()) {
        lastParameters = event.dictionary
        numberOfCalls += 1
        success()
    }
    
    func send(events: [Event], success: ()->(), failure: (Bool)->()) {
        lastParameters = events.first!.dictionary
        numberOfCalls += 1
        success()
    }
    
}
