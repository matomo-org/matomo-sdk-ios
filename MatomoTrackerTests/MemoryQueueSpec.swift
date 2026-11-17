import Foundation
@testable import MatomoTracker
import Testing

extension MatomoTrackerSpecs {
    @Suite("MemoryQueue")
    @MainActor
    struct MemoryQueueSpec {
        @Suite("eventCount")
        @MainActor
        struct EventCount {
            @Test("with an empty queue should return 0")
            func emptyQueue() {
                let queue = MemoryQueue()
                #expect(queue.eventCount == 0)
            }

            @Test("with a queue with two items should return 2")
            func twoItems() {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                #expect(queue.eventCount == 2)
            }
        }

        @Suite("enqueue")
        @MainActor
        struct Enqueue {
            @Test("should increase item count")
            func increasesItemCount() async {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                #expect(await eventually { queue.eventCount == 1 })
            }

            @Test("should call the completion closure")
            func callsCompletionClosure() async {
                var queue = MemoryQueue()
                var calledClosure = false
                queue.enqueue(event: .fixture()) {
                    calledClosure = true
                }
                #expect(await eventually { calledClosure })
            }

            @Test("should enqueue the object")
            func enqueuesTheObject() async {
                var queue = MemoryQueue()
                let event = Event.fixture()
                var dequeued: Event? = nil
                queue.enqueue(event: event)
                queue.first(limit: 1) { events in
                    dequeued = events.first
                }
                #expect(await eventually { dequeued?.uuid == event.uuid })
            }
        }

        @Suite("first")
        @MainActor
        struct First {
            @Test("with an empty queue should call the completionblock without items")
            func emptyQueue() async {
                let queue = MemoryQueue()
                var dequeuedItems: [Event]? = nil
                queue.first(limit: 10) { events in
                    dequeuedItems = events
                }
                #expect(await eventually { dequeuedItems?.count == 0 })
            }

            @Test("with a queue with two items should return one item if just asked for one")
            func returnsOneItem() async {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                var dequeuedItems: [Event]? = nil
                queue.first(limit: 1) { events in
                    dequeuedItems = events
                }
                #expect(await eventually { dequeuedItems?.count == 1 })
            }

            @Test("with a queue with two items should return two items if asked for two or more")
            func returnsTwoItems() async {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                var dequeuedItems: [Event]? = nil
                queue.first(limit: 10) { events in
                    dequeuedItems = events
                }
                #expect(await eventually { dequeuedItems?.count == 2 })
            }

            @Test("with a queue with two items should not remove objects from the queue")
            func doesNotRemoveObjects() {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                queue.first(limit: 1, completion: { _ in })
                #expect(queue.eventCount == 2)
            }
        }

        @Suite("remove")
        @MainActor
        struct Remove {
            @Test("should remove events that are enqueued")
            func removesEnqueuedEvents() throws {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                let event = try #require(dequeuedItem)
                queue.remove(events: [event], completion: {})
                #expect(queue.eventCount == 1)
            }

            @Test("should ignore if one event is tried to remove twice")
            func ignoresRemovingTwice() throws {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                let event = try #require(dequeuedItem)
                queue.remove(events: [event], completion: {})
                queue.remove(events: [event], completion: {})
                #expect(queue.eventCount == 1)
            }

            @Test("should skip not queued events")
            func skipsNotQueuedEvents() throws {
                var queue = MemoryQueue()
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                let event = try #require(dequeuedItem)
                queue.remove(events: [event, .fixture()], completion: {})
                #expect(queue.eventCount == 1)
            }
        }
    }
}
