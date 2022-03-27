import Foundation

/// The UserDefaultsQueue is a **not thread safe** queue that persists all events in the `UserDefaults`.
/// Per default only the last 100 Events will be queued. If there are more Events than that, the oldest ones will be dropped.
public final class UserDefaultsQueue: NSObject, Queue {
    
    private let userDefaults: UserDefaults
    private let maximumQueueSize: Int?
    
    private let encoder: PropertyListEncoder = PropertyListEncoder()
    private let decoder: PropertyListDecoder = PropertyListDecoder()
    
    private var enqueuedEvents: [Event] {
        get {
            guard let data = userDefaults.object(forKey: UserDefaultsQueue.Key.queuedEvents) as? [Data]
            else { return [] }
            return data.map { try? decoder.decode(Event.self, from: $0) }.compactMap { $0 }
        }
        set {
            let eventsToStore: [Event]
            if let maximumQueueSize = maximumQueueSize {
                eventsToStore = newValue.suffix(max(0,maximumQueueSize))
            } else {
                eventsToStore = newValue
            }
            let data = eventsToStore.map { try? encoder.encode($0) }.compactMap { $0 }
            userDefaults.set(data, forKey: UserDefaultsQueue.Key.queuedEvents)
        }
    }
    
    public var eventCount: Int {
        assertMainThread()
        return enqueuedEvents.count
    }
    
    /// Initializes a new UserDefaultsQueue
    /// - Parameters:
    ///   - suiteName: The UserDefaults in which the events should be persisted.
    ///   - maximumQueueSize: The maximum number of events to be queued, 100 per default. If nil, the number of events is not limited.
    public init(userDefaults: UserDefaults, maximumQueueSize: Int? = 100) {
        self.userDefaults = userDefaults
        self.maximumQueueSize = maximumQueueSize
    }
    
    public func enqueue(events: [Event], completion: (() -> Void)?) {
        assertMainThread()
        enqueuedEvents.append(contentsOf: events)
        completion?()
    }
    
    public func first(limit: Int, completion: @escaping ([Event]) -> Void) {
        assertMainThread()
        
        let amount = [limit,eventCount].min()!
        let dequeuedItems = Array(enqueuedEvents[0..<amount])
        completion(dequeuedItems)
    }
    
    public func remove(events: [Event], completion: @escaping () -> Void) {
        assertMainThread()
        enqueuedEvents = enqueuedEvents.filter({ event in !events.contains(where: { eventToRemove in eventToRemove.uuid == event.uuid })})
        completion()
    }
}

extension UserDefaultsQueue {
    internal struct Key {
        static let queuedEvents = "MatomoQueuedEvents"
    }
}
