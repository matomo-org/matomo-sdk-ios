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
    
    func send(event: Event, success: ()->(), failure: (Bool)->());
    func send(events: [Event], success: ()->(), failure: (Bool)->());
}
