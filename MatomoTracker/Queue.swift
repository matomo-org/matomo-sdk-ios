import Foundation

/// A queue that stores events until they are dispatched.
///
/// The `MatomoTracker` calls all methods on one internal serial queue: never concurrently,
/// and not on the main thread. If your implementation needs a specific thread, for example
/// a Core Data context bound to the main queue, switch to it yourself.
/// The completion handlers can be called on any thread, synchronously or later.
public protocol Queue {
    
    var eventCount: Int { get }
    
    mutating func enqueue(events: [Event], completion: (()-> Void)?)
    
    /// Returns the first `limit` events ordered by Event.date
    func first(limit: Int, completion: @escaping (_ items: [Event]) -> Void)
    
    /// Removes the events from the queue
    mutating func remove(events: [Event], completion: @escaping () -> Void)
}

extension Queue {
    mutating func enqueue(event: Event, completion: (()->Void)? = nil) {
        enqueue(events: [event], completion: completion)
    }
}
