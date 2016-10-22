//
//  EventQueueVolatile.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

class EventQueueVolatile: EventQueue {
    
    var eventCount: UInt32 { get {
        return UInt32(events.count)
        }}
    
    var events = [Event]()
    
    func storeEvent(event: Event, completion: ()->()) {
        events.append(event)
        completion()
    }
    
    func events(withLimit limit: UInt8, completion: (_ entityIds: [EntityId], _ events: [Event], _ hasMore: Bool)->()) {
        let uuids = events.map({ $0.uuid })
        completion(uuids, events, false)
    }
    
    func deleteEvents(withUUIDs uuids: [String]) {
        events = events.filter({ !uuids.contains($0.uuid) })
    }
    
    func deleteAllEvents() {
        events = []
    }
}
