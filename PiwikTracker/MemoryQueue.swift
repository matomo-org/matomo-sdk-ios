import Foundation

/// The MemoryQueue is a **not thread safe** in memory Queue.
struct MemoryQueue<E: Any>: Queue {
    typealias T = E
    private var items = [Data]()
    
    var itemCount: Int { get {
        return items.count
        }
    }
    
    mutating func queue(item: T, completion: ()->()) {
        let data = NSKeyedArchiver.archivedData(withRootObject: item)
        items.append(data)
        completion()
    }
    
    mutating func dequeue(withLimit limit: Int, completion: (_ items: [T])->()) {
        let amount = [limit,itemCount].min()!
        let dequeuedItems = items[0..<amount].flatMap({ NSKeyedUnarchiver.unarchiveObject(with: $0) as? T })
        items.removeSubrange(0..<amount)
        completion(dequeuedItems)
    }
    
    mutating func deleteAll() {
        items = []
    }
}
