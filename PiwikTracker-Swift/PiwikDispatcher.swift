//
//  PiwikDispatcher.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 07.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

public protocol PiwikDispatcher {
    
    var userAgent: String? { get set }
    
    func sendEvent(with parameters: [AnyHashable:AnyObject], success: ()->(), failure: ()->(Bool));
    func sendBulkEvent(with parameters: [AnyHashable:AnyObject], success: ()->(), failure: ()->(Bool));
}
