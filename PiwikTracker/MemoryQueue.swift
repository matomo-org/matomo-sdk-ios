import Foundation

/// The MemoryQueue is a **not thread safe** in memory Queue.
struct MemoryQueue: Queue {
    private var items = [Event]()
    
    var itemCount: Int { get {
        return items.count
        }
    }
    
    mutating func queue(item: Event, completion: ()->()) {
        items.append(item)
        completion()
    }
    
    mutating func dequeue(withLimit limit: Int, completion: (_ items: [Event])->()) {
        let amount = [limit,itemCount].min()!
        let dequeuedItems = Array(items[0..<amount])
        items.removeSubrange(0..<amount)
        completion(dequeuedItems)
    }
    
    mutating func deleteAll() {
        items = []
    }
}
