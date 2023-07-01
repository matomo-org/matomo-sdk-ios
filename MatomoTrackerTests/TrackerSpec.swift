@testable import MatomoTracker
import Quick
import Nimble

class TrackerSpec: QuickSpec {
    override class func spec() {
        Nimble.PollingDefaults.timeout = .seconds(5)
        describe("init") {
            it("should be able to initialized the MatomoTracker with a URL ending on `matomo.php`") {
                let tracker = MatomoTracker(siteId: "5", baseURL: URL(string: "https://example.com/matomo.php")!)
                expect(tracker).toNot(beNil())
            }
            it("should be released if no external strong reference exists (no retain cycles") {
                weak var tracker = MatomoTracker(siteId: "5", baseURL: URL(string: "https://example.com/matomo.php")!)
                expect(tracker).to(beNil())
            }
        }
        describe("queue") {
            it("should enqueue the item in the queue") {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }
                let event = Event.fixture()
                tracker.queue(event: event)
                expect(queuedEvent).toNot(beNil())
            }
            it("should not throw an assertion if called from a background thread") {
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: DispatcherMock())
                var queued = false
                DispatchQueue.global(qos: .background).async {
                    expect{ tracker.queue(event: .fixture()) }.toNot(throwAssertion())
                    queued = true
                }
                expect(queued).toEventually(beTrue())
            }
        }
        describe("dispatch") {
            context("with an idle tracker and queued events") {
                it("should ask the queue for event") {
                    let queue = QueueMock()
                    queue.eventCount = 1
                    let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                    tracker.dispatch()
                    expect(queue.firstCallCount == 1).to(beTrue())
                }
                it("should give dequeued events to the dispatcher") {
                    var eventsDispatched: [Event] = []
                    let dispatcher = DispatcherMock()
                    let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                    dispatcher.sendEventsHandler = { events, _,_ in
                        eventsDispatched = events
                    }
                    tracker.track(.fixture())
                    tracker.dispatch()
                    expect(eventsDispatched.count).toEventually(equal(1))
                }
                it("should set isDispatching to true") {
                    let queue = QueueMock()
                    queue.eventCount = 1
                    let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                    tracker.dispatch()
                    expect(tracker.isDispatching).to(beTrue())
                }
                it("should not throw an assertion if called from a background thread") {
                    let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: DispatcherMock())
                    tracker.queue(event: .fixture())
                    var dispatched = false
                    DispatchQueue.global(qos: .background).async {
                        expect{ tracker.dispatch() }.toNot(throwAssertion())
                        dispatched = true
                    }
                    expect(dispatched).toEventually(beTrue(), timeout: .seconds(20))
                }
                it("should cancel dispatching if the dispatcher failes") {
                    
                }
                it("should ask for the next events if the dispatcher succeeds") {
                    
                }
                it("should stop dispatching if the queue is empty") {
                }
            }
            it("should start a new DispatchTimer if dispatching failed") {
                let dispatcher = DispatcherMock()
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                dispatcher.sendEventsHandler = { _, _, failure in
                    failure(NSError(domain: "spec", code: 0))
                }
                tracker.queue(event: .fixture())
                tracker.dispatchInterval = 0.5
                expect(dispatcher.sendEventsCallCount).toEventually(equal(5), timeout: .seconds(10))
            }
            it("should start a new DispatchTimer if dispatching succeeded") {
                let dispatcher = DispatcherMock()
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                dispatcher.sendEventsHandler = { _, success, _ in
                    tracker.queue(event: .fixture())
                    success()
                }
                tracker.queue(event: .fixture())
                tracker.dispatchInterval = 0.01
                expect(dispatcher.sendEventsCallCount).toEventually(beGreaterThan(5))
            }
            context("with an already dispatching tracker") {
                it("should not ask the queue for events") {
                    // TODO
                }
            }
        }
        describe("forcedVisitorID") {
            it("populates the cid value if set") {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }
                tracker.forcedVisitorId = "0123456789abcdef"
                tracker.track(view: ["spec_view"])
                expect(queuedEvent?.visitor.forcedId).toEventually(equal("0123456789abcdef"))
            }
            it("it doesn't change the existing value if set to an invalid one") {
                let tracker = MatomoTracker.init(siteId: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                tracker.forcedVisitorId = "0123456789abcdef"
                tracker.forcedVisitorId = "invalid"
                expect(tracker.forcedVisitorId) == "0123456789abcdef"
            }
            it("should persist and restore the value") {
                let tracker = MatomoTracker.init(siteId: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                tracker.forcedVisitorId = "0123456789abcdef"
                let tracker2 = MatomoTracker.init(siteId: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                expect(tracker2.forcedVisitorId) == "0123456789abcdef"
            }
        }
        describe("reset") {
            it("generates new visitor") {
                var queuedEvents = [Event]()
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvents += events
                }
                
                tracker.track(view: ["spec_view"])
                tracker.reset()
                tracker.track(view: ["spec_view"])
                
                expect(queuedEvents.count) == 2
                expect(queuedEvents.first?.visitor.id).toNot(equal(queuedEvents.last?.visitor.id))
            }
            it("clears session information") {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }
                
                tracker.startNewSession()
                tracker.reset()
                tracker.track(view: ["spec_view"])
                
                expect(queuedEvent?.session.sessionsCount) == 1
            }
            it("clears dimensions") {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }
                
                tracker.set(dimension: CustomDimension(index: 0, value: "fake-dimension"))
                tracker.reset()
                tracker.track(view: ["spec_view"])
                
                expect(queuedEvent?.dimensions).to(beEmpty())
            }
            it("removes all custom variables") {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }
                
                tracker.set(customVariable: CustomVariable(index: 0, name: "fake-variable", value: "fake-value"))
                tracker.reset()
                tracker.track(view: ["spec_view"])
                
                expect(queuedEvent?.customVariables).to(beEmpty())
            }
            it("clear campaigns") {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }
                
                tracker.trackCampaign(name: "fake-campaign", keyword: "fake-keyword")
                tracker.reset()
                tracker.track(view: ["spec_view"])
                
                expect(queuedEvent).toNot(beNil())
                expect(queuedEvent?.campaignName).to(beNil())
                expect(queuedEvent?.campaignKeyword).to(beNil())
            }
        }
    }
}
