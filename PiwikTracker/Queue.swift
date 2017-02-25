import Foundation

public protocol Queue {
    
    var eventCount: Int { get }
    
    mutating func enqueue(events: [Event], completion: (()->())?)
    
    /// Returns the first `limit` events ordered by Event.date
    func first(limit: Int, completion: (_ items: [Event])->())
    
    /// Removes the events from the queue
    mutating func remove(events: [Event], completion: ()->())
}

extension Queue {
    mutating func enqueue(event: Event, completion: (()->())? = nil) {
        enqueue(events: [event], completion: completion)
    }
}
