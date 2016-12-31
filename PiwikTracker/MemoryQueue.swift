import Foundation

/// The MemoryQueue is a **thread-unsave** in memory Queue.
class MemoryQueue: Queue {
    private var items = [Data]()
    
    var itemCount: Int { get {
        return items.count
        }
    }
    
    func queue(item: NSCoding, completion: ()->()) {
        let data = NSKeyedArchiver.archivedData(withRootObject: item)
        items.append(data)
        completion()
    }
    
    func dequeue(withLimit limit: Int, completion: (_ items: [Any])->()) {
        let amount = [limit,itemCount].min()!
        let dequeuedItems = items[0..<amount].flatMap({ NSKeyedUnarchiver.unarchiveObject(with: $0) })
        items.removeSubrange(0..<amount)
        completion(dequeuedItems)
    }
    
    func deleteAll() {
        items = []
    }
}
