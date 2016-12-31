import Foundation

protocol Queue {
    associatedtype T
    /// The number of queued items.
    var itemCount: Int { get }
    
    /// Queues an Item.
    ///
    /// - Parameters:
    ///   - item: The Item to queue.
    ///   - completion: A closure to be called once queueing is completed.
    mutating func queue(item: T, completion: ()->())
    
    /// Dequeues and returns a certain amount of items.
    ///
    /// - Parameters:
    ///   - limit: The maximum amount of items to dequeue. May return less if less are queued.
    ///   - completion: A closure to be called once the elements are dequeued. The closure will be called with the dequeued items.
    mutating func dequeue(withLimit limit: Int, completion: (_ items: [T])->())
    
    /// Removes all items from the queue.
    mutating func deleteAll()
}

extension Queue {
    mutating func dequeue(completion: (_ items: [T])->()) {
        dequeue(withLimit: 1, completion: completion)
    }
}
