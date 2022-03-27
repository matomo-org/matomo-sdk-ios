@testable import MatomoTracker
import Quick
import Nimble

class UserDefaultsQueueSpec: QuickSpec {
    override func setUp() {
        Nimble.AsyncDefaults.timeout = .seconds(10)
        Nimble.AsyncDefaults.pollInterval = .milliseconds(100)
    }
    
    override func spec() {
        let userDefaults = UserDefaults(suiteName: "UserDefaultsQueueSpec")!
        afterEach {
            self.removeAllInSuite(suite: "UserDefaultsQueueSpec")
        }
        describe("init") {
            it("should return not null") {
                let queue = UserDefaultsQueue(userDefaults: userDefaults)
                expect(queue).toNot(beNil())
            }
            it("should limit to 100 events per default") {
                var queue = UserDefaultsQueue(userDefaults: userDefaults)
                for _ in 0..<111 {
                    queue.enqueue(event: .fixture())
                }
                expect(queue.eventCount) == 100
            }
            it("should limit to the given maximumQueueSize") {
                var queue = UserDefaultsQueue(userDefaults: userDefaults, maximumQueueSize: 10)
                for _ in 0..<13 {
                    queue.enqueue(event: .fixture())
                }
                expect(queue.eventCount) == 10
            }
            it("should not limit if maximumQueueSize is set to nil") {
                var queue = UserDefaultsQueue(userDefaults: userDefaults, maximumQueueSize: nil)
                for _ in 0..<111 {
                    queue.enqueue(event: .fixture())
                }
                expect(queue.eventCount) == 111
            }
        }
        describe("eventCount") {
            it("should return 0 with an empty queue") {
                let queue = UserDefaultsQueue(userDefaults: userDefaults)
                expect(queue.eventCount) == 0
            }
            it("should return 2 with a queue with two items") {
                var queue = UserDefaultsQueue(userDefaults: userDefaults)
                queue.enqueue(event: .fixture())
                queue.enqueue(event: .fixture())
                expect(queue.eventCount) == 2
            }
        }
        describe("enqueue") {
            it("should increase item count") {
                var queue = UserDefaultsQueue(userDefaults: userDefaults)
                queue.enqueue(event: .fixture())
                expect(queue.eventCount).toEventually(equal(1))
            }
            it("should call the completion closure") {
                var queue = UserDefaultsQueue(userDefaults: userDefaults)
                var calledClosure = false
                queue.enqueue(event: .fixture()) {
                    calledClosure = true
                }
                expect(calledClosure).toEventually(beTrue())
            }
            it("should enqueue the object") {
                var queue = UserDefaultsQueue(userDefaults: userDefaults)
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
                let queue = UserDefaultsQueue(userDefaults: userDefaults)
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
                    var queue = UserDefaultsQueue(userDefaults: userDefaults)
                    queue.enqueue(event: .fixture())
                    queue.enqueue(event: .fixture())
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 1) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems?.count).toEventually(equal(1))
                }
                it("should return two items if asked for two or more") {
                    var queue = UserDefaultsQueue(userDefaults: userDefaults)
                    queue.enqueue(event: .fixture())
                    queue.enqueue(event: .fixture())
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 10) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems?.count).toEventually(equal(2))
                }
                it("should not remove objects from the queue") {
                    var queue = UserDefaultsQueue(userDefaults: userDefaults)
                    queue.enqueue(event: .fixture())
                    queue.enqueue(event: .fixture())
                    queue.first(limit: 1, completion: { items in })
                    expect(queue.eventCount) == 2
                }
            }
        }
        describe("remove") {
            it("should remove events that are enqueued") {
                var queue = UserDefaultsQueue(userDefaults: userDefaults)
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
                var queue = UserDefaultsQueue(userDefaults: userDefaults)
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
                var queue = UserDefaultsQueue(userDefaults: userDefaults)
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
    private func removeAllInSuite(suite: String) {
        guard let newuserDefaults = UserDefaults(suiteName: suite) else { return }
        let allKeys: [String]? = Array(newuserDefaults.dictionaryRepresentation().keys)
        for key in allKeys ?? [] {
            newuserDefaults.removeObject(forKey: key)
        }
    }
}
