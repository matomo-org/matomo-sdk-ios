@testable import MatomoTracker
import Foundation
import Testing

extension MatomoTrackerSpecs {
    @Suite("MatomoTracker")
    @MainActor
    struct TrackerSpec {
        @Suite("init")
        @MainActor
        struct Init {
            @Test("should be able to initialized the MatomoTracker with a URL ending on `matomo.php`")
            func initializesWithMatomoPHP() {
                _ = MatomoTracker(siteID: "5", baseURL: URL(string: "https://example.com/matomo.php")!)
            }

            @Test("should be released if no external strong reference exists (no retain cycles)")
            func hasNoRetainCycles() {
                weak var weakTracker: MatomoTracker?
                do {
                    let tracker = MatomoTracker(siteID: "5", baseURL: URL(string: "https://example.com/matomo.php")!)
                    weakTracker = tracker
                }
                #expect(weakTracker == nil)
            }

            @Test("should be released while its dispatch timer is scheduled")
            func isReleasedWithScheduledTimer() {
                weak var weakTracker: MatomoTracker?
                do {
                    let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: DispatcherMock())
                    tracker.dispatchInterval = 0.1
                    tracker.waitUntilIdle()
                    weakTracker = tracker
                }
                #expect(weakTracker == nil)
            }

            @Test("should not deadlock if initialized on a background thread while the main thread waits for it")
            func doesNotDeadlockWhenInitializedInBackground() {
                let initialized = DispatchSemaphore(value: 0)
                var tracker: MatomoTracker?
                DispatchQueue.global(qos: .userInitiated).async {
                    tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: DispatcherMock())
                    initialized.signal()
                }
                // Blocks the main thread, like a dependency injection container resolving the tracker would.
                let result = initialized.wait(timeout: .now() + 5)
                #expect(result == .success)
                #expect(tracker != nil)
            }
        }

        @Suite("queue")
        @MainActor
        struct Queueing {
            @Test("should enqueue the item in the queue")
            func enqueuesTheItem() {
                let queuedEvent = Locked<Event?>(nil)
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent.mutate { $0 = events.first }
                }
                tracker.queue(event: .fixture())
                tracker.waitUntilIdle()
                #expect(queuedEvent.value != nil)
            }

            /// A failing assertion would crash the test process, which fails the run.
            @Test("should not throw an assertion if called from a background thread")
            func canBeCalledFromBackgroundThread() async {
                let queue = MemoryQueue()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                await onBackgroundThread {
                    tracker.queue(event: .fixture())
                }
                tracker.waitUntilIdle()
                #expect(queue.eventCount == 1)
            }

            @Test("never calls the queue on the main thread")
            func doesNotUseTheMainThread() {
                let calledOnMainThread = Locked(false)
                let queue = QueueMock()
                queue.enqueueEventsHandler = { _, _ in
                    if Thread.isMainThread { calledOnMainThread.mutate { $0 = true } }
                }
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                tracker.track(view: ["spec_view"])
                tracker.waitUntilIdle()
                #expect(queue.enqueueEventsCallCount == 1)
                #expect(calledOnMainThread.value == false)
            }

            @Test("queues events in the order they were tracked")
            func keepsTheOrder() {
                let queue = MemoryQueue()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                for index in 0..<200 {
                    tracker.track(view: ["\(index)"])
                }
                tracker.waitUntilIdle()
                var queuedViews: [String] = []
                queue.first(limit: 200) { events in
                    queuedViews = events.flatMap { $0.actionName }
                }
                #expect(queuedViews == (0..<200).map { "\($0)" })
            }

            @Test("queues every event if tracked and configured from many threads at once")
            func isThreadSafe() {
                let queue = MemoryQueue()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                let trackedViews = Locked(0)
                DispatchQueue.concurrentPerform(iterations: 400) { index in
                    switch index % 8 {
                    case 0: tracker.set(dimension: CustomDimension(index: index % 3, value: "\(index)"))
                    case 1: tracker.userID = "user-\(index)"
                    case 2: tracker.trackCampaign(name: "campaign-\(index)", keyword: nil)
                    case 3: tracker.startNewSession()
                    case 4: tracker.contentBase = URL(string: "https://example.com/\(index)")
                    case 5: _ = tracker.visitorID
                    default:
                        tracker.track(view: ["spec_view"])
                        trackedViews.mutate { $0 += 1 }
                    }
                }
                tracker.waitUntilIdle()
                #expect(queue.eventCount == trackedViews.value)
            }

            @Test("doesn't deadlock when the main thread waits for a background thread using the tracker")
            func doesNotDeadlock() {
                let queue = MemoryQueue()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                let finished = DispatchSemaphore(value: 0)
                DispatchQueue.global(qos: .userInitiated).async {
                    tracker.track(view: ["spec_view"])
                    tracker.set(dimension: CustomDimension(index: 1, value: "spec"))
                    tracker.dispatchInterval = 60
                    tracker.dispatch()
                    tracker.reset()
                    tracker.waitUntilIdle()
                    finished.signal()
                }
                // Blocks the main thread while the background thread uses the tracker.
                #expect(finished.wait(timeout: .now() + 5) == .success)
            }
        }

        @Suite("session")
        @MainActor
        struct NewSession {
            @Test("only the first event tracked after starting a new session starts it")
            func onlyFirstEventStartsTheSession() {
                let queuedEvents = Locked<[Event]>([])
                let queue = QueueMock()
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvents.mutate { $0 += events }
                }
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                tracker.startNewSession()
                // Both events are created before either of them is tracked, like on two threads at once.
                let first = Event(tracker: tracker, action: ["first"], isCustomAction: false)
                let second = Event(tracker: tracker, action: ["second"], isCustomAction: false)
                #expect(first.isNewSession && second.isNewSession)
                tracker.track(second)
                tracker.track(first)
                tracker.track(view: ["third"])
                tracker.waitUntilIdle()
                #expect(queuedEvents.value.map(\.isNewSession) == [true, false, false])
            }

            @Test("an event created before starting a new session doesn't use it up")
            func olderEventDoesNotUseUpTheSession() {
                let queuedEvents = Locked<[Event]>([])
                let queue = QueueMock()
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvents.mutate { $0 += events }
                }
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                tracker.track(view: ["initial"])
                let olderEvent = Event(tracker: tracker, action: ["older"], isCustomAction: false)
                tracker.startNewSession()
                tracker.track(olderEvent)
                tracker.track(view: ["newer"])
                tracker.waitUntilIdle()
                #expect(queuedEvents.value.map(\.isNewSession) == [true, false, true])
            }
        }

        @Suite("dispatch")
        @MainActor
        struct Dispatch {
            /// Dispatches and waits until dispatching has finished.
            private func dispatchAndWait(_ tracker: MatomoTracker) async {
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    tracker.dispatch {
                        continuation.resume()
                    }
                }
            }

            @Test("with an idle tracker and queued events should ask the queue for event")
            func asksQueueForEvents() {
                let queue = QueueMock()
                queue.eventCount = 1
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                tracker.dispatch()
                tracker.waitUntilIdle()
                #expect(queue.firstCallCount == 1)
            }

            @Test("with an idle tracker and queued events should give dequeued events to the dispatcher")
            func givesEventsToDispatcher() async {
                let eventsDispatched = Locked<[Event]>([])
                let dispatcher = DispatcherMock()
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                dispatcher.sendEventsHandler = { events, success, _ in
                    eventsDispatched.mutate { $0 = events }
                    success()
                }
                tracker.track(.fixture())
                await dispatchAndWait(tracker)
                #expect(eventsDispatched.value.count == 1)
            }

            @Test("with an idle tracker and queued events should set isDispatching to true")
            func setsIsDispatching() {
                let queue = QueueMock()
                queue.eventCount = 1
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                tracker.dispatch()
                tracker.waitUntilIdle()
                #expect(tracker.isDispatching)
            }

            /// A failing assertion would crash the test process, which fails the run.
            @Test("with an idle tracker and queued events should not throw an assertion if called from a background thread")
            func canBeCalledFromBackgroundThread() async {
                let dispatcher = DispatcherMock()
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                tracker.queue(event: .fixture())
                await onBackgroundThread {
                    tracker.dispatch()
                }
                #expect(await eventually { dispatcher.sendEventsCallCount == 1 })
            }

            @Test("never calls the dispatcher on the main thread")
            func doesNotUseTheMainThread() async {
                let calledOnMainThread = Locked(false)
                let dispatcher = DispatcherMock()
                dispatcher.sendEventsHandler = { _, success, _ in
                    if Thread.isMainThread { calledOnMainThread.mutate { $0 = true } }
                    success()
                }
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                tracker.track(view: ["spec_view"])
                await dispatchAndWait(tracker)
                #expect(dispatcher.sendEventsCallCount == 1)
                #expect(calledOnMainThread.value == false)
            }

            @Test("with an idle tracker and queued events should cancel dispatching if the dispatcher failes")
            func cancelsDispatchingOnFailure() async {
                let queue = MemoryQueue()
                let dispatcher = DispatcherMock()
                dispatcher.sendEventsHandler = { _, _, failure in
                    failure(NSError(domain: "spec", code: 0))
                }
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: dispatcher)
                tracker.track(view: ["spec_view"])
                await dispatchAndWait(tracker)
                tracker.waitUntilIdle()
                #expect(tracker.isDispatching == false)
                #expect(dispatcher.sendEventsCallCount == 1)
                #expect(queue.eventCount == 1)
            }

            @Test("can dispatch again after the dispatcher failed on a background thread")
            func recoversFromFailureOnBackgroundThread() async {
                let dispatcher = DispatcherMock()
                let shouldFail = Locked(true)
                dispatcher.sendEventsHandler = { _, success, failure in
                    DispatchQueue.global().async {
                        if shouldFail.value {
                            failure(NSError(domain: "spec", code: 0))
                        } else {
                            success()
                        }
                    }
                }
                let queue = MemoryQueue()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: dispatcher)
                tracker.track(view: ["spec_view"])
                await dispatchAndWait(tracker)
                shouldFail.mutate { $0 = false }
                await dispatchAndWait(tracker)
                tracker.waitUntilIdle()
                #expect(dispatcher.sendEventsCallCount == 2)
                #expect(queue.eventCount == 0)
            }

            @Test("with an idle tracker and queued events should ask for the next events if the dispatcher succeeds")
            func asksForNextEventsOnSuccess() async {
                let queue = MemoryQueue()
                let dispatcher = DispatcherMock()
                let batchSizes = Locked<[Int]>([])
                dispatcher.sendEventsHandler = { events, success, _ in
                    batchSizes.mutate { $0.append(events.count) }
                    success()
                }
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: dispatcher)
                for _ in 0..<25 {
                    tracker.track(view: ["spec_view"])
                }
                await dispatchAndWait(tracker)
                tracker.waitUntilIdle()
                #expect(batchSizes.value == [20, 5])
                #expect(queue.eventCount == 0)
            }

            @Test("with an idle tracker and queued events should stop dispatching if the queue is empty")
            func stopsDispatchingIfQueueIsEmpty() async {
                let dispatcher = DispatcherMock()
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                await dispatchAndWait(tracker)
                tracker.waitUntilIdle()
                #expect(dispatcher.sendEventsCallCount == 0)
                #expect(tracker.isDispatching == false)
            }

            @Test("with an already dispatching tracker should not ask the queue for events")
            func doesNotAskQueueWhileDispatching() {
                let queue = QueueMock()
                queue.eventCount = 1
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                tracker.dispatch()
                tracker.dispatch()
                tracker.waitUntilIdle()
                #expect(queue.firstCallCount == 1)
            }

            @Test("with an already dispatching tracker calls the completion when that dispatch has finished")
            func completesWhenRunningDispatchFinishes() async {
                let dispatcher = DispatcherMock()
                let pendingSuccess = Locked<(() -> Void)?>(nil)
                dispatcher.sendEventsHandler = { _, success, _ in
                    pendingSuccess.mutate { $0 = success }
                }
                let queue = MemoryQueue()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: dispatcher)
                tracker.track(view: ["spec_view"])
                let completions = Locked(0)
                tracker.dispatch { completions.mutate { $0 += 1 } }
                tracker.dispatch { completions.mutate { $0 += 1 } }
                #expect(await eventually { pendingSuccess.value != nil })
                tracker.waitUntilIdle()
                #expect(completions.value == 0)
                pendingSuccess.value?()
                #expect(await eventually { completions.value == 2 })
                #expect(dispatcher.sendEventsCallCount == 1)
            }

            @Test("should start a new DispatchTimer if dispatching failed")
            func restartsTimerAfterFailure() async {
                let dispatcher = DispatcherMock()
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                dispatcher.sendEventsHandler = { _, _, failure in
                    failure(NSError(domain: "spec", code: 0))
                }
                tracker.queue(event: .fixture())
                tracker.dispatchInterval = 0.5
                #expect(await eventually(timeout: 10) { dispatcher.sendEventsCallCount >= 5 })
            }

            @Test("should start a new DispatchTimer if dispatching succeeded")
            func restartsTimerAfterSuccess() async {
                let dispatcher = DispatcherMock()
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                dispatcher.sendEventsHandler = { _, success, _ in
                    tracker.queue(event: .fixture())
                    success()
                }
                tracker.queue(event: .fixture())
                tracker.dispatchInterval = 0.01
                #expect(await eventually { dispatcher.sendEventsCallCount > 5 })
            }

            @Test("the dispatch timer fires while the main thread is blocked")
            func timerDoesNotNeedTheMainThread() {
                let dispatched = DispatchSemaphore(value: 0)
                let dispatcher = DispatcherMock()
                dispatcher.sendEventsHandler = { _, success, _ in
                    success()
                    dispatched.signal()
                }
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                tracker.track(view: ["spec_view"])
                tracker.dispatchInterval = 0.1
                // Blocks the main thread, so a timer on the main run loop couldn't fire.
                #expect(dispatched.wait(timeout: .now() + 5) == .success)
            }
        }

        @Suite("forcedVisitorID")
        @MainActor
        struct ForcedVisitorID {
            @Test("populates the cid value if set")
            func populatesCid() {
                let queuedEvent = Locked<Event?>(nil)
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent.mutate { $0 = events.first }
                }
                tracker.forcedVisitorID = "0123456789abcdef"
                tracker.track(view: ["spec_view"])
                tracker.waitUntilIdle()
                #expect(queuedEvent.value?.visitor.forcedID == "0123456789abcdef")
            }

            @Test("it doesn't change the existing value if set to an invalid one")
            func ignoresInvalidValues() {
                let tracker = MatomoTracker(siteID: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                tracker.forcedVisitorID = "0123456789abcdef"
                tracker.forcedVisitorID = "invalid"
                #expect(tracker.forcedVisitorID == "0123456789abcdef")
            }

            @Test("should persist and restore the value")
            func persistsAndRestores() {
                let tracker = MatomoTracker(siteID: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                tracker.forcedVisitorID = "0123456789abcdef"
                let tracker2 = MatomoTracker(siteID: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                #expect(tracker2.forcedVisitorID == "0123456789abcdef")
            }
        }

        @Suite("reset")
        @MainActor
        struct Reset {
            @Test("generates new visitor")
            func generatesNewVisitor() {
                let queuedEvents = Locked<[Event]>([])
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvents.mutate { $0 += events }
                }

                tracker.track(view: ["spec_view"])
                tracker.reset()
                tracker.track(view: ["spec_view"])
                tracker.waitUntilIdle()

                #expect(queuedEvents.value.count == 2)
                #expect(queuedEvents.value.first?.visitor.id != queuedEvents.value.last?.visitor.id)
            }

            @Test("clears session information")
            func clearsSessionInformation() {
                let queuedEvent = Locked<Event?>(nil)
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent.mutate { $0 = events.first }
                }

                tracker.startNewSession()
                tracker.reset()
                tracker.track(view: ["spec_view"])
                tracker.waitUntilIdle()

                #expect(queuedEvent.value?.session.sessionsCount == 1)
            }

            @Test("clears dimensions")
            func clearsDimensions() {
                let queuedEvent = Locked<Event?>(nil)
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent.mutate { $0 = events.first }
                }

                tracker.set(dimension: CustomDimension(index: 0, value: "fake-dimension"))
                tracker.reset()
                tracker.track(view: ["spec_view"])
                tracker.waitUntilIdle()

                #expect(queuedEvent.value?.dimensions.isEmpty == true)
            }

            @Test("removes all custom variables")
            func removesCustomVariables() {
                let queuedEvent = Locked<Event?>(nil)
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent.mutate { $0 = events.first }
                }

                tracker.set(customVariable: CustomVariable(index: 0, name: "fake-variable", value: "fake-value"))
                tracker.reset()
                tracker.track(view: ["spec_view"])
                tracker.waitUntilIdle()

                #expect(queuedEvent.value?.customVariables.isEmpty == true)
            }

            @Test("clear campaigns")
            func clearsCampaigns() throws {
                let queuedEvent = Locked<Event?>(nil)
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent.mutate { $0 = events.first }
                }

                tracker.trackCampaign(name: "fake-campaign", keyword: "fake-keyword")
                tracker.reset()
                tracker.track(view: ["spec_view"])
                tracker.waitUntilIdle()

                let event = try #require(queuedEvent.value)
                #expect(event.campaignName == nil)
                #expect(event.campaignKeyword == nil)
            }
        }
    }
}
