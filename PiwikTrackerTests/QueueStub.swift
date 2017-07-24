@testable import PiwikTracker

final class QueueStub: Queue {
    struct Callback {
        typealias QueueEvents = (_ events: [Event], _ completion: ()->()) -> ()
        typealias FirstEvents = (_ limit: Int, _ completion: (_ items: [Event])->()) -> ()
        typealias EventCount = () -> (Int)
        typealias RemoveEvents = (_ events: [Event], _ completion: ()->()) -> ()
    }
    
    var queueEvents: Callback.QueueEvents? = nil
    var firstItems: Callback.FirstEvents? = nil
    var countEvents: Callback.EventCount? = nil
    var removeEventsCallback: Callback.RemoveEvents? = nil
    
    init() {}
    
    public var eventCount: Int { get {
        return self.countEvents?() ?? 0
        }
    }
    
    func enqueue(events: [Event], completion: (()->())?) {
        if let closure = queueEvents {
            closure(events, completion ?? {})
        } else {
            completion?()
        }
    }
    
    func first(limit: Int, completion: ([Event]) -> ()) {
        if let closure = firstItems {
            closure(limit, completion)
        } else {
            completion([])
        }
    }
    
    func remove(events: [Event], completion: () -> ()) {
        if let closure = removeEventsCallback {
            closure(events, completion)
        } else {
            completion()
        }
    }
    
}
