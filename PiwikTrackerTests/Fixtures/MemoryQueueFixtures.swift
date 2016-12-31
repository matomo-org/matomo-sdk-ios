@testable import PiwikTracker
import Foundation

class Dummy: NSObject, NSCoding {
    let uuid: UUID
    public override init() {
        uuid = UUID()
    }
    public init(uuid: UUID) {
        self.uuid = uuid
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: "uuid")
    }
    public convenience required init?(coder aDecoder: NSCoder) {
        let uuid = aDecoder.decodeObject(forKey: "uuid") as! UUID
        self.init(uuid: uuid)
    }
}

struct MemoryQueueFixture {
    static func empty() -> MemoryQueue {
        return MemoryQueue()
    }
    static func withTwoItems() -> MemoryQueue {
        let queue = MemoryQueue()
        queue.queue(item: Dummy(), completion: {})
        queue.queue(item: Dummy(), completion: {})
        return queue
    }
    static func queueable() -> NSCoding {
        return Dummy()
    }
}
