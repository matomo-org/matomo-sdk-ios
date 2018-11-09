import Foundation
import MatomoTracker

public final class UserDefaultsQueue: NSObject, Queue {
    private var items: [Event] {
        didSet {
            if autoSave {
                try? UserDefaultsQueue.write(items, to: userDefaults)
            }
        }
    }
    private let userDefaults: UserDefaults
    private let autoSave: Bool
    
    init(_ userDefaults: UserDefaults, autoSave: Bool = false) {
        self.userDefaults = userDefaults
        self.autoSave = autoSave
        self.items = (try? UserDefaultsQueue.readEvents(from: userDefaults)) ?? []
        super.init()
    }
    
    public var eventCount: Int {
        return items.count
    }
    
    public func enqueue(events: [Event], completion: (()->())?) {
        items.append(contentsOf: events)
        completion?()
    }
    
    public func first(limit: Int, completion: (_ items: [Event])->()) {
        let amount = [limit,eventCount].min()!
        let dequeuedItems = Array(items[0..<amount])
        completion(dequeuedItems)
    }
    
    public func remove(events: [Event], completion: ()->()) {
        items = items.filter({ event in !events.contains(where: { eventToRemove in eventToRemove.uuid == event.uuid })})
        completion()
    }
    
    public func save() throws {
        try UserDefaultsQueue.write(items, to: userDefaults)
    }
}

extension UserDefaultsQueue {
    
    private static let userDefaultsKey = "UserDefaultsQueue.items"
    
    private static func readEvents(from userDefaults: UserDefaults) throws -> [Event] {
        guard let data = userDefaults.data(forKey: userDefaultsKey) else { return [] }
        let decoder = JSONDecoder()
        return try decoder.decode([Event].self, from: data)
    }
    
    private static func write(_ events: [Event], to userDefaults: UserDefaults) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(events)
        userDefaults.set(data, forKey: userDefaultsKey)
    }
    
}
