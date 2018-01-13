@testable import PiwikTracker

struct TrackerFixture {
    public var queue: Queue
    public var dispatcher: Dispatcher
    public var tracker: PiwikTracker

    init(queue: Queue = QueueStub(), dispatcher: Dispatcher = DispatcherStub()) {
        self.queue = queue
        self.dispatcher = dispatcher
        self.tracker = PiwikTracker(siteId: "spec_siteId", queue: self.queue, dispatcher: self.dispatcher)
    }
    
    static func withQueueEventsCallback(queueEvents: @escaping QueueStub.Callback.QueueEvents) -> TrackerFixture {
        let queue = QueueStub()
        queue.queueEvents = queueEvents
        return TrackerFixture(queue: queue)
    }
    
    static func nonEmptyQueueWithFirstItemsCallback(firstItems: @escaping QueueStub.Callback.FirstEvents) -> TrackerFixture {
        let queue = QueueStub()
        queue.countEvents = { return 1 }
        queue.firstItems = firstItems
        return TrackerFixture(queue: queue)
    }
    
    static func nonEmptyQueueWithSendEventsCallback(sendEvents: @escaping DispatcherStub.Callback.SendEvents) -> TrackerFixture {
        let queue = QueueStub()
        queue.countEvents = { return 1 }
        queue.firstItems = { limit, completion in
            completion([EventFixture.event()])
        }
        let dispatcher = DispatcherStub()
        dispatcher.sendEvents = sendEvents
        return TrackerFixture(queue: queue, dispatcher: dispatcher)
    }
    
    static func withSendEventsCallback(sendEvents: @escaping DispatcherStub.Callback.SendEvents) -> TrackerFixture {
        let dispatcher = DispatcherStub()
        dispatcher.sendEvents = sendEvents
        return TrackerFixture(queue: MemoryQueue(), dispatcher: dispatcher)
    }
}
