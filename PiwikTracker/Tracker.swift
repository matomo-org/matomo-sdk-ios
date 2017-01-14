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
    
    private func queue(event: Event) {
        queue.queue(item: event) { 
            // Discussion: Do we want the possibility to dispatch synchronous?
        }
    }
    
    // MARK: dispatching
    
    private let dispatchCount = 20
    public private(set) var isDispatching = false
    
    func dispatch () {
        guard !isDispatching else { return }
        guard queue.itemCount > 0 else {
            startDispatchTimer()
            return
        }
        isDispatching = true
        dispatchBatch()
    }
    
    private func dispatchBatch() {
        queue.dequeue(withLimit: dispatchCount) { events in
            self.dispatcher.send(events: events, success: {
                dispatchBatch()
            }, failure: { shouldContinue in
                // Should the events be dispatched in exact order? If so, in case of a failure we cannot continue with the next items.
                
                // Also: Dequeueing items an re-queueing items in case of an error is error-prone. If the app crashes during dispatching all currently dispatching events would be lost. And requeueing results in wrong ordered events if we don't sort them otherwise.
                for event in events {
                    self.queue.queue(item: event) {}
                }
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
