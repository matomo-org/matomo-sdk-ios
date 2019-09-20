@testable import MatomoTracker
import Quick
import Nimble

class TrackerSpec: QuickSpec {
    override func spec() {
        Nimble.AsyncDefaults.Timeout = 1
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
                let trackerFixture = TrackerFixture.withQueueEventsCallback() { events, completion in
                    queuedEvent = events.first
                    completion()
                }
                let event = EventFixture.event()
                trackerFixture.tracker.queue(event: event)
                expect(queuedEvent).toNot(beNil())
            }
            it("should not throw an assertion if called from a background thread") {
                let trackerFixture = TrackerFixture(queue: MemoryQueue(), dispatcher: DispatcherStub())
                var queued = false
                DispatchQueue.global(qos: .background).async {
                    expect{ trackerFixture.tracker.queue(event: EventFixture.event()) }.toNot(throwAssertion())
                    queued = true
                }
                expect(queued).toEventually(beTrue())
            }
        }
        describe("dispatch") {
            context("with an idle tracker and queued events") {
                it("should ask the queue for event") {
                    var didAskForItems = false
                    let trackerFixture = TrackerFixture.nonEmptyQueueWithFirstItemsCallback() { limit, completion in
                        didAskForItems = true
                    }
                    trackerFixture.tracker.dispatch()
                    expect(didAskForItems).to(beTrue())
                }
                it("should give dequeued events to the dispatcher") {
                    var eventsDispatched: [Event] = []
                    let trackerFixture = TrackerFixture.nonEmptyQueueWithSendEventsCallback() { events, _,_ in
                        eventsDispatched = events
                    }
                    trackerFixture.tracker.dispatch()
                    expect(eventsDispatched.count).toEventually(equal(1))
                }
                it("should set isDispatching to true") {
                    let trackerFixture = TrackerFixture.nonEmptyQueueWithFirstItemsCallback() { limit, completion in }
                    trackerFixture.tracker.dispatch()
                    expect(trackerFixture.tracker.isDispatching).to(beTrue())
                }
                it("should not throw an assertion if called from a background thread") {
                    var trackerFixture = TrackerFixture(queue: MemoryQueue(), dispatcher: DispatcherStub())
                    trackerFixture.queue.enqueue(event: EventFixture.event())
                    var dispatched = false
                    DispatchQueue.global(qos: .background).async {
                        expect{ trackerFixture.tracker.dispatch() }.toNot(throwAssertion())
                        dispatched = true
                    }
                    expect(dispatched).toEventually(beTrue())
                }
                it("should cancel dispatching if the dispatcher failes") {
                    
                }
                it("should ask for the next events if the dispatcher succeeds") {
                    
                }
                it("should stop dispatching if the queue is empty") {
                }
            }
            it("should start a new DispatchTimer if dispatching failed") {
                var numberOfDispatches = 0
                let trackerFixture = TrackerFixture.withSendEventsCallback() { events, success, failure in
                    numberOfDispatches += 1
                    failure(NSError(domain: "spec", code: 0))
                }
                trackerFixture.tracker.queue(event: EventFixture.event())
                trackerFixture.tracker.dispatchInterval = 0.5
                expect(numberOfDispatches).toEventually(equal(5), timeout: 10)
            }
            it("should start a new DispatchTimer if dispatching succeeded") {
                var numberOfDispatches = 0
                let trackerFixture = TrackerFixture.withSendEventsCallback() { events, success, failure in
                    numberOfDispatches += 1
                    success()
                }
                trackerFixture.tracker.queue(event: EventFixture.event())
                let autoTracker = AutoTracker(tracker: trackerFixture.tracker, trackingInterval: 0.1)
                autoTracker.start()
                trackerFixture.tracker.dispatchInterval = 0.1
                expect(numberOfDispatches).toEventually(beGreaterThan(5))
                autoTracker.stop()
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
                let trackerFixture = TrackerFixture.withQueueEventsCallback() { events, completion in
                    queuedEvent = events.first
                    completion()
                }
                trackerFixture.tracker.forcedVisitorId = "0123456789abcdef"
                trackerFixture.tracker.track(view: ["spec_view"])
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
    }
}
