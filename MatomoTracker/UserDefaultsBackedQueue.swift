import Foundation

public final class UserDefaultsBackedQueue: NSObject, Queue {
    let userDefaults: UserDefaults
    
    init(suiteName: String?) {
        userDefaults = UserDefaults(suiteName: suiteName)!
    }
    
    public var eventCount: Int {
        return self.items.count
    }
    
    public func enqueue(events: [Event], completion: (() -> Void)?) {
        assertMainThread()
        self.items = self.items + events
        completion?()
    }
    
    public func first(limit: Int, completion: @escaping ([Event]) -> Void) {
        assertMainThread()
        let amount = [limit,eventCount].min()!
        let dequeuedItems = Array(self.items[0..<amount])
        completion(dequeuedItems)
    }
    
    public func remove(events: [Event], completion: @escaping () -> Void) {
        assertMainThread()
        self.items = self.items.filter({ event in !events.contains(where: { eventToRemove in eventToRemove.uuid == event.uuid })})
        completion()
    }
    
    private var items: [Event] {
        get {
            guard let data = userDefaults.object(forKey: UserDefaultsBackedQueue.Key.queueEvents) as? [Data]
            else { return [] }
            return data.map { try? PropertyListDecoder().decode(Event.self, from: $0) }.compactMap { $0 }
        }
        set {
            let data = newValue.map { try? PropertyListEncoder().encode($0) }.compactMap { $0 }
            userDefaults.set(data, forKey: UserDefaultsBackedQueue.Key.queueEvents)
            userDefaults.synchronize()
        }
    }
}

extension UserDefaultsBackedQueue {
    internal struct Key {
        static let queueEvents = "PiwikBackedQueueEvents"
    }
}
