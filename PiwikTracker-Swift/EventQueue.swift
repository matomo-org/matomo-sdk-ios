//
//  EventQueue.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

typealias EntityId = AnyObject

protocol EventQueue {
    
    func storeEvent(withParameters parameters: [String:String], completion: ()->())
    func events(withLimit limit: UInt8, completion: (_ entityIds: [EntityId], _ events: [[String:String]], _ hasMore: Bool)->())
    
    func deleteEvents(withEntityIds entityIds: [EntityId])
    func deleteAllEvents()
}
