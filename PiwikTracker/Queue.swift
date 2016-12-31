import Foundation

/// A queue in which Objects that conform to queueable can be stored.
protocol Queue {
    /// The number of queud items.
    var itemCount: Int { get }
    
    /// Queues an Item.
    ///
    /// - Parameters:
    ///   - item: The Item to queue.
    ///   - completion: A closure to be called once queueing is completed.
    func queue(item: NSCoding, completion: ()->())
    
    /// Dequeues and returns a certain amount of items.
    ///
    /// - Parameters:
    ///   - limit: The maximum amount of items to dequeue. May return less if less are queued.
    ///   - completion: A closure to be called once the elements are dequeued. The closure will be called with the dequeued items.
    func dequeue(withLimit limit: Int, completion: (_ items: [Any])->())
    
    /// Removes all items from the queue.
    func deleteAll()
}
