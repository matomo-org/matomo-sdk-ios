//
//  EventQueue.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

typealias EntityId = String

protocol EventQueue {
    var eventCount: UInt32 { get }
    
    func storeEvent(event: Event, completion: ()->())
    func events(withLimit limit: UInt8, completion: (_ entityIds: [EntityId], _ events: [Event], _ hasMore: Bool)->())
    
    func deleteEvents(withEntityIds entityIds: [EntityId])
    func deleteAllEvents()
}
