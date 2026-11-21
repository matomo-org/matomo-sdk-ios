import Foundation
@testable import MatomoTracker

/// The tracker calls its queue on an internal queue, so the call counts can be read from any thread.
final class QueueMock: Queue, @unchecked Sendable {
    
    private let counts = Locked((eventCountOnSet: 0, enqueueEvents: 0, first: 0, remove: 0))

    var eventCountOnSetCallCount: Int { counts.value.eventCountOnSet }
    var eventCount: Int = 0 {
        didSet {
            counts.mutate { $0.eventCountOnSet += 1 }
        }
    }

    var enqueueEventsCallCount: Int { counts.value.enqueueEvents }
    var enqueueEventsHandler: (([Event], (()-> Void)?) -> Void)? = nil
    func enqueue(events: [Event], completion: (()-> Void)?) {
        counts.mutate { $0.enqueueEvents += 1 }
        enqueueEventsHandler?(events, completion)
    }
    
    var firstCallCount: Int { counts.value.first }
    var firstHandler: ((Int, @escaping (_ items: [Event]) -> Void) -> Void)? = nil
    func first(limit: Int, completion: @escaping (_ items: [Event]) -> Void) {
        counts.mutate { $0.first += 1 }
        firstHandler?(limit, completion)
    }
    
    var removeCallCount: Int { counts.value.remove }
    var removeHandler: (([Event], @escaping () -> Void) -> Void)? = nil
    func remove(events: [Event], completion: @escaping () -> Void) {
        counts.mutate { $0.remove += 1 }
        removeHandler?(events, completion)
    }
}
