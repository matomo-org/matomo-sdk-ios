import Foundation

/// The MemoryQueue is a **not thread safe** in memory Queue.
struct MemoryQueue<E: Any>: Queue {
    typealias T = E
    private var items = [E]()
    
    var itemCount: Int { get {
        return items.count
        }
    }
    
    mutating func queue(item: T, completion: ()->()) {
        items.append(item)
        completion()
    }
    
    mutating func dequeue(withLimit limit: Int, completion: (_ items: [T])->()) {
        let amount = [limit,itemCount].min()!
        let dequeuedItems = Array(items[0..<amount])
        items.removeSubrange(0..<amount)
        completion(dequeuedItems)
    }
    
    mutating func deleteAll() {
        items = []
    }
}
