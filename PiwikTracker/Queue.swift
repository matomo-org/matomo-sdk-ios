//
//  EventQueue.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

/// An Element that is queueable.
protocol Queueable {
    /// A unique identifier. It should be unique per object.
    var id: UUID { get }
    
    /// This property is used to get the data that should be stored in the queue.
    var data: Data { get }
    
    /// This initializer is used when dequeueing.
    init?(data: Data)
}

/// A queue in which Objects that conform to queueable can be stored.
protocol Queue {
    /// The Item type have to conform to the Queueable protocol.
    associatedtype Item: Queueable
    
    /// The number of queud items.
    var itemCount: Int { get }
    
    /// Queues an Item.
    ///
    /// - Parameters:
    ///   - item: The Item to queue.
    ///   - completion: A closure to be called once queueing is completed.
    func queue(item: Item, completion: ()->())
    
    /// Dequeues and returns a certain amount of items.
    ///
    /// - Parameters:
    ///   - limit: The maximum amount of items to dequeue. May return less if less are queued.
    ///   - completion: A closure to be called once the elements are dequeued. The closure will be called with the dequeued items.
    func dequeue(withLimit limit: Int, completion: (_ items: [Item])->())
    
    /// Removes all items from the queue.
    func deleteAll()
}
