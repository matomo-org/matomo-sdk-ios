//
//  EventQueueVolatile.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

class EventQueueVolatile: EventQueue {
    
    var events = [[String:String]]()
    
    func storeEvent(withParameters parameters: [String:String], completion: ()->()) {
        events.append(parameters)
        completion()
    }
    
    func events(withLimit limit: UInt8, completion: (_ entityIds: [EntityId], _ events: [[String:String]], _ hasMore: Bool)->()) {
        completion([], events, false)
    }
    
    func deleteEvents(withEntityIds entityIds: [EntityId]) { }
}
