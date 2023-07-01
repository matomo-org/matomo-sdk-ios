@testable import MatomoTracker
import Quick
import Nimble

class MemoryQueueSpec: QuickSpec {
    override class func setUp() {
        Nimble.PollingDefaults.timeout = .seconds(10)
        Nimble.PollingDefaults.pollInterval = .milliseconds(100)
    }
    
    override class func spec() {
        describe("init") {
            it("should return not null") {
                let queue = MemoryQueue()
                expect(queue).toNot(beNil())
            }
        }
        describe("eventCount") {
            context("with an empty queue") {
                let queue = MemoryQueue()
                it("should return 0") {
                    expect(queue.eventCount) == 0
                }
            }
            context("with a queue with two items") {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                it("should return 2") {
                    expect(queue.eventCount) == 2
                }
            }
        }
        describe("enqueue") {
            it("should increase item count") {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                expect(queue.eventCount).toEventually(equal(1))
            }
            it("should call the completion closure") {
                var queue = MemoryQueue()
                var calledClosure = false
                queue.enqueue(event: .fixture()) {
                    calledClosure = true
                }
                expect(calledClosure).toEventually(beTrue())
            }
            it("should enqueue the object") {
                var queue = MemoryQueue()
                let event = Event.fixture()
                var dequeued: Event? = nil
                queue.enqueue(event: event)
                queue.first(limit: 1) { event in
                    dequeued = event.first
                }
                expect(dequeued).toEventuallyNot(beNil())
                expect(dequeued?.uuid).toEventually(equal(event.uuid))
            }
        }
        describe("first") {
            context("with an empty queue") {
                let queue = MemoryQueue()
                it("should call the completionblock without items") {
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 10) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems).toEventuallyNot(beNil())
                    expect(dequeuedItems?.count).toEventually(equal(0))
                }
            }
            context("with a queue with two items") {
                it("should return one item if just asked for one") {
                    var queue = MemoryQueue()
                    queue.enqueue(event: .fixture())
                    queue.enqueue(event: .fixture())
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 1) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems?.count).toEventually(equal(1))
                }
                it("should return two items if asked for two or more") {
                    var queue = MemoryQueue()
                    queue.enqueue(event: .fixture())
                    queue.enqueue(event: .fixture())
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 10) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems?.count).toEventually(equal(2))
                }
                it("should not remove objects from the queue") {
                    var queue = MemoryQueue()
                    queue.enqueue(event: .fixture())
                    queue.enqueue(event: .fixture())
                    queue.first(limit: 1, completion: { items in })
                    expect(queue.eventCount) == 2
                }
            }
        }
        describe("remove") {
            it("should remove events that are enqueued") {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!], completion: {})
                expect(queue.eventCount) == 1
            }
            it("should ignore if one event is tried to remove twice") {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!], completion: {})
                queue.remove(events: [dequeuedItem!], completion: {})
                expect(queue.eventCount) == 1
            }
            it("should skip not queued events") {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!, .fixture()], completion: {})
                expect(queue.eventCount) == 1
            }
        }
    }
}
