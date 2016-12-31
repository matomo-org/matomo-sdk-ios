@testable import PiwikTracker
import Quick
import Nimble

class MemoryQueueSpec: QuickSpec {
    override func spec() {
        describe("init") {
            it("should return not null") {
                let queue = MemoryQueue<Any>()
                expect(queue).toNot(beNil())
            }
        }
        describe("itemCount") {
            context("with an empty queue") {
                let queue = MemoryQueueFixture.empty()
                it("should return 0") {
                    expect(queue.itemCount) == 0
                }
            }
            context("with a queue with two items") {
                let queue = MemoryQueueFixture.withTwoItems()
                it("should return 2") {
                    expect(queue.itemCount) == 2
                }
            }
        }
        describe("queue") {
            it("should increase item count") {
                var queue = MemoryQueueFixture.empty()
                queue.queue(item: MemoryQueueFixture.queueable(), completion: {})
                expect(queue.itemCount).toEventually(equal(1))
            }
            it("should call the completion closure") {
                var queue = MemoryQueueFixture.empty()
                var calledClosure = false
                queue.queue(item: MemoryQueueFixture.queueable(), completion: {
                    calledClosure = true
                })
                expect(calledClosure).toEventually(beTrue())
            }
            it("should enqueue the object") {
                var queue = MemoryQueueFixture.empty()
                let dummy = Dummy()
                var dequeued: Dummy? = nil
                queue.queue(item: dummy, completion: {})
                queue.dequeue(withLimit: 1, completion: { item in
                    dequeued = item.first as? Dummy
                })
                expect(dequeued).toEventuallyNot(beNil())
                expect(dequeued?.uuid).toEventually(equal(dummy.uuid))
            }
        }
        describe("dequeue") {
            context("with an empty queue") {
                var queue = MemoryQueueFixture.empty()
                it("should call the completionblock without items") {
                    var dequeuedItems: [Any]? = nil
                    queue.dequeue(withLimit: 10, completion: { items in
                        dequeuedItems = items
                    })
                    expect(dequeuedItems).toEventuallyNot(beNil())
                    expect(dequeuedItems?.count).toEventually(equal(0))
                }
            }
            context("with a queue with two items") {
                it("should return one item if just asked for one") {
                    var queue = MemoryQueueFixture.withTwoItems()
                    var dequeuedItems: [Any]? = nil
                    queue.dequeue(withLimit: 1, completion: { items in
                        dequeuedItems = items
                    })
                    expect(dequeuedItems?.count).toEventually(equal(1))
                }
                it("should return two items if asked for two or more") {
                    var queue = MemoryQueueFixture.withTwoItems()
                    var dequeuedItems: [Any]? = nil
                    queue.dequeue(withLimit: 10, completion: { items in
                        dequeuedItems = items
                    })
                    expect(dequeuedItems?.count).toEventually(equal(2))
                }
                it("should remove dequeued objects from the queue") {
                    var queue = MemoryQueueFixture.withTwoItems()
                    queue.dequeue(withLimit: 1, completion: { items in })
                    expect(queue.itemCount).toEventually(equal(1))
                }
            }
        }
        describe("deleteAll") {
            it("should remove all items") {
                var queue = MemoryQueueFixture.withTwoItems()
                queue.deleteAll()
                expect(queue.itemCount) == 0
            }
        }
    }
}
