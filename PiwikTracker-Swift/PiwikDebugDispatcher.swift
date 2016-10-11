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
            debugPrint("Set custom user agent: \(userAgent)")
        }
    }
    
    func sendEvent(with parameters: [AnyHashable:AnyObject], success: ()->(), failure: (Bool)->()) {
        debugPrint("Request: \(parameters)")
        success()
    }
    
    func sendBulkEvent(with parameters: [AnyHashable:AnyObject], success: ()->(), failure: (Bool)->()) {
        debugPrint("Request: \(parameters)")
        success()
    }
}
