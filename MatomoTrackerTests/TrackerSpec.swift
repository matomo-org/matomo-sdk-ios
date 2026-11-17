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
                _ = MatomoTracker(siteId: "5", baseURL: URL(string: "https://example.com/matomo.php")!)
            }

            @Test("should be released if no external strong reference exists (no retain cycles)")
            func hasNoRetainCycles() {
                weak var weakTracker: MatomoTracker?
                do {
                    let tracker = MatomoTracker(siteId: "5", baseURL: URL(string: "https://example.com/matomo.php")!)
                    weakTracker = tracker
                }
                #expect(weakTracker == nil)
            }
        }

        @Suite("queue")
        @MainActor
        struct Queueing {
            @Test("should enqueue the item in the queue")
            func enqueuesTheItem() {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }
                tracker.queue(event: .fixture())
                #expect(queuedEvent != nil)
            }

            /// A failing assertion would crash the test process, which fails the run.
            @Test("should not throw an assertion if called from a background thread")
            func canBeCalledFromBackgroundThread() async {
                let queue = MemoryQueue()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                await onBackgroundThread {
                    tracker.queue(event: .fixture())
                }
                #expect(queue.eventCount == 1)
            }
        }

        @Suite("dispatch")
        @MainActor
        struct Dispatch {
            @Test("with an idle tracker and queued events should ask the queue for event")
            func asksQueueForEvents() {
                let queue = QueueMock()
                queue.eventCount = 1
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                tracker.dispatch()
                #expect(queue.firstCallCount == 1)
            }

            @Test("with an idle tracker and queued events should give dequeued events to the dispatcher")
            func givesEventsToDispatcher() async {
                var eventsDispatched: [Event] = []
                let dispatcher = DispatcherMock()
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: dispatcher)
                dispatcher.sendEventsHandler = { events, _, _ in
                    eventsDispatched = events
                }
                tracker.track(.fixture())
                tracker.dispatch()
                #expect(await eventually { eventsDispatched.count == 1 })
            }

            @Test("with an idle tracker and queued events should set isDispatching to true")
            func setsIsDispatching() {
                let queue = QueueMock()
                queue.eventCount = 1
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                tracker.dispatch()
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

            @Test("with an idle tracker and queued events should cancel dispatching if the dispatcher failes", .disabled("Not implemented yet"))
            func cancelsDispatchingOnFailure() {}

            @Test("with an idle tracker and queued events should ask for the next events if the dispatcher succeeds", .disabled("Not implemented yet"))
            func asksForNextEventsOnSuccess() {}

            @Test("with an idle tracker and queued events should stop dispatching if the queue is empty", .disabled("Not implemented yet"))
            func stopsDispatchingIfQueueIsEmpty() {}

            @Test("with an already dispatching tracker should not ask the queue for events", .disabled("Not implemented yet"))
            func doesNotAskQueueWhileDispatching() {}

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
        }

        @Suite("forcedVisitorID")
        @MainActor
        struct ForcedVisitorID {
            @Test("populates the cid value if set")
            func populatesCid() async {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }
                tracker.forcedVisitorId = "0123456789abcdef"
                tracker.track(view: ["spec_view"])
                #expect(await eventually { queuedEvent?.visitor.forcedId == "0123456789abcdef" })
            }

            @Test("it doesn't change the existing value if set to an invalid one")
            func ignoresInvalidValues() {
                let tracker = MatomoTracker(siteId: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                tracker.forcedVisitorId = "0123456789abcdef"
                tracker.forcedVisitorId = "invalid"
                #expect(tracker.forcedVisitorId == "0123456789abcdef")
            }

            @Test("should persist and restore the value")
            func persistsAndRestores() {
                let tracker = MatomoTracker(siteId: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                tracker.forcedVisitorId = "0123456789abcdef"
                let tracker2 = MatomoTracker(siteId: "spec", baseURL: URL(string: "http://matomo.org/spec/piwik.php")!)
                #expect(tracker2.forcedVisitorId == "0123456789abcdef")
            }
        }

        @Suite("reset")
        @MainActor
        struct Reset {
            @Test("generates new visitor")
            func generatesNewVisitor() {
                var queuedEvents = [Event]()
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvents += events
                }

                tracker.track(view: ["spec_view"])
                tracker.reset()
                tracker.track(view: ["spec_view"])

                #expect(queuedEvents.count == 2)
                #expect(queuedEvents.first?.visitor.id != queuedEvents.last?.visitor.id)
            }

            @Test("clears session information")
            func clearsSessionInformation() {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }

                tracker.startNewSession()
                tracker.reset()
                tracker.track(view: ["spec_view"])

                #expect(queuedEvent?.session.sessionsCount == 1)
            }

            @Test("clears dimensions")
            func clearsDimensions() {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }

                tracker.set(dimension: CustomDimension(index: 0, value: "fake-dimension"))
                tracker.reset()
                tracker.track(view: ["spec_view"])

                #expect(queuedEvent?.dimensions.isEmpty == true)
            }

            @Test("removes all custom variables")
            func removesCustomVariables() {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }

                tracker.set(customVariable: CustomVariable(index: 0, name: "fake-variable", value: "fake-value"))
                tracker.reset()
                tracker.track(view: ["spec_view"])

                #expect(queuedEvent?.customVariables.isEmpty == true)
            }

            @Test("clear campaigns")
            func clearsCampaigns() throws {
                var queuedEvent: Event? = nil
                let queue = QueueMock()
                let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
                queue.enqueueEventsHandler = { events, _ in
                    queuedEvent = events.first
                }

                tracker.trackCampaign(name: "fake-campaign", keyword: "fake-keyword")
                tracker.reset()
                tracker.track(view: ["spec_view"])

                let event = try #require(queuedEvent)
                #expect(event.campaignName == nil)
                #expect(event.campaignKeyword == nil)
            }
        }
    }
}
