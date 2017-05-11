import Foundation

/// The MemoryQueue is a **not thread safe** in memory Queue.
struct MemoryQueue: Queue {
    private var items = [Event]()
    
    var eventCount: Int { get {
        return items.count
        }
    }
    
    mutating func enqueue(events: [Event], completion: (()->())?) {
        items.append(contentsOf: events)
        completion?()
    }
    
    func first(limit: Int, completion: (_ items: [Event])->()) {
        let amount = [limit,eventCount].min()!
        let dequeuedItems = Array(items[0..<amount])
        completion(dequeuedItems)
    }
    
    mutating func remove(events: [Event], completion: ()->()) {
        items = items.filter({ event in !events.contains(where: { eventToRemove in eventToRemove.uuid == event.uuid })})
        completion()
    }
}
