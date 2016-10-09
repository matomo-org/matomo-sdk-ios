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
    public var lastParameters: [AnyHashable:AnyObject]? = nil
    
    var userAgent: String?
    
    func sendEvent(with parameters: [AnyHashable:AnyObject], success: ()->(), failure: ()->(Bool)) {
        lastParameters = parameters
        numberOfCalls += 1
        success()
    }
    
    func sendBulkEvent(with parameters: [AnyHashable:AnyObject], success: ()->(), failure: ()->(Bool)) {
        lastParameters = parameters
        numberOfCalls += 1
        success()
    }
    
}
