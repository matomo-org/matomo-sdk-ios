@testable import MatomoTracker
import Foundation
import Testing

extension MatomoTrackerSpecs {
    @Suite("UserDefaultsQueue")
    @MainActor
    final class UserDefaultsQueueSpec {
        let userDefaults = UserDefaults(suiteName: suiteName)!

        init() {
            removeAllInSuite(suite: suiteName)
        }

        deinit {
            removeAllInSuite(suite: suiteName)
        }

        // MARK: init

        @Test("init should limit to 100 events per default")
        func limitsTo100EventsPerDefault() {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
            for _ in 0..<111 {
                queue.enqueue(event: .fixture())
            }
            #expect(queue.eventCount == 100)
        }

        @Test("init should limit to the given maximumQueueSize")
        func limitsToGivenMaximumQueueSize() {
            var queue = UserDefaultsQueue(userDefaults: userDefaults, maximumQueueSize: 10)
            for _ in 0..<13 {
                queue.enqueue(event: .fixture())
            }
            #expect(queue.eventCount == 10)
        }

        @Test("init should not limit if maximumQueueSize is set to nil")
        func doesNotLimitWithoutMaximumQueueSize() {
            var queue = UserDefaultsQueue(userDefaults: userDefaults, maximumQueueSize: nil)
            for _ in 0..<111 {
                queue.enqueue(event: .fixture())
            }
            #expect(queue.eventCount == 111)
        }

        // MARK: eventCount

        @Test("eventCount should return 0 with an empty queue")
        func eventCountEmptyQueue() {
            let queue = UserDefaultsQueue(userDefaults: userDefaults)
            #expect(queue.eventCount == 0)
        }

        @Test("eventCount should return 2 with a queue with two items")
        func eventCountTwoItems() {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
            queue.enqueue(event: .fixture())
            queue.enqueue(event: .fixture())
            #expect(queue.eventCount == 2)
        }

        // MARK: enqueue

        @Test("enqueue should increase item count")
        func enqueueIncreasesItemCount() async {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
            queue.enqueue(event: .fixture())
            #expect(await eventually { queue.eventCount == 1 })
        }

        @Test("enqueue should call the completion closure")
        func enqueueCallsCompletionClosure() async {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
            var calledClosure = false
            queue.enqueue(event: .fixture()) {
                calledClosure = true
            }
            #expect(await eventually { calledClosure })
        }

        @Test("enqueue should enqueue the object")
        func enqueueEnqueuesTheObject() async {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
            let event = Event.fixture()
            var dequeued: Event? = nil
            queue.enqueue(event: event)
            queue.first(limit: 1) { events in
                dequeued = events.first
            }
            #expect(await eventually { dequeued?.uuid == event.uuid })
        }

        // MARK: first

        @Test("first with an empty queue should call the completionblock without items")
        func firstEmptyQueue() async {
            let queue = UserDefaultsQueue(userDefaults: userDefaults)
            var dequeuedItems: [Event]? = nil
            queue.first(limit: 10) { events in
                dequeuedItems = events
            }
            #expect(await eventually { dequeuedItems?.count == 0 })
        }

        @Test("first with a queue with two items should return one item if just asked for one")
        func firstReturnsOneItem() async {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
            queue.enqueue(event: .fixture())
            queue.enqueue(event: .fixture())
            var dequeuedItems: [Event]? = nil
            queue.first(limit: 1) { events in
                dequeuedItems = events
            }
            #expect(await eventually { dequeuedItems?.count == 1 })
        }

        @Test("first with a queue with two items should return two items if asked for two or more")
        func firstReturnsTwoItems() async {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
            queue.enqueue(event: .fixture())
            queue.enqueue(event: .fixture())
            var dequeuedItems: [Event]? = nil
            queue.first(limit: 10) { events in
                dequeuedItems = events
            }
            #expect(await eventually { dequeuedItems?.count == 2 })
        }

        @Test("first with a queue with two items should not remove objects from the queue")
        func firstDoesNotRemoveObjects() {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
            queue.enqueue(event: .fixture())
            queue.enqueue(event: .fixture())
            queue.first(limit: 1, completion: { _ in })
            #expect(queue.eventCount == 2)
        }

        // MARK: remove

        @Test("remove should remove events that are enqueued")
        func removeRemovesEnqueuedEvents() throws {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
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

        @Test("remove should ignore if one event is tried to remove twice")
        func removeIgnoresRemovingTwice() throws {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
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

        @Test("remove should skip not queued events")
        func removeSkipsNotQueuedEvents() throws {
            var queue = UserDefaultsQueue(userDefaults: userDefaults)
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

private let suiteName = "UserDefaultsQueueSpec"
