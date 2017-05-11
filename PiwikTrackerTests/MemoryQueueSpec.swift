@testable import PiwikTracker
import Quick
import Nimble

class MemoryQueueSpec: QuickSpec {
    override func spec() {
        describe("init") {
            it("should return not null") {
                let queue = MemoryQueue()
                expect(queue).toNot(beNil())
            }
        }
        describe("eventCount") {
            context("with an empty queue") {
                let queue = MemoryQueueFixture.empty()
                it("should return 0") {
                    expect(queue.eventCount) == 0
                }
            }
            context("with a queue with two items") {
                let queue = MemoryQueueFixture.withTwoItems()
                it("should return 2") {
                    expect(queue.eventCount) == 2
                }
            }
        }
        describe("enqueue") {
            it("should increase item count") {
                var queue = MemoryQueueFixture.empty()
                queue.enqueue(event: EventFixture.event())
                expect(queue.eventCount).toEventually(equal(1))
            }
            it("should call the completion closure") {
                var queue = MemoryQueueFixture.empty()
                var calledClosure = false
                queue.enqueue(event: EventFixture.event(), completion: {
                    calledClosure = true
                })
                expect(calledClosure).toEventually(beTrue())
            }
            it("should enqueue the object") {
                var queue = MemoryQueueFixture.empty()
                let event = EventFixture.event()
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
                let queue = MemoryQueueFixture.empty()
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
                    let queue = MemoryQueueFixture.withTwoItems()
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 1) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems?.count).toEventually(equal(1))
                }
                it("should return two items if asked for two or more") {
                    let queue = MemoryQueueFixture.withTwoItems()
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 10) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems?.count).toEventually(equal(2))
                }
                it("should not remove objects from the queue") {
                    let queue = MemoryQueueFixture.withTwoItems()
                    queue.first(limit: 1, completion: { items in })
                    expect(queue.eventCount) == 2
                }
            }
        }
        describe("remove") {
            it("should remove events that are enqueued") {
                var queue = MemoryQueueFixture.withTwoItems()
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!], completion: {})
                expect(queue.eventCount) == 1
            }
            it("should ignore if one event is tried to remove twice") {
                var queue = MemoryQueueFixture.withTwoItems()
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!], completion: {})
                queue.remove(events: [dequeuedItem!], completion: {})
                expect(queue.eventCount) == 1
            }
            it("should skip not queued events") {
                var queue = MemoryQueueFixture.withTwoItems()
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!, EventFixture.event()], completion: {})
                expect(queue.eventCount) == 1
            }
        }
    }
}
