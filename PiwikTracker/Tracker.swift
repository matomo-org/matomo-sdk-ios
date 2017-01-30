import Foundation

final public class Tracker: NSObject {
    
    let dispatcher: Dispatcher
    var queue: Queue
    let siteId: String
    
    required public init(siteId: String, queue: Queue, dispatcher: Dispatcher) {
        self.siteId = siteId
        self.queue = queue
        self.dispatcher = dispatcher
        super.init()
        startDispatchTimer()
    }
    
    func queue(event: Event) {
        queue.enqueue(event: event)
    }
    
    // MARK: dispatching
    
    private let numberOfEventsDispatchedAtOnce = 20
    public private(set) var isDispatching = false
    
    func dispatch () {
        guard !isDispatching else { return }
        guard queue.eventCount > 0 else {
            startDispatchTimer()
            return
        }
        isDispatching = true
        dispatchBatch()
    }
    
    private func dispatchBatch() {
        queue.first(limit: numberOfEventsDispatchedAtOnce) { events in
            guard events.count > 0 else {
                // there are no more events queued, finish dispatching
                self.isDispatching = false
                return
            }
            self.dispatcher.send(events: events, success: {
                self.queue.remove(events: events, completion: {
                    self.dispatchBatch()
                })
            }, failure: { _ in
                self.isDispatching = false
            })
        }
    }
    
    // MARK: dispatch timer
    
    private let dispatchInterval: TimeInterval = 60.0 // Discussion: move this into a configuration?
    private var dispatchTimer: Timer?
    
    private func startDispatchTimer() {
        guard dispatchInterval > 0  else { return } // Discussion: Do we want the possibility to dispatch synchronous? That than would be dispatchInterval = 0
        if let dispatchTimer = dispatchTimer {
            dispatchTimer.invalidate()
            self.dispatchTimer = nil
        }
        self.dispatchTimer = Timer.scheduledTimer(timeInterval: dispatchInterval, target: self, selector: #selector(dispatch), userInfo: nil, repeats: false)
    }
}
