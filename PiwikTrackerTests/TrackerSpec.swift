@testable import PiwikTracker
import Quick
import Nimble

class TrackerSpec: QuickSpec {
    override func spec() {
        describe("init") {
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
        }
        describe("dispatch") {
            context("with an idle tracke and queued events") {
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
                    expect(eventsDispatched.count) == 1
                }
                it("should set isDispatching to true") {
                    let trackerFixture = TrackerFixture.nonEmptyQueueWithFirstItemsCallback() { limit, completion in}
                    trackerFixture.tracker.dispatch()
                    expect(trackerFixture.tracker.isDispatching).to(beTrue())
                }
                it("should cancel dispatching if the dispatcher failes") {
                    
                }
                it("should ask for the next events if the dispatcher succeeds") {
                    
                }
                it("should stop dispatching if the queue is empty") {
                    
                }
            }
            context("with an already dispatching tracker") {
                it("should not ask the queue for events") {
                    // TODO
                }
            }
        }
    }
}
