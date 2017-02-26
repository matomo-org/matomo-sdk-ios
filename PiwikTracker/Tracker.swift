import Foundation

final public class Tracker: NSObject {
    
    let dispatcher: Dispatcher
    var queue: Queue
    let siteId: String
    
    internal static var _sharedInstance: Tracker?
    
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
    
    public func dispatch() {
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
    
    private let dispatchInterval: TimeInterval = 30.0 // Discussion: move this into a configuration?
    private var dispatchTimer: Timer?
    
    private func startDispatchTimer() {
        guard dispatchInterval > 0  else { return } // Discussion: Do we want the possibility to dispatch synchronous? That than would be dispatchInterval = 0
        if let dispatchTimer = dispatchTimer {
            dispatchTimer.invalidate()
            self.dispatchTimer = nil
        }
        self.dispatchTimer = Timer.scheduledTimer(timeInterval: dispatchInterval, target: self, selector: #selector(dispatch), userInfo: nil, repeats: false)
    }
    
    var visitor = Visitor.current()
    var session = Session.current()
}

// shared instance
extension Tracker {
    public static var sharedInstance: Tracker? {
        get { return _sharedInstance }
    }
    
    public class func configureSharedInstance(withSiteID siteID: String, baseURL: URL) {
        let queue = MemoryQueue()
        let dispatcher = URLSessionDispatcher(baseURL: baseURL)
        self._sharedInstance = Tracker.init(siteId: siteID, queue: queue, dispatcher: dispatcher)
    }
    
    public class func configureSharedInstance(withSiteID siteID: String, queue: Queue = MemoryQueue(), dispatcher: Dispatcher) {
        self._sharedInstance = Tracker(siteId: siteID, queue: queue, dispatcher: dispatcher)
    }
}

extension Tracker {
    func event(action: [String]) -> Event {
        return Event(
            siteId: siteId,
            uuid: NSUUID(),
            visitor: visitor,
            session: session,
            date: Date(),
            url: URL(string: "http://example.com")!.appendingPathComponent(action.joined(separator: "/")),
            actionName: action,
            language: Locale.httpAcceptLanguage,
            isNewSession: false, // set this to true once we can start a new session
            referer: nil)
    }
}

extension Locale {
    static var httpAcceptLanguage: String {
        var components: [String] = []
        for (index, languageCode) in preferredLanguages.enumerated() {
            let quality = 1.0 - (Double(index) * 0.1)
            components.append("\(languageCode);q=\(quality)")
            if quality <= 0.5 {
                break
            }
        }
        return components.joined(separator: ",")
    }
}

extension Tracker {
    public func track(view: [String]) {
        queue(event: event(action: view))
    }
}
