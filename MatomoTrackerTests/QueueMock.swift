@testable import MatomoTracker

class QueueMock: Queue {
    
    private(set) var eventCountOnSetCallCount = 0
    var eventCount: Int = 0 {
        didSet {
            eventCountOnSetCallCount += 1
        }
    }

    private(set) var enqueueEventsCallCount = 0
    var enqueueEventsHandler: (([Event], (()-> Void)?) -> Void)? = nil
    func enqueue(events: [Event], completion: (()-> Void)?) {
        enqueueEventsCallCount += 1
        enqueueEventsHandler?(events, completion)
    }
    
    private(set) var firstCallCount = 0
    var firstHandler: ((Int, @escaping (_ items: [Event]) -> Void) -> Void)? = nil
    func first(limit: Int, completion: @escaping (_ items: [Event]) -> Void) {
        firstCallCount += 1
        firstHandler?(limit, completion)
    }
    
    private(set) var removeCallCount = 0
    var removeHandler: (([Event], @escaping () -> Void) -> Void)? = nil
    func remove(events: [Event], completion: @escaping () -> Void) {
        removeCallCount += 1
        removeHandler?(events, completion)
    }
}
